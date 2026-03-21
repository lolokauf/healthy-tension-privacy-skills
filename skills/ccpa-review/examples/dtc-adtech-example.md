# CCPA Review — DTC E-Commerce with Adtech Example

A worked example demonstrating the CCPA review skill applied to a direct-to-consumer e-commerce application with advertising integrations.

---

## Input Description

A React + Node.js e-commerce application for a DTC skincare brand with:

- **User accounts:** Email/password registration, profile with name, address, phone, skin type quiz results
- **Payments:** Stripe integration for checkout, order history stored in PostgreSQL
- **Advertising:** Meta Pixel (`fbq()`) on all pages, Google Ads conversion tracking (`gtag()`), both fire on purchase events with order value and product IDs
- **CDP:** Segment analytics collecting user traits (email, name, purchase history) and forwarding to multiple destinations
- **Email:** Klaviyo for marketing emails, receives full user profile + purchase history from Segment
- **No DNSSOPI link** on the site
- **No GPC handling** — `Sec-GPC` header is not checked anywhere in the codebase
- **No age gate** — site sells products marketed to teenagers
- **Privacy policy** exists but does not mention "sale" or "sharing"

---

## Expected Output

### CCPA/CPRA Compliance Review — DTC Skincare E-Commerce

#### Summary
- **PI categories found:** 6 of 11
- **Sensitive PI present:** yes — login credentials (password), precise geolocation (shipping address coordinates)
- **Sale/sharing relationships:** 3 identified (Meta, Google, Klaviyo)
- **Consumer rights implemented:** 1 of 6 (partial right to know via account profile page)
- **DNSSOPI link present:** no
- **GPC handling:** not implemented

#### Section 1: PI Classification (key rows)

| Data Element | CCPA Category | Sensitive PI? | Source | Purpose | Confidence |
|-------------|---------------|---------------|--------|---------|------------|
| users.email | 1. Identifiers | No | POST /api/register | Account authentication | HIGH |
| users.passwordHash | 1. Identifiers | Yes (login credentials) | POST /api/register | Authentication | HIGH |
| users.name | 2. Customer records | No | POST /api/register | Order fulfilment | HIGH |
| users.phone | 2. Customer records | No | POST /api/register | Order notifications | HIGH |
| users.address | 2. Customer records | No | POST /api/checkout | Shipping | HIGH |
| orders.* | 4. Commercial information | No | POST /api/checkout | Transaction records | HIGH |
| skinQuiz.results | 11. Inferences | No | POST /api/quiz | Product recommendations | HIGH |
| analytics.pageViews | 6. Internet/network activity | No | Client-side tracking | Advertising optimisation | HIGH |
| analytics.deviceId | 1. Identifiers | No | Meta Pixel, Google Ads | Cross-context behavioural advertising | HIGH |
| analytics.purchaseEvent | 4. Commercial information | No | Meta Pixel, Google Ads | Conversion tracking | HIGH |

#### Section 2: Sale/Sharing Assessment (key rows)

| Vendor | Data Transmitted | CCPA Classification | Evidence | SP Exception Applicable? | Confidence |
|--------|-----------------|---------------------|----------|--------------------------|------------|
| Meta Pixel | Device ID, page URLs, purchase events (value, product IDs), fbclid cookie | **SHARING** | `fbq('track', 'Purchase', {value, content_ids})` in `checkout.tsx`; data used for cross-context behavioural advertising | No — Meta uses data for its own advertising purposes; no SP contract restricts this | HIGH |
| Google Ads | Device ID, page URLs, conversion events, gclid cookie | **SHARING** | `gtag('event', 'conversion', {value})` in `checkout.tsx`; data used for cross-context behavioural advertising | No — Google uses conversion data for ad targeting across properties | HIGH |
| Segment → Klaviyo | Email, name, purchase history, skin quiz results | **UNKNOWN** | `analytics.identify(userId, {email, name})` + `analytics.track('Order Completed')` in Segment; Klaviyo receives full profile as Segment destination | Requires contract review — Segment may qualify as SP if contract restricts purpose; Klaviyo receives PI for marketing (may be third party if used for own purposes) | MEDIUM |
| Stripe | Payment card, billing address, order details | SERVICE_PROVIDER | Stripe SDK server-side only, processes payments on behalf of business | Yes — Stripe's standard agreement includes SP terms restricting data use to payment processing | MEDIUM |

