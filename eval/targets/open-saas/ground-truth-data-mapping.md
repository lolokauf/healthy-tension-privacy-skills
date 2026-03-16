<!-- PROMOTED by maintainer on 2026-03-16 -->
# Ground Truth: OpenSaaS Template

## Metadata
- **Date audited:** 2026-03-16
- **Audited by:** Auto-generated auditor
- **Skill focus:** Map and inventory all personal data in a codebase - collection points, storage, flows, third-party sharing, retention

## Must-Find Items

Critical findings any competent assessment should identify within this skill's focus area.

| # | Finding | Category | Expected Severity | Expected Confidence | Reasoning | Acceptable Alternatives |
|---|---------|----------|-------------------|---------------------|-----------|------------------------|
| 1 | User email addresses stored in `User.email` field (schema.prisma:14) and used for authentication, payment processing, and email communications | PII - Email | HIGH | HIGH | Email is primary identifier for users, shared with Stripe/LemonSqueezy/Polar payment processors, SendGrid/Mailgun, and used across the app | None - this is a core data element |
| 2 | User payment processor IDs stored in `User.paymentProcessorUserId` (schema.prisma:18) linking users to Stripe/LemonSqueezy/Polar customer accounts | PII - Financial ID | HIGH | HIGH | Third-party customer IDs from payment processors create linkage to external payment data; enables cross-system tracking | Could note as "Financial Identifier" or "External Customer ID" |
| 3 | Task descriptions stored in `Task.description` (schema.prisma:49) containing user-generated content potentially including PII | PII - User Content | MEDIUM | HIGH | Free-text field where users could enter names, emails, personal details; sent to OpenAI API for processing (operations.ts:243-337) | Could be categorized as "User-Generated Content with PII Risk" |
| 4 | GPT response content stored in `GptResponse.content` (schema.prisma:39) containing AI-processed user data | PII - Derived Data | MEDIUM | HIGH | Contains AI processing results that may include personal information from task descriptions; stored indefinitely with no apparent deletion mechanism | None - derived data classification is appropriate |
| 5 | File metadata stored in `File` table including name, type, s3Key (schema.prisma:54-64) and S3 bucket storage | PII - File Metadata | MEDIUM | HIGH | File names may contain personal information; files stored in AWS S3 with user ID in path (s3Utils.ts:86-89); cross-border transfer to AWS | Could categorize as "File Storage Metadata and Content" |
| 6 | Email sent to Stripe customer email via webhook handler (stripe/webhook.ts:176-182) when subscription cancelled | Data Flow - Email | MEDIUM | HIGH | Automated email communication triggered by payment events; user email shared with emailSender (SendGrid/Mailgun/SMTP) | None |
| 7 | User emails sent to LemonSqueezy checkout system (lemonSqueezy/checkoutUtils.ts:18) for payment processing | Third-Party Sharing | HIGH | HIGH | Email explicitly shared with LemonSqueezy payment processor during checkout session creation | None |
| 8 | User emails sent to Stripe checkout system (stripe/checkoutUtils.ts:18-20) for customer creation | Third-Party Sharing | HIGH | HIGH | Email shared with Stripe to create/lookup customers; Stripe enforces email uniqueness in their system | None |
| 9 | User ID and email sent to Polar payment processor (polar/checkoutUtils.ts:22-24) with external ID linkage | Third-Party Sharing | HIGH | HIGH | Both userId as externalId and email sent to Polar; creates permanent external linkage (externalId cannot be changed once set) | None |
| 10 | Analytics data sent to Plausible/Google Analytics including page views, visitor counts, and source tracking (analytics/stats.ts, googleAnalyticsUtils.ts, plausibleAnalyticsUtils.ts) | Third-Party Sharing | MEDIUM | HIGH | User behavior data collected and sent to analytics providers; Google Analytics uses cookies (Config.ts:46-53) | Could note cookie-based vs cookieless tracking difference |
| 11 | Task data sent to OpenAI API including task descriptions and time estimates (demo-ai-app/operations.ts:252-330) | Third-Party Sharing | HIGH | HIGH | User task content sent to OpenAI GPT-3.5 for processing; may contain PII in free-text descriptions | None |
| 12 | Contact form messages stored in `ContactFormMessage` table (schema.prisma:101-111) with user content and read status tracking | PII - User Content | MEDIUM | HIGH | Free-text contact messages linked to userId; includes isRead tracking and repliedAt timestamp; no deletion mechanism implemented | None |
| 13 | Username stored in `User.username` (schema.prisma:15) used as display identifier | PII - Username | MEDIUM | HIGH | Optional unique identifier; used across UI; for social auth becomes the social platform username (userSignupFields.ts) | None |
| 14 | Payment timestamps in `User.datePaid` (schema.prisma:22) revealing subscription purchase dates | PII - Financial Metadata | LOW | HIGH | Reveals when user made payments; used for subscription period calculations | Could be "Transaction Metadata" |
| 15 | User creation timestamps in `User.createdAt`, `Task.createdAt`, `GptResponse.createdAt`, `File.createdAt` (schema.prisma multiple locations) | PII - Behavioral Metadata | LOW | HIGH | Timestamps reveal user activity patterns and account lifecycle | Could categorize as "Activity Metadata" |

