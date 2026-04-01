# Cookie Compliance Checklist

Combined compliance requirements for cookies and tracking technologies across ePrivacy Directive, GDPR, CNIL guidelines, ICO guidance, and CCPA/CPRA. Use this checklist when performing Step 6 (Pre-Consent & Consent Enforcement Audit) of the Cookie & Tracker Audit.

---

## ePrivacy Directive Art. 5(3) — Core Requirements

The ePrivacy Directive is the primary cookie-specific regulation. GDPR provides the legal basis for consent validity; ePrivacy Art. 5(3) is the trigger for when consent is required.

### Consent Required Unless Strictly Necessary

| Requirement | Check | Severity if Missing |
|-------------|-------|-------------------|
| **Prior consent** for non-strictly-necessary cookies/storage | No cookie is set, no script loads, and no storage is written before the user makes an affirmative consent choice | CRITICAL |
| **Informed consent** — user knows what they are consenting to | Consent mechanism discloses: what trackers are used, their purposes, their categories, and their retention periods | HIGH |
| **Specific consent** — per-purpose or per-category | Consent is granular (at minimum per category: analytics, advertising, functional), not all-or-nothing | HIGH |
| **Freely given** — refusal does not block service access | Refusing non-essential cookies does not trigger a cookie wall, degraded UX, or nagging modals | HIGH |
| **Active consent** — clear affirmative act | Consent requires a click/toggle, not silence, pre-checked boxes, or "continue browsing" | CRITICAL |

### Strictly Necessary Exemption

| Requirement | Check | Severity if Wrong |
|-------------|-------|------------------|
| **Purpose-necessity test** | For each "strictly necessary" cookie: would the service the user explicitly requested fail entirely without it? | HIGH |
| **No over-claiming** | Analytics, A/B testing, advertising, session replay, and performance cookies are NEVER strictly necessary | HIGH |
| **Minimal scope** | Strictly necessary cookies are limited to what is needed (no excess data, minimal expiry) | MEDIUM |

---

## GDPR Art. 6/7 — Consent Validity

When ePrivacy Art. 5(3) requires consent, GDPR Art. 7 defines what valid consent looks like.

| Requirement | Check | Reference |
|-------------|-------|-----------|
| **Freely given** | Consent is not a condition of service access (Art. 7(4)). Cookie walls prohibited. | EDPB 05/2020 |
| **Specific** | Separate consent per purpose. "Accept all" must have a "Reject all" or per-category controls. | EDPB 05/2020 |
| **Informed** | Controller identity, purposes, data types, withdrawal right communicated before consent action. | Art. 13 |
| **Unambiguous** | Clear affirmative act. Pre-checked boxes, scroll-to-consent, and continue-browsing are not valid. | Planet49 (C-673/17) |
| **Withdrawal as easy as granting** | Same number of clicks to withdraw as to grant. Settings page must be accessible. | Art. 7(3) |
| **Record of consent** | Controller can demonstrate consent was obtained (timestamp, version of consent text, choices made). | Art. 7(1) |
| **Age verification** | If service is directed at minors (under 16 / member state threshold), parental consent required. | Art. 8 |

---

## CNIL Guidelines — France-Specific

CNIL's 2020 cookie guidelines are the strictest widely-enforced interpretation and serve as a practical baseline.

| Requirement | Check | Notes |
|-------------|-------|-------|
| **Refuse as prominent as Accept** | "Reject all" button must be at the same level and with equal visual prominence as "Accept all" | CNIL fined Google (€150M) and Facebook (€60M) for this in 2022 |
| **No cookie walls** | Service access cannot be conditioned on cookie acceptance | Narrow "reasonable alternative" exception exists but is rarely valid |
| **No "continue browsing" consent** | Scrolling, navigating, or any passive action does not constitute consent | Pre-Planet49 this was common; now CRITICAL if still in use |
| **13-month maximum cookie duration** | Cookies should not persist longer than 13 months from the time of setting | Flag any cookie with `Max-Age` > 13 months (33696000 seconds) |
| **13-month consent renewal** | Consent choice must be re-presented at least every 13 months | Check whether CMP consent cookie has ≤ 13-month expiry |
| **Trackers must not load before consent** | All analytics, advertising, and functional trackers blocked until consent granted | Script load order is the primary check |
| **Four categories** | Strictly necessary, functional, analytics, advertising — granularity at minimum at category level | Single "essential + non-essential" toggle is insufficient |
| **Consent proof** | Retain evidence of consent (timestamp, choices, consent text version) for audit purposes | Check CMP configuration for consent logging |

---

## ICO Guidance — UK-Specific

