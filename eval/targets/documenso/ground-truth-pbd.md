# PbD Code Review — Ground Truth: Documenso

## Metadata
- **Target:** documenso
- **Repo:** https://github.com/documenso/documenso.git
- **Pinned commit:** 70fb834a6a5a58df3a6203fc892b30014f8647cc
- **Stack:** Remix (Next.js), Prisma, TypeScript, PostgreSQL
- **Date audited:** 2026-03-15
- **Audited by:** Lauren Kaufman + Claude

## Expected Findings

### Must-Find Items

These are critical findings any competent review should identify. Missing a must-find item should heavily penalise the Coverage score.

| # | Finding | Principle | Expected Severity | Expected Confidence | Reasoning | Acceptable Alternatives |
|---|---------|-----------|-------------------|---------------------|-----------|------------------------|
| 1 | OAuth tokens (access_token, refresh_token, id_token) stored plaintext in Account table | 5 (End-to-End Security) | CRITICAL | HIGH | OAuth tokens are long-lived credentials stored unencrypted in PostgreSQL. Compromise of database exposes all OAuth sessions. | HIGH severity acceptable if reviewer notes the tokens are at least database-access-gated |
| 2 | Recipient signing tokens stored plaintext in database | 5 (End-to-End Security) | HIGH | HIGH | Recipient.token grants document access without further authentication. Plaintext storage means database read access = document access for all recipients. | CRITICAL acceptable — depends on whether reviewer considers this equivalent to a session token |
| 3 | 2FA secrets and backup codes stored plaintext | 5 (End-to-End Security) | CRITICAL | HIGH | twoFactorSecret and twoFactorBackupCodes stored unencrypted. Database compromise completely defeats 2FA. | HIGH acceptable |
| 4 | Document visibility defaults to EVERYONE | 2 (Privacy as Default) | HIGH | HIGH | Envelope.visibility defaults to EVERYONE (all team members). Most permissive option is the default — violates privacy-by-default. Should default to ADMIN or MANAGER_AND_ABOVE. | MEDIUM acceptable if reviewer notes this is configurable |
| 5 | No data retention policy — documents and audit logs retained indefinitely | 5 (End-to-End Security) | HIGH | HIGH | No automatic purge of soft-deleted documents, expired tokens, or audit logs. Documents use deletedAt but are never hard-deleted. Sessions/tokens expire but records persist. | MEDIUM acceptable if reviewer notes soft delete as partial mitigation |
| 6 | Signature images (signatureImageAsBase64) stored plaintext | 5 (End-to-End Security) | HIGH | HIGH | Drawn signatures are biometric data stored as unencrypted base64 strings. No field-level encryption. | MEDIUM acceptable if reviewer doesn't classify signatures as biometric |
| 7 | Audit logs capture IP addresses and user agents for all events | 1 (Proactive) | MEDIUM | HIGH | Both UserSecurityAuditLog and DocumentAuditLog capture IP + user agent without consent. This is overcollection for most use cases. | HIGH severity acceptable if reviewer considers this a data minimisation violation |
| 8 | No data export / portability feature | 7 (Respect for User Privacy) | HIGH | HIGH | No bulk data export endpoint. Users can download individual documents but cannot export their complete data (GDPR Art. 20 right to data portability). | MEDIUM acceptable — document download is partial compliance |
| 9 | Webhook payloads forward full recipient PII to external URLs | 6 (Transparency) | HIGH | HIGH | WebhookCall sends recipient names, emails, tokens, signing status to user-configured URLs. No per-event consent or data minimisation — full payload always sent. | MEDIUM acceptable if reviewer notes webhooks are user-configured |
| 10 | PostHog analytics enabled by default, no user opt-out | 2 (Privacy as Default) | HIGH | HIGH | Analytics controlled via env var only. No user-facing preference to opt out. Telemetry for self-hosted instances enabled by default. | MEDIUM acceptable if reviewer notes the env var toggle |
| 11 | DKIM private keys stored plaintext in database | 5 (End-to-End Security) | CRITICAL | HIGH | EmailDomain.privateKey stores cryptographic private keys unencrypted. Should use KMS/HSM or at minimum field-level encryption. | — |
| 12 | OIDC client secret stored plaintext in database | 5 (End-to-End Security) | HIGH | HIGH | OrganisationAuthenticationPortal.clientSecret stored unencrypted. Compromise enables SSO impersonation. | CRITICAL acceptable |

### Nice-to-Find Items

Deeper findings that demonstrate thoroughness. Not required for a passing score.

| # | Finding | Principle | Expected Severity | Expected Confidence | Reasoning |
|---|---------|-----------|-------------------|---------------------|-----------|
| 1 | Google Vertex AI processes document content without explicit user consent | 1 (Proactive) | MEDIUM | MEDIUM | Document content sent to Google for field detection. No opt-in toggle; feature runs transparently. |
| 2 | Webhook secret can be null — payloads sent unsigned | 5 (End-to-End Security) | MEDIUM | HIGH | Webhook.secret is optional. If not set, payloads lack HMAC signature, enabling forgery. |
| 3 | Session lifetime is 30 days with auto-extension | 5 (End-to-End Security) | LOW | HIGH | Long session lifetime (30 days, extends if active within 15 days). Standard for SaaS but notable. |
| 4 | JSON fields (formValues, authOptions, requestBody) lack schema validation | 3 (Embedded in Design) | MEDIUM | MEDIUM | Multiple JSON fields store potentially sensitive data without strict type enforcement. |
| 5 | Cookie-based preferences set without explicit consent banner | 2 (Privacy as Default) | MEDIUM | MEDIUM | Theme and language cookies set automatically. May require consent under ePrivacy Directive. |
| 6 | Recipients have no unsubscribe mechanism | 7 (Respect for User Privacy) | MEDIUM | HIGH | Recipients cannot opt out of future signing invitations from a sender. No block/unsubscribe. |
| 7 | Full-text search indexes on recipient name and email | 3 (Embedded in Design) | LOW | HIGH | PostgreSQL gin_trgm_ops indexes enable efficient PII search. Useful feature but increases queryable PII surface. |
| 8 | Envelope.formValues stores user-entered data in unencrypted JSON | 5 (End-to-End Security) | MEDIUM | MEDIUM | Signer responses stored in schemaless JSON without encryption. Content depends on form design. |

