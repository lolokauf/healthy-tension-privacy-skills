# Data Mapping — Ground Truth: Documenso

## Metadata
- **Target:** documenso
- **Repo:** https://github.com/documenso/documenso.git
- **Pinned commit:** 70fb834a6a5a58df3a6203fc892b30014f8647cc
- **Stack:** Remix (Next.js), Prisma, TypeScript, PostgreSQL
- **Date audited:** 2026-03-15
- **Audited by:** Lauren Kaufman + Claude

## Expected PII Fields

### Must-Find Fields

Critical PII fields any competent inventory should discover.

| # | Data Element | Location | PII Category | Source | Storage | Expected Confidence | Acceptable Alternative Categories |
|---|-------------|----------|-------------|--------|---------|---------------------|----------------------------------|
| 1 | `User.email` | `packages/prisma/schema.prisma` User model | contact | Registration, OAuth | PostgreSQL `User` table | HIGH | identifier |
| 2 | `User.name` | User model | contact | Registration, profile settings | PostgreSQL `User` table | HIGH | identifier |
| 3 | `User.password` | User model | authentication | Registration (deprecated, RR7 migration) | PostgreSQL, bcrypt-hashed | HIGH | — |
| 4 | `User.signature` | User model | biometric | Profile settings (drawn/typed) | PostgreSQL, plaintext string | HIGH | user_content |
| 5 | `Recipient.email` | Recipient model | contact | Document owner adds recipient | PostgreSQL `Recipient` table | HIGH | identifier |
| 6 | `Recipient.name` | Recipient model | contact | Document owner adds recipient | PostgreSQL `Recipient` table | HIGH | identifier |
| 7 | `Recipient.token` | Recipient model | authentication | Auto-generated (nanoid) | PostgreSQL, plaintext | HIGH | session_data |
| 8 | `Signature.signatureImageAsBase64` | Signature model | biometric | Signing flow (drawn signature) | PostgreSQL, base64 plaintext | HIGH | user_content |
| 9 | `Signature.typedSignature` | Signature model | contact | Signing flow (typed name) | PostgreSQL, plaintext | HIGH | identifier |
| 10 | `Session.sessionToken` | Session model | authentication | Login | PostgreSQL, SHA256-hashed | HIGH | session_data |
| 11 | `Session.ipAddress` | Session model | identifier | HTTP request | PostgreSQL, plaintext | HIGH | — |
| 12 | `Session.userAgent` | Session model | identifier | HTTP request | PostgreSQL, plaintext | HIGH | — |
| 13 | `Account.access_token` | Account model (OAuth) | authentication | OAuth flow | PostgreSQL, plaintext | HIGH | — |
| 14 | `Account.refresh_token` | Account model (OAuth) | authentication | OAuth flow | PostgreSQL, plaintext | HIGH | — |
| 15 | `Account.id_token` | Account model (OAuth) | authentication | OAuth flow | PostgreSQL, plaintext | HIGH | — |
| 16 | `DocumentAuditLog.email` | DocumentAuditLog model | contact | Document workflow actions | PostgreSQL | HIGH | identifier |
| 17 | `DocumentAuditLog.name` | DocumentAuditLog model | contact | Document workflow actions | PostgreSQL | HIGH | identifier |
| 18 | `DocumentAuditLog.ipAddress` | DocumentAuditLog model | identifier | HTTP request | PostgreSQL | HIGH | — |
| 19 | `UserSecurityAuditLog.ipAddress` | UserSecurityAuditLog model | identifier | Auth events | PostgreSQL | HIGH | — |
| 20 | `UserSecurityAuditLog.userAgent` | UserSecurityAuditLog model | identifier | Auth events | PostgreSQL | HIGH | — |
| 21 | `User.twoFactorSecret` | User model | authentication | 2FA setup | PostgreSQL, plaintext | HIGH | — |
| 22 | `User.twoFactorBackupCodes` | User model | authentication | 2FA setup | PostgreSQL, plaintext | HIGH | — |
| 23 | `PasswordResetToken.token` | PasswordResetToken model | authentication | Password reset flow | PostgreSQL, plaintext | HIGH | — |
| 24 | `OrganisationMemberInvite.email` | OrganisationMemberInvite model | contact | Team invite | PostgreSQL | HIGH | — |
| 25 | `DocumentShareLink.email` | DocumentShareLink model | contact | Document sharing | PostgreSQL | HIGH | — |

### Nice-to-Find Fields

Fields that demonstrate thorough exploration beyond the Prisma schema.

