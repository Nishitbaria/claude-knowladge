# Sub-Agents Feature — Implementation Plan

## Context

Users want to spawn pre-configured OpenClaw sub-agents from the RunAgents dashboard. The sub-agents already have skills and system prompts configured inside the OpenClaw instance. The dashboard only needs to **spawn** them and **show status** — all chatting happens via Telegram.

## Files to Create

### 1. Server Actions — `src/server/actions/subagent.actions.ts`

Three server actions following the existing `orgAction` + `getSandboxRuntime` + `runOrThrow` pattern (same as `cron.actions.ts`):

- **`spawnSubAgent`** — Runs `openclaw agent --agent <agentId> --message <task> --json` in the sandbox. Returns the parsed JSON response (runId, sessionKey, status).
- **`listSubAgents`** — Runs `openclaw sessions --json` and filters sessions where the key matches `agent:*:subagent:*` pattern. Returns array of sub-agent sessions with status info.
- **`killSubAgent`** — Runs `openclaw sessions delete <sessionKey>` to stop a running sub-agent.

### 2. Types — `src/app/(app)/sandboxes/[id]/subagents/_components/types.ts`

```ts
interface SubAgentTemplate {
  id: string;
  name: string;
  description: string;
  icon: LucideIcon;
  agentId: string;            // maps to --agent flag
  defaultMessage: string;     // maps to --message flag
}

interface SubAgentSession {
  key: string;
  label: string | null;
  model: string | null;
  status: "running" | "completed" | "error" | "unknown";
  updatedAt: number | null;
  tokens: { input: number; output: number; total: number } | null;
}
```

### 3. Templates — `src/app/(app)/sandboxes/[id]/subagents/_constants/templates.ts`

4 pre-built placeholder templates:

| Template | agentId | Icon | Description |
|----------|---------|------|-------------|
| Marketing Agent | `marketing` | `Megaphone` | Competitor research, campaign ideas, market analysis |
| SEO Auditor | `seo-auditor` | `Search` | Website SEO auditing and recommendations |
| Content Writer | `content-writer` | `PenTool` | Blog posts, social copy, email drafts |
| Analytics Reporter | `analytics` | `TrendingUp` | Performance reports and data insights |

### 4. Hook — `src/app/(app)/sandboxes/[id]/subagents/_hooks/use-subagents.ts`

Following the exact `use-cron.ts` pattern:

- **`useSubAgentSessions(sandboxId)`** — React Query hook polling `listSubAgents`. Query key: `["subagent-sessions", sandboxId]`.
- **`useSubAgentMutations(sandboxId)`** — Returns `spawn` and `kill` mutations with toast notifications and cache invalidation.

### 5. View — `src/app/(app)/sandboxes/[id]/subagents/_components/subagents-view.tsx`

Two sections in a responsive grid:

**Left — Template Cards:**
- Grid of pre-built sub-agent cards (icon, name, description)
- Each card has a "Spawn" button
- Clicking spawns the sub-agent via `spawn` mutation

**Right — Active Sub-Agents:**
- List of spawned sub-agent sessions with status badges (running = green, completed = blue, error = red)
- Each running sub-agent has a "Kill" button
- Shows session key, model, token usage, last updated
- Refresh button to re-poll

### 6. Page — `src/app/(app)/sandboxes/[id]/subagents/page.tsx`

Thin wrapper (same pattern as cron/page.tsx):

```tsx
"use client";
import { useParams } from "next/navigation";
import { SubAgentsView } from "./_components/subagents-view";

export default function SubAgentsPage() {
  const { id } = useParams<{ id: string }>();
  return <SubAgentsView sandboxId={id} />;
}
```

## File to Modify

### 7. Sidebar — `src/components/sidebar.tsx`

Add one entry to `SANDBOX_NAV_ITEMS` array, below "Channels":

```ts
{
  label: "Sub-Agents",
  icon: Bot,  // from lucide-react
  segment: "subagents",
},
```

Import `Bot` from `lucide-react`.

## Command Reference

```bash
# Spawn
openclaw agent --agent marketing --message "You are now active" --json

# List sessions (filter client-side for subagent keys)
openclaw sessions --json

# Kill
openclaw sessions delete <sessionKey>
```

## Verification

1. `pnpm build` — ensure no type errors
2. Navigate to `/sandboxes/{id}/subagents` — page renders with template cards
3. Sidebar shows "Sub-Agents" below "Channels" with Bot icon
4. Click "Spawn" on a template card — confirms sub-agent spawned via toast
5. Active sub-agents list updates showing running session
6. "Kill" button stops a running sub-agent
7. Refresh re-fetches session list