### Expected Severity Distribution

Approximate expected counts. The skill's distribution should be in the same ballpark.

- **CRITICAL:** 3 (OAuth tokens plaintext, 2FA secrets plaintext, DKIM private keys plaintext)
- **HIGH:** 6-8 (recipient tokens, default visibility, no retention, signature images, no data export, webhooks, analytics default, OIDC secret)
- **MEDIUM:** 4-6 (audit log IP collection, AI processing, JSON fields, cookies, webhook secrets, form values)
- **LOW:** 1-2 (session lifetime, search indexes)

### Expected Artifacts

The PbD Code Review skill should produce these 8 artifacts. Note key expectations for each.

| Artifact | Expected? | Key Content Expectations |
|----------|-----------|------------------------|
| PII Touchpoint Manifest | Yes | Should list 20+ PII fields across User, Recipient, Signature, Session, Account, AuditLog models |
| Default Configuration Audit | Yes | Should flag: document visibility defaults to EVERYONE, telemetry enabled by default, analytics enabled by env var |
| PII Data Flow Heatmap | Yes | Should show Prisma schema as centralised, but PII scattered across audit logs, webhook payloads, email templates, and AI calls |
| Privacy-Preserving Alternatives Table | Yes | Should suggest: token hashing for recipients, field-level encryption for OAuth tokens and signatures, data minimisation for webhook payloads |
| Data Lifecycle Table | Yes | Should flag: no retention policy on any model, soft deletes without hard-delete follow-up, expired tokens not purged |
| Transparency Audit | Yes | Should identify 7 processors (PostHog, Stripe, email service, Google Vertex AI, S3, Google Cloud HSM, OAuth providers) and note webhook forwarding |
| User Privacy Controls Checklist | Yes | Should check for: account deletion (exists), data export (missing), analytics opt-out (missing), recipient controls (rejection exists, unsubscribe missing) |
| Delete-My-Account Trace | Yes | Should trace: User cascade delete → Account, Session, Passkey, VerificationToken, ApiToken, AuditLogs, Envelopes. Note: webhook call history, audit logs may persist |

### Known Ambiguities

Findings where reasonable reviewers might disagree. The skill should not be penalised for either interpretation.

| Finding | Why It's Ambiguous | Acceptable Interpretations |
|---------|-------------------|---------------------------|
| Audit log IP/UA collection | Security teams want comprehensive audit trails; privacy teams want data minimisation | HIGH (overcollection violates minimisation) or MEDIUM (standard security practice) |
| Signature as biometric data | Legal classification varies by jurisdiction. GDPR Art. 9 may apply to handwritten/drawn signatures. | Biometric (special category, CRITICAL handling required) or user_content (standard PII) |
| Soft delete for documents | Legal hold requirements may mandate retention of signed documents. Privacy demands deletion. | Privacy violation (no hard delete) or acceptable design (legal compliance) — skill should note the tradeoff |
| Webhook data forwarding | User configures webhooks voluntarily, but may not understand full payload contents | HIGH (undisclosed PII sharing) or MEDIUM (user-initiated) |
| Recipient token security | Tokens are single-use-ish access credentials, but they don't grant account-level access | CRITICAL (equivalent to session hijacking) or HIGH (scoped document access) |

### Red Herrings

Things that look like privacy issues but are not. If the skill flags these, it's a false positive.

| Item | Why It Looks Like an Issue | Why It's Not |
|------|--------------------------|-------------|
| `Envelope.qrToken` | Looks like a personal access token that should be hashed | It's a public certificate verification token for QR codes. Not tied to a person's identity. Hashing would break the verification flow. |
| `ApiToken.token` stored in database | Looks like plaintext credential storage | API tokens are SHA512-hashed before storage (verified in `create-api-token.ts`). Only the hash is persisted; plaintext returned once at creation. This is correct practice. |
| `Field.customText` after signing | Stores user-entered field values (names, dates, text responses) — clearly PII | This IS PII (user_content) and correctly flagging it is valid. However, before signing it contains creator-set labels. Skill should flag it as PII with note about dual purpose. Not a red herring — moved to nice-to-find. |
| `Passkey.credentialPublicKey` as biometric data | WebAuthn credential stored in database | Public key material is not biometric data. It's a cryptographic artifact. The actual biometric (fingerprint, face) never leaves the user's device. |
| XChaCha20-Poly1305 encryption in `crypto.ts` | Might suggest documents are encrypted | This is used for secondary data encryption (tokens, verification codes). Documents themselves are not encrypted with this mechanism. Not a false positive to flag document encryption as missing, but flagging "no encryption exists" would be wrong — partial encryption is implemented. |
