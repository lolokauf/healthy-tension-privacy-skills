# LGPD Review — International SaaS with Brazilian Users Example

A worked example demonstrating the LGPD review skill applied to an international SaaS application that serves Brazilian users without being headquartered in Brazil.

---

## Input Description

A US-based project management SaaS (React + Python/Django) with:

- **User accounts:** Email/password registration, Google/Microsoft SSO, profile with name, email, avatar, timezone, company
- **Brazilian presence:** Portuguese language option, BRL pricing tier, Brazilian customer logos on marketing site, `.com.br` domain redirect to main `.com` site
- **Payments:** Stripe for global billing, supports BRL currency
- **Analytics:** Google Analytics 4 on marketing site, Mixpanel for product analytics (user traits: email, company, plan tier, feature usage)
- **Email:** Intercom for in-app messaging and support, receives user profile + company data
- **Storage:** AWS US East (us-east-1) primary, no Brazil region
- **Team features:** Workspace members can see each other's names, emails, avatars, and activity status
- **Integrations:** Slack notifications (sends user name + task data), Jira sync (sends user name + task assignments)
- **Privacy policy** in English only, mentions GDPR, does not mention LGPD
- **Cookie banner** uses OneTrust, configured for GDPR regions only
- **No CPF/CNPJ collection** — registration uses email only

---

## Expected Output

### LGPD Compliance Review — International Project Management SaaS

#### Summary
- **Personal data categories found:** 7 (direct identifiers, contact, authentication, behavioural, device/technical, communication, employment/professional)
- **Sensitive personal data present:** no
- **Processing activities identified:** 9
- **Legal bases assigned:** 5 with basis / 4 without clear basis
- **Data subject rights implemented:** 2 of 9 + Art. 20 (partial access, partial deletion)
- **International transfers identified:** all data (primary infrastructure in US)
- **DPO designated:** no
- **Breach notification mechanism:** not found

#### Section 1: Personal Data Classification (key rows)

| Data Element | Category | Sensitive? | Source | Purpose | Confidence |
|-------------|----------|------------|--------|---------|------------|
| users.email | Direct identifier | No | POST /api/register, SSO callback | Authentication, notifications | HIGH |
| users.name | Direct identifier | No | Registration, SSO profile | Display, collaboration | HIGH |
| users.passwordHash | Authentication | No | POST /api/register | Authentication | HIGH |
| users.avatar | Images/media | No | Profile upload, SSO profile | Display | HIGH |
| users.timezone | Location (indirect) | No | Profile settings, browser detection | Scheduling, display | HIGH |
| users.company | Employment/professional | No | Registration | Workspace routing, billing | HIGH |
| workspace.memberActivity | Behavioural | No | Application usage | Team collaboration features | HIGH |
| analytics.ga4Events | Behavioural + device/technical | No | GA4 client-side | Marketing analytics | HIGH |
| analytics.mixpanelTraits | Behavioural + direct identifier | No | Mixpanel SDK (email, company, plan, features) | Product analytics | HIGH |
| intercom.conversations | Communication | No | In-app widget | Customer support | HIGH |

#### Section 2: Legal Basis Mapping (key rows)

| Processing Activity | Data Elements | Legal Basis (Art. 7/11) | Evidence | Documentation Required? | Confidence |
|---------------------|--------------|-------------------------|----------|------------------------|------------|
| Account registration | name, email, company, timezone | Art. 7(V) — contract performance | Required for SaaS service | No (contract) | HIGH |
| Authentication | passwordHash, SSO tokens | Art. 7(V) — contract performance | Necessary for account access | No (contract) | HIGH |
| Team collaboration | member names, emails, avatars, activity | Art. 7(V) — contract performance | Core product feature | No (contract) | HIGH |
| Google Analytics 4 | pageViews, device data, IP | **No clear basis for Brazilian users** | GA4 loads on all pages regardless of region; cookie banner only configured for GDPR regions; no LGPD consent mechanism | **Yes — consent required** | HIGH |
| Mixpanel product analytics | email, company, plan, feature usage | **No clear basis** | `mixpanel.identify(email)` sends PII; no consent mechanism; legitimate interest requires LIA | **Yes — LIA mandatory if Art. 7(IX)** | HIGH |
| Intercom support | user profile, conversations | Art. 7(V) — contract performance | Support is part of service; user initiates conversations | No (contract) | MEDIUM |
| Stripe billing | payment method, billing address | Art. 7(V) — contract performance + Art. 7(II) — legal obligation (tax) | Necessary for paid service | No (contract + regulation) | HIGH |
| Slack integration | user name, task data | Art. 7(V) — contract performance | User-configured integration | No (contract — user opted into integration) | MEDIUM |
| Jira integration | user name, task assignments | Art. 7(V) — contract performance | User-configured integration | No (contract — user opted into integration) | MEDIUM |

