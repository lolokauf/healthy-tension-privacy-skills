# CCPA Review — B2B SaaS Example

A worked example demonstrating the CCPA review skill applied to a B2B SaaS application with minimal consumer-facing surface. Shows that B2B does not mean CCPA-exempt.

---

## Input Description

A B2B SaaS project management tool with:

- **User accounts:** Email/password registration, SSO via Google Workspace, profile with name, email, avatar, job title, company
- **Payments:** Stripe for subscription billing (business credit card, billing contact)
- **Monitoring:** Datadog APM for application performance monitoring (request traces, error tracking)
- **Analytics:** No advertising pixels, no marketing trackers
- **Email:** SendGrid for transactional emails only (password reset, billing alerts)
- **Customer data:** Customers store project data, task descriptions, file attachments, comments (user-generated content)
- **Employee data:** HR admin module allows customers to import employee rosters (name, email, department, role)
- **Website:** Marketing site with contact form, blog with comments, cookie consent banner
- **Privacy policy** exists, mentions CCPA, but does not include a DNSSOPI link
- **GPC handling:** Not implemented

---

## Expected Output

### CCPA/CPRA Compliance Review — B2B Project Management SaaS

#### Summary
- **PI categories found:** 5 of 11
- **Sensitive PI present:** yes — login credentials (password hashes, SSO tokens)
- **Sale/sharing relationships:** 0 confirmed
- **Consumer rights implemented:** 2 of 6 (partial right to know, partial right to delete)
- **DNSSOPI link present:** no
- **GPC handling:** not implemented

#### Section 1: PI Classification (key rows)

| Data Element | CCPA Category | Sensitive PI? | Source | Purpose | Confidence |
|-------------|---------------|---------------|--------|---------|------------|
| users.email | 1. Identifiers | No | POST /api/auth/register, Google SSO | Account authentication | HIGH |
| users.passwordHash | 1. Identifiers | Yes (login credentials) | POST /api/auth/register | Authentication | HIGH |
| users.ssoToken | 1. Identifiers | Yes (login credentials) | Google SSO callback | SSO authentication | HIGH |
| users.name | 2. Customer records | No | Registration, SSO profile | Account identification | HIGH |
| users.jobTitle | 9. Professional/employment | No | Profile settings | Display, permissions | HIGH |
| users.company | 9. Professional/employment | No | Registration | Multi-tenant routing | HIGH |
| billing.cardLast4 | 2. Customer records | No | Stripe webhook | Billing display | HIGH |
| employeeRoster.* | 9. Professional/employment | No | CSV import, HR admin module | Customer HR workflows | HIGH |
| contactForm.email | 1. Identifiers | No | POST /api/contact | Lead capture | HIGH |
| contactForm.message | 8. Sensory data (electronic) | No | POST /api/contact | Sales inquiry | MEDIUM |
| website.visitorIP | 1. Identifiers | No | Server access logs | Security, rate limiting | HIGH |

#### Section 2: Sale/Sharing Assessment

| Vendor | Data Transmitted | CCPA Classification | Evidence | SP Exception Applicable? | Confidence |
|--------|-----------------|---------------------|----------|--------------------------|------------|
| Stripe | Billing contact email, card details (via Stripe.js — card data never touches server) | SERVICE_PROVIDER | Server-side Stripe SDK for subscription management; card tokenised client-side | Yes — Stripe's standard agreement includes SP restrictions; processes payments on behalf of business only | MEDIUM |
| Datadog | Request traces (URLs, response times, error stack traces), server IP | SERVICE_PROVIDER | `dd-trace` Node.js package initialised in `server.ts`; APM data sent to Datadog for monitoring | Yes — Datadog's standard DPA includes SP-qualifying restrictions; processes data for customer's monitoring purposes only | MEDIUM |
| SendGrid | Recipient email, email subject, email body | SERVICE_PROVIDER | `sgMail.send()` in `email-service.ts`; transactional emails only (no marketing) | Yes — SendGrid's standard DPA includes SP restrictions for transactional email | MEDIUM |
| Google (SSO) | OAuth token exchange, user profile (name, email, avatar) | SERVICE_PROVIDER | Google Workspace SSO for authentication; no data shared back to Google beyond OAuth flow | Yes — Google Workspace agreement includes SP terms for SSO functionality | MEDIUM |

**No sale or sharing relationships identified.** All vendors process PI on behalf of the business under contracts that likely qualify for SP exception. Confidence is MEDIUM because contract terms require legal review to confirm.

#### Section 3: Consumer Rights Matrix

