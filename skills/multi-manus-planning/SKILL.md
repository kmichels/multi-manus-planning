---
name: multi-manus-planning
version: "1.4.2"
description: Multi-project Manus-style planning with coordinator pattern. Supports project switching, separate planning/source paths, and cross-machine sync via git. Creates task_plan.md, findings.md, and progress.md.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch, WebSearch
hooks:
  PreToolUse:
    - matcher: "Write|Edit|Bash"
      hooks:
        - type: command
          command: "cat task_plan.md 2>/dev/null | head -30 || true"
  Stop:
    - hooks:
        - type: command
          command: "~/.claude/hooks/check-complete.sh"
---

# Planning with Files

Work like Manus: Use persistent markdown files as your "working memory on disk."

## Multi-Project Support (v3.0)

This skill supports multiple project contexts via a coordinator file.

### On Skill Activation

**FIRST**, check for a coordinator file:

1. Check if `.planning/index.md` exists (walking up from CWD like git finds `.git`)
2. If found, determine active project using priority cascade:
   - **Priority 1:** `$MANUS_PROJECT` environment variable (explicit override)
   - **Priority 2:** `.planning/.active.override.$CLAUDE_CODE_SESSION_ID` (session-local state)
   - **Priority 3:** `active:` field in `index.md` (workspace default)
3. Look up that project's path in the Projects table
4. Expand `~` to the user's home directory in paths
5. Use that path as `{project_path}` for all planning files
6. Create the directory if it doesn't exist
7. Report: "Planning context: [project-name] at [path]"

If no `.planning/` found:

- Use current directory as `{project_path}` (backward compatible)
- Planning files go directly in CWD

**Session ID:**

Claude Code exposes `$CLAUDE_CODE_SESSION_ID` (a UUID) in all execution contexts.
Use this for session-local override files. TTY detection doesn't work because
Claude Code's Bash tool runs without a TTY attached.

### Planning File Locations

All planning files use `{project_path}`:

- `{project_path}/task_plan.md`
- `{project_path}/findings.md`
- `{project_path}/progress.md`

### Project Commands

Recognize these natural language patterns:

| User Says                            | Action                                                            |
| ------------------------------------ | ----------------------------------------------------------------- |
| "switch to [name]"                   | Write to session override file, read new project's task_plan.md   |
| "set default [name]"                 | Update `active:` in index.md (workspace default for new sessions) |
| "list projects" / "show projects"    | Display all projects from index.md table                          |
| "which project?" / "current context" | Show active project name, source, and resolved path               |
| "add project [name]"                 | Interactive flow to create new project (see below)                |
| "set default path [path]"            | Update default_path in index.md                                   |
| "where are planning files?"          | Show resolved `{project_path}`                                    |
| "where is source?"                   | Show source path for current project                              |

### Adding a Project

When user says "add project [name]":

**First, check if project already exists** in the Projects table:

- If exists: "Project '[name]' already exists. Would you like to update it, use a different name, or switch to it?"
- If not exists: continue with creation flow

1. **Ask for planning location** using AskUserQuestion:
   - Option 1: "Default location ({default_path}/[name]/)" [Recommended]
   - Option 2: "Somewhere else (I'll specify)"

2. If "somewhere else", ask for the custom planning path

3. **Ask for source/working folder**:
   - "What's the source/working folder for this project?"
   - This is where the actual code lives

4. **Create the project**:
   - Create the planning directory if it doesn't exist
   - Create task_plan.md with Source header (see template)
   - Create findings.md
   - Create progress.md
   - Add row to Projects table in index.md
   - Set as active project

5. **Report**:
   ```
   Created project "[name]":
   - Planning: [resolved planning path]
   - Source: [source path]
   - Files: task_plan.md, findings.md, progress.md
   ```

### Switching Projects (Session-Local)

When user requests a project switch with "switch to [name]":

