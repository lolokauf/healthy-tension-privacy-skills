# LGPD Legal Bases

The 10 legal bases for processing general personal data under LGPD Art. 7, plus the restricted bases for sensitive personal data under Art. 11. Use this checklist when performing Step 3 (Legal Basis Identification) of the LGPD review.

---

## Art. 7 — Legal Bases for General Personal Data

| # | Legal Basis | LGPD Article | When It Applies | Code Patterns / Indicators | Documentation Required? |
|---|------------|-------------|-----------------|---------------------------|------------------------|
| 1 | **Consent** | Art. 7(I), Art. 8 | Data subject has given consent for one or more specific purposes | Consent banners, checkbox UIs, `consentGiven`, `optIn`, `termsAccepted`, consent storage tables, consent timestamps, CMP (consent management platform) integration | Yes — consent records must be stored with timestamp, scope, and method of collection |
| 2 | **Legal or regulatory obligation** | Art. 7(II) | Processing is necessary for compliance with a legal or regulatory obligation of the controller | Tax ID storage (`cpf`, `cnpj`), fiscal invoice generation (`notaFiscal`), anti-money laundering checks, employment record keeping (`ctps`), regulatory reporting endpoints | Yes — identify the specific law/regulation that creates the obligation |
| 3 | **Public administration** | Art. 7(III) | Processing by public bodies for execution of public policies | Government APIs, public service integrations, `gov.br` auth, public health data submissions — rare in private-sector codebases | Yes — legal basis must reference specific public policy |
| 4 | **Research** | Art. 7(IV) | Processing by research bodies, with anonymisation when possible | Research databases, academic data collection, `anonymize()` functions, research consent forms, IRB/ethics committee references | Yes — anonymisation measures must be documented |
| 5 | **Contract performance** | Art. 7(V) | Processing is necessary for performing a contract with the data subject or for pre-contractual steps at the data subject's request | User registration for a paid service, order fulfilment, subscription management, checkout flows, account provisioning | No special documentation beyond the contract itself |
| 6 | **Exercise of rights** | Art. 7(VI) | Processing necessary for the exercise of rights in judicial, administrative, or arbitral proceedings | Litigation hold flags, legal discovery exports, dispute resolution data, arbitration records, court order compliance | Yes — identify the specific proceeding or right being exercised |
| 7 | **Protection of life** | Art. 7(VII) | Processing necessary to protect the life or physical safety of the data subject or a third party | Emergency contact systems, health alert mechanisms, safety check-in features — rare in most software | No special documentation if genuinely protecting life |
| 8 | **Health protection** | Art. 7(VIII) | Processing by health professionals, health services, or sanitary authorities | Telemedicine platforms, health record systems, patient portals, prescription management, lab result delivery | Yes — processing agent must be a health professional or health authority |
| 9 | **Legitimate interest** | Art. 7(IX), Art. 10 | Processing necessary for the legitimate interests of the controller or a third party, except where overridden by the data subject's fundamental rights and freedoms | Analytics, fraud prevention, security monitoring, marketing to existing customers, product improvement, internal administration | **Yes — mandatory documented balancing assessment (LIA/RIPD) before processing begins** |
| 10 | **Credit protection** | Art. 7(X) | Processing for the protection of credit | Credit scoring, credit bureau integrations (`SPC`, `Serasa`), payment history analysis, default risk assessment | Yes — must be proportional and limited to credit protection purpose |

---

## Art. 11 — Legal Bases for Sensitive Personal Data

Sensitive personal data (*dados pessoais sensíveis*) can ONLY be processed under the following bases. **Legitimate interest is NOT available for sensitive data.**

| # | Legal Basis | LGPD Article | When It Applies | Key Constraint |
|---|------------|-------------|-----------------|----------------|
| 1 | **Specific and prominent consent** | Art. 11(I) | Data subject consents specifically for the sensitive data processing purpose | Consent must be **specific** (not bundled with general consent) and **prominent** (clearly highlighted). A general "I agree to the privacy policy" does NOT satisfy this requirement. |
| 2 | **Legal or regulatory obligation** | Art. 11(II)(a) | Compliance with a legal obligation — same as Art. 7(II) but for sensitive data | Must identify the specific law requiring sensitive data processing |
| 3 | **Public administration** | Art. 11(II)(b) | Public policy execution — same as Art. 7(III) | Restricted to public bodies |
| 4 | **Research** | Art. 11(II)(c) | Research bodies, with anonymisation when possible | Anonymisation is more strongly expected for sensitive data |
| 5 | **Exercise of rights** | Art. 11(II)(d) | Rights in proceedings — same as Art. 7(VI) | Sensitive data must be strictly necessary for the proceeding |
| 6 | **Protection of life** | Art. 11(II)(e) | Life/safety protection — same as Art. 7(VII) | Immediate necessity standard |
| 7 | **Health protection** | Art. 11(II)(f) | Health procedures by health professionals — same as Art. 7(VIII) | Restricted to health context by qualified professionals |
| 8 | **Fraud prevention** | Art. 11(II)(g) | Guarantee of fraud prevention and security of the data subject in identification and authentication processes | Biometric authentication is the primary use case. Must be strictly necessary for security. |

