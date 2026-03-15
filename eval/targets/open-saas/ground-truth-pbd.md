# PbD Code Review — Ground Truth: Open SaaS

## Metadata
- **Target:** open-saas
- **Repo:** https://github.com/wasp-lang/open-saas.git
- **Pinned commit:** c2f4624cf8a34cbebc9e1561be944fc35ed32a35
- **Stack:** Wasp (React + Express + Prisma), TypeScript, PostgreSQL
- **Date audited:** 2026-03-15
- **Audited by:** Lauren Kaufman + Claude

## Expected Findings

### Must-Find Items

| # | Finding | Principle | Expected Severity | Expected Confidence | Reasoning | Acceptable Alternatives |
|---|---------|-----------|-------------------|---------------------|-----------|------------------------|
| 1 | No account deletion mechanism — users cannot delete their accounts or data | 7 (Respect) | CRITICAL | HIGH | No `deleteAccount` action exists anywhere. Violates GDPR Art. 17 (right to erasure). Users are permanently stored. | — |
| 2 | No cascade deletes on any FK relationship — user deletion would leave orphaned GptResponse, Task, File, ContactFormMessage records | 5 (End-to-End) | CRITICAL | HIGH | All FK relations use Prisma default (RESTRICT). Even if deletion were implemented, child records would block it or be orphaned. | HIGH acceptable if reviewer notes Wasp might handle this internally |
| 3 | No data export / portability feature | 7 (Respect) | HIGH | HIGH | No export endpoint. Users cannot obtain a copy of their data (GDPR Art. 20). | MEDIUM acceptable |
| 4 | Plausible analytics script included unconditionally in page head, not gated by consent | 2 (Privacy as Default) | HIGH | HIGH | Plausible `<script>` tags are in the `main.wasp` head array (lines 29-30), loaded on every page without consent check. Cookie consent only gates Google Analytics. Note: the template ships with placeholder `data-domain='<your-site-id>'` so it won't actually transmit until configured, but the *pattern* is consent-bypass — once a user sets their site ID, tracking begins immediately. | MEDIUM acceptable if reviewer notes Plausible is "privacy-friendly" (no cookies) or notes the placeholder isn't active |
| 5 | User task descriptions sent to OpenAI without explicit consent or privacy notice | 6 (Transparency) | HIGH | HIGH | `operations.ts` sends task descriptions to GPT-3.5-turbo. No in-app notice that data goes to OpenAI. No opt-in toggle. | MEDIUM acceptable |
| 6 | No data retention policy — all user data retained indefinitely | 5 (End-to-End) | HIGH | HIGH | No `deletedAt`, `expiresAt`, or cleanup job on any model. GptResponse, Task, File, ContactFormMessage, Logs, DailyStats all stored forever. | — |
| 7 | S3 file deletion failures silently logged — orphaned files persist | 5 (End-to-End) | HIGH | HIGH | `operations.ts` catches S3 deletion errors with `console.error` but doesn't retry. Orphaned files remain in S3 indefinitely. | MEDIUM acceptable |
| 8 | Admin dashboard exposes user PII without audit logging | 6 (Transparency) | HIGH | HIGH | `getPaginatedUsers` returns email, username, subscription status, payment processor ID. No audit log of admin queries. No user notification. | MEDIUM acceptable if reviewer classifies as admin-internal |
| 9 | All PII stored unencrypted — email, username, payment IDs, task content, file metadata | 5 (End-to-End) | MEDIUM | HIGH | No field-level encryption on any model. All PII queryable as plaintext in PostgreSQL. | HIGH acceptable |
| 10 | User ID visible in S3 storage key — correlation risk | 3 (Embedded) | MEDIUM | HIGH | S3 key format is `userId/uuid.ext`. Exposes user-file relationship to anyone with S3 access. | LOW acceptable |

### Nice-to-Find Items

| # | Finding | Principle | Expected Severity | Expected Confidence | Reasoning |
|---|---------|-----------|-------------------|---------------------|-----------|
| 1 | Subscription cancellation email sent automatically without opt-out | 2 (Privacy as Default) | MEDIUM | HIGH | Stripe webhook triggers retention email ("We hate to see you go") with no unsubscribe option. |
| 2 | No login/logout audit trail | 6 (Transparency) | MEDIUM | HIGH | No security audit log model. Wasp may handle session creation but no application-level logging of auth events. |
| 3 | Admin email list exposed in environment variable | 5 (End-to-End) | LOW | HIGH | `ADMIN_EMAILS` env var determines admin status at signup. Not encrypted or access-controlled. |
| 4 | Pre-signed S3 upload URLs valid for 1 hour | 5 (End-to-End) | LOW | HIGH | 3600-second URL expiry. Standard but long — leaked URLs grant file access for a full hour. |
| 5 | Logs model may contain PII in error messages | 1 (Proactive) | MEDIUM | MEDIUM | Error messages logged with `message: error?.message`. Stack traces or API errors may contain emails or user data. |
| 6 | Google Analytics cookies cleared on reject but Plausible unaffected | 2 (Privacy as Default) | MEDIUM | HIGH | Cookie consent `autoClear` removes `_ga`/`_gid` on reject, but Plausible operates without cookies so isn't affected by consent withdrawal. |
| 7 | No password complexity requirements visible | 5 (End-to-End) | LOW | MEDIUM | Wasp handles password validation internally, but no visible enforcement of complexity rules in application code. |
| 8 | Contact form messages retained indefinitely with no user control | 5 (End-to-End) | MEDIUM | HIGH | Messages stored in `ContactFormMessage` with no deletion mechanism, no retention limit, and no user visibility. |

