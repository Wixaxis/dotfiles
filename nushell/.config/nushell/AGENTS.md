
## Build, Lint, and Test Commands

- There are no dedicated build, lint, or test commands in this repository.
- Ruby scripts can be executed directly with `ruby <script_path>.rb`.
- Nushell scripts are sourced on shell startup.

## Code Style Guidelines

### General
- Follow the existing code style.
- Files are organized by type (envs, modules, scripts, sources).

### Nushell (`.nu`)
- **Imports:** Use `use` for modules and `source` for scripts.
- **Formatting:** Use 4-space indentation.
- **Naming:** Variables are lowercase with underscores (e.g., `exit_code`). Functions are lowercase with hyphens (e.g., `export-env`).
- **Error Handling:** Check command exit codes and print to stderr.

### Ruby (`.rb`)
- **Formatting:** Use 2-space indentation.
- **Naming:** Follow standard Ruby conventions (snake_case for methods and variables).
