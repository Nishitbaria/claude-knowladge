# Sub-Agents / Named Agents Feature

## What We Built

A dashboard page at `/sandboxes/[id]/subagents` that lets users deploy **named OpenClaw agents** — each with its own workspace, skills, system prompt, and identity. Users chat with all agents through a single Telegram bot — the main agent delegates tasks to named agents via sub-agent spawning.

## Key Concept: Named Agents (NOT ephemeral sub-agents)

- **Sub-agents** (`sessions_spawn`) = ephemeral one-shot background tasks, no persistence
- **Named agents** (`openclaw agents add`) = persistent isolated workspaces with own identity, skills, sessions

We use **named agents** — they persist, have their own AGENTS.md, and the main Telegram agent delegates to them.

## OpenClaw CLI Commands Used

```bash
# Register a named agent
openclaw agents add <id> --workspace <path>

# List all agents
openclaw agents list
openclaw agents list --json

# Delete an agent
openclaw agents delete <id>

# Enable main agent to delegate (jq patch openclaw.json)
.agents.defaults.subagents.maxSpawnDepth = 2
```

## OpenClaw Docs (Important Links)

- Skills creation: https://docs.openclaw.ai/tools/creating-skills
- Sub-agents: https://docs.openclaw.ai/tools/subagents
- Agent Send (CLI): https://docs.openclaw.ai/cli/agent
- Agents management (CLI): https://docs.openclaw.ai/cli/agents

## Files Created/Modified

### Server Actions
- `src/server/actions/subagent.actions.ts` — `createAgent`, `listAgents`, `deleteAgent` + `updateMainAgentContext`

### Page & Components
- `src/app/(app)/sandboxes/[id]/subagents/page.tsx` — thin wrapper
- `src/app/(app)/sandboxes/[id]/subagents/_components/subagents-view.tsx` — main view
- `src/app/(app)/sandboxes/[id]/subagents/_components/types.ts` — `AgentTemplate`, `AgentInfo`
- `src/app/(app)/sandboxes/[id]/subagents/_constants/templates.ts` — 4 placeholder templates
- `src/app/(app)/sandboxes/[id]/subagents/_hooks/use-subagents.ts` — `useAgentsList`, `useAgentMutations`

### Sidebar
- `src/components/sidebar.tsx` — added "Sub-Agents" nav item with `Bot` icon below "Channels"

## createAgent Flow (what happens when user clicks "Deploy Agent")

```
1. agentExists() check (plain text fallback if --json fails)
If agent doesn't exist:
  2. mkdir $HOME/.openclaw/workspace-<agentId>/
  3. Write AGENTS.md with system prompt (heredoc)
  4. openclaw agents add <id> --workspace <path>  (tolerates "already exists")
  5. jq patch: enable delegation (maxSpawnDepth: 2)
Always:
  6. Write .description file to agent workspace
  7. updateMainAgentContext() — updates main agent's AGENTS.md with all specialists
```

## deleteAgent Flow

```
1. openclaw agents delete <id>
2. rm -rf $HOME/.openclaw/workspace-<agentId>/ (clean up workspace)
3. updateMainAgentContext() — removes deleted agent from main AGENTS.md
```

## updateMainAgentContext — How Main Agent Learns About Specialists

1. Lists all registered agents via `openclaw agents list`
2. Reads `.description` file from each non-default agent's workspace
3. Builds a specialist section with `<!-- DEPLOYED_SPECIALISTS_START/END -->` markers
4. Finds default agent's workspace from `openclaw.json` (jq parse)
5. Reads existing AGENTS.md, replaces or appends specialist section
6. Writes back — preserves any custom content the user had

## UI Structure

- **Agent Templates** (top) — 4 cards, always show "Deploy Agent" button, purely for deploying
- **Active Agents** (bottom) — list from `openclaw agents list`, shows name + workspace + "Active" badge + "Remove" button
- **No sessions section** — sessions have their own page already

## Telegram Integration (Main agent delegates)

Users chat with ONE Telegram bot. The main agent sees deployed named agents and can delegate:
```
User: "Use the marketing agent to analyze competitors"
Main agent → spawns marketing sub-agent → result → shown in Telegram
```

Enabled by `maxSpawnDepth: 2` in openclaw.json + specialist info in main AGENTS.md.

## Known Issues / Gotchas

1. **`~` doesn't expand in single quotes** — use `$HOME` with double quotes for paths
2. **`openclaw agents list --json` format unknown** — we have JSON + plain text fallback parsing
3. **`agents add` may say "already exists"** — we catch this and continue gracefully
4. **E2B sandbox user is NOT root** — `/root` path fails, must use `$HOME`
5. **`allowAgents` is NOT valid** under `agents.defaults.subagents` — don't set it
6. **No need for**: gateway restart, set-identity, sending "hi" message — user confirmed these are unnecessary

## Current Status (March 2026)

- Build passes (`pnpm build`)
- Sidebar nav item added
- Page renders with template cards
- Deploy creates workspace + registers agent + enables delegation
- Active agents list with remove functionality
- Main agent AGENTS.md auto-updated with specialist context on deploy/delete
- Need to test full Telegram delegation flow end-to-end
