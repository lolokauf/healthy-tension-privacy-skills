# PbD Code Review — Express API Example

A worked example demonstrating the PbD Code Review skill applied to a typical Express API backend.

---

## Input Description

A Node.js/Express API backend for a SaaS product with:

- **User auth:** Email/password registration, bcrypt password hashing, JWT sessions
- **Database:** PostgreSQL via Prisma ORM, `users` table with email, passwordHash, name, phone, createdAt
- **Payments:** Stripe integration (Stripe.js + server-side API), `stripeCustomerId` stored in users table
- **Analytics:** PostHog SDK initialised server-side, tracking user events with userId
- **Email:** Sendgrid for transactional emails (welcome, password reset)
- **Logging:** Winston logger, default config logs request bodies to file
- **Config:** `analytics_enabled: true`, `data_sharing: "all_partners"` in defaults
- **No existing data inventory or privacy policy documentation**

---

## Expected Output

### Privacy Review Report

```markdown
## Privacy-by-Design Review — SaaS API Backend

### Summary
- **PII fields introduced/modified:** 5 (email, passwordHash, name, phone, stripeCustomerId)
- **New third-party dependencies:** 3 (Stripe, PostHog, Sendgrid)
- **Privacy risk score:** HIGH
- **Blocking findings:** 4

### Findings by Principle

| # | Principle | Finding | Severity | Confidence | Blocking? |
|---|-----------|---------|----------|------------|-----------|
| 1 | Proactive | `phone` field collected with no documented purpose | HIGH | HIGH | Yes |
| 2 | Default Setting | `analytics_enabled` defaults to `true` (opt-out) | HIGH | HIGH | Yes |
| 2 | Default Setting | `data_sharing` defaults to `"all_partners"` | HIGH | HIGH | Yes |
| 3 | Embedded in Design | Raw email accessed directly in 4 route handlers outside auth module | MEDIUM | HIGH | No |
| 4 | Positive-Sum | PostHog tracks events with raw userId; no aggregation or pseudonymisation | LOW | MEDIUM | No |
| 5 | Full Lifecycle | No retention policy for any PII field | HIGH | HIGH | Yes |
| 5 | Full Lifecycle | Winston logs request bodies containing PII (email, phone) to file | CRITICAL | HIGH | Yes |
| 6 | Transparency | No data inventory exists; Stripe, PostHog, Sendgrid undocumented | MEDIUM | HIGH | No |
| 7 | User-Centric | No account deletion endpoint; no data export mechanism | HIGH | HIGH | Yes |

### Recommended Fixes (ordered by severity)

1. **[BLOCKING]** Add PII log scrubbing — configure Winston to redact email, phone, and password fields from request body logging
2. **[BLOCKING]** Remove `phone` field or add documented purpose justification
3. **[BLOCKING]** Change `analytics_enabled` default to `false` and `data_sharing` to `"none"`
4. **[BLOCKING]** Define retention policies for all PII fields (email, name, phone, stripeCustomerId)
5. **[BLOCKING]** Implement account deletion endpoint that purges users table, Stripe customer, PostHog person, and Sendgrid contact
6. Route email access through a dedicated user data service instead of direct Prisma queries in route handlers
7. Create a `data_inventory.yaml` documenting all PII fields and third-party processors
8. Consider pseudonymised user IDs for PostHog events instead of raw userId

### Generated Artifacts

- PII Touchpoint Manifest (5 fields)
- Default Configuration Audit (2 FAIL)
- PII Data Flow Heatmap (4 modules flagged)
- Privacy-Preserving Alternatives Table (1 alternative identified)
- Data Lifecycle Table (5 fields, all FAIL on retention)
- Transparency Audit (3 undocumented processors)
- User Privacy Controls Checklist (0 of 4 controls implemented)
- Delete-My-Account Trace (no deletion path exists)
```

---

## Key Findings Demonstrated

| Finding | Principle | Why It Matters |
|---------|-----------|---------------|
| Analytics defaults to opt-out | Principle 2 | Violates "privacy as default" — users must take action to protect their data |
| PII in log files | Principle 5 | Winston logging request bodies is a common pattern that silently leaks PII to disk. HIGH confidence because the logging config is unambiguous. |
| No data inventory | Principle 6 | With 3 third-party processors (Stripe, PostHog, Sendgrid), there is no documentation of what data leaves the system. MEDIUM severity because the risk is indirect (documentation gap, not active harm). |
| No account deletion | Principle 7 | Users cannot exercise their right to erasure. This is a blocking finding under GDPR Art. 17 and CCPA §1798.105. |
