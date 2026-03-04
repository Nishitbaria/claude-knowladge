# Email System — Resend + React Email + Better Auth

## Stack
- **Resend SDK** `resend@6.9.2` — email delivery
- **React Email** `@react-email/components@1.0.8` — HTML email templates
- **Domain**: `mail.runagents.co` (via `EMAIL_DOMAIN` env var)
- **Default sender**: `RunAgents <hello@mail.runagents.co>`

## File Structure
```
src/
├── lib/
│   ├── resend.ts              # Resend client singleton
│   └── email/
│       └── send.ts            # sendEmail() typed utility
├── emails/                    # React Email templates (preview via pnpm email:dev)
│   ├── waitlist-email.tsx     # Waitlist confirmation
│   ├── verification-email.tsx # Email verification (signup)
│   ├── password-reset-email.tsx # Password reset
│   └── welcome-email.tsx      # Welcome (post-verification)
```

## sendEmail() Utility (`src/lib/email/send.ts`)
- Wraps `resend.emails.send()` with typed `SendEmailOptions` / `SendEmailResult`
- Returns `{ success, messageId?, error? }` — does NOT throw
- Logs errors with `[email]` prefix
- Callers decide whether to throw on failure

## Email Flow by Trigger

| Trigger | Email | Where configured |
|---------|-------|-----------------|
| Email/password signup | Verification email | `emailVerification.sendVerificationEmail` in `auth.ts` |
| Click verify link (email/password) | Welcome email | `emailVerification.afterEmailVerification` in `auth.ts` |
| Fresh Google OAuth signup | Welcome email | `databaseHooks.user.create.after` (only if `emailVerified === true`) |
| Email/password signup → later links Google | No welcome email (by design — edge case) |
| Password reset request | Password reset email | `emailAndPassword.sendResetPassword` in `auth.ts` |
| Waitlist signup | Waitlist email | `src/server/actions/waitlist.actions.ts` |

## Key Design Decisions
1. **Welcome email only after verification** — never send to unverified users
2. **`user.create.after` checks `emailVerified`** — only true for OAuth users; email/password users are `false` at creation
3. **`afterEmailVerification`** — only fires when user clicks verify link, NOT when OAuth sets `emailVerified` via account linking
4. **sendEmail returns result, doesn't throw** — auth callbacks check `result.success` and throw explicitly so Better Auth can propagate errors
5. **Templates match waitlist-email.tsx style** — same Tailwind, same container, same footer

## Env Vars (already validated in `src/env/server.ts`)
- `RESEND_API_KEY` — `z.string().min(1)`
- `EMAIL_DOMAIN` — `z.string().default("mail.runagents.co")`

## Testing
- Preview templates: `pnpm email:dev -d src/emails -p 3001` → `http://localhost:3001`
- Resend test mode: use `re_test_` prefixed API keys (accepts sends, no real delivery)
- Check Resend dashboard for delivery logs
