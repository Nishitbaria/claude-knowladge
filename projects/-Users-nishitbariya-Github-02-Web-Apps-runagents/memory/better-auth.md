# Better Auth Configuration

## Config Location
- Server: `src/lib/auth.ts` (betterAuth instance)
- Client: `src/lib/auth-client.ts` (createAuthClient)
- Route handler: `src/app/api/auth/[...better-auth]/route.ts`
- Auth model: `src/server/db/models/auth.model.ts` (auto-generated, DO NOT edit)
- UI provider: `src/components/providers.tsx` (AuthUIProvider from `@daveyplate/better-auth-ui`)

## Email Verification Flow (IMPORTANT — verified against source code)

### Config placement (verified from Better Auth v1.4.18 source)
```ts
emailAndPassword: {
  requireEmailVerification: true,  // ← MUST be here, NOT in emailVerification
},
emailVerification: {
  sendOnSignUp: true,              // Auto-send on signup
  autoSignInAfterVerification: true, // Create session after verify click
  afterEmailVerification(user) {},  // Hook: fires after verify link click
  sendVerificationEmail({ user, url }) {}, // The email sender
},
```

### How requireEmailVerification works (from source: dist/api/routes/sign-up.mjs)
- On signup: returns `{ token: null }` — NO session created
- On sign-in: throws 403 "EMAIL_NOT_VERIFIED" if user not verified
- sendOnSignUp triggers automatically when requireEmailVerification is true

### autoSignInAfterVerification (from source: dist/api/routes/email-verification.mjs)
- After user clicks verify link → creates session → sets cookie → user can proceed

### afterEmailVerification
- ONLY fires when user clicks the email verify link
- Does NOT fire when OAuth (Google) sets emailVerified via account linking
- Used to send welcome email for email/password users

## OAuth Account Linking Behavior (from source: dist/oauth2/link-account.mjs)

### Scenario: Email/password signup (unverified) → Google sign-in (same email)
1. Better Auth finds existing user by email
2. Links Google account to existing user
3. Sets `emailVerified: true` via `updateUser()` (line 48)
4. Creates session → user gets in
5. `afterEmailVerification` does NOT fire (only fires from verify-link flow)
6. `user.create.after` does NOT fire (user already exists)
7. Result: user gets in, no welcome email (by design — edge case)

### Scenario: Email/password signup (unverified) → Email/password sign-in
1. `requireEmailVerification` is true, `emailVerified` is false
2. Throws 403 "EMAIL_NOT_VERIFIED" → user blocked

## better-auth-ui (AuthUIProvider)

### emailVerification prop
- `emailVerification={true}` → resolves to `{ otp: false }`
- Sign-up form behavior when `requireEmailVerification: true`:
  - Signup returns `token: null`
  - Library redirects to sign-in page with toast "Check your email for the verification link"
  - Only redirects to EMAIL_VERIFICATION page if `otp: true`

### View paths
- `SIGN_IN` → `sign-in`
- `SIGN_UP` → `sign-up`
- `EMAIL_VERIFICATION` → `email-verification`

## Pages
- `/sign-in`, `/sign-up` — use `<AuthView>` from better-auth-ui
- `/email-verification` — custom page with 60s resend cooldown
- `/forgot-password`, `/reset-password` — use `<AuthView>`

## Auth Guards
- `src/app/(app)/layout.tsx` — requires session + `emailVerified` (defense-in-depth)
- `src/app/(auth)/layout.tsx` — redirects verified users to `/dashboard`
- `src/server/action-utils.ts` — `getAuthedSession()` for server actions

## User Model Extra Fields
- `trialExpiresAt: date` — set to 7 days from signup (via `BILLING_CONFIG.trialDays`)

## Plugins
- `dodopayments` — billing (createCustomerOnSignUp, checkout, portal)

## Social Providers
- Google OAuth (conditional on env vars being set)
