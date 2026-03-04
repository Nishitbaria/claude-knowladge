# Agent Folder Refactoring Plan

Adopt modular folder structure from PR #11 while keeping your improvements from PR #19.

## Target Structure

```
src/lib/agents/
├── index.ts                    # Clean exports
├── media-agent.ts              # ToolLoopAgent definition
├── prompts.ts                  # System prompts (consolidated)
├── types.ts                    # MediaAgentCallOptions schema
├── middleware/
│   ├── index.ts
│   ├── error-handler.ts        # Error utilities
│   └── tracing.ts              # Langfuse abstraction
├── tools/
│   ├── index.ts
│   ├── generate-image.ts
│   ├── generate-video.ts
│   ├── edit-image.ts
│   ├── generate-audio.ts
│   ├── remove-background.ts
│   ├── resize-image.ts
│   └── upscale-image.ts
└── utils/
    ├── index.ts
    ├── polling.ts              # Moved from model-suggester
    └── stream-utils.ts         # Extracted from route.ts
```

---

## Phase 1: Create Folder Structure

Create empty directories:
- `src/lib/agents/tools/`
- `src/lib/agents/middleware/`
- `src/lib/agents/utils/`

---

## Phase 2: Split Tools (7 files)

Split `src/lib/agents/model-suggester/tools.ts` into individual files:

| Source Tool | New File |
|-------------|----------|
| `generateImageTool` | `tools/generate-image.ts` |
| `generateVideoTool` | `tools/generate-video.ts` |
| `editImageTool` | `tools/edit-image.ts` |
| `generateAudioTool` | `tools/generate-audio.ts` |
| `removeBackgroundTool` | `tools/remove-background.ts` |
| `resizeImageTool` | `tools/resize-image.ts` |
| `upscaleImageTool` | `tools/upscale-image.ts` |

Create `tools/index.ts` to export all tools.

---

## Phase 3: Create Middleware (2 files)

**`middleware/error-handler.ts`:**
- `getErrorMessage(error)` - maps errors to user-friendly messages
- `logAgentError(error, context)` - structured error logging
- `createStreamErrorHandler(context)` - factory for onError callback

**`middleware/tracing.ts`:**
- `updateAgentTrace(params)` - wrapper for Langfuse trace updates
- `updateAgentObservation(params)` - wrapper for observation updates
- `endActiveSpan()` - OpenTelemetry span helper
- Re-export `observe` from @langfuse/tracing

Create `middleware/index.ts` to export all middleware.

---

## Phase 4: Create Utils (2 files)

**`utils/stream-utils.ts`** - Extract from route.ts:
- `extractTextFromUiMessage(message)`
- `extractTextFromParts(parts)`
- `extractLatestUserTextFromUiMessages(messages)`
- `summarizeParts(parts)`

**`utils/polling.ts`** - Move from:
- `src/lib/agents/model-suggester/utils/polling.ts` → `src/lib/agents/utils/polling.ts`

Create `utils/index.ts` to export all utilities.

---

## Phase 5: Reorganize Root Level (4 files)

**`src/lib/agents/types.ts`:**
- Move from `media-agent/types.ts`
- Contains `mediaAgentCallOptionsSchema` and `MediaAgentCallOptions`

**`src/lib/agents/prompts.ts`:**
- Copy from `model-suggester/prompts.ts`
- Contains `main_agent_prompt`, `manual_mode_agent_prompt`, `vision_prompt`

**`src/lib/agents/media-agent.ts`:**
- Move from `media-agent/index.ts`
- Update imports to use new paths (`./tools`, `./types`)
- Keep importing prompts from `@/lib/langfuse/prompt` (Langfuse integration)

**`src/lib/agents/index.ts`:**
- Export `mediaAgent`, `mediaAgentTools`, `MediaAgentUIMessage`
- Export `MediaAgentCallOptions`, `mediaAgentCallOptionsSchema`
- Export all tools, utils, middleware

---

## Phase 6: Update Imports (3 files)

**`src/app/api/agents/v1/route.ts`:**
```typescript
// Before
import { mediaAgent, mediaAgentTools, MediaAgentCallOptions } from "@/lib/agents/media-agent";

// After
import { mediaAgent, mediaAgentTools, MediaAgentCallOptions } from "@/lib/agents";
```
- Remove inline utility functions (moved to stream-utils.ts)
- Import utilities from `@/lib/agents`

**`src/server/actions/ai.actions.ts`:**
```typescript
// Before
import { pollPrediction } from "@/lib/agents/model-suggester/utils/polling";

// After
import { pollPrediction } from "@/lib/agents/utils/polling";
```

**`src/lib/langfuse/prompt.ts`:**
- Keep as-is (media-agent.ts imports from here for Langfuse integration)

---

## Phase 7: Delete Old Folders

After all tests pass:
```
rm -rf src/lib/agents/media-agent/
rm -rf src/lib/agents/model-suggester/
```

---

## Files Summary

### Create (17 files)
| File | Purpose |
|------|---------|
| `src/lib/agents/index.ts` | Root exports |
| `src/lib/agents/media-agent.ts` | Agent definition |
| `src/lib/agents/prompts.ts` | System prompts |
| `src/lib/agents/types.ts` | Schemas & types |
| `src/lib/agents/tools/index.ts` | Tool exports |
| `src/lib/agents/tools/generate-image.ts` | Image generation |
| `src/lib/agents/tools/generate-video.ts` | Video generation |
| `src/lib/agents/tools/edit-image.ts` | Image editing |
| `src/lib/agents/tools/generate-audio.ts` | Audio generation |
| `src/lib/agents/tools/remove-background.ts` | Background removal |
| `src/lib/agents/tools/resize-image.ts` | Image resizing |
| `src/lib/agents/tools/upscale-image.ts` | Image upscaling |
| `src/lib/agents/middleware/index.ts` | Middleware exports |
| `src/lib/agents/middleware/error-handler.ts` | Error handling |
| `src/lib/agents/middleware/tracing.ts` | Langfuse tracing |
| `src/lib/agents/utils/index.ts` | Utils exports |
| `src/lib/agents/utils/stream-utils.ts` | Stream utilities |

### Move (1 file)
| From | To |
|------|-----|
| `model-suggester/utils/polling.ts` | `utils/polling.ts` |

### Update (2 files)
| File | Changes |
|------|---------|
| `src/app/api/agents/v1/route.ts` | Update imports, remove inline utils |
| `src/server/actions/ai.actions.ts` | Update polling import path |

### Delete (2 folders)
- `src/lib/agents/media-agent/`
- `src/lib/agents/model-suggester/`

---

## Verification

1. **Type check:** `pnpm tsc --noEmit`
2. **Lint:** `pnpm ultracite check && pnpm ultracite fix`
3. **Dev server:** `pnpm dev` - ensure no import errors
4. **Manual test:**
   - Generate an image (auto mode)
   - Generate a video (manual mode)
   - Edit an image
   - Remove background
   - Refresh page - verify tool outputs persist (bug fix still works)

---

## Notes

- Keep your tool naming: `generateImage`, `removeBackground` (not PR #11's `generateImageWithPolling`)
- Keep your `mediaAgent` name (not PR #11's `creativeAgent`)
- Keep prompts importing from `@/lib/langfuse/prompt` for Langfuse integration
- Your bug fix for tool parts persistence is in `chatMessage.repo.ts` - not touched by this refactor
