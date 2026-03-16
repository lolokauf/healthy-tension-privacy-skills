<!-- PROMOTED by maintainer on 2026-03-16 -->

# Ground Truth: Documenso

## Metadata
- **Date audited:** 2026-03-16
- **Audited by:** Auto-generated auditor
- **Skill focus:** Map and inventory all personal data in a codebase - collection points, storage, flows, third-party sharing, and retention

## Must-Find Items

Critical findings any competent assessment should identify within this skill's focus area.

| # | Finding | Category | Expected Severity | Expected Confidence | Reasoning | Acceptable Alternatives |
|---|---------|----------|-------------------|---------------------|-----------|------------------------|
| 1 | User emails stored in User.email (schema.prisma:42), unique indexed, collected at signup (/signup route) | PII - Contact Info | HIGH | HIGH | Email is the primary identifier for users, stored unencrypted, used for authentication and document signing notifications | None |
| 2 | User names stored in User.name (schema.prisma:41), collected at signup and document signing | PII - Identity | HIGH | HIGH | Full names linked to user accounts, used in audit logs and displayed to other parties during document signing | Could classify as MEDIUM if considering optional field |
| 3 | IP addresses logged in UserSecurityAuditLog.ipAddress (schema.prisma:116), Session.ipAddress (schema.prisma:322), DocumentAuditLog.ipAddress (schema.prisma:479) - collected via extract-request-metadata.ts | PII - Network Identifiers | HIGH | HIGH | IP addresses systematically collected for security audit trails, document audit logs, and session tracking. Extracted from X-Forwarded-For and other headers | None |
| 4 | User passwords hashed in User.password (schema.prisma:44) and Account.password (schema.prisma:310), processed with bcrypt (@node-rs/bcrypt in package.json) | PII - Authentication Credentials | CRITICAL | HIGH | Password authentication credentials stored (even if hashed). Note: marked for removal in schema comments | None |
| 5 | Recipient email addresses stored in Recipient.email (schema.prisma:583), indexed with GIN trigram for search, collected when document owners add recipients | PII - Contact Info | HIGH | HIGH | Email addresses of document signers/recipients, may include external parties not registered as users | None |
| 6 | Recipient names stored in Recipient.name (schema.prisma:584), indexed with GIN trigram for search | PII - Identity | HIGH | HIGH | Names of document signers/recipients, displayed on documents and in audit trails | None |
| 7 | User signatures stored as base64 images (Signature.signatureImageAsBase64, schema.prisma:659) and typed text (Signature.typedSignature, schema.prisma:660) plus User.signature (schema.prisma:46) | PII - Biometric/Identity | CRITICAL | HIGH | Digital representations of handwritten signatures, legally binding biometric identifiers | Could debate if typed signatures are biometric |
| 8 | User agent strings logged in UserSecurityAuditLog.userAgent (schema.prisma:115), Session.userAgent (schema.prisma:323), DocumentAuditLog.userAgent (schema.prisma:478) | PII - Device Fingerprinting | MEDIUM | HIGH | Browser/device fingerprinting data collected from HTTP headers for security and audit purposes | None |
| 9 | Two-factor authentication secrets stored in User.twoFactorSecret and User.twoFactorBackupCodes (schema.prisma:62-64), encrypted | PII - Authentication Credentials | CRITICAL | HIGH | TOTP secrets and backup codes for account security, high sensitivity | None |
| 10 | PostHog analytics integration (posthog-js, posthog-node in package.json, use-analytics.ts, telemetry-client.ts) sending installation IDs and event data | Third-Party Data Sharing | HIGH | HIGH | Client-side and server-side analytics with PostHog, includes event capture and optional session recording capabilities (commented out but present in code) | Could be MEDIUM if telemetry is minimal |
| 11 | Stripe payment processor integration receiving customer data (ee/stripe/create-customer.ts) with name and email, subscription management via webhooks | Third-Party Data Sharing | HIGH | HIGH | Payment processor receives name and email to create Stripe customers, manages subscription lifecycle | None |
| 12 | AWS S3 storage for document uploads (server-actions.ts with S3Client) with access keys, optional CloudFront distribution | Third-Party Data Sharing | HIGH | HIGH | Documents (containing potentially sensitive signed agreements) stored in S3 buckets, configurable via NEXT_PRIVATE_UPLOAD_* env vars | Could store in database instead |
| 13 | Document content stored in DocumentData.data (schema.prisma:500) as S3_PATH, BYTES, or BYTES_64, containing PDFs with recipient information | PII - Document Content | CRITICAL | HIGH | Actual document files containing whatever personal data is in the PDFs being signed (contracts, agreements, forms) | None |
| 14 | No automated deletion or retention period defined for user data - cascade deletes on user/document deletion but no time-based retention | Data Retention Gap | HIGH | HIGH | Schema shows onDelete: Cascade but no TTL or automated cleanup jobs visible for old data, sessions, or inactive accounts | Could have scheduled jobs not in this codebase |
| 15 | Webhook data sharing with user-configured URLs (Webhook.webhookUrl, schema.prisma:186) sending document events including recipient emails/names via trigger-webhook.ts | Third-Party Data Sharing | HIGH | HIGH | Outbound webhooks send document lifecycle events to third-party URLs, includes recipient PII in webhook payloads (WebhookCall.requestBody stores full payload) | None |

