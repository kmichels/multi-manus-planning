# Changelog

All notable changes to this project will be documented in this file.

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
