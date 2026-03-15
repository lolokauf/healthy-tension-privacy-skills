# Data Mapping — Ground Truth: Open SaaS

## Metadata
- **Target:** open-saas
- **Repo:** https://github.com/wasp-lang/open-saas.git
- **Pinned commit:** c2f4624cf8a34cbebc9e1561be944fc35ed32a35
- **Stack:** Wasp (React + Express + Prisma), TypeScript, PostgreSQL
- **Date audited:** 2026-03-15
- **Audited by:** Lauren Kaufman + Claude

## Expected PII Fields

### Must-Find Fields

| # | Data Element | Location | PII Category | Source | Storage | Expected Confidence | Acceptable Alternative Categories |
|---|-------------|----------|-------------|--------|---------|---------------------|----------------------------------|
| 1 | `User.email` | `template/app/schema.prisma` User model | contact | Registration, OAuth | PostgreSQL `User` table | HIGH | identifier |
| 2 | `User.username` | User model | identifier | Registration (auto-populated from email) | PostgreSQL `User` table | HIGH | contact |
| 3 | `User.paymentProcessorUserId` | User model | financial | Stripe/Lemon Squeezy/Polar checkout | PostgreSQL, plaintext | HIGH | identifier |
| 4 | `User.subscriptionStatus` | User model | financial | Payment webhook | PostgreSQL | HIGH | — |
| 5 | `User.datePaid` | User model | financial | Payment webhook | PostgreSQL | HIGH | — |
| 6 | `GptResponse.content` | GptResponse model | user_content | OpenAI API response | PostgreSQL, plaintext | HIGH | — |
| 7 | `Task.description` | Task model | user_content | User input (demo AI app) | PostgreSQL, plaintext | HIGH | — |
| 8 | `File.name` | File model | user_content | File upload | PostgreSQL, plaintext | HIGH | identifier |
| 9 | `File.s3Key` | File model | identifier | Generated (`userId/uuid.ext`) | PostgreSQL, plaintext | HIGH | — |
| 10 | `ContactFormMessage.content` | ContactFormMessage model | user_content | Contact form submission | PostgreSQL, plaintext | HIGH | — |

### Nice-to-Find Fields

| # | Data Element | Location | PII Category | Source | Expected Confidence |
|---|-------------|----------|-------------|--------|---------------------|
| 1 | `User.subscriptionPlan` | User model | financial | Payment webhook | HIGH |
| 2 | `User.credits` | User model | financial | Payment/usage | MEDIUM (arguably non-PII aggregate) |
| 3 | `Logs.message` | Logs model | user_content | Error logging | MEDIUM (may contain PII in error messages) |
| 4 | `DailyStats.userCount` / `paidUserCount` | DailyStats model | identifier | Analytics aggregation job | LOW (aggregated, not individual) |
| 5 | `DailyStats.totalRevenue` / `totalProfit` | DailyStats model | financial | Analytics aggregation job | MEDIUM |
| 6 | `User.lemonSqueezyCustomerPortalUrl` | User model | identifier | Lemon Squeezy checkout | HIGH (contains customer-specific URL) |
| 7 | Wasp-managed auth fields (password hash, session tokens) | Wasp internal tables | authentication | Auth flows | MEDIUM (not in app schema but exist in DB) |

## Expected Processors

| Processor | Data Received | Purpose | Expected Confidence |
|-----------|--------------|---------|---------------------|
| Stripe | User email, user ID, billing address (auto-collected), subscription data | Payment processing | HIGH |
| OpenAI | Task descriptions, work hours (user input) | AI-powered schedule generation | HIGH |
| Plausible | Visitor IP, pages visited, referrer, browser info | Privacy-friendly analytics | HIGH |
| AWS S3 | File contents, user ID in storage key path | File storage | HIGH |
| SendGrid (or configured email provider) | User email, verification/reset tokens | Transactional emails | HIGH |
| Google Analytics (optional) | IP, pages, clicks, cookies (_ga, _gid) | Web analytics | MEDIUM (behind consent, optional) |
| Lemon Squeezy / Polar (optional) | User email, subscription data | Alternative payment processors | MEDIUM (alternative to Stripe) |
| OAuth providers (Google, GitHub, Discord — commented out) | User email, username, profile | Authentication | LOW (commented out by default) |

## Expected Data Flows

1. **Registration**: User submits email + password → Wasp auth layer → bcrypt hash → PostgreSQL `User` table → verification email via SendGrid
2. **OAuth login**: User clicks OAuth → provider consent screen → email/username returned → Wasp creates User record
3. **Payment checkout**: User selects plan → Stripe checkout session created with email + user ID → Stripe processes payment → webhook updates `subscriptionStatus`, `datePaid`, `paymentProcessorUserId`
4. **AI schedule generation**: User enters task descriptions + hours → sent to OpenAI GPT-3.5-turbo → response stored in `GptResponse.content` linked to user
5. **File upload**: User selects file → presigned S3 URL generated → client uploads to S3 (`userId/uuid.ext`) → `File` record created in DB
6. **Contact form**: User submits message → stored in `ContactFormMessage.content` → visible in admin dashboard
7. **Analytics**: Plausible script fires on page load (before consent) → IP + page data sent to Plausible → daily aggregation job queries Plausible API → stores in `DailyStats`
8. **Admin dashboard**: Admin queries `getPaginatedUsers` → returns email, username, subscription status, payment processor ID → no audit log of query

## Expected Completeness

- **Approximate %:** 75-85%
- **Reasoning:** The Prisma schema is straightforward (9 models, all discoverable). Must-find fields are clearly PII. The main gaps will be: Wasp-managed auth tables (not in app schema), Plausible data transmission (requires tracing the analytics script in `main.wasp`), and understanding that `Logs.message` may contain PII from error contexts. Optional/commented-out integrations (OAuth, alternative payment processors) may be missed.

## Known Ambiguities

| Data Element | Why It's Ambiguous | Acceptable Categories |
|-------------|-------------------|----------------------|
| `User.credits` | Numeric balance — could be financial PII or non-personal usage metric | financial, or not PII |
| `DailyStats` aggregates | Aggregated counts — could be considered de-identified or PII-adjacent | identifier (re-identification risk), or not PII |
| `GptResponse.content` | AI-generated content based on user input — is the AI output PII? | user_content (derived from PII input), or not PII |
| `Logs.message` | Error messages — depends on what's logged at runtime | user_content (if PII in error), or not PII |
| Wasp auth internals | Framework manages auth tables not visible in app schema | authentication (if discovered via DB), or out-of-scope |
| `User.paymentProcessorUserId` | Stripe customer ID — financial identifier or just a reference | financial, identifier |

## Red Herrings

| Item | Why It Looks Like PII | Why It's Not |
|------|----------------------|-------------|
| `DailyStats.prevDayViewsChangePercent` | Stored per-day, looks like it could be per-user | It's an aggregate percentage change across all users — not tied to any individual |
| `PageViewSource.name` | Looks like it could be a user's name | It's the traffic source name (e.g., "Google", "Direct", "Twitter") — not a person |
| `Task.time` | Looks like a timestamp or PII | It's the estimated hours string for the task (e.g., "2 hours") — not a personal time record |
| `User.isAdmin` | Stored per-user, looks sensitive | It's a boolean role flag, not PII — knowing someone is an admin doesn't identify them |
