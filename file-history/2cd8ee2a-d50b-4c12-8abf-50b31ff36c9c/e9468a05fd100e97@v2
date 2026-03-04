---
name: ship-it
description: Review code quality, run linting/type-checks, fix errors, create a feature branch synced with development, commit, push, and open a PR. Use when asked to "ship it", "push my changes", "create a PR", "review and push", or "finalize and submit".
metadata:
  author: nishitbariya
  version: "1.0.0"
argument-hint: [branch-name] [pr-title]
---

# Ship It — Review, Lint, Branch, Push & PR

Automated pipeline that reviews code, fixes issues, creates a branch, pushes, and opens a PR. Execute every step in order. Do NOT skip steps.

## Arguments

- `$1` — (optional) Branch name suffix. Default: auto-generated from changed files.
- `$2` — (optional) PR title. Default: auto-generated from commit analysis.

## Step 1 — Analyze Changes

1. Run `git status` to see all modified, staged, and untracked files.
2. Run `git diff` and `git diff --cached` to understand what changed.
3. If there are NO changes at all (clean working tree), stop and tell the user "Nothing to ship — working tree is clean."

## Step 2 — Code Review

1. Read every changed/new file identified in Step 1.
2. Check for:
   - Obvious bugs or logic errors
   - Security issues (hardcoded secrets, injection vectors, exposed API keys)
   - Missing error handling at system boundaries
   - Unused imports or dead code you introduced
3. If you find issues, fix them immediately. Tell the user what you fixed and why.

## Step 3 — Linting

1. Detect the project's linter from `package.json` scripts (biome, eslint, prettier, etc.).
2. Run the lint command ONLY on changed files. Examples:
   - Biome: `pnpm lint -- <files>`
   - ESLint: `pnpm lint <files>`
3. If lint errors are found:
   - Run the formatter first (`pnpm format -- <files>` or equivalent).
   - Re-run lint. If errors remain, fix them manually.
   - Repeat until lint passes clean.

## Step 4 — Type Check

1. Run `pnpm type-check` or `npx tsc --noEmit` (whichever exists in scripts).
2. If TypeScript errors exist:
   - Fix errors that are clearly caused by the current changes.
   - If errors are pre-existing (not from your changes), note them but do NOT block the pipeline.
3. Confirm type-check passes or document pre-existing issues.

## Step 5 — Build Check (optional but recommended)

1. If a `build` script exists, run `pnpm build`.
2. If build fails due to current changes, fix the issues.
3. If build fails due to missing env vars or external dependencies, note it and proceed.

## Step 6 — Branch Management

1. Run `git branch --show-current` to check the current branch.
2. Run `git fetch origin` to sync remote state.
3. **If on `development` (or `main`/`master`):**
   - Create a new branch: `git checkout -b feature/<branch-name>`
   - Branch name: use `$1` if provided, otherwise derive from the changes (e.g., `feature/update-blog-components`).
   - The new branch is already based on the current development HEAD — no extra sync needed.
4. **If already on a feature branch:**
   - Stay on it. Pull latest from its upstream if it has one.
   - Rebase on development if behind: `git rebase origin/development`
   - Resolve conflicts if any arise (prefer current changes, ask user if ambiguous).

## Step 7 — Stage & Commit

1. Stage all relevant changed files. Use specific file paths — avoid `git add -A`.
   - Do NOT stage `.env`, `.env.local`, credentials, or secrets.
   - DO include lockfile changes if dependencies were added/updated.
2. Analyze all staged changes to write a commit message:
   - Follow Conventional Commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, etc.
   - First line: concise summary under 72 chars.
   - Body: bullet points of what changed and why (if non-trivial).
   - End with: `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
3. Commit using a HEREDOC for the message.

## Step 8 — Push

1. Push the branch to origin: `git push origin <branch-name>`
2. If push is rejected (branch exists remotely), use `git push origin <branch-name> --force-with-lease` — but ONLY with `--force-with-lease`, never `--force`.
3. Confirm push succeeded.

## Step 9 — Create Pull Request

1. Determine the base branch (usually `development`).
2. Run `git log origin/<base>..HEAD --oneline` to summarize all commits in the PR.
3. Create PR using GitHub CLI:

```
gh pr create \
  --base <base-branch> \
  --title "<pr-title>" \
  --body "$(cat <<'EOF'
## Summary
<3-5 bullet points describing what changed and why>

## Changes
<list of key files changed with one-line descriptions>

## Testing
<how to verify these changes work>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

4. Use `$2` as PR title if provided. Otherwise auto-generate from commit messages.
5. Output the PR URL to the user.

## Step 10 — Final Report

Output a summary:

```
✅ Ship complete!
Branch: <branch-name>
PR: <pr-url>
Commits: <count>
Files changed: <count>
Lint: passed
Types: passed / <note if pre-existing issues>
```

## Important Rules

- NEVER push directly to `development`, `main`, or `master`. Always create a feature branch.
- NEVER use `--force` push. Only `--force-with-lease` if absolutely needed.
- NEVER commit secrets or `.env` files.
- NEVER skip linting or type-checking. If they fail, fix first.
- If the user has uncommitted changes AND staged changes, commit them together unless they are clearly unrelated (then ask).
- Always use the project's package manager (check for `pnpm-lock.yaml`, `yarn.lock`, or `package-lock.json`).
