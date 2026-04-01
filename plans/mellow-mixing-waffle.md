# Plan: Apply stripJsonPrefix fix from commit b32365c4

## Context
OpenClaw CLI prints warning lines (e.g. `[xai-auth] bootstrap config fallback...`) to stdout before JSON output. This breaks `JSON.parse` across 8 call sites, causing silent failures like empty model lists during onboarding. Commit `b32365c4` on the `feat/acceptance-criteria` branch has the fix but it was never merged into `development`.

## Approach
Cherry-pick the changes from commit `b32365c4` onto `development`. Skip the E2B template name change (current `runagents-dev-20260331` is newer than the commit's `20260329`).

## Changes (9 files, 8 call sites + 1 helper)

### 1. Add `stripJsonPrefix()` helper
**File:** `src/server/actions/utils/sandbox.utils.ts`
- Add the exported `stripJsonPrefix()` function (tries `JSON.parse` at each `{`/`[` line start)
- Update `parseProviderModelsOutput()` to use it

### 2. Apply to all JSON parse sites

| # | File | Location | Change |
|---|------|----------|--------|
| 1 | `src/app/api/mc/callback/route.ts` | create-subtask cron result parse | Import + use `stripJsonPrefix` |
| 2 | `src/app/api/scheduler/dispatch/route.ts` | cron job ID parse | Import + use `stripJsonPrefix` |
| 3 | `src/server/actions/models.actions.ts` | `getModelsStatus` + `listConfiguredModels` (2 sites) | Import + use `stripJsonPrefix` |
| 4 | `src/server/actions/sandbox.actions.ts` | `finalizeSandbox` agent list parse | Import + use `stripJsonPrefix` |
| 5 | `src/server/actions/tasks.actions.ts` | `getTaskSessionHistory` session parse | Import + use `stripJsonPrefix` |
| 6 | `src/server/actions/utils/dispatch.utils.ts` | `resolveSessionId` session parse | Import + use `stripJsonPrefix` |
| 7 | `src/server/actions/utils/setup-main-agent.ts` | `findDefaultAgentId` agent list parse | Import + use `stripJsonPrefix` |

### 3. Skip
- `src/lib/e2b.ts` template name — current `20260331` is already newer

## Verification
1. `pnpm build` — ensure no type/import errors
2. Grep for remaining `JSON.parse.*stdout` to confirm no sites were missed