---

## Legitimate Interest: Mandatory Balancing Assessment (Art. 10)

When legitimate interest is claimed as the legal basis, LGPD Art. 10 requires a balancing assessment BEFORE processing begins. This is more prescriptive than GDPR (which recommends but does not mandate the assessment format).

### What the Balancing Assessment Must Cover

1. **Legitimate purpose:** Specific, concrete purpose — not vague claims like "business improvement"
2. **Necessity:** Processing must be necessary to achieve the purpose — no less intrusive alternative exists
3. **Balancing:** Controller's interest weighed against data subject's fundamental rights and freedoms
4. **Transparency:** Data subject must be informed about the processing and the legitimate interest basis
5. **Opt-out:** Data subject must be able to object to processing based on legitimate interest

### Code Indicators That Suggest Legitimate Interest

| Pattern | Likely Purpose | LIA Required? |
|---------|---------------|---------------|
| Analytics tracking (internal, no third-party sharing) | Product improvement | Yes |
| Fraud detection scoring | Security | Yes (unless biometric — use Art. 11(II)(g) instead) |
| Marketing emails to existing customers | Direct marketing | Yes — and must honour opt-out |
| Server access logs with IP addresses | Security, debugging | Yes — but likely proportional |
| A/B testing with user data | Product improvement | Yes |
| Recommendation engine using purchase history | Personalisation | Yes |

### Red Flags: Legitimate Interest Likely Insufficient

| Pattern | Why Problematic | Better Basis |
|---------|----------------|-------------|
| Third-party advertising pixels | Not the controller's own interest | Consent (Art. 7(I)) |
| Sensitive data for any purpose | Art. 11 excludes legitimate interest | Specific consent (Art. 11(I)) or narrow exceptions |
| Profiling with significant effects on data subject | Disproportionate impact | Consent or contract performance |
| Data sharing with unrelated third parties | Beyond the legitimate purpose | Consent |
| Processing children's data | Art. 14 requires best interest standard | Parental consent |

---

## Consent Requirements Summary (Art. 8)

When consent is the legal basis, LGPD Art. 8 imposes specific requirements. Check code against each:

| Requirement | LGPD Reference | What to Check in Code |
|------------|---------------|----------------------|
| Written or demonstrable consent | Art. 8, caput | Consent checkbox, click-to-accept, signature, or other recorded affirmative act |
| Specific purposes | Art. 8(§4) | Consent text references specific processing activities, not blanket "all purposes" |
| Separate clause (if in written document) | Art. 8(§1) | Consent is not buried in ToS — separate UI element or clearly distinguished section |
| Burden of proof on controller | Art. 8(§2) | Consent records stored with timestamp, scope, version of notice shown |
| Blanket consent is void | Art. 8(§4) | No single checkbox covering multiple unrelated purposes |
| Consent can be revoked at any time | Art. 8(§5) | Withdrawal mechanism exists, equally accessible as the consent mechanism |
| Consent for controller-to-controller sharing must be specific | Art. 7(§5) | When a controller that obtained consent needs to share data with another controller, specific consent is required for the sharing (processor sharing is governed by the processing agreement, not Art. 7(§5)) |

---

## Legal Basis Selection Decision Tree

```
Is the data sensitive (Art. 5(II))?
├── YES → Can you obtain specific, prominent consent?
│   ├── YES → Use Art. 11(I) — specific consent for sensitive data
│   └── NO → Does an Art. 11(II) exception apply?
│       ├── YES → Use the specific exception (a-g)
│       └── NO → CANNOT process this data — no valid legal basis
│
└── NO (general personal data) →
    ├── Is there a contract with the data subject? → Art. 7(V)
    ├── Is there a legal obligation requiring this processing? → Art. 7(II)
    ├── Can you obtain consent? → Art. 7(I)
    ├── Is this for the controller's legitimate interest?
    │   ├── YES → Art. 7(IX) — but MUST complete LIA first
    │   └── Check other bases (III, IV, VI-VIII, X)
    └── None apply? → CANNOT process — no valid legal basis
```
