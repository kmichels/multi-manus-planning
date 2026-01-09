# Examples: Planning with Files in Action

## Example 1: Research Task

**User Request:** "Research the benefits of morning exercise and write a summary"

### Loop 1: Create Plan

```bash
Write task_plan.md
```

```markdown
# Task Plan: Morning Exercise Benefits Research

## Goal

Create a research summary on the benefits of morning exercise.

## Phases

- [ ] Phase 1: Create this plan ✓
- [ ] Phase 2: Search and gather sources
- [ ] Phase 3: Synthesize findings
- [ ] Phase 4: Deliver summary

## Key Questions

1. What are the physical health benefits?
2. What are the mental health benefits?
3. What scientific studies support this?

## Status

**Currently in Phase 1** - Creating plan
```

### Loop 2: Research

```bash
Read task_plan.md           # Refresh goals
WebSearch "morning exercise benefits"
Write notes.md              # Store findings
Edit task_plan.md           # Mark Phase 2 complete
```

### Loop 3: Synthesize

```bash
Read task_plan.md           # Refresh goals
Read notes.md               # Get findings
Write morning_exercise_summary.md
Edit task_plan.md           # Mark Phase 3 complete
```

### Loop 4: Deliver

```bash
Read task_plan.md           # Verify complete
Deliver morning_exercise_summary.md
```

---

## Example 2: Bug Fix Task

**User Request:** "Fix the login bug in the authentication module"

### task_plan.md

```markdown
# Task Plan: Fix Login Bug

## Goal

Identify and fix the bug preventing successful login.

## Phases

- [x] Phase 1: Understand the bug report ✓
- [x] Phase 2: Locate relevant code ✓
- [ ] Phase 3: Identify root cause (CURRENT)
- [ ] Phase 4: Implement fix
- [ ] Phase 5: Test and verify

## Key Questions

1. What error message appears?
2. Which file handles authentication?
3. What changed recently?

## Decisions Made

- Auth handler is in src/auth/login.ts
- Error occurs in validateToken() function

## Errors Encountered

- [Initial] TypeError: Cannot read property 'token' of undefined
  → Root cause: user object not awaited properly

## Status

**Currently in Phase 3** - Found root cause, preparing fix
```

---

## Example 3: Feature Development

**User Request:** "Add a dark mode toggle to the settings page"

### The 3-File Pattern in Action

**task_plan.md:**

```markdown
# Task Plan: Dark Mode Toggle

## Goal

Add functional dark mode toggle to settings.

## Phases

- [x] Phase 1: Research existing theme system ✓
- [x] Phase 2: Design implementation approach ✓
- [ ] Phase 3: Implement toggle component (CURRENT)
- [ ] Phase 4: Add theme switching logic
- [ ] Phase 5: Test and polish

## Decisions Made

- Using CSS custom properties for theme
- Storing preference in localStorage
- Toggle component in SettingsPage.tsx

## Status

**Currently in Phase 3** - Building toggle component
```

**notes.md:**

```markdown
# Notes: Dark Mode Implementation

## Existing Theme System

- Located in: src/styles/theme.ts
- Uses: CSS custom properties
- Current themes: light only

## Files to Modify

1. src/styles/theme.ts - Add dark theme colors
2. src/components/SettingsPage.tsx - Add toggle
3. src/hooks/useTheme.ts - Create new hook
4. src/App.tsx - Wrap with ThemeProvider

## Color Decisions

- Dark background: #1a1a2e
- Dark surface: #16213e
- Dark text: #eaeaea
```

**dark_mode_implementation.md:** (deliverable)

```markdown
# Dark Mode Implementation

## Changes Made

### 1. Added dark theme colors

File: src/styles/theme.ts
...

### 2. Created useTheme hook

File: src/hooks/useTheme.ts
...
```

---

## Example 4: Error Recovery Pattern

When something fails, DON'T hide it:

### Before (Wrong)

```
Action: Read config.json
Error: File not found
Action: Read config.json  # Silent retry
Action: Read config.json  # Another retry
```

### After (Correct)

```
Action: Read config.json
Error: File not found

# Update task_plan.md:
## Errors Encountered
- config.json not found → Will create default config

Action: Write config.json (default config)
Action: Read config.json
Success!
```

---

## The Read-Before-Decide Pattern

**Always read your plan before major decisions:**

```
[Many tool calls have happened...]
[Context is getting long...]
[Original goal might be forgotten...]

→ Read task_plan.md          # This brings goals back into attention!
→ Now make the decision       # Goals are fresh in context
```

This is why Manus can handle ~50 tool calls without losing track. The plan file acts as a "goal refresh" mechanism.

---

## Example 5: Multi-Project Workflow

**User manages multiple projects from ~/scripts:**

### Setting Up the Coordinator

```
User: I want to set up multi-project planning

Claude: I'll create a coordinator. Where should planning files go by default?

User: ~/Obsidian/Planning

Claude: Created .planning/index.md with default_path: ~/Obsidian/Planning
```

**.planning/index.md:**

```markdown
# Planning Coordinator

active: default
default_path: ~/Obsidian/Planning

## Projects

| Name    | Planning Path | Source Path | Description                         |
| ------- | ------------- | ----------- | ----------------------------------- |
| default | .             | .           | Default project (current directory) |
```

### Adding Projects

```
User: add project my-app

Claude: Where should I store the planning files?
        ○ Default location (~/Obsidian/Planning/my-app/) [Recommended]
        ○ Somewhere else (I'll specify)

User: [selects default]

Claude: What's the source/working folder for this project?

User: ~/code/my-app

Claude: Created project "my-app":
        - Planning: ~/Obsidian/Planning/my-app/
        - Source: ~/code/my-app
        - Files: task_plan.md, findings.md, progress.md
```

### Switching Between Projects

```
User: list projects

Claude: Projects:
        - my-app (active) - ~/Obsidian/Planning/my-app/
        - side-project - ~/Obsidian/Planning/side-project/
        - client-work - ~/Dropbox/Client/planning/

User: switch to client-work

Claude: Switched to client-work
        Planning: ~/Dropbox/Client/planning/
        Source: ~/clients/acme/

        Current status from task_plan.md:
        - Phase 2: API Integration (in progress)
        - 3 of 5 phases complete
```

### Cross-Machine Continuity

**On Mac Mini:**

```
User: Let's work on my-app. I need to add user authentication.

Claude: [Creates task_plan.md with auth phases]
        [Commits to git]
```

**Later, on MacBook:**

```
[SessionStart hook runs]
Planning files synced. Planning context: my-app

User: where were we?

Claude: [Reads task_plan.md from Obsidian vault]
        We're working on my-app - user authentication.
        Currently in Phase 2: Implement JWT tokens
        Source: ~/code/my-app
```

---

## Example 6: Planning Files in Obsidian

**Store planning files alongside project notes:**

```
~/Obsidian/
├── Planning/
│   ├── my-app/
│   │   ├── task_plan.md      # Claude uses this
│   │   ├── findings.md       # Claude uses this
│   │   ├── progress.md       # Claude uses this
│   │   └── architecture.md   # Your own notes
│   └── side-project/
│       └── ...
├── Notes/
│   └── ...
```

Benefits:

- Planning files are searchable in Obsidian
- Link to other notes using `[[wikilinks]]`
- View progress in Obsidian's graph view
- Sync via iCloud/Dropbox automatically
