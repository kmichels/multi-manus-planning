# Planning Coordinator

active: default
default_path: ~/Planning

## Projects

| Name    | Planning Path | Source Path | Description                         |
| ------- | ------------- | ----------- | ----------------------------------- |
| default | .             | .           | Default project (current directory) |

## Usage

**Project commands:**

- "switch to [name]" - Change active project
- "list projects" - Show all registered projects
- "which project?" - Show current active project
- "add project [name]" - Create new project (interactive)
- "set default path [path]" - Change default planning location

**Path info:**

- "where are planning files?" - Show planning path
- "where is source?" - Show source/working folder

## Notes

- `default_path` is where new project planning files go by default
- `{default}` in Planning Path expands to default_path
- Planning Path = where task_plan.md, findings.md, progress.md live
- Source Path = where the actual project code lives
- Paths support `~` for home directory
