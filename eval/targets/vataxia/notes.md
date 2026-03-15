# Target Notes: Vataxia

## Description

Vataxia is a Django REST Framework social network API. Features include user accounts, posts, replies, private messages, voting, an internal credits/wallet system, and invitation-based signup. Built with Django 1.11 and DRF 3.6.

## Why This Is a Good Eval Target

Tests skill generalisation beyond the JavaScript/Prisma ecosystem. Django ORM models have different patterns from Prisma schemas. The codebase has substantial privacy issues typical of older projects:

- **Extensive PII exposure** — email and full name included in every API response via nested UserSerializer
- **No `on_delete` parameter** on any ForeignKey — undefined cascade behavior on user deletion
- **Security misconfigurations** — hardcoded SECRET_KEY, ALLOWED_HOSTS='*', CORS fully open
- **Private messages** stored plaintext with no encryption
- **Wallet balances** accessible without authentication
- **No privacy controls** — no blocking, muting, profile visibility settings, account deletion, or data export
- **Different ORM** — Django ORM vs. Prisma, tests whether skills can parse Python model definitions

## Special Considerations

- **Django 1.11 is EOL** (2017). All dependencies are severely outdated. Skills should flag this as a security concern, but the focus is on privacy patterns, not dependency auditing.
- **Minimal third-party integrations** — only AWS S3 for production file storage. No analytics, no payment processor, no email service. This tests whether the skill correctly reports "no processors found" vs. fabricating integrations that don't exist.
- **Internal credits system** — not a real payment processor. Wallet/Transfer models are application-internal. Skills should categorise these as financial data but note there's no external payment service.
- **Invitation-based signup** — users join via UUID invitation codes, not open registration. This is an unusual auth pattern.
- **`on_delete` omission** — Django 1.11 defaulted to `CASCADE` when `on_delete` was omitted, but this was deprecated and later made a required argument. Skills should flag the missing parameter but acknowledge CASCADE was the implicit default.

## Stack Summary

| Component | Technology |
|-----------|-----------|
| Framework | Django 1.11, Django REST Framework 3.6 |
| ORM | Django ORM |
| Database | PostgreSQL (production), SQLite (development) |
| Language | Python |
| Auth | DRF TokenAuthentication (+ Basic + Session) |
| Email | Not implemented |
| Storage | AWS S3 via django-storages (production), local filesystem (dev) |
| Payments | Internal credits system (no external processor) |
| Analytics | None |
| AI | None |
