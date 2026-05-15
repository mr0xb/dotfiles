Load context from Obsidian notes in the `Claude/` directory into the current conversation.

## Behavior

1. Derive the project name from the current working directory (use the repo or app folder name).
2. List files in `Claude/<project-name>/` using `mcp__obsidian__list_vault_files`.
3. If `$ARGUMENTS` is provided, treat it as a search query and use `mcp__obsidian__search_vault_smart` to find relevant notes across the entire `Claude/` directory instead of listing by project.
4. Read the most relevant notes:
   - Without args: read the 3 most recent notes for the current project (by filename date prefix).
   - With args: read the top 3 search results.
   - Use `mcp__obsidian__get_vault_file` to fetch each note's content.
5. Synthesize what you loaded into a brief summary for the user, covering:
   - What sessions were found and when they occurred
   - Key decisions or context that is now loaded
   - Any open questions or next steps from prior sessions that are still relevant
6. Explicitly tell the user: "I've loaded this context and will use it going forward in this conversation."

## Notes

- If no notes exist for the current project yet, say so and suggest running `/obsidian-save` at the end of a session.
- Do not dump raw note content at the user — synthesize and summarize it.
- If notes contain contradictory information, flag it and ask which is current.
