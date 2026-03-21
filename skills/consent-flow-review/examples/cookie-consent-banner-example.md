# Consent Flow Review — Cookie Consent Banner Example

A worked example demonstrating the Consent Flow Reviewer skill applied to an e-commerce site's cookie consent implementation.

---

## Input Description

A React-based e-commerce site with the following consent-relevant features:

- **Cookie banner:** Custom-built banner component. "Accept All" button is large, green, and prominent. "Manage Preferences" is a small grey text link below it. No "Reject All" button.
- **Google Analytics 4:** GA4 script tag in `<head>` of `index.html` — loads on every page before any React component renders.
- **Meta Pixel:** Facebook pixel initialised in `useEffect` of the root `App.tsx` component. Fires `PageView` event on every route change. Consent check exists but reads from a `consentState` variable that defaults to `true`.
- **Newsletter popup:** A modal prompting newsletter signup appears 3 seconds after page load, overlapping the cookie banner if the user has not yet interacted with it.
- **Consent storage:** Cookie preferences saved to `localStorage` under `cookie_consent` key. No backend sync — consent state is browser-local only.
- **No withdrawal UI:** No settings page or mechanism to change cookie preferences after initial banner interaction.

---

## Expected Output

### Summary

- **Consent mechanisms found:** 1
- **Pre-consent violations:** 1
- **Dark patterns found:** 3
- **Enforcement gaps:** 2
- **Withdrawal issues:** 1

---

### Section 1: Consent Mechanism Inventory

| Mechanism | Type | Legal Basis | Granularity | Revocable? | Art. 4(11) Failures | Confidence |
|-----------|------|-------------|-------------|------------|---------------------|------------|
| Cookie consent banner | Cookie consent | Consent (Art. 6(1)(a)) | Per-category (analytics, marketing, functional) | No — no withdrawal UI exists | Freely given (no reject all), Unambiguous (deceptive snugness) | HIGH |

---

### Section 2: Pre-Consent Violations

| Script / Pixel | Loads Before Consent? | Data Transmitted | Strictly Necessary? | Severity | Confidence |
|---------------|----------------------|------------------|---------------------|----------|------------|
| GA4 (`gtag.js`) | Yes — script in `<head>`, loads before React mounts | IP address, page URL, viewport size, referrer, client ID cookie | No — analytics serves the controller's interest, not a user-requested service | CRITICAL | HIGH |

---

### Section 3: Dark Pattern Findings

| Pattern | EDPB Category | Sub-Type | Code Evidence | Severity | Confidence |
|---------|--------------|----------|---------------|----------|------------|
| "Accept All" is a large green `Button variant="primary"`, "Manage Preferences" is a `<span>` styled as grey underlined text at 12px | Skipping | Deceptive snugness (2.1) | `CookieBanner.tsx:45` — `<Button variant="primary" size="lg">Accept All</Button>` vs `CookieBanner.tsx:52` — `<span className="text-xs text-gray-400 underline cursor-pointer">` | HIGH | HIGH |
| Newsletter signup modal renders 3s after page load via `setTimeout`, z-index higher than cookie banner, covers banner if not yet dismissed | Skipping | Look over there (2.2) | `App.tsx:28` — `setTimeout(() => setShowNewsletter(true), 3000)` with `z-index: 9999` vs banner `z-index: 9998` | MEDIUM | HIGH |
| No "Reject All" button — users must click "Manage Preferences", then individually disable each category, then click "Save" (3 clicks vs 1 for accept) | Hindering | Longer than necessary (4.2) | `CookieBanner.tsx` — no reject/decline handler exists in component. `ManagePreferences.tsx:12` — categories default to `true`, requiring individual toggle-off | HIGH | HIGH |

---

### Section 4: Consent Enforcement Map