## Nice-to-Find Items

Deeper findings that demonstrate thoroughness.

| # | Finding | Category | Expected Severity | Expected Confidence | Reasoning |
|---|---------|----------|-------------------|---------------------|-----------|
| 1 | Passkey credentials stored as binary data (Passkey.credentialId, credentialPublicKey in schema.prisma:137-138) using WebAuthn | PII - Authentication | MEDIUM | HIGH | Passwordless authentication credentials, device-specific biometric authenticators |
| 2 | OAuth tokens from Google/Microsoft stored in Account table (refresh_token, access_token, id_token as TEXT, schema.prisma:299-308) | PII - Authentication | CRITICAL | HIGH | Third-party OAuth tokens stored for SSO, potential access to external accounts |
| 3 | Email sending via multiple providers: SMTP, Resend API, MailChannels (configured in .env.example:96-133) - all receive recipient emails/names | Third-Party Sharing | MEDIUM | HIGH | Email delivery services process recipient contact information and email content |
| 4 | Google Vertex AI integration for AI features (ai/google.ts) with project ID and API key, controlled by aiFeaturesEnabled flag | Third-Party Sharing | MEDIUM | MEDIUM | AI service integration, unclear what data is sent but has access to API |
| 5 | Session tokens stored in Session.sessionToken (schema.prisma:319) with expiration tracking | PII - Session Data | MEDIUM | HIGH | Session management tokens, indexed and tied to IP addresses |
| 6 | Avatar images stored as base64 in AvatarImage.bytes (schema.prisma:1032) for users/teams/organisations | PII - Biometric | LOW | HIGH | Profile pictures may contain faces, biometric identifiers |
| 7 | Rejection reasons captured in Recipient.rejectionReason (schema.prisma:593) as free text | PII - User Input | LOW | HIGH | Free-text field may contain sensitive explanations for document rejection |
| 8 | DocumentMeta.redirectUrl (schema.prisma:517) and DocumentMeta.message (schema.prisma:514) contain user-provided content | PII - User Input | LOW | MEDIUM | May contain personal information depending on user input |
| 9 | AWS SES integration for custom email domain verification (create-email-domain.ts) with DKIM private keys | Third-Party Sharing | MEDIUM | HIGH | AWS SES processes email domain verification, stores DKIM keys encrypted |
| 10 | Organisation URLs (Organisation.url, Team.url in schema.prisma:693, 908) may reveal company/personal names | PII - Identity | LOW | MEDIUM | URL slugs might contain identifiable information about organizations |
| 11 | Email share links with recipient emails (DocumentShareLink.email, schema.prisma:670) creating access tokens | PII - Access Control | MEDIUM | HIGH | Email-based document sharing generates persistent links tied to specific emails |
| 12 | Field custom text data (Field.customText, schema.prisma:641) stores form field values entered by recipients | PII - User Input | HIGH | MEDIUM | Depending on field type (NAME, EMAIL, TEXT, NUMBER), could contain various PII |
| 13 | telemetry-client.ts collects installation ID and node ID, sends to PostHog on heartbeat (every 60 min) | Third-Party Sharing | LOW | HIGH | Anonymous telemetry unless DOCUMENSO_DISABLE_TELEMETRY is set, claims not to collect personal data but worth noting |
| 14 | Plain Support integration (NEXT_PRIVATE_PLAIN_API_KEY in .env.example:188) - support ticket system integration | Third-Party Sharing | MEDIUM | LOW | Support system integration present but usage unclear from codebase |

