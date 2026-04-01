# Full List: Everything Removed in PR #98 Figma Redesign

## Context
Commit `96658c1` (PR #98: "feat: redesign app pages to match Figma") redesigned the dashboard. This document lists **everything removed or changed** from the deploy bot onboarding flow and dashboard.

---

## Deleted Files

| File | What it was |
|------|-------------|
| `deploy-bot-pairing-step.tsx` | Pairing code input step (channel icon, code input, 2-step instructions) |
| `deploy-bot-bot-step.tsx` | Dedicated bot name + channel token input step (211 lines) |

---

## Deploy Dialog: Old Flow vs New Flow

| Old (5 steps) | New (3 steps) |
|----------------|---------------|
| 1. **Channel** — select Telegram/Discord/Slack | 1. **Provider** — bot name + AI provider + API key |
| 2. **Bot** — enter bot name + channel token | 2. **Models** — select AI models |
| 3. **Provider** — select AI provider + auth | 3. **Channel** — select channel + token (optional, can skip) |
| 4. **Models** — select AI models | ~~4. Pairing — removed~~ |
| 5. **Pairing** — enter pairing code from bot | |

---

## Removed Features (Detailed)

### 1. Pairing Step (FULLY REMOVED) - **already re-added**
- Pairing code input (monospaced, 6-12 char, uppercase)
- 2-step instruction cards ("Message your bot" → "Paste code and confirm")
- "Skip" and "Confirm" buttons
- Post-deploy pairing flow (deploy → message bot → get code → confirm)
- `handlePairingConfirm()` and `handleSkipPairing()` were disconnected (functions exist but never called)

### 2. Bot Step (FULLY REMOVED)
- Dedicated step for entering **bot name**
- Channel-specific **token input** with show/hide password toggle
- Per-channel **instruction panels** (how to get Telegram/Discord/Slack token)
- Bot name was **moved** into the Provider step instead

### 3. Stepper UI (REPLACED)
- **Old**: Numbered circles (1–5) with connecting progress line, check marks on completed steps, step labels inline
- **New**: Simple horizontal progress bars with "GUIDED SETUP" header, "STEP X OF 3" counter, "Fast Setup in under 1 minute" badge

### 4. Channel Step Position & Skip
- **Old**: Channel selection was step 1 (first thing user sees), with a separate "Skip" button
- **New**: Channel is step 3 (last, optional), with "I will do it later" checkbox

### 5. Dashboard Sandbox Grid (REPLACED)
- **Old**: Grid of `SandboxCard` components showing all sandboxes (name, date, bot icon, 3-column responsive grid)
- **New**: Auto-redirect to first sandbox if one exists; empty state with illustration (`human01.svg`) + "Configure your Lead Agent" CTA
- `SandboxCard` and `SkeletonCard` and `SandboxGrid` components removed
- `MAX_SANDBOXES_PER_ORG` subscription limit enforcement on button removed
- Page heading changed from "Sandboxes" to "Dashboard"

### 6. Removed State Variables
- `channelSkipped` (replaced by `skipChannel` checkbox)
- `pairingCode` (removed, hardcoded to `""`)
- `finalSandboxId` usage simplified (pairing flow removed)

### 7. Removed Validation
- `canBotNext` — bot step validation (name + token)
- `canPairingNext` — pairing code validation

### 8. Removed UI Callbacks
- `handlePairingConfirm()` — disconnected (exists but never called)
- `handleSkipPairing()` — disconnected (exists but never called)
- `handleSkipChannel()` — replaced by checkbox toggle
- `handleSelectChannel()` — replaced by direct `setSelectedChannel`

### 9. Styling Changes
- **Old**: Shadcn `<Button>`, `<Input>`, `<Label>` components; semantic colors (`primary`, `muted-foreground`, `destructive`)
- **New**: Plain HTML `<button>`/`<input>` with `cn()` utility; explicit neutral palette (`neutral-900`, `neutral-500`, `neutral-200`)

---

## Added in Redesign

| Feature | Details |
|---------|---------|
| `credits-indicator.tsx` | New component showing platform key credits (green/amber/red based on balance) |
| Platform key auth | "Use Our Key" vs "Add Your Key" toggle for OpenRouter (no API key needed) |
| Bot name in Provider step | Consolidated from separate Bot step |
| Auto-redirect | Dashboard auto-redirects to first sandbox if one exists |
| Empty state illustration | `human01.svg` with "Configure your Lead Agent" CTA |

---

## Status of Fixes

| Removed Feature | Status | Notes |
|----------------|--------|-------|
| Pairing step | **RE-ADDED** | Already implemented in this session |
| Duplicate model key error | **FIXED** | Deduplication added to `ModelStep` |
| `stripJsonPrefix` for model parsing | **FIXED** | User applied to `models.actions.ts` |
| Bot step (separate) | **Not needed** | Bot name is now in Provider step; token is in Channel step |
| Sandbox grid on dashboard | **Not needed** | Auto-redirect to sandbox is the new pattern |
| Old stepper UI | **Not needed** | New progress bar matches Figma |