**Two-phase analysis for Meta Pixel:**
- Phase 1: Code transmits device identifiers + purchase events to Meta's servers via `fbq()`. Meta uses this data for cross-context behavioural advertising (ad targeting across Facebook, Instagram, Audience Network). This is "sharing" per §1798.140(ah).
- Phase 2: Meta's standard business terms do not include SP restrictions — Meta retains the right to use pixel data for its own advertising purposes. SP exception does not apply. Classification: **SHARING** (HIGH confidence).

**Two-phase analysis for Segment → Klaviyo:**
- Phase 1: Code transmits email, name, purchase history, and skin quiz results to Segment, which forwards to Klaviyo. Klaviyo uses data for email marketing campaigns.
- Phase 2: Segment's contract terms vary by plan — enterprise plans may include SP-qualifying restrictions. Klaviyo's standard terms may allow use of aggregated data for own purposes. Classification: **UNKNOWN** — requires contract review for both vendors (MEDIUM confidence).

#### Section 3: Consumer Rights Matrix

| Right | Endpoint Exists? | Functional? | Identity Verification | Response Timeline | Gaps | Severity | Confidence |
|-------|-----------------|-------------|----------------------|-------------------|------|----------|------------|
| Right to Know | Partial (profile page) | Partial | Session auth | N/A (no formal request flow) | No dedicated request endpoint, no third-party disclosures, no 12-month lookback | HIGH | HIGH |
| Right to Delete | No | No | N/A | N/A | No deletion endpoint; no SP notification; no Segment/Klaviyo/Meta data purge | HIGH | HIGH |
| Right to Correct | No | No | N/A | N/A | Profile edit exists but no formal correction request flow | MEDIUM | HIGH |
| Right to Opt-Out | No | No | N/A | N/A | No DNSSOPI link, no opt-out mechanism for Meta/Google sharing | CRITICAL | HIGH |
| Limit Sensitive PI | No | No | N/A | N/A | Login credentials and precise geolocation collected with no limitation mechanism | HIGH | HIGH |
| Non-Discrimination | N/A | N/A | N/A | N/A | Cannot assess — no opt-out mechanism exists to test discrimination against | MEDIUM | MEDIUM |
| Minors | No | No | N/A | N/A | No age gate; products marketed to teenagers; no opt-in for sale/sharing of minors' PI | CRITICAL | HIGH |

#### Section 6: Recommended Fixes (top items)

1. **[BLOCKING]** Implement DNSSOPI link and opt-out mechanism for Meta Pixel and Google Ads sharing — CRITICAL, HIGH confidence
2. **[BLOCKING]** Add GPC signal handling (`Sec-GPC` header detection) that suppresses Meta Pixel and Google Ads loading — HIGH, HIGH confidence
3. **[BLOCKING]** Implement age gate — products marketed to teenagers require opt-in consent for sale/sharing for consumers 13–15, parental consent for under 13 — CRITICAL, HIGH confidence
4. **[BLOCKING]** Implement account deletion endpoint that purges user data from PostgreSQL, Segment, Klaviyo, and requests deletion from Meta and Google — HIGH, HIGH confidence
5. **[BLOCKING]** Add "Limit the Use of My Sensitive Personal Information" link — login credentials and precise geolocation qualify — HIGH, HIGH confidence
6. Review Segment and Klaviyo contracts to determine whether SP exception applies; if not, classify as sale/sharing and add to opt-out mechanism — HIGH, MEDIUM confidence
7. Update privacy policy to disclose sale/sharing relationships with Meta and Google, and categories of PI shared — MEDIUM, HIGH confidence

---

## Key Findings Demonstrated

| Finding | Step | Why It Matters |
|---------|------|---------------|
| Meta Pixel = SHARING, not "analytics" | Step 3 | The function is called from an analytics wrapper, but the data flows to Meta for cross-context behavioural advertising. Code behaviour determines classification, not function names or comments. HIGH confidence because the code pattern is unambiguous. |
| Segment → Klaviyo = UNKNOWN | Step 3 | Segment is a CDP that forwards PI to downstream destinations. Whether this is a sale, sharing, or SP arrangement depends on contract terms not visible in code. MEDIUM confidence — requires contract review. |
| Missing DNSSOPI link + active sharing = CRITICAL | Step 6 | Three vendors receive PI for advertising purposes with no consumer opt-out mechanism. This is the highest-severity CCPA finding possible. |
| No age gate with teen-marketed products | Step 4 | Products marketed to teenagers trigger §1798.120(d) requirements. Without an age gate, the business has no mechanism to obtain required opt-in consent for minors' PI sale/sharing. |
| Login credentials as sensitive PI | Step 2 | §1798.140(ae)(C) includes login credentials — password hashes stored in the database qualify. This triggers the right to limit use of sensitive PI (§1798.121), which most implementations miss. |