#### Section 3: Data Subject Rights Matrix

| Right (Art. 18) | Endpoint Exists? | Functional? | Identity Verification | Response Timeline | Gaps | Severity | Confidence |
|-----------------|-----------------|-------------|----------------------|-------------------|------|----------|------------|
| Confirmation (I) | No | No | N/A | N/A | No dedicated endpoint | HIGH | HIGH |
| Access (II) | Partial | Partial | Session auth | N/A | Profile page shows basic data; no Mixpanel data, no GA4 data, no Intercom conversation export | HIGH | HIGH |
| Correction (III) | Partial | Partial | Session auth | N/A | Profile edit for name/email/avatar; no mechanism for correcting analytics data | MEDIUM | HIGH |
| Anonymisation/blocking/deletion (IV) | No | No | N/A | N/A | No mechanism for selective data anonymisation | HIGH | HIGH |
| Portability (V) | No | No | N/A | N/A | No data export feature in any format | HIGH | HIGH |
| Deletion of consent data (VI) | Partial | Partial | Session auth | N/A | Account deletion exists but does not purge: Mixpanel profiles, GA4 data, Intercom conversations, Stripe records | HIGH | HIGH |
| Sharing information (VII) | No | No | N/A | N/A | Privacy policy does not list Mixpanel, GA4, Intercom, Slack, or Jira as data recipients | HIGH | HIGH |
| Consent denial info (VIII) | No | No | N/A | N/A | No consent collection for analytics — so no opportunity to explain denial consequences | MEDIUM | MEDIUM |
| Consent revocation (IX) | No | No | N/A | N/A | No analytics opt-out for Brazilian users (OneTrust only triggers in GDPR regions) | HIGH | HIGH |
| Automated decision review (Art. 20) | N/A | N/A | N/A | N/A | No automated decisions affecting user interests identified | LOW | HIGH |

#### Section 4: International Transfer Assessment

| Destination | Vendor/Service | Data Transferred | Transfer Mechanism | Adequacy Status | Gaps | Severity | Confidence |
|-------------|---------------|-----------------|-------------------|-----------------|------|----------|------------|
| US (AWS us-east-1) | AWS | All personal data (primary DB, file storage) | None identified for LGPD | No ANPD adequacy for US | All data of Brazilian users stored in US with no transfer mechanism | HIGH | HIGH |
| US | Google (GA4) | Browsing behaviour, device data, IP | None identified for LGPD | No ANPD adequacy for US | GA4 data of Brazilian visitors sent to Google US servers | HIGH | HIGH |
| US | Mixpanel | Email, company, plan, feature usage | None identified for LGPD | No ANPD adequacy for US | PII sent to Mixpanel US servers | HIGH | HIGH |
| US | Intercom | User profile, conversation content | None identified for LGPD | No ANPD adequacy for US | Support conversations with PII sent to US | MEDIUM | HIGH |
| US | Stripe | Payment data, billing address | Stripe DPA with SCCs | Stripe offers SCCs | Stripe's standard DPA includes international transfer mechanisms — verify LGPD-specific coverage | MEDIUM | MEDIUM |

#### Section 5: Vendor Classification

| Vendor | LGPD Role | Contract Type | Data Access | International Transfer? | Confidence |
|--------|-----------|---------------|-------------|------------------------|------------|
| AWS | PROCESSOR | DPA (standard) | All data (hosting) | Yes — US | MEDIUM |
| Google (GA4) | CONTROLLER (joint) | GA4 ToS | Browsing data, device data | Yes — US | MEDIUM |
| Mixpanel | PROCESSOR | DPA (if executed) | Email, company, usage data | Yes — US | LOW |
| Intercom | PROCESSOR | DPA (if executed) | User profile, conversations | Yes — US | LOW |
| Stripe | PROCESSOR | DPA with SCCs | Payment data | Yes — US (with SCCs) | MEDIUM |
| Slack | PROCESSOR | Workspace admin controls | User name, task data | Yes — US | LOW |
| Atlassian (Jira) | PROCESSOR | DPA (standard) | User name, task assignments | Yes — US (Atlassian offers SCCs) | MEDIUM |

