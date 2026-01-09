# Multi-Manus Planning

> **Multi-project Manus-style planning** with coordinator pattern for Claude Code.

A Claude Code skill that extends the [planning-with-files](https://github.com/OthmanAdi/planning-with-files) pattern with support for multiple projects, separate planning/source paths, and cross-machine sync via git.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-green)](https://code.claude.com/docs/en/skills)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen)](https://github.com/kmichels/multi-manus-planning/releases)

## What's Different?

| Feature           | planning-with-files | multi-manus-planning                |
| ----------------- | ------------------- | ----------------------------------- |
| Projects          | Single (CWD)        | Multiple via coordinator            |
| Planning location | CWD only            | Configurable (e.g., Obsidian vault) |
| Source path       | Same as planning    | Separate (code can live elsewhere)  |
| Cross-machine     | Manual              | SessionStart hook with git sync     |
| Project switching | N/A                 | Natural language ("switch to X")    |

## The Coordinator Pattern

Instead of planning files in your working directory, use a `.planning/index.md` coordinator:

```
~/scripts/                          # Your CWD
├── .planning/
│   ├── index.md                    # Coordinator (active project, registry)
│   └── projects/
│       ├── project-a/
│       │   ├── task_plan.md
│       │   ├── findings.md
│       │   └── progress.md
│       └── project-b/
│           └── ...
```

Or store planning files anywhere (Obsidian, Dropbox, etc.) with the coordinator pointing to them.

### Coordinator Format

```markdown
# Planning Coordinator

active: project-a
default_path: ~/Planning

## Projects

| Name      | Planning Path                 | Source Path      | Description  |
| --------- | ----------------------------- | ---------------- | ------------ |
| project-a | {default}/project-a           | ~/code/project-a | Main project |
| project-b | ~/Obsidian/Planning/project-b | ~/code/project-b | Side project |
```

## Installation

### From Marketplace (Recommended)

```
/plugin marketplace add kmichels/multi-manus-planning
/plugin install multi-manus-planning@multi-manus-planning
```

### Via Synced Config (Multi-Machine)

If your `~/.claude` folder syncs across machines (via iCloud, Dropbox, or git):

1. Install once on any machine using marketplace or manual method
2. The skill syncs automatically to all machines
3. No additional installation needed on other machines

This is ideal for cross-machine workflows where you want the same planning context everywhere.

### Manual Installation

```bash
# Clone and copy to skills folder
git clone https://github.com/kmichels/multi-manus-planning.git
cp -r multi-manus-planning/skills/multi-manus-planning ~/.claude/skills/
```

### Cross-Machine Sync (Optional)

To automatically sync planning files when starting a session:

1. Copy the hook:

   ```bash
   cp ~/.claude/skills/multi-manus-planning/scripts/planning-sync.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/planning-sync.sh
   ```

2. Add to `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "/path/to/hooks/planning-sync.sh"
             }
           ]
         }
       ]
     }
   }
   ```

## Usage

### Project Commands

| Say                         | Action                        |
| --------------------------- | ----------------------------- |
| "list projects"             | Show all registered projects  |
| "switch to [name]"          | Change active project         |
| "which project?"            | Show current project and path |
| "add project [name]"        | Interactive project creation  |
| "where are planning files?" | Show resolved planning path   |

### Adding a Project

```
You: add project my-app

Claude: Where should I store the planning files?
        ○ Default location (~/Planning/my-app/) [Recommended]
        ○ Somewhere else (I'll specify)

You: [select default]

Claude: What's the source/working folder for this project?

You: ~/code/my-app

Claude: Created project "my-app":
        - Planning: ~/Planning/my-app/
        - Source: ~/code/my-app
        - Files: task_plan.md, findings.md, progress.md
```

### Switching Projects

```
You: switch to project-b

Claude: Switched to project-b
        Planning: ~/Obsidian/Planning/project-b/
        Source: ~/code/project-b

        [Reads task_plan.md and shows current status]
```

## Backward Compatibility

- **No coordinator?** Works exactly like planning-with-files (files in CWD)
- **Existing task_plan.md?** Still works, just won't have multi-project features
- **Single project?** Use `default` as your only project

## File Structure

```
multi-manus-planning/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── skills/multi-manus-planning/
│   ├── SKILL.md                 # Main skill definition
│   ├── reference.md             # Manus principles
│   ├── examples.md              # Usage examples
│   ├── templates/
│   │   ├── index.md             # Coordinator template
│   │   ├── task_plan.md         # With Source header
│   │   ├── findings.md
│   │   └── progress.md
│   └── scripts/
│       ├── init-session.sh
│       ├── check-complete.sh
│       └── planning-sync.sh     # SessionStart hook
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Testing

Run the hook test to verify the SessionStart hook works:

```bash
./skills/multi-manus-planning/scripts/test-hook.sh
```

Manual test checklist:

- [ ] `list projects` shows registered projects
- [ ] `switch to X` changes active project
- [ ] `add project Y` creates files in correct location
- [ ] SessionStart hook displays active project
- [ ] Backward compatible (no index.md = CWD behavior)

## Attribution

Based on [planning-with-files](https://github.com/OthmanAdi/planning-with-files) by [OthmanAdi](https://github.com/OthmanAdi) (MIT License).

The original implements the Manus context engineering pattern. This fork adds multi-project coordination.

## License

MIT License - see [LICENSE](LICENSE)

---

**Author:** [kmichels](https://github.com/kmichels)
