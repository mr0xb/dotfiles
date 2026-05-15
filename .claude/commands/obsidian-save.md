Save current conversation context to an Obsidian note under the `Claude/` directory.

## What to save

Capture all of the following that are relevant to the current conversation:

- **Conversation summary**: What the user is trying to accomplish and why
- **Project context**: Relevant architecture, design decisions, or constraints discovered
- **Task state**: What has been completed, what is in progress, what is blocked or pending
- **Key decisions**: Any choices made and the reasoning behind them
- **Open questions**: Unresolved questions or things to revisit
- **Next steps**: Concrete actions that should follow from this session

## File location

Derive the project name from the current working directory (use the repo or app folder name). Save to:

```
Claude/<project-name>/<YYYY-MM-DD>-<short-slug>.md
```

Use today's date and a short 2-4 word slug describing the session topic (e.g. `2026-04-29-ruth-plugin-setup.md`).

If `$ARGUMENTS` is provided, use it as the slug instead of generating one.

## Note format

Use this structure:

```markdown
---
date: <YYYY-MM-DD>
project: <project-name>
tags: [claude-context]
---

# <Session Title>

## Summary
<1-3 sentence overview of what this session was about>

## Context
<Relevant project background, architecture notes, constraints>

## Decisions
<Decisions made and rationale>

## Task State
<What was completed, in progress, or blocked>

## Open Questions
<Anything unresolved>

## Next Steps
<Concrete follow-up actions>
```

## Steps

1. Determine the project name from the working directory.
2. Determine today's date.
3. Draft the note content based on the current conversation.
4. Use `mcp__obsidian__create_vault_file` to write the note to the vault.
5. Confirm to the user where the note was saved.