| # | Data Element | Location | PII Category | Source | Expected Confidence |
|---|-------------|----------|-------------|--------|---------------------|
| 1 | `Envelope.title` | Envelope model | user_content | Document upload | MEDIUM (title may contain PII like names) |
| 2 | `Envelope.formValues` | Envelope model (JSON) | user_content | Signing flow | MEDIUM (user-entered form responses) |
| 3 | `Passkey.credentialId` | Passkey model | authentication | WebAuthn registration | HIGH |
| 4 | `Passkey.credentialPublicKey` | Passkey model | authentication | WebAuthn registration | HIGH |
| 5 | `VerificationToken.identifier` | VerificationToken model | contact | Email verification | HIGH (contains email address) |
| 6 | `WebhookCall.requestBody` | WebhookCall model (JSON) | user_content | Webhook execution | MEDIUM (contains recipient PII forwarded to external service) |
| 7 | `EmailDomain.privateKey` | EmailDomain model | authentication | Custom email domain setup | HIGH (DKIM private key, plaintext) |
| 8 | `OrganisationAuthenticationPortal.clientSecret` | OrgAuthPortal model | authentication | OIDC/SSO setup | HIGH (OAuth secret, plaintext) |
| 9 | `User.avatarImageId` | User model | biometric | Profile settings | LOW (reference to image, not image itself) |
| 10 | `EnvelopeItem.data` / uploaded documents | EnvelopeItem/storage | user_content | Document upload | MEDIUM (documents may contain any PII) |
| 11 | `Recipient.rejectionReason` | Recipient model | user_content | Signing refusal | MEDIUM |
| 12 | `OrganisationEmail.email` | OrganisationEmail model | contact | Custom email setup | HIGH |
| 13 | `Field.customText` | Field model | user_content | Signing flow (user-entered values after signing) | MEDIUM (dual purpose: label before signing, user data after) |

## Expected Processors

| Processor | Data Received | Purpose | Expected Confidence |
|-----------|--------------|---------|---------------------|
| PostHog | User email (via `analytics.capture`), installation ID, event names, timestamps | Product analytics and telemetry | HIGH |
| Stripe | User name, email, subscription metadata | Payment processing and billing | HIGH |
| Email service (Resend / Mailchannels / SMTP / AWS SES) | Recipient name, email, document title, signing link with token, sender info | Signing invitation and notification emails | HIGH |
| Google Vertex AI | Document content (PDF text), field names and types | AI-powered field detection in documents | HIGH |
| S3-compatible storage (optional) | Document files (PDFs), attachments | Document persistence | HIGH |
| Google Cloud HSM (optional) | Document signature requests | Cryptographic signing | MEDIUM |
| OAuth providers (Google, Microsoft, custom OIDC) | User email, name, profile via OAuth flow | Authentication | HIGH |

## Expected Data Flows

1. **Registration**: User submits email + password → Prisma → PostgreSQL `User` table (bcrypt hash) → Email verification token sent via email service
2. **OAuth login**: User clicks OAuth → redirect to Google/Microsoft → tokens returned → stored plaintext in `Account` table
3. **Document upload**: User uploads PDF → stored in PostgreSQL (base64) or S3 → `Envelope` + `EnvelopeItem` created
4. **Signing invitation**: Owner adds recipients → `Recipient` records created with tokens → email service sends signing links with tokens + document title + recipient name
5. **Signing flow**: Recipient clicks link → authenticates via token → views document → signs → `Signature` record (base64 image or typed name) + `Field` records → `DocumentAuditLog` entry (IP, user agent, email)
6. **Audit trail**: Every document action → `DocumentAuditLog` (actor name, email, IP, user agent); every auth event → `UserSecurityAuditLog` (IP, user agent)
7. **Webhook forwarding**: On document events → full document + recipient data (names, emails, tokens, signing status) sent to user-configured webhook URLs
8. **AI field detection**: Document content sent to Google Vertex AI for field/recipient detection
9. **Analytics**: User actions captured by PostHog (email on account claim events, installation telemetry on heartbeat)

## Expected Completeness

- **Approximate %:** 70-80%
- **Reasoning:** The Prisma schema is the primary source and is highly discoverable (25+ must-find fields). Nice-to-find items require deeper exploration of JSON fields (formValues, requestBody), transient data in email templates, and uploaded document content analysis. Document contents are inherently unknowable PII (user-uploaded PDFs could contain anything). AI integration and webhook payloads are discoverable but require tracing data flows beyond the schema.

## Known Ambiguities

| Data Element | Why It's Ambiguous | Acceptable Categories |
|-------------|-------------------|----------------------|
| `User.signature` | Could be classified as biometric (drawn signature) or user_content (typed text) | biometric, user_content, identifier |
| `Signature.signatureImageAsBase64` | Drawn signature image — biometric vs. user_content | biometric, user_content |
| `Envelope.title` | Document title may or may not contain PII (e.g., "Employment Contract for John Doe") | user_content, identifier, or not PII |
| `Envelope.formValues` (JSON) | Contains user-entered form responses — category depends on what was asked | user_content, or more specific categories |
| Uploaded document content | PDFs could contain any PII — health, financial, legal. Skill should flag systemically. | user_content (catch-all) |
| `Recipient.token` | Access token for document — authentication vs. session_data | authentication, session_data |
| `User.avatarImageId` | Reference to an image — biometric (face photo) vs. identifier | biometric, identifier |

## Red Herrings

| Item | Why It Looks Like PII | Why It's Not |
|------|----------------------|-------------|
| `Envelope.qrToken` | Looks like a personal access token | Certificate verification token for public QR codes — not linked to a specific person's identity |
| `Field.customText` before signing | Looks like it always contains PII | Before signing, contains creator-set label text. After signing, populated with user-entered values (via `envelope-signing.ts`). Flagging unfilled fields as PII is overly broad. |
| `TemplateDirectLink.token` | Looks like a personal authentication token | Public template access token — not tied to a specific user |
| `Passkey.counter` | Stored per-user | WebAuthn security counter — not PII, purely a replay attack prevention mechanism |
