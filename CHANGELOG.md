# Changelog

All notable changes to this project will be documented in this file.

## [1.4.1] - 2026-01-11

### Fixed

- **Session isolation now works in Claude Code** - TTY detection doesn't work because Claude Code's Bash tool runs without a TTY attached. Now uses `$CLAUDE_CODE_SESSION_ID` environment variable instead, which is available in all Claude Code execution contexts.

### Changed

- Override files now use session ID: `.active.override.$CLAUDE_CODE_SESSION_ID` (was `$TTY_ID`)
- Updated all documentation to reflect the change from TTY to session ID
- Priority cascade unchanged, just uses different identifier source

---

## [1.4.0] - 2026-01-11

### Added

- **Session-aware project isolation** - Multiple terminals can work on different projects without conflicts
  - Each terminal has a unique TTY ID (e.g., `ttys001`, `ttys002`)
  - "switch to X" writes to `.planning/.active.override.$TTY_ID` (session-local)
  - Other terminals are unaffected by project switches
  - SessionEnd hook (`planning-cleanup.sh`) cleans up override files automatically

- **New "set default [name]" command** - Updates `active:` in `index.md` for new sessions
  - Separates "current session project" from "workspace default project"
  - New sessions start with the workspace default unless overridden

- **Priority cascade for active project detection**:
  1. `$MANUS_PROJECT` environment variable (explicit override)
  2. `.active.override.$TTY_ID` (session-local state)
  3. `active:` field in `index.md` (workspace default)

- **New SessionEnd hook** (`planning-cleanup.sh`) - Removes session-local override files

### Changed

- "switch to X" no longer modifies `index.md` - writes to session-local file instead
- SessionStart hook now checks TTY-scoped override files before `index.md`
- SKILL.md updated with session isolation documentation
- README updated with Session Isolation section and SessionEnd hook setup

---

## [1.3.0] - 2026-01-11

### Fixed

- **SessionStart hook now walks up directory tree** to find `.planning/`, like how git finds `.git/`
  - Previously only checked CWD, so hook failed when starting session in a subdirectory
  - Now works from any subdirectory of a workspace with `.planning/`
- Git operations in hook now use correct path (the directory containing `.planning/`, not CWD)

### Added

- **Multi-Manus Planning hint** in SessionStart output - reminds users of available commands
- Active project context now shows in all sessions that have `.planning/` in parent directory

---

## [1.2.0] - 2026-01-09

### Added

- **Command wrapper** (`commands/multi-manus-planning.md`) - Enables `/multi-manus-planning` slash command
  - Plugins provide skills (Skill tool), not commands (slash)
  - Users must copy command file to `~/.claude/commands/` for slash command to work
- Updated installation instructions with Step 3 for command file copy
- Clarified difference between skills and commands in README

---

## [1.1.0] - 2026-01-09

### Fixed

- `check-complete.sh` now exits 0 (skip) when no `task_plan.md` exists, instead of exit 1 (error)
  - Prevents stop hook errors in sessions that don't use planning

### Changed

- **Installation instructions** - Corrected to use `claude plugin` CLI commands instead of incorrect `/plugin` slash commands
- **Removed "synced config" section** - iCloud/Dropbox sync of `~/.claude` is no longer recommended; per-machine installation is now the standard
- Added clear "What gets installed" section clarifying that only the skill is installed (no automatic hooks)

### Added

- Development workflow documentation in `CLAUDE.md`
  - Clear guidance on where to edit (dev repo vs installed plugin)
  - Testing checklist
  - Multi-machine update instructions

---

## [1.0.0] - 2026-01-09

Initial release of multi-manus-planning, forked from planning-with-files v2.0.0.

### Added

- **Multi-project coordinator pattern**
  - `.planning/index.md` as single source of truth for project registry
  - `active:` field tracks current project
  - `default_path:` for centralized planning file storage
  - `{default}` placeholder expansion in paths

- **Separate Planning/Source paths**
  - Planning files can live anywhere (Obsidian, Dropbox, etc.)
  - Source path points to where code actually lives
  - `task_plan.md` includes Source header for reference

- **Natural language project commands**
  - "list projects" - show all registered projects
  - "switch to [name]" - change active project
  - "which project?" - show current context
  - "add project [name]" - interactive project creation

- **Interactive "add project" flow**
  - AskUserQuestion for planning location choice
  - Default path vs custom "somewhere else" option
  - Creates all 3 planning files automatically
  - Duplicate detection with update/rename/switch options

- **Cross-machine sync via git**
  - `planning-sync.sh` SessionStart hook
  - Automatic git fetch/pull on session start
  - Graceful handling of dirty working directory
  - JSON output format for context injection

- **New templates**
  - `templates/index.md` - Coordinator template

### Changed

- `task_plan.md` template now includes Source header
- SKILL.md updated with multi-project sections

### Preserved from planning-with-files v2.0.0

- Core 3-file pattern (task_plan.md, findings.md, progress.md)
- Hooks integration (PreToolUse, Stop)
- Templates for all planning files
- Helper scripts (init-session.sh, check-complete.sh)
- Manus principles documentation

### Backward Compatible

- No index.md = original CWD behavior
- Existing task_plan.md files work unchanged
- Single-project users unaffected

---

## Attribution

Based on [planning-with-files](https://github.com/OthmanAdi/planning-with-files) by [OthmanAdi](https://github.com/OthmanAdi) (MIT License).

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- MAJOR: Breaking changes to skill behavior
- MINOR: New features, backward compatible
- PATCH: Bug fixes, documentation updates