| Right | Endpoint Exists? | Functional? | Identity Verification | Response Timeline | Gaps | Severity | Confidence |
|-------|-----------------|-------------|----------------------|-------------------|------|----------|------------|
| Right to Know | Partial | Partial | Session auth | N/A (no formal flow) | Profile page shows own data but no formal request endpoint; no third-party disclosures; employee roster data not included | HIGH | HIGH |
| Right to Delete | Partial | Partial | Session auth | N/A (no formal flow) | Account deletion exists but does not purge: Datadog traces, SendGrid logs, employee roster data uploaded by other users | HIGH | HIGH |
| Right to Correct | No | No | N/A | N/A | Profile edit exists but no formal correction request mechanism for data the user cannot self-edit (e.g., employee roster entries) | MEDIUM | HIGH |
| Right to Opt-Out | N/A | N/A | N/A | N/A | No current sale/sharing — but no mechanism exists if future integrations introduce sale/sharing | MEDIUM | MEDIUM |
| Limit Sensitive PI | No | No | N/A | N/A | Login credentials (password hashes, SSO tokens) collected with no limitation mechanism | MEDIUM | HIGH |
| Non-Discrimination | N/A | N/A | N/A | N/A | No sale/sharing to opt out of — cannot assess discrimination | LOW | MEDIUM |
| Minors | N/A | N/A | N/A | N/A | B2B product — no minor-facing surface | LOW | HIGH |

#### Section 4: Vendor Classification

| Vendor | CCPA Role | Contract Type | Data Access | Sub-contractors | Confidence |
|--------|-----------|---------------|-------------|-----------------|------------|
| Stripe | SERVICE_PROVIDER | SP agreement (standard) | Payment card data, billing contact | AWS (hosting) | MEDIUM |
| Datadog | SERVICE_PROVIDER | SP agreement (DPA) | Request traces, server metadata | AWS, GCP (infrastructure) | MEDIUM |
| SendGrid | SERVICE_PROVIDER | SP agreement (DPA) | Recipient email, message content | Twilio infrastructure | MEDIUM |
| Google Workspace | SERVICE_PROVIDER | SP agreement (Workspace) | OAuth profile data | Google infrastructure | MEDIUM |

#### Section 5: Notice & Disclosure Audit

**Privacy Notice:**
- Present: yes
- Categories of PI disclosed: partial — does not list employee roster data or website visitor IP
- Third parties disclosed: partial — mentions Stripe but not Datadog or SendGrid

**DNSSOPI Link:**
- Present: no
- Severity: **MEDIUM** — no current sale/sharing, but defensive measure protects against future integrations introducing sale/sharing without corresponding opt-out

**GPC Handling:**
- `Sec-GPC` header detected: no
- Severity: **MEDIUM** — no current sale/sharing to opt out of, but GPC handling should be implemented defensively

**Financial Incentive Notices:**
- N/A — no financial incentives identified

#### Section 6: Recommended Fixes (top items)

1. **[BLOCKING]** Expand account deletion to purge user data from Datadog (traces containing user identifiers), SendGrid (email logs), and employee roster entries — HIGH, HIGH confidence
2. **[BLOCKING]** Implement formal right-to-know request endpoint that returns all PI categories including employee roster data and third-party disclosures — HIGH, HIGH confidence
3. Add DNSSOPI link as a defensive measure — if any future integration introduces sale/sharing, the opt-out mechanism is already in place — MEDIUM, MEDIUM confidence
4. Implement GPC signal detection (`Sec-GPC` header check) as a defensive measure — MEDIUM, MEDIUM confidence
5. Update privacy notice to disclose all PI categories (including employee roster data, website visitor IP) and all service providers (Datadog, SendGrid) — MEDIUM, HIGH confidence
6. Add "Limit the Use of My Sensitive Personal Information" link — login credentials qualify as sensitive PI — MEDIUM, HIGH confidence
7. Implement formal correction request mechanism for data users cannot self-edit (employee roster entries created by admins) — MEDIUM, HIGH confidence

---

## Key Findings Demonstrated

| Finding | Step | Why It Matters |
|---------|------|---------------|
| B2B does not mean CCPA-exempt | Step 1 | Employee data (HR roster imports), website visitor data (contact form, IP logs), and billing contact data are all PI under CCPA. A B2B SaaS with no consumer-facing product still collects PI from employees, website visitors, and billing contacts. |
| Clean vendor stack still has findings | Step 3 | Even with no advertising pixels, every vendor relationship needs SP contract verification. All four vendors are classified MEDIUM confidence because contract terms require legal review. |
| DNSSOPI link as defensive measure | Step 6 | No current sale/sharing means a missing DNSSOPI link is MEDIUM severity, not CRITICAL. But recommending it defensively protects the business — adding an advertising pixel later without remembering to add the opt-out link is a common compliance failure. |
| Employee roster data is PI | Step 2 | Customer-uploaded employee rosters (name, email, department) are PI under CCPA. The business processes this PI and must include it in right-to-know responses and account deletion flows. This is frequently overlooked in B2B applications. |
| Login credentials as sensitive PI | Step 2 | Even a "clean" B2B app collects sensitive PI via password hashes and SSO tokens (§1798.140(ae)(C)). This triggers the right to limit use of sensitive PI — a requirement most B2B applications have not implemented. |