### Expected Severity Distribution

- **CRITICAL:** 2 (no account deletion, no cascade deletes)
- **HIGH:** 6 (no data export, Plausible consent bypass, OpenAI transparency, no retention, S3 orphans, admin exposure)
- **MEDIUM:** 4-5 (unencrypted PII, S3 key correlation, cancellation email, logs PII, contact form retention)
- **LOW:** 2-3 (admin email env var, S3 URL expiry, password complexity)

### Expected Artifacts

| Artifact | Expected? | Key Content Expectations |
|----------|-----------|------------------------|
| PII Touchpoint Manifest | Yes | Should list 10+ PII fields across User, GptResponse, Task, File, ContactFormMessage |
| Default Configuration Audit | Yes | Should flag: Plausible loads before consent, no analytics opt-out, cookie consent only partial |
| PII Data Flow Heatmap | Yes | Should show: Prisma schema centralised but PII flows out to Stripe, OpenAI, S3, Plausible, SendGrid |
| Privacy-Preserving Alternatives Table | Yes | Should suggest: randomised S3 keys (remove userId), field-level encryption, local AI alternatives, cascade deletes |
| Data Lifecycle Table | Yes | Should flag: no retention policy on any model, no cleanup job, no soft-delete pattern |
| Transparency Audit | Yes | Should identify 5+ processors (Stripe, OpenAI, Plausible, S3, SendGrid) and note OpenAI receives user content without notice |
| User Privacy Controls Checklist | Yes | Should check for: account deletion (missing), data export (missing), analytics opt-out (partial — GA yes, Plausible no), profile management (minimal — view only) |
| Delete-My-Account Trace | Yes | Should note: no deletion path exists. If implemented, would need to cascade across GptResponse, Task, File (DB + S3), ContactFormMessage, Logs. Currently blocked by FK constraints (RESTRICT). |

### Known Ambiguities

| Finding | Why It's Ambiguous | Acceptable Interpretations |
|---------|-------------------|---------------------------|
| Plausible as privacy violation | Plausible markets itself as "privacy-friendly" (no cookies, EU-hosted). But it still collects IP-based data without consent. | CRITICAL (pre-consent tracking), HIGH (tracking without opt-out), or MEDIUM (privacy-friendly tool, less harmful than GA) |
| OpenAI data sharing | Demo feature, not core product. But it sends real user input to a third party. | HIGH (PII to third party without consent) or MEDIUM (demo feature, optional usage) |
| Wasp-managed auth | Passwords and sessions handled by framework — not visible in app code. | Flag as "framework-managed" with note, or skip (out of scope for code review) |
| Commented-out OAuth | Google, GitHub, Discord OAuth code exists but is commented out. | Flag as "potential integration surface" or skip (not active) |
| S3 file deletion failure | `console.error` is logged but no retry. Is this a privacy issue or just a reliability bug? | HIGH (data persists against intent) or MEDIUM (operational issue) |

### Red Herrings

| Item | Why It Looks Like an Issue | Why It's Not |
|------|--------------------------|-------------|
| `DailyStats` storing `userCount` and `paidUserCount` | Looks like per-user tracking | These are aggregate counts — they show "500 users total" not "which users." Re-identification from aggregates is theoretically possible but practically low risk for these metrics. |
| `PageViewSource.name` | Looks like a person's name | It's the traffic source name (e.g., "Google", "Twitter", "Direct") — a referrer category, not a person |
| `Task.time` | Looks like a timestamp or personal schedule | It's the estimated hours string (e.g., "2 hours") — just a duration estimate |
| `User.isAdmin` as sensitive data | Stored per-user, seems like it should be protected | It's a boolean role flag. Not PII — knowing someone's role doesn't identify them. Appropriate to store alongside auth data. |
| Missing password field in schema | Looks like passwords aren't handled | Wasp framework manages password hashing internally (bcrypt). Passwords exist in the database but aren't exposed in the application-level Prisma schema. This is correct separation of concerns, not a gap. |
