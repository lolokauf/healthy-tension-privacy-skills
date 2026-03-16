# Target Notes: Documenso

## Description

Documenso is an open-source document signing platform (DocuSign alternative). Built with Next.js (Remix), Prisma, TypeScript, and PostgreSQL. Production product with real users, self-hosted and cloud-hosted variants.

## Why This Eval?

Document signing is inherently high-PII: legal signatures, recipient personal data, uploaded documents that may contain any category of PII. The codebase has:

- **Rich Prisma schema** with 20+ models, many PII-bearing (users, recipients, signatures, audit logs)
- **Multiple third-party integrations**: Stripe, PostHog, email services (Resend/Mailchannels/SMTP/SES), Google Vertex AI, S3 storage, OAuth providers
- **Complex data flows**: document upload → storage → recipient notification → signing → audit trail → webhook forwarding
- **Non-account users**: recipients can sign without creating accounts, creating interesting consent questions
- **Audit logging**: IP addresses, user agents, and actor identity captured for all events

## Special Considerations

- **Document contents are user-uploaded** and may contain any category of PII (health data, financial data, legal information). Skills should flag this as a systemic consideration rather than trying to enumerate every possible PII field within uploaded documents.
- **Document signing creates legal obligations** — privacy findings here have real regulatory weight (eIDAS for electronic signatures, GDPR Art. 6(1)(b) contract basis for processing signer data).
- **Recipient ≠ user** — many recipients interact via token-based links without accounts. The skill should distinguish between account-holder PII and recipient PII.
- **Self-hosted vs. cloud** — some integrations (telemetry, billing) behave differently in self-hosted mode. The skill should evaluate based on what the code enables, not just cloud defaults.
- **Soft deletes for documents** — documents use `deletedAt` for logical deletion but data is retained. This is a deliberate design choice for legal compliance (signed documents may need to be preserved), not necessarily a privacy failing — but the skill should note the tradeoff.

## Stack Summary

| Component | Technology |
|-----------|-----------|
| Framework | Remix (Next.js migration in progress) |
| ORM | Prisma |
| Database | PostgreSQL |
| Language | TypeScript |
| Auth | Custom (sessions + OAuth + Passkey + 2FA) |
| Email | Resend, Mailchannels, SMTP, AWS SES |
| Storage | Database (default), S3 (configurable) |
| Payments | Stripe |
| Analytics | PostHog |
| AI | Google Vertex AI (field detection) |
| Signing | Local or Google Cloud HSM |
