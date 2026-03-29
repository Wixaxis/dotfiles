#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

run_case() {
  local case_name="$1"
  local os="$2"
  local distro="$3"
  local desktop="$4"
  shift 4

  local home_dir="$TMP_DIR/$case_name/home"
  mkdir -p "$home_dir/.ssh" "$home_dir/.config/truenas-mount"
  printf 'Host existing\n  HostName example.test\n' > "$home_dir/.ssh/config"
  printf 'TRUENAS_HOST=example\nTRUENAS_SHARE=example\nTRUENAS_USERNAME=example\nTRUENAS_PASSWORD=example\nMOUNT_POINT=%s/mnt/truenas\n' "$home_dir" > "$home_dir/.config/truenas-mount/truenas-smb.env"

  env \
    DOTFILES_HOME="$home_dir" \
    DOTFILES_OS="$os" \
    DOTFILES_DISTRO="$distro" \
    DOTFILES_DESKTOP="$desktop" \
    "$ROOT/setup.sh" --yes --no-install "$@"

  env \
    DOTFILES_HOME="$home_dir" \
    DOTFILES_OS="$os" \
    DOTFILES_DISTRO="$distro" \
    DOTFILES_DESKTOP="$desktop" \
    "$ROOT/setup.sh" --check "$@"
}

run_case macos macos macos none \
  --package zed \
  --package ssh \
  --package nushell \
  --package truenas-macos

run_case linux linux arch other \
  --package fastfetch \
  --package bash \
  --package mimeapps \
  --package zed

run_case hyprland linux arch hyprland \
  --package hyprland \
  --package waybar \
  --package rofi \
  --package swaync \
  --package thunar \
  --package wob
