# Target Notes: Open SaaS

## Description

Open SaaS is a Wasp-based SaaS boilerplate with integrated payments, file uploads, AI features, and admin dashboard. Built with Wasp (generates React + Node.js + Prisma), TypeScript, and PostgreSQL. Designed as a production-ready starter kit for SaaS products.

## Why This Is a Good Eval Target

Represents what many early-stage SaaS products actually ship — a boilerplate with real integrations but minimal privacy engineering. Tests whether skills can identify common startup privacy gaps:

- **Multiple payment processors** (Stripe, Lemon Squeezy, Polar) with customer data
- **AI integration** (OpenAI) sending user task data to third-party LLM
- **File upload** to AWS S3 with user ID in storage key
- **Analytics** (Plausible + Google Analytics) with flawed consent enforcement
- **Admin dashboard** exposing user PII without audit logging
- **No cascade deletes** — user deletion leaves orphaned records everywhere
- **No account deletion or data export** — GDPR Art. 17/20 gaps

## Special Considerations

- **Wasp framework** handles auth internally — passwords, sessions, and tokens are managed by the framework and not directly visible in the Prisma schema. Skills should note this rather than flagging "missing password handling."
- **Boilerplate nature** — some integrations are commented out (Google/GitHub/Discord OAuth). The skill should evaluate what's enabled by default vs. optional. Commented-out code still reveals the intended integration surface.
- **Demo AI app** — the GPT integration is a demo feature (daily schedule generator). Skills should still flag the PII sent to OpenAI even though it's a demo.
- **Cookie consent exists but is incomplete** — Google Analytics is behind opt-in consent, but Plausible is loaded unconditionally in `main.wasp`. This split is a nuanced finding.

## Stack Summary

| Component | Technology |
|-----------|-----------|
| Framework | Wasp (generates React + Express + Prisma) |
| ORM | Prisma (via Wasp) |
| Database | PostgreSQL |
| Language | TypeScript |
| Auth | Wasp built-in (email/password + OAuth) |
| Email | SendGrid (configurable), Dummy (dev default) |
| Storage | AWS S3 (presigned URLs) |
| Payments | Stripe (primary), Lemon Squeezy, Polar |
| Analytics | Plausible, Google Analytics (optional) |
| AI | OpenAI GPT-3.5-turbo |
