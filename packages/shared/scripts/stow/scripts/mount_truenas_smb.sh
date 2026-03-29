#!/bin/bash
#
# TrueNAS SMB auto-mount helper for macOS.
# Safe to run repeatedly: exits when already mounted.

set -euo pipefail

CONFIG_FILE="${HOME}/.config/truenas-mount/truenas-smb.env"
LOCK_FILE="/tmp/com.wixaxis.mount-truenas.lock"
LOG_TAG="mount-truenas"

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

log_info() {
  echo "$(timestamp) [INFO] ${LOG_TAG}: $*"
}

log_warn() {
  echo "$(timestamp) [WARN] ${LOG_TAG}: $*" >&2
}

log_error() {
  echo "$(timestamp) [ERROR] ${LOG_TAG}: $*" >&2
}

is_mounted() {
  /sbin/mount | /usr/bin/grep -q " on ${SMB_MOUNTPOINT} "
}

check_prerequisites() {
  local required_cmds=("/sbin/mount_smbfs" "/usr/bin/nc" "/usr/bin/lockf")
  local cmd
  for cmd in "${required_cmds[@]}"; do
    if [[ ! -x "${cmd}" ]]; then
      log_error "Missing required command: ${cmd}"
      exit 1
    fi
  done
}

load_config() {
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    log_warn "Config not found at ${CONFIG_FILE}; skipping mount"
    exit 0
  fi

  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"

  : "${SMB_HOST:?SMB_HOST is required}"
  : "${SMB_SHARE:?SMB_SHARE is required}"
  : "${SMB_USERNAME:?SMB_USERNAME is required}"
  : "${SMB_MOUNTPOINT:?SMB_MOUNTPOINT is required}"

  if [[ -n "${SMB_PASSWORD_URI:-}" ]]; then
    SMB_PASSWORD_VALUE="${SMB_PASSWORD_URI}"
  else
    : "${SMB_PASSWORD:?SMB_PASSWORD is required when SMB_PASSWORD_URI is not set}"
    SMB_PASSWORD_VALUE="${SMB_PASSWORD}"
  fi

  # Share names often contain spaces; allow override with pre-encoded value.
  if [[ -n "${SMB_SHARE_URI:-}" ]]; then
    SMB_SHARE_VALUE="${SMB_SHARE_URI}"
  else
    SMB_SHARE_VALUE="${SMB_SHARE// /%20}"
  fi

  SMB_CONNECT_ATTEMPTS="${SMB_CONNECT_ATTEMPTS:-4}"
  SMB_CONNECT_SLEEP_SECONDS="${SMB_CONNECT_SLEEP_SECONDS:-5}"
  SMB_MOUNT_ATTEMPTS="${SMB_MOUNT_ATTEMPTS:-3}"
  SMB_MOUNT_SLEEP_SECONDS="${SMB_MOUNT_SLEEP_SECONDS:-4}"
}

ensure_mountpoint() {
  if [[ -e "${SMB_MOUNTPOINT}" && ! -d "${SMB_MOUNTPOINT}" ]]; then
    log_error "Mountpoint exists but is not a directory: ${SMB_MOUNTPOINT}"
    exit 1
  fi
  /bin/mkdir -p "${SMB_MOUNTPOINT}"
}

wait_for_smb_service() {
  local attempt=1
  while (( attempt <= SMB_CONNECT_ATTEMPTS )); do
    if /usr/bin/nc -G 2 -z "${SMB_HOST}" 445 >/dev/null 2>&1; then
      log_info "SMB endpoint reachable at ${SMB_HOST}:445"
      return 0
    fi

    if (( attempt < SMB_CONNECT_ATTEMPTS )); then
      log_warn "Host not reachable (attempt ${attempt}/${SMB_CONNECT_ATTEMPTS}); retrying in ${SMB_CONNECT_SLEEP_SECONDS}s"
      /bin/sleep "${SMB_CONNECT_SLEEP_SECONDS}"
    fi
    attempt=$(( attempt + 1 ))
  done

  log_warn "Host unavailable after ${SMB_CONNECT_ATTEMPTS} checks; giving up this run"
  return 1
}

mount_with_retries() {
  local attempt=1
  while (( attempt <= SMB_MOUNT_ATTEMPTS )); do
    if /sbin/mount_smbfs "//${SMB_USERNAME}:${SMB_PASSWORD_VALUE}@${SMB_HOST}/${SMB_SHARE_VALUE}" "${SMB_MOUNTPOINT}" >/dev/null 2>&1; then
      log_info "Mounted //${SMB_HOST}/${SMB_SHARE} at ${SMB_MOUNTPOINT}"
      return 0
    fi

    if is_mounted; then
      log_info "Mount became active during retry window: ${SMB_MOUNTPOINT}"
      return 0
    fi

    if (( attempt < SMB_MOUNT_ATTEMPTS )); then
      log_warn "mount_smbfs failed (attempt ${attempt}/${SMB_MOUNT_ATTEMPTS}); retrying in ${SMB_MOUNT_SLEEP_SECONDS}s"
      /bin/sleep "${SMB_MOUNT_SLEEP_SECONDS}"
    fi
    attempt=$(( attempt + 1 ))
  done

  log_error "Mount failed after ${SMB_MOUNT_ATTEMPTS} attempts"
  return 1
}

main() {
  check_prerequisites
  load_config
  ensure_mountpoint

  if is_mounted; then
    log_info "Already mounted: ${SMB_MOUNTPOINT}"
    exit 0
  fi

  if ! wait_for_smb_service; then
    exit 0
  fi

  mount_with_retries
}

if [[ "${1:-}" != "__locked" ]]; then
  # Prevent overlapping runs when launchd StartInterval fires frequently.
  /usr/bin/lockf -s -t 0 "${LOCK_FILE}" "$0" "__locked" || exit 0
  exit 0
fi

main
