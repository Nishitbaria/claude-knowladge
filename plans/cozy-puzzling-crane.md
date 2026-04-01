# Plan: Fix PR #98 review comments from Aayush

## Context
PR #98 was reviewed by @aayushdutt (approved with comments) and @gemini-code-assist. There are 7 actionable issues to fix — 1 critical bug, 2 high-priority bugs, and 4 medium improvements.

## Issues to fix

### 1. [CRITICAL] Sidebar: duplicate agent rendering when no orchestrator
**File:** `src/components/sidebar.tsx` (lines 224-243)
**Problem:** When there's no orchestrator agent, agents at index 1+ are rendered by both the first loop (lines 172-222, because `isSubAgent` is false) AND the second conditional block (lines 224-243, `visibleAgents.slice(1)`), causing duplicate sidebar entries.
**Fix:** Remove the second rendering block (lines 224-243) entirely. The first loop already handles the flat list case correctly — when no orchestrator exists, `isSubAgent` evaluates to false for all agents, so they all render.

### 2. [HIGH] Chat: timestamps show current time instead of message time
**File:** `src/app/(app)/sandboxes/[id]/chat/_components/chat-interface.tsx` (line 207)
**Problem:** `const time = formatTime(new Date())` generates a new timestamp on every render. All messages show the current time, not their creation time.
**Fix:** Change to `const time = formatTime(msg.createdAt)` — the `ChatMessage` type already has a `createdAt: Date` field populated when messages are created.

### 3. [HIGH] Usage: Messages count is wrong
**File:** `src/app/(app)/sandboxes/[id]/_components/usage-summary.tsx` (line 56)
**Problem:** `normalized.byModel.reduce((sum, m) => sum + (m.tokens ? 1 : 0), 0)` counts the number of models with token usage, not actual messages. The usage-cost API doesn't return message counts.
**Fix:** Since we don't have actual message count data from the usage API, change the metric to show total model count or remove the Messages card. Best option: replace "Messages" with the sum of all requests/completions from `byModel`, or simply show `byModel.length` as "Models Used". Alternatively, remove the card and keep 3 stats (Spent, Tokens, Sessions).

### 4. [MEDIUM] Channel step: refactor repetitive ternary logic
**File:** `src/app/(app)/dashboard/_components/deploy-bot-channel-step.tsx` (lines 129-166)
**Problem:** Four consecutive ternary chains (`tokenValue`, `tokenOnChange`, `tokenPlaceholder`, `tokenInstructions`) for each channel type. Hard to read and maintain.
**Fix:** Replace with a `channelConfigMap` object keyed by `ChannelId`, then look up from that map:
```ts
const channelConfigMap: Record<ChannelId, { value: string; onChange: (v: string) => void; placeholder: string; instructions: InstructionStep[] }> = {
  telegram: { value: telegramBotToken, onChange: onTelegramBotTokenChange, ... },
  discord: { ... },
  slack: { ... },
};
const config = selectedChannel ? channelConfigMap[selectedChannel] : null;
```

### 5. [MEDIUM] Channel step: fix confusing checkbox text
**File:** `src/app/(app)/dashboard/_components/deploy-bot-channel-step.tsx` (line 238)
**Problem:** "I will do it later Start chatting" is confusing — looks like a concatenation error.
**Fix:** Change to "I will do it later" only.

### 6. [MEDIUM] Deploy dialog: "Cancel" button label on non-first steps
**File:** `src/app/(app)/dashboard/_components/deploy-bot-dialog.tsx` (line 342)
**Problem:** The back button is always labeled "Cancel" even on steps 2 and 3 where it navigates to the previous step, not exits the flow.
**Fix:** Show "Cancel" on step 1, "Back" on steps 2 and 3.

### 7. [MEDIUM] Hardcoded `#2486eb` color across files
**Files:**
- `src/app/(app)/sandboxes/[id]/_components/agents-section.tsx` (line 126)
- `src/app/(app)/sandboxes/[id]/_components/usage-summary.tsx` (line 94)
**Problem:** Hardcoded hex color for "View All" links instead of semantic Tailwind class.
**Fix:** Replace `text-[#2486eb]` with `text-primary` in both files. (The project uses `--primary` CSS variable.)

## Verification
- `npx tsc --noEmit` — no type errors
- Check sidebar with sandbox that has no orchestrator agent — agents should not duplicate
- Check chat page — message timestamps should persist correctly, not update on re-render
- Check dashboard usage section — Messages/Models stat should show correct data
- Check onboarding flow — step 3 channel refactor works, checkbox text is clear, Back/Cancel labels are correct
- Grep for `#2486eb` — should return 0 results in modified files