1. Read `.planning/index.md`
2. Verify the requested project exists in the Projects table
3. Get session ID from `$CLAUDE_CODE_SESSION_ID` environment variable
4. Write the project name to `.planning/.active.override.$CLAUDE_CODE_SESSION_ID`
   - This is session-local - does NOT modify index.md
   - Other Claude Code sessions are unaffected
5. Read the new project's `task_plan.md` if it exists
6. Report: "Switched to [name] (this session). Current task: [summary from task_plan.md or 'No active task']"

If the requested project doesn't exist, offer to create it.

### Setting Workspace Default

When user says "set default [name]":

1. Verify the requested project exists in the Projects table
2. Update the `active:` field in `.planning/index.md`
3. Report: "Set [name] as workspace default. New sessions will start with this project."

This changes the default project for all new sessions in this workspace.

### Intent Mismatch Detection

If the user mentions working on a project different from the active one:

- Example: Active is "bracket" but user says "let's work on the college advisor"
- Prompt: "You mentioned college-advisor but we're in bracket context. Switch projects?"

### Example index.md

```markdown
# Planning Coordinator

active: college-advisor
default_path: ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal/Planning

## Projects

| Name            | Planning Path             | Source Path                        | Description                 |
| --------------- | ------------------------- | ---------------------------------- | --------------------------- |
| college-advisor | {default}/college-advisor | ~/scripts/projects/college-advisor | College matching automation |
| bracket         | {default}/bracket         | ~/scripts/projects/bracket         | macOS backup utility        |
| imageintact     | ~/custom/path             | ~/Library/.../XCode/ImageIntact    | Photo backup app (custom)   |
```

**Path Resolution:**

- `{default}` expands to the `default_path` value
- `~` expands to user's home directory
- Planning Path = where planning files live
- Source Path = where project code lives

---

## Quick Start

Before ANY complex task:

1. **Check for coordinator** — Read `.planning/index.md` if it exists
2. **Create `task_plan.md`** — See [templates/task_plan.md](templates/task_plan.md)
3. **Create `findings.md`** — See [templates/findings.md](templates/findings.md)
4. **Create `progress.md`** — See [templates/progress.md](templates/progress.md)
5. **Re-read plan before decisions** — Refreshes goals in attention window
6. **Update after each phase** — Mark complete, log errors

## The Core Pattern

```
Context Window = RAM (volatile, limited)
Filesystem = Disk (persistent, unlimited)

→ Anything important gets written to disk.
```

## File Purposes

| File           | Purpose                     | When to Update      |
| -------------- | --------------------------- | ------------------- |
| `task_plan.md` | Phases, progress, decisions | After each phase    |
| `findings.md`  | Research, discoveries       | After ANY discovery |
| `progress.md`  | Session log, test results   | Throughout session  |

## Critical Rules

### 1. Create Plan First

Never start a complex task without `task_plan.md`. Non-negotiable.

### 2. The 2-Action Rule

> "After every 2 view/browser/search operations, IMMEDIATELY save key findings to text files."

This prevents visual/multimodal information from being lost.

### 3. Read Before Decide

Before major decisions, read the plan file. This keeps goals in your attention window.

### 4. Update After Act

After completing any phase:

- Mark phase status: `in_progress` → `complete`
- Log any errors encountered
- Note files created/modified

### 5. Log ALL Errors

Every error goes in the plan file. This builds knowledge and prevents repetition.

```markdown
## Errors Encountered

| Error             | Attempt | Resolution             |
| ----------------- | ------- | ---------------------- |
| FileNotFoundError | 1       | Created default config |
| API timeout       | 2       | Added retry logic      |
```

### 6. Never Repeat Failures

```
if action_failed:
    next_action != same_action
```

Track what you tried. Mutate the approach.

## The 3-Strike Error Protocol

```
ATTEMPT 1: Diagnose & Fix
  → Read error carefully
  → Identify root cause
  → Apply targeted fix

ATTEMPT 2: Alternative Approach
  → Same error? Try different method
  → Different tool? Different library?
  → NEVER repeat exact same failing action

ATTEMPT 3: Broader Rethink
  → Question assumptions
  → Search for solutions
  → Consider updating the plan

AFTER 3 FAILURES: Escalate to User
  → Explain what you tried
  → Share the specific error
  → Ask for guidance
```

