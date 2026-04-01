# Privacy Notice Section Requirements

Mandatory disclosure items per jurisdiction. Use this checklist to verify that the generated privacy notice covers all legally required elements. Items marked **Must disclose** are required by the cited provision; items marked **Best practice** are recommended but not strictly mandatory.

---

## GDPR Art. 13 — Direct Collection

When personal data is collected directly from the data subject, the notice must include:

| # | Disclosure Item | GDPR Article | Must Disclose | Code Pattern to Check |
|---|----------------|-------------|---------------|----------------------|
| 1 | Controller identity and contact details | Art. 13(1)(a) | Yes | Config files, contact pages, `about` routes |
| 2 | DPO contact details (if appointed) | Art. 13(1)(b) | Yes (if DPO exists) | DPO config, privacy page templates |
| 3 | Purposes of processing | Art. 13(1)(c) | Yes | All processing activities from data inventory |
| 4 | Legal basis for each purpose | Art. 13(1)(c) | Yes | Consent flows, contract logic, LI assessments |
| 5 | Legitimate interests pursued (if Art. 6(1)(f)) | Art. 13(1)(d) | Yes (if LI basis) | Analytics, fraud detection, security logging |
| 6 | Recipients or categories of recipients | Art. 13(1)(e) | Yes | Third-party API calls, SDK integrations, processors |
| 7 | International transfer details + safeguards | Art. 13(1)(f) | Yes (if transfers) | Cloud provider regions, API endpoints, CDN configs |
| 8 | Retention period or criteria | Art. 13(2)(a) | Yes | TTL configs, deletion logic, retention policies |
| 9 | Data subject rights (access, rectification, erasure, restriction, portability, objection) | Art. 13(2)(b) | Yes | Rights endpoints, DSAR forms, account settings |
| 10 | Right to withdraw consent | Art. 13(2)(c) | Yes (if consent basis) | Consent revocation flows, preference centres |
| 11 | Right to lodge complaint with supervisory authority | Art. 13(2)(d) | Yes | Static notice text (not code-detectable) |
| 12 | Whether provision is statutory/contractual requirement | Art. 13(2)(e) | Yes | Required fields, validation rules, form asterisks |
| 13 | Automated decision-making including profiling | Art. 13(2)(f) | Yes (if applicable) | ML models, scoring functions, automated approval/denial |

## GDPR Art. 14 — Indirect Collection

All Art. 13 items above, plus:

| # | Additional Item | GDPR Article | Must Disclose | Code Pattern to Check |
|---|----------------|-------------|---------------|----------------------|
| 14 | Categories of personal data obtained | Art. 14(1)(d) | Yes | Third-party API response schemas, data enrichment |
| 15 | Source of data (public or private) | Art. 14(2)(f) | Yes | Third-party API integrations, data import functions |

**Timing:** Art. 14(3) — within 1 month of obtaining data, at first communication with data subject, or before disclosure to another recipient (whichever is earliest).

---

## CCPA §1798.100(a) — Consumer Privacy Notice

| # | Disclosure Item | CCPA Section | Must Disclose | Code Pattern to Check |
|---|----------------|-------------|---------------|----------------------|
| 1 | Categories of PI collected | §1798.100(a)(1) | Yes | All data elements mapped to 11 CCPA PI categories |
| 2 | Purposes for each PI category | §1798.100(a)(2) | Yes | Processing activities linked to PI categories |
| 3 | Categories of sources | §1798.100(a)(3) | Yes | Collection points (forms, APIs, SDKs, automatic) |
| 4 | Categories of third parties disclosed to | §1798.100(a)(4) | Yes | Third-party API calls, vendor integrations |
| 5 | Specific pieces of PI collected | §1798.100(a)(5) | Yes (on request) | Individual data fields from inventory |
| 6 | Whether PI is sold or shared | §1798.140(ad)/(ah) | Yes | Advertising pixels, cross-context behavioural ad code |
| 7 | Retention period per PI category | §1798.100(a) (CPRA) | Yes | TTL configs, deletion logic per data type |
| 8 | Consumer rights descriptions | §1798.100(a) | Yes | Rights endpoints, DSAR mechanism |
| 9 | DNSSOPI link | §1798.135(a) | Yes (if sale/sharing) | Opt-out endpoint, GPC handling |
| 10 | Sensitive PI disclosure | §1798.121 | Yes (if applicable) | Login credentials, precise geolocation, biometrics |

---

## LGPD Art. 9 — Titular Information Rights

