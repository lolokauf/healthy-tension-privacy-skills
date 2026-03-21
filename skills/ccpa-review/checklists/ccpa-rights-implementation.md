# CCPA Consumer Rights Implementation Checklist

Audit checklist for verifying implementation of the 6 CCPA consumer rights plus minors protections. For each right, check both existence (does a mechanism exist?) and functionality (does it work end-to-end?).

---

## Right to Know (§1798.100, §1798.110, §1798.115)

Consumers can request disclosure of PI collected, sources, purposes, and third parties shared with.

| Check | What to Look For | Severity if Missing |
|-------|-----------------|---------------------|
| Request endpoint exists | `GET /api/privacy/data-request`, `/api/user/data`, or equivalent | HIGH |
| Returns all PI categories | Response includes all data elements from PI Classification | HIGH |
| Includes sources and purposes | Response states where PI was collected and why | MEDIUM |
| Includes third-party disclosures | Response lists vendors PI was shared with | MEDIUM |
| Identity verification | Email verification (passwordless) or re-authentication (password-protected) per §7060 | HIGH |
| Response timeline | 45 calendar days from verifiable request, with 45-day extension if notified | HIGH |
| 12-month lookback | Response covers preceding 12 months of PI collection | MEDIUM |
| Machine-readable format | Portable, readily usable format for right-to-know requests | LOW |

---

## Right to Delete (§1798.105)

Consumers can request deletion of PI collected from them.

| Check | What to Look For | Severity if Missing |
|-------|-----------------|---------------------|
| Deletion endpoint exists | `DELETE /api/user/account`, `/api/privacy/delete`, or equivalent | HIGH |
| Deletes from all storage | Primary database, caches, backups (within reasonable timeframe), analytics, logs | HIGH |
| Notifies service providers | Deletion propagated to SPs and contractors that received PI | HIGH |
| Identity verification | Heightened verification per §7064 (more stringent than right-to-know) | HIGH |
| Response timeline | 45 calendar days, with 45-day extension if notified | HIGH |
| Handles exceptions | 9 exceptions under §1798.105(d) — applied narrowly, not as blanket retention justification | MEDIUM |
| Confirmation | Consumer notified of deletion completion | LOW |

### Deletion Exception Scope (§1798.105(d))

The 9 exceptions are narrow. Common misapplications to watch for:

1. **Transaction completion** — only applies to the specific transaction, not indefinite retention
2. **Security** — must be a specific, articulable security need, not a general "we might need it"
3. **Legal obligation** — requires an actual legal obligation, not a theoretical future need
4. **Internal uses compatible with expectations** — must be reasonably expected by the consumer based on their relationship with the business

---

## Right to Correct (§1798.106)

Consumers can request correction of inaccurate PI. CPRA addition.

| Check | What to Look For | Severity if Missing |
|-------|-----------------|---------------------|
| Correction endpoint exists | `PATCH /api/user/profile`, `/api/privacy/correct`, or equivalent | HIGH |
| Accepts documented corrections | Consumer can specify what is inaccurate and provide correct information | MEDIUM |
| Propagates corrections | Corrections forwarded to SPs and contractors | MEDIUM |
| Identity verification | Same tier as right-to-know (§7060) | HIGH |
| Response timeline | 45 calendar days, with 45-day extension if notified | HIGH |

---

## Right to Opt-Out of Sale/Sharing (§1798.120)

Consumers can direct a business to stop selling or sharing their PI.

| Check | What to Look For | Severity if Missing |
|-------|-----------------|---------------------|
| Opt-out mechanism exists | DNSSOPI link, toggle, preference centre, or API endpoint | CRITICAL |
| Covers both sale AND sharing | Opt-out applies to sale (§1798.140(ad)) and sharing for advertising (§1798.140(ah)) | CRITICAL |
| GPC signal honoured | `Sec-GPC: 1` header detected and treated as valid opt-out per §7025 | HIGH |
| No account required | Opt-out must not require account creation | HIGH |
| Effective within 15 business days | Sale/sharing ceases within 15 business days of request | HIGH |
| No dark patterns | Opt-out path is not more burdensome than opt-in per §7004 | MEDIUM |
| Re-opt-in wait period | If consumer opts out then opts back in, at least 12 months before asking to opt in again | LOW |

---

## Right to Limit Use of Sensitive PI (§1798.121)

Consumers can limit a business's use of sensitive PI to what is necessary. CPRA addition.

| Check | What to Look For | Severity if Missing |
|-------|-----------------|---------------------|
| Limitation mechanism exists | "Limit the Use of My Sensitive Personal Information" link or toggle | HIGH (if sensitive PI collected) |
| Sensitive PI identified | Sensitive PI fields flagged per §1798.140(ae) — includes login credentials | HIGH |
| Use limited to necessary purposes | Processing restricted to purposes listed in §7027(l) after limitation | HIGH |
| Identity verification | Same tier as right-to-know (§7060) | MEDIUM |

---

## Non-Discrimination (§1798.125)

Consumers must not be penalised for exercising CCPA rights.

| Check | What to Look For | Severity if Missing |
|-------|-----------------|---------------------|
| No service degradation | Exercising rights does not trigger account restrictions, price increases, or feature removal | HIGH |
| No retaliatory patterns | Opt-out does not redirect to degraded experience | HIGH |
| Financial incentive notice | If offering incentives for PI (discounts, loyalty programmes), notice per §1798.125(b) | MEDIUM |
| Incentive valuation | Financial incentive reasonably related to value of PI per §1798.125(b)(4) | LOW |

---

## Minors (§1798.120(d))

Additional protections for consumers under 16.

| Check | What to Look For | Severity if Missing |
|-------|-----------------|---------------------|
| Age gate mechanism | Age verification or collection for users who may be under 16 | HIGH (if consumer-facing) |
| Opt-in for 13–15 | Sale/sharing of PI for consumers 13–15 requires affirmative opt-in | CRITICAL (if applicable) |
| Parental consent for <13 | Sale/sharing of PI for consumers under 13 requires parental consent | CRITICAL (if applicable) |
| No default sale/sharing for minors | PI of known minors is not sold/shared unless opted in | CRITICAL (if applicable) |

---

## Identity Verification Tiers (§7060–§7064)

Match verification stringency to the right being exercised:

| Right | Verification Tier | Minimum Method |
|-------|-------------------|----------------|
| Right to know (categories) | Reasonable | Email verification |
| Right to know (specific pieces) | Reasonably high | Email + re-authentication or security questions |
| Right to delete | Reasonably high | Email + re-authentication |
| Right to correct | Reasonable | Email verification |
| Right to opt-out | None required | No account or verification needed |
| Right to limit sensitive PI | Reasonable | Email verification |

Passwordless accounts (no stored credentials): email-based verification is sufficient for "reasonable" tier. For "reasonably high" tier, additional factors are needed (e.g., verification code + account-specific knowledge).