## Read vs Write Decision Matrix

| Situation             | Action                  | Reason                        |
| --------------------- | ----------------------- | ----------------------------- |
| Just wrote a file     | DON'T read              | Content still in context      |
| Viewed image/PDF      | Write findings NOW      | Multimodal → text before lost |
| Browser returned data | Write to file           | Screenshots don't persist     |
| Starting new phase    | Read plan/findings      | Re-orient if context stale    |
| Error occurred        | Read relevant file      | Need current state to fix     |
| Resuming after gap    | Read all planning files | Recover state                 |

## The 5-Question Reboot Test

If you can answer these, your context management is solid:

| Question             | Answer Source                 |
| -------------------- | ----------------------------- |
| Where am I?          | Current phase in task_plan.md |
| Where am I going?    | Remaining phases              |
| What's the goal?     | Goal statement in plan        |
| What have I learned? | findings.md                   |
| What have I done?    | progress.md                   |

## When to Use This Pattern

**Use for:**

- Multi-step tasks (3+ steps)
- Research tasks
- Building/creating projects
- Tasks spanning many tool calls
- Anything requiring organization

**Skip for:**

- Simple questions
- Single-file edits
- Quick lookups

## Templates

Copy these templates to start:

- [templates/index.md](templates/index.md) — Multi-project coordinator (v3.0)
- [templates/task_plan.md](templates/task_plan.md) — Phase tracking
- [templates/findings.md](templates/findings.md) — Research storage
- [templates/progress.md](templates/progress.md) — Session logging

## Scripts

Helper scripts for automation:

- `scripts/init-session.sh` — Initialize all planning files
- `scripts/check-complete.sh` — Verify all phases complete
- `scripts/planning-sync.sh` — SessionStart hook for cross-machine sync

## Cross-Machine Sync Setup

To automatically sync planning files when starting a session on a different machine:

1. **Copy the hook** to your Claude Code hooks folder:

   ```bash
   cp scripts/planning-sync.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/planning-sync.sh
   ```

2. **Add to settings.json** (`~/.claude/settings.json`):

   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/hooks/planning-sync.sh"
             }
           ]
         }
       ]
     }
   }
   ```

3. **How it works**:
   - On session start, the hook runs `git pull` to fetch latest planning files
   - Stashes local changes before pulling, restores after
   - Displays the active project: "Planning context: [project-name]"
   - Warns if conflicts occur (you'll need to resolve manually)

## Task Completion Check Setup

The skill includes a Stop hook that warns you if you try to end a session with incomplete phases. To enable it:

1. **Copy the script** to your Claude Code hooks folder:

   ```bash
   cp scripts/check-complete.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/check-complete.sh
   ```

2. **How it works**:
   - On session stop, the hook checks `task_plan.md` for phase status
   - Counts phases marked with `` `complete` ``, `` `in_progress` ``, or `` `pending` ``
   - Exits with error if not all phases are complete (non-blocking warning)

**Note:** The hook uses `~/.claude/hooks/check-complete.sh` instead of a relative path because `${CLAUDE_PLUGIN_ROOT}` doesn't resolve for standalone skill installations.

## Advanced Topics

- **Manus Principles:** See [reference.md](reference.md)
- **Real Examples:** See [examples.md](examples.md)

## Anti-Patterns

| Don't                          | Do Instead                      |
| ------------------------------ | ------------------------------- |
| Use TodoWrite for persistence  | Create task_plan.md file        |
| State goals once and forget    | Re-read plan before decisions   |
| Hide errors and retry silently | Log errors to plan file         |
| Stuff everything in context    | Store large content in files    |
| Start executing immediately    | Create plan file FIRST          |
| Repeat failed actions          | Track attempts, mutate approach |