## Known Ambiguities

Findings where reasonable reviewers might disagree.

| Finding | Why It's Ambiguous | Acceptable Interpretations |
|---------|-------------------|---------------------------|
| User.source field (schema.prisma:45) | Field named "source" with no clear definition - could be referral source, signup source, or something else | Could be PII if it tracks referral URLs with personal tokens, or could be non-PII metadata like "google-oauth" or "email-signup" |
| Envelope.externalId (schema.prisma:390) | Custom external ID field - content depends on user input | Could contain PII if users use it to store customer IDs, names, or other identifiers, or could be random UUIDs |
| DocumentData storage location | Documents stored in S3 or database as base64, both could cross borders | Whether this constitutes cross-border transfer depends on S3 region configuration, not determinable from code alone |
| PostHog session recording | Code exists for session recording (use-analytics.ts:42-65) but is commented out/disabled | Unclear if this was used before, might be enabled in future, represents potential privacy risk |
| Webhook payload contents | WebhookCall.requestBody stores full webhook payload (schema.prisma:209) | Exact PII shared depends on webhook event type and template, would need to trace each event type |
| Email template personalization | Email templates in packages/email/templates/ may include recipient names, document details | Depth of personalization and PII in emails depends on template implementation |
| Stripe customer metadata | create-customer.ts only shows name/email sent to Stripe, but Stripe API allows arbitrary metadata | Additional metadata might be sent in other flows not examined |
| Legal basis for processing | No explicit legal basis tracking in database schema | Application likely relies on contract/legitimate interest but this isn't documented in data model |

## Red Herrings

Things that look like issues within this skill's focus area but are not.

| Item | Why It Looks Like an Issue | Why It's Not |
|------|--------------------------|-------------|
| PasswordResetToken.token (schema.prisma:123) | Looks like a password being stored | This is a temporary password reset token sent via email, not the actual password. Tokens expire (schema has expiry field) and are one-time use |
| VerificationToken.token (schema.prisma:158) | Another token that might store credentials | Email verification token for confirming email ownership, not a password or permanent credential |
| ApiToken.token (schema.prisma:225) | "Token" suggests password-like data | This is an API key for programmatic access, hashed with SHA512 (schema.prisma:219), appropriate for this use case |
| DocumentData.initialData (schema.prisma:501) | Duplicate data field suggests data duplication/retention issue | This stores the original unmodified PDF for audit trail purposes, intentional design for legal compliance |
| Recipient.documentDeletedAt (schema.prisma:586) | Soft delete timestamp might indicate data not being deleted | This is for marking when a document owner deletes their copy, but recipients retain access - legitimate business logic, not a retention issue |
| NEXT_PRIVATE_ENCRYPTION_KEY in .env.example | Looks like a weak encryption key (value: "CAFEBABE") | This is an example file with placeholder values, not production configuration |
| Session.expiresAt (schema.prisma:324) | Sessions might not expire properly | Field exists and is used for expiration, this is proper session management |
| Subscription.customerId (schema.prisma:251) | Duplicate customer ID storage | This is Stripe's customer ID, not PII itself, just a reference to Stripe's system |
| BackgroundJob.payload (schema.prisma:990) as JSON | Arbitrary JSON might contain PII | This is for internal job queue system, payload structure controlled by application code for legitimate processing |
| User.disabled field (schema.prisma:53) instead of deletion | Looks like data isn't deleted when accounts are deactivated | Separate from actual deletion (delete-user.ts exists), this is for temporary account suspension |

<!-- EVAL METADATA
  cost: unknown
  duration_ms: 227241
  turns: 69
  session_id: ce623fa4-fc6a-40ff-8a67-1979ef6f247a
  extraction: markers
-->