## Nice-to-Find Items

Deeper findings that demonstrate thoroughness.

| # | Finding | Category | Expected Severity | Expected Confidence | Reasoning |
|---|---------|----------|-------------------|---------------------|-----------|
| 1 | Admin email addresses stored in environment variable ADMIN_EMAILS (auth/env.ts:4-8) and checked during signup (userSignupFields.ts:5-7) | PII - Admin Data | LOW | HIGH | Admin emails stored in config; used to grant admin privileges; creates a special data category |
| 2 | LemonSqueezy customer portal URLs stored in `User.lemonSqueezyCustomerPortalUrl` (schema.prisma:19) | PII - Account Metadata | LOW | HIGH | Unique URLs for customer payment management; enables direct access to payment portal |
| 3 | Subscription status tracking in `User.subscriptionStatus` (schema.prisma:20) revealing user's payment state | PII - Financial Status | MEDIUM | HIGH | Reveals whether user is paying customer; used for access control and analytics (stats.ts:39-43) |
| 4 | Credits balance in `User.credits` (schema.prisma:23) tracking user's consumption | PII - Account Balance | MEDIUM | HIGH | Numerical balance decremented on AI usage; reveals usage patterns |
| 5 | Google Analytics service account credentials stored as base64-encoded private key (googleAnalyticsUtils.ts:4-7, .env.server.example:55) | Sensitive Config | MEDIUM | HIGH | Private key for GA access stored in env var; grants API access to user analytics data |
| 6 | AWS S3 IAM credentials in environment (fileUpload/env.ts:8-13, .env.server.example:60-63) | Sensitive Config | MEDIUM | HIGH | Access keys grant permission to user files in S3 bucket |
| 7 | Page view source tracking in `PageViewSource` table (schema.prisma:82-91) revealing traffic sources | Behavioral Data | LOW | HIGH | Tracks where visitors come from; aggregated analytics but could reveal patterns |
| 8 | Daily stats aggregation including user counts and revenue in `DailyStats` table (schema.prisma:66-80) | Aggregate Analytics | LOW | MEDIUM | Aggregated data but includes total user counts and paying user counts |
| 9 | Cookie consent acceptance tracked via vanilla-cookieconsent library (cookie-consent/Config.ts, Banner.tsx) | Consent Data | MEDIUM | HIGH | Cookie consent choices stored in browser; affects analytics tracking activation |
| 10 | No explicit data retention policy or automated deletion for GptResponse, Task, or File records | Data Retention Gap | MEDIUM | HIGH | No TTL or cleanup jobs found; data appears to be retained indefinitely |
| 11 | User deletion functionality appears to be UI-only stub (DropdownEditDelete.tsx:22-25) with no backend implementation | Data Deletion Gap | HIGH | HIGH | Delete button exists in admin UI but has no connected backend handler; GDPR/DSAR risk |
| 12 | Logs table storing system messages (schema.prisma:93-99) potentially including user data in error messages | Logging - PII Risk | LOW | MEDIUM | Generic message field could inadvertently log PII during errors |
| 13 | Mock user data generator creates fake emails, usernames for testing (dbSeeds.ts:42-43) | Test Data | LOW | HIGH | Seed script generates synthetic user data; should not be run in production |

