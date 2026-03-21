# CCPA/CPRA Compliance Report Template

Blank template for the ccpa-review skill's output. Complete all sections — use "None identified", "N/A", or "Unknown" rather than leaving sections empty.

---

## CCPA/CPRA Compliance Review — [Project/Repo identifier]

<!-- Replace [Project/Repo identifier] with the project name, PR number, or repository path. -->

### Summary

<!-- High-level compliance snapshot. Fill all fields. -->

- **PI categories found:** [count] of 11
- **Sensitive PI present:** [yes/no — list categories if yes]
- **Sale/sharing relationships:** [count] identified
- **Consumer rights implemented:** [count] of 6
- **DNSSOPI link present:** [yes/no]
- **GPC handling:** [implemented / not implemented / partial]
- **Applicability signals:** [brief note from Step 1, e.g., "Consumer table has >100K rows, enterprise pricing tier present"]

---

### Section 1: PI Classification

<!-- One row per personal data element. CCPA Category must be one of the 11 statutory categories from §1798.140(v). Sensitive PI per §1798.140(ae) — includes login credentials. -->

| Data Element | CCPA Category | Sensitive PI? | Source | Purpose | Confidence |
|-------------|---------------|---------------|--------|---------|------------|
| <!-- e.g., users.email --> | <!-- e.g., 1. Identifiers --> | <!-- yes/no --> | <!-- e.g., POST /api/register --> | <!-- e.g., Account authentication --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | |

<!-- After the table, note any household-level data identified. -->

---

### Section 2: Sale/Sharing Assessment

<!-- One row per vendor or external data recipient. Two-phase analysis:
     Phase 1 (code patterns) = HIGH confidence.
     Phase 2 (SP exception) = typically MEDIUM confidence (requires contract review).
     CCPA Classification values: SALE, SHARING, SERVICE_PROVIDER, CONTRACTOR, UNKNOWN.
     Use CCPA-native terminology — not GDPR processor/controller. -->

| Vendor | Data Transmitted | CCPA Classification | Evidence | SP Exception Applicable? | Confidence |
|--------|-----------------|---------------------|----------|--------------------------|------------|
| <!-- e.g., Meta Pixel --> | <!-- e.g., device ID, page URL, purchase events --> | <!-- e.g., SHARING --> | <!-- e.g., fbq('track', 'Purchase') call in checkout.js --> | <!-- yes/no/requires contract review --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | |

<!-- For each SALE or SHARING classification, note whether an opt-out mechanism exists. -->

---

### Section 3: Consumer Rights Matrix

<!-- One row per right. Check both existence AND functionality.
     Response timeline: 45 days + 45-day extension for know/delete/correct; 15 business days for opt-out.
     Identity verification tiers per §7060-7064. -->

| Right | Endpoint Exists? | Functional? | Identity Verification | Response Timeline | Gaps | Severity | Confidence |
|-------|-----------------|-------------|----------------------|-------------------|------|----------|------------|
| Right to Know (§1798.100) | <!-- yes/no --> | <!-- yes/no/partial --> | <!-- e.g., email verification --> | <!-- e.g., 45 days --> | <!-- e.g., missing third-party disclosures --> | <!-- severity --> | <!-- HIGH/MEDIUM/LOW --> |
| Right to Delete (§1798.105) | | | | | | | |
| Right to Correct (§1798.106) | | | | | | | |
| Right to Opt-Out (§1798.120) | | | | | | | |
| Limit Sensitive PI (§1798.121) | | | | | | | |
| Non-Discrimination (§1798.125) | | | | | | | |
| Minors (§1798.120(d)) | <!-- N/A if no minor-facing surface --> | | | | | | |

---

### Section 4: Vendor Classification

<!-- One row per vendor. CCPA Role values: BUSINESS, SERVICE_PROVIDER, CONTRACTOR, THIRD_PARTY.
     Contract type: SP agreement, contractor agreement, DPA, terms of service, none, unknown.
     Vendor classification confidence is typically MEDIUM (requires contract review). -->

| Vendor | CCPA Role | Contract Type | Data Access | Sub-contractors | Confidence |
|--------|-----------|---------------|-------------|-----------------|------------|
| <!-- e.g., Stripe --> | <!-- e.g., SERVICE_PROVIDER --> | <!-- e.g., SP agreement --> | <!-- e.g., payment card data, billing address --> | <!-- e.g., AWS (hosting) --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | |

---

### Section 5: Notice & Disclosure Audit

#### Privacy Notice

<!-- Check for required elements per §1798.100(a): categories of PI collected, purposes, categories of third parties, consumer rights, contact info. -->

- **Present:** [yes/no]
- **Location:** [URL or file path]
- **Categories of PI disclosed:** [yes/no — matches Section 1?]
- **Purposes disclosed:** [yes/no]
- **Third parties disclosed:** [yes/no — matches Section 2?]
- **Consumer rights described:** [yes/no]
- **Contact information:** [yes/no]
- **Gaps:** [list any missing required elements]
- **Severity:** [severity]

#### DNSSOPI Link

<!-- "Do Not Sell or Share My Personal Information" link per §1798.135(a). Must be on homepage or equivalent. -->

- **Present:** [yes/no]
- **Location:** [URL, footer, settings page, etc.]
- **Functional:** [yes/no/not tested]
- **Covers both sale AND sharing:** [yes/no]
- **Gaps:** [list any issues]
- **Severity:** [severity — CRITICAL if sale/sharing exists and link is missing]

#### GPC Handling

<!-- Global Privacy Control signal per CPPA §7025. Applies to BOTH sale AND sharing. -->

- **`Sec-GPC` header detected:** [yes/no]
- **Opt-out triggered on GPC signal:** [yes/no]
- **Covers sale AND sharing:** [yes/no — §7025 requires both]
- **Conflicts with other user settings:** [describe any conflicts, e.g., user opted in but GPC says opt out]
- **Gaps:** [list any issues]
- **Severity:** [severity]

#### Financial Incentive Notices

<!-- Only applicable if loyalty programmes, discounts-for-data, or similar exist. -->

- **Financial incentives present:** [yes/no/N/A]
- **Notice provided:** [yes/no/N/A]
- **Valuation disclosed:** [yes/no/N/A]
- **Gaps:** [list any issues or "N/A — no financial incentives identified"]
- **Severity:** [severity or N/A]

---

### Section 6: Recommended Fixes (ordered by severity)

<!-- Order: CRITICAL first, then HIGH, MEDIUM, LOW. Mark blocking findings. -->

1. **[BLOCKING]** [fix description — severity, confidence]
2. **[BLOCKING]** [fix description — severity, confidence]
3. [fix description — severity, confidence]

---

### Severity Levels

| Level | Definition |
|-------|-----------|
| **CRITICAL** | PI actively sold/shared without opt-out mechanism, consumer rights non-functional, sensitive PI exposed |
| **HIGH** | Missing consumer rights endpoint, no DNSSOPI link, no GPC handling, vendor classified as third party with no SP contract |
| **MEDIUM** | Incomplete identity verification, missing financial incentive notice, vendor contract status unknown |
| **LOW** | Documentation gap, minor notice deficiency, defensive measure recommendation |

### Confidence Levels

| Level | Definition | Action |
|-------|-----------|--------|
| **HIGH** | Unambiguous code pattern or clear statutory definition | Finding can be acted on directly |
| **MEDIUM** | Requires contract review or business context not visible in code | Review recommended before acting |
| **LOW** | Ambiguous data flow, multiple valid classifications | Consult a privacy attorney before acting |