| Requirement | Check | Notes |
|-------------|-------|-------|
| **Analytics requires consent** | Including Google Analytics, even with IP anonymisation | ICO position is clear: analytics cookies are not strictly necessary |
| **12-month recommended maximum** | Cookie duration should not exceed 12 months | Slightly stricter than CNIL's 13 months |
| **Prominent refusal mechanism** | Users must be able to refuse non-essential cookies easily | "Reject all" or clear per-category toggles |
| **Consent renewal** | Re-present consent choices periodically | No specific interval mandated, but "regularly" |
| **First-party analytics debate** | First-party analytics with limited retention and no cross-site sharing may have a legitimate interest argument under UK GDPR | Debated — flag as requiring legal review rather than assuming exemption |

---

## CCPA/CPRA — Cookie-Specific Requirements

CCPA does not require prior consent for cookies (unlike ePrivacy), but requires opt-out mechanisms for cookies that facilitate sale or sharing.

| Requirement | Check | Notes |
|-------------|-------|-------|
| **Opt-out for sale/sharing** | Cookies that transmit PI to third parties for cross-context behavioural advertising must have an opt-out mechanism | "Do Not Sell or Share My Personal Information" link |
| **GPC signal (§7025)** | Application must honour Global Privacy Control (`Sec-GPC: 1` header) as a valid opt-out for both sale AND sharing | Check for `Sec-GPC` header detection in backend/middleware |
| **No opt-out = CRITICAL** | Advertising cookies active without any opt-out mechanism is a CCPA violation | Severity: CRITICAL |
| **Minors opt-in** | Sale/sharing of PI of consumers under 16 requires opt-in; under 13 requires parental consent | Check for age gates on advertising-tracked surfaces |

---

## Cookie Attribute Security Checklist

For all cookies, verify security attributes. These are not consent requirements but are privacy/security best practices that should be reported.

| Attribute | Recommended Setting | Why | Severity if Missing |
|-----------|-------------------|-----|-------------------|
| **HttpOnly** | `true` for server-side cookies | Prevents JavaScript access (XSS protection) | MEDIUM |
| **Secure** | `true` (always, for production) | Prevents transmission over insecure HTTP | MEDIUM |
| **SameSite** | `Strict` or `Lax` (default) | Prevents CSRF and cross-site tracking | MEDIUM |
| **Path** | Most restrictive path needed | Limits cookie scope | LOW |
| **Domain** | Omit or set to exact domain | Prevents subdomain leakage | MEDIUM |
| **Max-Age/Expires** | Minimal duration for purpose | Reduces exposure window | LOW (unless > 13 months → HIGH) |

**Third-party cookie status (updated Oct 2025):** Google dropped its plan to deprecate third-party cookies in Chrome (announced April 2025). Third-party cookies remain fully functional in Chrome. Google also retired the Privacy Sandbox measurement and relevance APIs — Topics API, Attribution Reporting API, Protected Audiences API, and Shared Storage API — in October 2025. CHIPS (partitioned cookies via the `Partitioned` attribute) and FedCM (Federated Credential Management) remain active. Codebases may contain dead Privacy Sandbox code (`document.browsingTopics()`, `navigator.runAdAuction()`, `sharedStorage.worklet.addModule()`) — flag for cleanup but this is not a compliance finding. Third-party cookies (`.doubleclick.net`, `.facebook.com`) continue to function and still require consent/opt-out. Server-side tracking and first-party cookie workarounds also continue to require consent/opt-out.

---

## Pre-Consent Audit Checklist

For each tracker, answer these questions:

| Question | Expected Answer | If Violated |
|----------|----------------|------------|
| Does this tracker load before the consent mechanism renders? | No | CRITICAL — pre-consent violation |
| Does this tracker set cookies before consent is granted? | No | CRITICAL — pre-consent violation |
| Does this tracker fire pixels/beacons on page load without consent check? | No | CRITICAL if advertising, HIGH if analytics |
| Does this tracker write to localStorage/sessionStorage before consent? | No | HIGH — storage access without consent |
| Is this tracker injected by a tag manager that loads before consent? | No, or tag manager respects consent mode | MEDIUM — verify tag manager consent integration |
| Does the server set tracking cookies via `Set-Cookie` header before consent? | No | HIGH — server-side pre-consent violation |

---

## Consent Withdrawal Checklist

For each tracker with consent granted:

| Question | Expected Answer | If Violated |
|----------|----------------|------------|
| Does withdrawing consent stop the tracker from operating? | Yes | HIGH — withdrawal not enforced |
| Does withdrawal delete the tracker's cookies? | Yes | HIGH — stale tracking cookies persist |
| Does withdrawal clear localStorage/sessionStorage entries? | Yes | MEDIUM — stale identifiers persist |
| Is withdrawal as easy as granting consent (same click count)? | Yes | HIGH — Art. 7(3) violation |
| Does withdrawal require additional confirmation not present during granting? | No | MEDIUM — friction asymmetry |
| Does the server respect withdrawal on subsequent requests? | Yes | HIGH — server-side enforcement gap |