| Capture Point | Data Sent | Consent Required | Enforcement Point | Enforced? | Gap? | Confidence |
|--------------|-----------|------------------|-------------------|-----------|------|------------|
| `index.html:8` — GA4 script tag | IP, page URL, viewport, referrer, client ID | Analytics consent | NONE — script loads unconditionally from HTML `<head>` | No | **Yes** | HIGH |
| `App.tsx:15` — Meta Pixel `fbq('init')` | IP, page URL, fbp/fbc cookies, user agent | Marketing consent | `App.tsx:14` — `if (consentState.marketing)` | No — `consentState` defaults to `true` before banner interaction | **Yes** | HIGH |
| `App.tsx:22` — Meta Pixel `fbq('track', 'PageView')` | Page URL, referrer | Marketing consent | Same as above — gated by same defaulting `consentState` | No | **Yes** | HIGH |
| `CheckoutSuccess.tsx:31` — Meta Pixel `fbq('track', 'Purchase')` | Order value, currency, content IDs | Marketing consent | `CheckoutSuccess.tsx:30` — `if (consentState.marketing)` | No — same default-true issue | **Yes** | HIGH |
| `CartProvider.tsx:18` — `localStorage.setItem('cart', ...)` | Cart contents (product IDs, quantities) | Functional (strictly necessary) | N/A — exempt | N/A | No | HIGH |

#### Exempt Entries

| Capture Point | Exemption Justification | Strictly Necessary Because | User-Requested Purpose | Service Cannot Function Without |
|--------------|------------------------|---------------------------|----------------------|-------------------------------|
| `CartProvider.tsx:18` — cart localStorage | Shopping cart persistence | Cart state must survive page navigation for checkout flow | User clicked "Add to cart" | Cart would empty on every page navigation, making checkout impossible |

---

### Section 5: Withdrawal Trace

| Mechanism | Withdrawal Path | Clicks to Withdraw | Clicks to Grant | As Easy as Granting? | Data Purged? | Confidence |
|-----------|----------------|-------------------|-----------------|---------------------|-------------|------------|
| Cookie consent banner | No withdrawal path exists — no settings page, no footer link, no mechanism to re-open banner | N/A (impossible) | 1 (click "Accept All") | No — withdrawal is impossible, granting is 1 click | No — GA4 and Meta cookies persist indefinitely | HIGH |

---

### Section 6: Cross-Surface Sync

| Surface | Consent Mechanism | Sync Method | Consistent? | Confidence |
|---------|------------------|-------------|-------------|------------|
| Web (browser) | Cookie banner → localStorage | N/A (single surface) | N/A | HIGH |
| Backend (API) | None | None | N/A — backend does not process consent-dependent data | HIGH |

---

## Key Findings Demonstrated

| Finding | Step | Why It Matters |
|---------|------|---------------|
| GA4 loads before consent banner renders | Step 2 (Pre-Consent) | The GA4 script tag in `<head>` fires before any React component mounts, making consent collection impossible. This violates ePrivacy Art. 5(3) — analytics is not strictly necessary. The fix is conditional script loading: only inject the GA4 tag after consent is granted. HIGH confidence because HTML load order is deterministic. |
| Meta Pixel enforcement gap — default-true consent | Step 4 (Enforcement) | The consent check exists in code (`if (consentState.marketing)`) but `consentState` initialises with all categories `true`. This means the pixel fires on first page load before the banner is interacted with. The enforcement point is cosmetic — it gates on a value that is always true at the moment it matters. This exemplifies the adversarial resistance principle: evaluate behaviour, not labels. |
| No withdrawal mechanism | Step 5 (Withdrawal) | Once the user clicks "Accept All" (or even "Save" after managing preferences), there is no way to change the decision. Art. 7(3) requires withdrawal to be as easy as granting. Here, granting is 1 click and withdrawal is impossible. CRITICAL because consent that cannot be withdrawn is not valid consent under GDPR. |
| Newsletter modal obscures consent banner | Step 3 (Dark Patterns) | The newsletter popup at z-index 9999 renders on top of the cookie banner at z-index 9998 after 3 seconds. If the user has not yet interacted with the banner, the newsletter modal covers it. This is an EDPB "look over there" pattern (2.2) — drawing attention away from the consent decision. |
