# PbD Code Review — React App Example

A worked example demonstrating the PbD Code Review skill applied to a React single-page application.

---

## Input Description

A React 18 SPA for an e-commerce site with:

- **Auth:** Email/password registration form, social login (Google OAuth)
- **Forms:** Checkout form collecting name, email, address, phone, card details (via Stripe Elements)
- **Cookie consent:** Banner component with "Accept All" and "Manage Preferences" buttons, marketing checkbox pre-checked by default
- **Analytics:** Google Analytics 4 (GA4) script loaded in `index.html` head, fires `page_view` events before consent banner interaction
- **Tracking pixels:** Facebook Pixel and LinkedIn Insight Tag loaded unconditionally in `index.html`
- **Storage:** localStorage used for cart items (product IDs), user preferences (theme, language), and recently viewed products with timestamps
- **Third-party:** Intercom chat widget (loads user email and name), Hotjar session recording
- **No privacy settings page, no account deletion flow**

---

## Expected Output

### Privacy Review Report

```markdown
## Privacy-by-Design Review — E-commerce React SPA

### Summary
- **PII fields introduced/modified:** 6 (email, name, address, phone, Google OAuth profile, browsing history)
- **New third-party dependencies:** 6 (Stripe, GA4, Facebook Pixel, LinkedIn, Intercom, Hotjar)
- **Privacy risk score:** CRITICAL
- **Blocking findings:** 5

### Findings by Principle

| # | Principle | Finding | Severity | Confidence | Blocking? |
|---|-----------|---------|----------|------------|-----------|
| 1 | Proactive | GA4, Facebook Pixel, and LinkedIn Tag fire before user interacts with consent banner | CRITICAL | HIGH | Yes |
| 1 | Proactive | Hotjar records entire user session including form field interactions | HIGH | HIGH | Yes |
| 2 | Default Setting | Marketing consent checkbox is pre-checked in consent banner | HIGH | HIGH | Yes |
| 2 | Default Setting | Cookie consent banner "Accept All" is visually emphasised over "Manage Preferences" | MEDIUM | MEDIUM | No |
| 3 | Embedded in Design | No centralised consent state — each third-party script checks its own cookie independently | MEDIUM | HIGH | No |
| 4 | Positive-Sum | No middle ground between full Hotjar session recording and no analytics | LOW | MEDIUM | No |
| 5 | Full Lifecycle | localStorage stores recently viewed products with timestamps — no TTL, no deletion on logout | HIGH | HIGH | Yes |
| 5 | Full Lifecycle | Intercom receives user email and name with no documented DPA | MEDIUM | MEDIUM | No |
| 6 | Transparency | 6 third-party data processors, none documented in a data inventory or privacy policy | HIGH | HIGH | Yes |
| 7 | User-Centric | No privacy settings page; no way to withdraw consent after initial banner interaction | HIGH | HIGH | Yes |
| 7 | User-Centric | No account deletion flow | HIGH | HIGH | Yes |

### Recommended Fixes (ordered by severity)

1. **[BLOCKING]** Defer all non-essential scripts (GA4, Facebook Pixel, LinkedIn Tag, Hotjar) until user grants consent — move from `index.html` head to a consent-gated loader
2. **[BLOCKING]** Uncheck marketing consent checkbox by default — pre-checked consent is invalid under GDPR Art. 7 and ePrivacy Art. 5(3)
3. **[BLOCKING]** Add TTL to localStorage entries (recently viewed products) and clear on logout/account deletion
4. **[BLOCKING]** Create a privacy settings page accessible from the site footer where users can review and withdraw consent
5. **[BLOCKING]** Implement account deletion flow
6. Create a centralised consent management module that gates all third-party scripts based on a single consent state
7. Document all 6 third-party processors in a data inventory with purposes, data shared, and DPA status
8. Consider Hotjar's privacy-focused alternatives (session replay without form field capture, or aggregated heatmaps only)
9. Give "Manage Preferences" equal visual weight to "Accept All" in the consent banner

### Generated Artifacts

- PII Touchpoint Manifest (6 fields)
- Default Configuration Audit (2 FAIL, 1 WARN)
- PII Data Flow Heatmap (6 third-party data flows, 0 centralised)
- Privacy-Preserving Alternatives Table (2 alternatives identified)
- Data Lifecycle Table (localStorage entries: all FAIL on retention)
- Transparency Audit (6 undocumented processors)
- User Privacy Controls Checklist (1 of 5 controls partially implemented)
- Delete-My-Account Trace (no deletion path exists)
```

---

## Key Findings Demonstrated

| Finding | Principle | Why It Matters |
|---------|-----------|---------------|
| Tracking fires before consent | Principle 1 | Scripts in `index.html` head execute before the consent banner renders. This is a CRITICAL finding because data is transmitted to third parties without any legal basis. HIGH confidence — the load order is visible in code. |
| Pre-checked marketing consent | Principle 2 + 7 | Pre-checked boxes do not constitute valid consent under GDPR (Planet49 ruling, CJEU C-673/17) or ePrivacy Art. 5(3). HIGH confidence — the checkbox state is visible in the component code. |
| localStorage PII without TTL | Principle 5 | Recently viewed products with timestamps constitute behavioural data linkable to an individual. No TTL means indefinite retention on the user's device. HIGH confidence — localStorage API calls are visible in code, absence of TTL is verifiable. |
| No consent withdrawal mechanism | Principle 7 | Under GDPR Art. 7(3), withdrawal of consent must be as easy as giving it. A one-time banner with no settings page means users cannot change their mind. HIGH confidence — absence of a settings page is verifiable by examining routes and navigation. |