## Known Ambiguities

Findings where reasonable reviewers might disagree.

| Finding | Why It's Ambiguous | Acceptable Interpretations |
|---------|-------------------|---------------------------|
| S3 file content (not just metadata) containing PII | File content is not stored in database but in S3 bucket; schema only shows metadata | (A) List file content as separate data element requiring content analysis, OR (B) Document file storage location with note that content analysis requires S3 access |
| IsAdmin flag in User table | Could be considered authorization data (not PII) or sensitive role information | (A) Categorize as "Authorization/Role Data", OR (B) Include as PII since it reveals user status |
| Task.time field (schema.prisma:50) storing time estimates | Unclear if this is hours, minutes, or categorical time estimate | (A) Classify as user preference/metadata, OR (B) Include in behavioral profiling data |
| Subscription plan names (hobby/pro) in User.subscriptionPlan | Could be considered financial data or just product preference | (A) Financial/Purchase Data, OR (B) User Preference Data |
| Payment processor choice (Stripe vs LemonSqueezy vs Polar) | Three different processors are configured; unclear which is active | (A) Document all three as potential data recipients, OR (B) Note as "configurable - requires env var check to determine active processor" |
| Cross-border data transfers | AWS S3 region is configurable; actual data residency depends on deployment config | (A) Flag as "Yes - region dependent", OR (B) Mark as "Unknown - requires deployment inspection" |
| ContactFormMessage implementation | Schema exists but MessagesPage.tsx shows "under construction" (line 8) | (A) Include in inventory as designed feature, OR (B) Note as "planned but not implemented" |

## Red Herrings

Things that look like issues within this skill's focus area but are not.

| Item | Why It Looks Like an Issue | Why It's Not |
|------|--------------------------|-------------|
| User.isAdmin field appears to be publicly visible | Boolean field in schema; could seem like exposed sensitive role data | It's an authorization field properly protected by auth checks in operations (operations.ts:35-40); only used server-side for access control |
| Database logs containing "message" field | Looks like it could capture PII in error messages | Logs table is for system-level application logging (stats.ts:122-127); not user-facing messages and properly separated from PII tables |
| DailyStats and PageViewSource tables | Appear to track individual user page views | These are aggregate analytics only (stats.ts); no user-level tracking, just counts and sources |
| Multiple payment processor integrations | Looks like data is sent to all three (Stripe, LemonSqueezy, Polar) | Only ONE payment processor is active based on paymentProcessor.ts imports; the others are alternative implementations |
| Dark mode preference in localStorage (useColorMode hook) | Could be considered user preference tracking | This is client-side only UI state; not persisted to server or database; purely local browser storage |
| Google Analytics ID in client env var (.env.client.example:4) | Appears to be a secret | This is a public measurement ID meant to be exposed client-side; not a secret credential (unlike the server-side private key) |
| Email "fromField" configuration in main.wasp:40-42 | Looks like it might store sent email addresses | This is configuration for the sender address, not recipient data; static configuration, not PII |
| Webhook secrets for payment processors | Could appear to be user credentials | These are server-to-server API credentials for webhook validation, not user data |

<!-- EVAL METADATA
  cost: unknown
  duration_ms: 216109
  turns: 78
  session_id: 95c16418-77fa-4ebb-a202-b47fe45d0be8
  extraction: markers
-->