| # | Disclosure Item | LGPD Article | Must Disclose | Code Pattern to Check |
|---|----------------|-------------|---------------|----------------------|
| 1 | Specific purpose of processing | Art. 9(I) | Yes | All processing activities with stated purposes |
| 2 | Form and duration of processing | Art. 9(II) | Yes | Processing methods (automated/manual), retention |
| 3 | Controller identification | Art. 9(III) | Yes | Legal entity info in configs or templates |
| 4 | Controller contact information | Art. 9(IV) | Yes | Contact endpoints, privacy page |
| 5 | Information on shared use of data | Art. 9(V) | Yes | Third-party integrations, vendor relationships |
| 6 | Purpose of sharing and description of receiving agents | Art. 9(V) | Yes | Processor/vendor details, API documentation |
| 7 | Responsibilities of processing agents | Art. 9(VI) | Yes | Processor agreements (code references limited) |
| 8 | Rights of the titular | Art. 9(VII) → Art. 18 | Yes | Rights endpoints, DSAR forms |
| 9 | International transfer details | Art. 33–36 | Yes (if transfers) | Cloud hosting regions, third-party API locations |
| 10 | DPO (encarregado) contact | Art. 41 | Yes | DPO config, contact information |

---

## ePrivacy Art. 5(3) — Cookie & Tracking Disclosure

| # | Disclosure Item | Source | Must Disclose | Code Pattern to Check |
|---|----------------|--------|---------------|----------------------|
| 1 | Types of cookies used | ePrivacy + CNIL/ICO | Yes | `document.cookie`, `Set-Cookie` headers, cookie libraries |
| 2 | Purpose of each cookie | ePrivacy Art. 5(3) | Yes | Cookie names mapped to functionality |
| 3 | Cookie duration/expiry | CNIL guidelines | Yes | Cookie expiry settings, session vs persistent |
| 4 | Third-party cookies | ePrivacy + GDPR | Yes | Third-party scripts, pixel tags, tracking SDKs |
| 5 | How to manage/refuse cookies | ePrivacy Art. 5(3) | Yes | Consent banner, cookie preference centre |
| 6 | Consent mechanism | ePrivacy + GDPR Art. 7 | Yes (for non-essential) | CMP integration, consent gate logic |

---

## Cross-Jurisdiction Comparison: Notice Requirements

| Notice Element | GDPR Art. 13/14 | CCPA §1798.100(a) | LGPD Art. 9 |
|---------------|----------------|-------------------|------------|
| Controller/business identity | Required | Not required | Required |
| DPO/encarregado contact | Required (if DPO) | Not required | Required |
| Data categories collected | Required | Required (11 categories) | Implied (via purpose) |
| Purposes per category | Required | Required | Required |
| Legal basis per purpose | Required | Not required | Required (10 bases) |
| Recipients/third parties | Required | Required (categories) | Required (with reasons) |
| International transfers | Required + safeguards | Not required | Required (Art. 33–36) |
| Retention periods | Required (or criteria) | Required per category | Required (duration) |
| Data subject rights | Full Art. 15–22 list | Know, delete, correct, opt-out, limit, non-discrimination | 9 Art. 18 rights |
| Automated decisions | Required (Art. 22) | Not required | Required (Art. 20) |
| Right to complain | Required (SA details) | Not required | Not required |
| Source of data (indirect) | Required (Art. 14) | Required (categories of sources) | Not explicit |
| Sale/sharing disclosure | Not applicable | Required | Not applicable |
| Cookie/tracking details | ePrivacy Art. 5(3) | Required if tracking | Not explicit |
| Children's data | Art. 8 (age varies) | COPPA cross-reference | Art. 14 |

---

## Decision Tree: Which Sections to Generate

```
START
  │
  ├── Does the code collect data directly from users?
  │   └── YES → Generate Art. 13 sections (all 13 items)
  │
  ├── Does the code obtain data from third parties?
  │   └── YES → Generate Art. 14 additional sections (source, categories)
  │
  ├── Does the code use cookies or tracking technologies?
  │   └── YES → Generate cookie/tracking section (ePrivacy items)
  │
  ├── Does the code transmit PI to third parties?
  │   └── YES → Generate sharing section; assess CCPA sale/sharing
  │
  ├── Does the code transfer data internationally?
  │   └── YES → Generate transfers section with safeguard details
  │
  ├── Does the code include age-gating or children's features?
  │   └── YES → Generate children's data section
  │
  ├── Does the code include automated decision-making?
  │   └── YES → Generate automated decisions section (Art. 22 / Art. 20)
  │
  └── Generate all standard sections regardless:
      ├── What we collect (always)
      ├── How we use it (always)
      ├── Your rights (always)
      ├── Retention (always)
      └── Contact (always — with TODO placeholders)
```
