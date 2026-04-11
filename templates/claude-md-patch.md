## Context Navigation (Wiki-Brain)

You have access to a personal wiki at `{{VAULT_PATH}}`. This is the user's
compounding knowledge base. Use it as your primary context source.

When you need to understand the codebase, docs, past work, or any stored
knowledge:

1. **ALWAYS query the knowledge graph first:** `graphify query "your question"`
   (run from `{{VAULT_PATH}}`).
2. **Use `{{VAULT_PATH}}/wiki/index.md`** as your navigation entrypoint for
   browsing the wiki structure.
3. **Use `{{VAULT_PATH}}/graphify-out/wiki/index.md`** if it exists — it's
   the auto-generated Graphify wiki index.
4. **Only read raw files in `{{VAULT_PATH}}/raw/`** if the user explicitly
   says "read the raw file" or the graph query doesn't have the answer.

## Wiki-Brain Session Rules

**Ingesting sources.** When the user drops a file into `{{VAULT_PATH}}/raw/`
and asks you to ingest it, follow `/wiki-brain ingest` — read the source,
summarize, create/update wiki pages, cross-link aggressively, update
`wiki/index.md`, append to `log.md`.

**Every session must end with a log entry.** Before ending a session, append
one line to `{{VAULT_PATH}}/log.md` in this exact format:

```
## [YYYY-MM-DD HH:MM] session | <3-8 word session title>
Touched: <comma-separated wiki pages, or "none">
```

**If the session produced durable knowledge** (decisions made, things learned,
project state changed, problems solved) — update or create relevant wiki
pages with that knowledge before ending. Cross-link with `[[Page Name]]`.
Update `wiki/index.md`.

**If the session was trivial** (one-off fix, routine task, exploratory
chatter) — skip the wiki update. Just append the log line.

**Never modify files in `raw/`.** Sources are immutable.
**Claude owns `wiki/` entirely.** Update it, don't ask permission for each
page — just report what changed.
**Always update `wiki/index.md`** when you create or rename a wiki page.
**Cross-link aggressively.** `[[Page Name]]` Obsidian syntax. A page with
no inbound links is a dead-end.

## Wiki-Brain Commands Available

- `/wiki-brain` — status menu
- `/wiki-brain ingest <file>` — ingest a source
- `/wiki-brain query "<q>"` — query the graph + wiki
- `/wiki-brain lint` — health-check the wiki
- `/wiki-brain rebuild` — force a Graphify rebuild
- `/wiki-brain doctor` — verify install
- `/recall` — show last 5 activities + read linked pages