#### Section 6: DPO & Governance

**DPO Designation:**
- Not found. No *encarregado* contact in privacy notice or application. LGPD Art. 41 mandates DPO for controllers processing Brazilian data. International companies serving Brazilian users must designate a DPO or representative.
- **Severity: HIGH**

**Breach Notification:**
- No LGPD-specific incident response found. Generic incident response may exist but no ANPD notification mechanism.
- **Severity: HIGH**

**Privacy Notice (Art. 9):**
- English only — no Portuguese version. Does not mention LGPD, Brazilian rights, or ANPD. Does not list analytics vendors (Mixpanel, GA4) as data recipients.
- **Severity: HIGH**

#### Section 7: Recommended Fixes (top items)

1. **[BLOCKING]** Extend cookie/analytics consent to Brazilian users — OneTrust is configured for GDPR regions only. GA4 and Mixpanel fire without consent for Brazilian visitors. Either extend consent mechanism or implement LGPD-specific consent. — HIGH, HIGH confidence
2. **[BLOCKING]** Establish legal basis for Mixpanel analytics — `mixpanel.identify(email)` sends PII without consent or documented LIA. Either obtain consent or complete LIA. — HIGH, HIGH confidence
3. **[BLOCKING]** Implement international transfer mechanisms — all Brazilian user data stored in US without SCCs or other LGPD-compliant transfer mechanism. Stripe has SCCs; other vendors need contracts reviewed. — HIGH, HIGH confidence
4. **[BLOCKING]** Designate DPO and publish contact — required under Art. 41. — HIGH, HIGH confidence
5. **[BLOCKING]** Create Portuguese privacy notice — Art. 9 transparency requirements cannot be met with an English-only notice for Brazilian users. Must include LGPD-specific rights, legal bases, third-party names, and ANPD contact information. — HIGH, HIGH confidence
6. Implement data subject rights endpoints — start with Art. 18(II) access (full data export), Art. 18(V) portability, Art. 18(IX) consent revocation for analytics. — HIGH, HIGH confidence
7. Implement account deletion that cascades to Mixpanel, GA4, Intercom, and Slack/Jira data. — HIGH, HIGH confidence
8. Add analytics opt-out for Brazilian users that is equally accessible as the consent mechanism. — HIGH, HIGH confidence

---

## Key Findings Demonstrated

| Finding | Step | Why It Matters |
|---------|------|---------------|
| LGPD applies to non-Brazilian companies | Step 1 | Portuguese language, BRL pricing, `.com.br` redirect, Brazilian customer logos — the company offers services to individuals in Brazil (Art. 3(II)). LGPD applies even without a Brazilian entity. |
| GDPR consent ≠ LGPD consent | Step 3 | OneTrust configured for GDPR regions only. Brazilian users bypass the consent banner entirely. LGPD consent requirements are independent of GDPR compliance. |
| Mixpanel with PII needs explicit basis | Step 3 | `mixpanel.identify(email)` transmits a direct identifier. This is not anonymised analytics — it requires either consent or a documented LIA. |
| All data is an international transfer | Step 5 | No Brazil-region infrastructure means ALL Brazilian user data is an international transfer. This is a common oversight for US-based SaaS companies — LGPD's transfer rules apply to the entire dataset, not just specific flows. |
| Privacy notice must be in Portuguese | Step 7 | Art. 9 transparency requires information in clear and adequate language. For Brazilian users, this means Portuguese. An English-only privacy policy fails the transparency requirement regardless of content quality. |
| Google Analytics = joint controller | Step 6 | GA4 data is used by both the business (marketing analytics) and Google (ad targeting, product improvement). Google is a joint controller, not a processor, under most DPA interpretations. This complicates the transfer mechanism — SP exception arguments don't apply to joint controllers. |
