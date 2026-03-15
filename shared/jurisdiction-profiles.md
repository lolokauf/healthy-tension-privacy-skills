# Jurisdiction Profiles

Cross-skill reference for the major privacy regulatory frameworks. Skills reference this file for jurisdiction-specific guidance rather than embedding regulatory details inline.

**Last verified:** 2026-03-15

**How to reference:** `See shared/jurisdiction-profiles.md for [regulation] [article] details.`

---

## GDPR — General Data Protection Regulation (EU)

**Full text:** [EUR-Lex](https://eur-lex.europa.eu/eli/reg/2016/679/oj) | **Guidance:** [EDPB](https://edpb.europa.eu/our-work-tools/general-guidance_en)

### Scope

- **Territorial:** Applies to organisations established in the EU/EEA, OR organisations outside the EU that offer goods/services to, or monitor the behaviour of, individuals in the EU (Art. 3).
- **Material:** Applies to the processing of personal data wholly or partly by automated means, and to non-automated processing of personal data that forms part of a filing system (Art. 2).
- **Exclusions:** Purely personal/household activities, law enforcement (separate directive).

### Key Articles for Privacy Engineering

| Activity | Articles | Summary |
|----------|----------|---------|
| Lawful basis | Art. 6 | 6 legal bases: consent, contract, legal obligation, vital interests, public task, legitimate interest. At least one must apply to each processing activity. |
| Consent | Art. 7 | Must be freely given, specific, informed, unambiguous. Burden of proof on controller. Withdrawal must be as easy as giving consent. |
| Transparency | Art. 12–14 | Information must be provided in clear, plain language. Art. 13 (direct collection) and Art. 14 (indirect collection) specify required disclosures. |
| Data subject rights | Art. 15–22 | Access (15), rectification (16), erasure (17), restriction (18), portability (20), objection (21), automated decision-making (22). Response within 1 month. |
| Data protection by design/default | Art. 25 | Implement appropriate technical and organisational measures. Privacy-protective settings must be the default. |
| Processors | Art. 28 | Processing only on documented instructions. Requires a binding contract (DPA). Sub-processor approval required. |
| Records of processing (RoPA) | Art. 30 | Controllers and processors must maintain records of processing activities. Exemption for organisations with <250 employees (with exceptions). |
| DPIAs | Art. 35–36 | Required when processing is "likely to result in a high risk." Must assess necessity, proportionality, and risk mitigation. Prior consultation with DPA if high risk remains (Art. 36). |

### Key Concepts

**Lawful basis types:** Consent, contractual necessity, legal obligation, vital interests, public task, legitimate interest. Legitimate interest requires a balancing test (controller's interest vs. data subject's rights).

**DPIA trigger criteria (Art. 35(3)):** Systematic and extensive profiling with significant effects, large-scale processing of special categories, systematic monitoring of publicly accessible areas. DPAs publish additional lists.

**Cross-border transfer mechanisms:** Adequacy decisions (Art. 45), Standard Contractual Clauses (Art. 46(2)(c)), Binding Corporate Rules (Art. 47), derogations (Art. 49 — limited circumstances).

### Enforcement

Supervisory authorities (DPAs) in each member state. EDPB coordinates cross-border cases. Two fine tiers: up to 2% global annual turnover (administrative violations) or up to 4% (core principles, rights violations, international transfers).

---

## CCPA/CPRA — California Consumer Privacy Act (USA)

**Full text:** [CA OAG](https://oag.ca.gov/privacy/ccpa) | **CPPA regulations:** [cppa.ca.gov](https://cppa.ca.gov/regulations/)

### Scope

Applies to for-profit businesses that collect California consumers' personal information AND meet any threshold:
- Annual gross revenue > $25 million
- Buy, sell, or share PI of 100,000+ consumers or households annually
- Derive 50%+ of revenue from selling or sharing PI

**Does not apply to:** Non-profits, government agencies, businesses below all thresholds.

### Consumer Rights

| Right | Section | Summary |
|-------|---------|---------|
| Right to know | §1798.100 | What PI is collected, sources, purposes, third parties shared with. |
| Right to delete | §1798.105 | Request deletion of PI collected. Exceptions for legal compliance, security, etc. |
| Right to opt-out of sale/sharing | §1798.120 | "Do Not Sell or Share My Personal Information" link required. |
| Right to correct | §1798.106 | Request correction of inaccurate PI (CPRA addition). |
| Right to limit sensitive PI use | §1798.121 | Limit use of sensitive PI to what is necessary for the service (CPRA addition). |
| Non-discrimination | §1798.125 | Cannot discriminate against consumers who exercise rights. |

### Key Distinctions

- **Sale vs. sharing:** "Sale" = PI exchanged for monetary consideration. "Sharing" = PI disclosed for cross-context behavioural advertising (CPRA addition — closes the "we don't sell data" loophole for ad tech).
- **Business vs. service provider vs. contractor:** Business = controller equivalent. Service provider = processes PI on behalf of business under contract. Contractor = similar to service provider with additional audit/certification requirements (CPRA).
- **Sensitive PI:** SSN, financial account info, precise geolocation, racial/ethnic origin, religious beliefs, union membership, mail/email/text contents, genetic/biometric data, health data, sex life/orientation. Requires opt-in or "Limit Use" link.

### Enforcement

California Attorney General (original CCPA). California Privacy Protection Agency (CPPA, created by CPRA — dedicated enforcement body). Private right of action limited to data breaches involving non-encrypted/non-redacted PI (§1798.150).

---

## LGPD — Lei Geral de Proteção de Dados (Brazil)

**Full text:** [Planalto.gov.br](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/L13709.htm) | **ANPD:** [gov.br/anpd](https://www.gov.br/anpd/)

### Scope

Applies to any processing of personal data:
- Carried out in Brazil
- For the purpose of offering goods/services to individuals in Brazil
- Where the data was collected in Brazil

Broader territorial reach than GDPR in some respects (any data collected in Brazil, regardless of processor location).

### Legal Bases (Art. 7)

10 legal bases — more than GDPR's 6:

1. Consent
2. Legal or regulatory obligation
3. Public administration (public policies)
4. Research (anonymised when possible)
5. Contract performance
6. Exercise of rights in judicial/administrative/arbitral proceedings
7. Protection of life or physical safety
8. Health protection (by health professionals/authorities)
9. Legitimate interest (requires prior balancing assessment — more prescriptive than GDPR)
10. Credit protection

### Key Differences from GDPR

- **DPO requirement:** Mandatory for ALL controllers (not just high-risk processing). ANPD may simplify for small businesses.
- **Legitimate interest:** Requires a documented balancing assessment BEFORE invoking (Art. 10). GDPR recommends but doesn't mandate this format.
- **No "one-stop-shop":** ANPD is the sole authority. No cross-border coordination mechanism like EDPB.
- **Data subject rights:** Similar to GDPR (access, correction, deletion, portability, information about sharing) but includes right to information about denying consent and its consequences.

### Enforcement

ANPD (Autoridade Nacional de Proteção de Dados). Fines up to 2% of revenue in Brazil (capped at R$50 million per infraction). ANPD has been issuing guidance and regulations since 2022.

---

## ePrivacy Directive (EU)

**Full text:** [Directive 2002/58/EC](https://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX%3A32002L0058) | **Amended by:** [Directive 2009/136/EC](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex%3A32009L0136)

### Scope

Applies to the processing of personal data in connection with electronic communications services. Covers:
- Confidentiality of communications
- Traffic and location data
- **Cookies and similar tracking technologies (Art. 5(3))** — the most relevant provision for software engineering

### Relationship to GDPR

The ePrivacy Directive is **lex specialis** (special law) to the GDPR. Where both apply, ePrivacy takes precedence for electronic communications. GDPR provides the legal basis framework (e.g., consent under Art. 5(3) must meet GDPR Art. 7 standards).

### Cookie/Tracking Consent (Art. 5(3))

Storing or accessing information on a user's device requires:
- **Prior consent** (opt-in, not opt-out)
- **Clear and comprehensive information** about purposes

**Exemptions (no consent needed):**
- Strictly necessary for the service explicitly requested by the user (e.g., shopping cart, session cookies, load balancing)
- Technical storage for the sole purpose of transmitting a communication

**Not exempt:** Analytics, advertising, social media widgets, A/B testing, preference cookies (unless strictly necessary for a requested service).

### ePrivacy Regulation (Pending)

The ePrivacy Regulation was proposed in 2017 to replace the Directive and align with GDPR. As of 2026, it remains in legislative negotiations. The Directive continues to apply, implemented through national laws in each EU member state.

---

## Emerging Frameworks

These are brief pointers, not full profiles. Skills needing deep coverage for these jurisdictions should create jurisdiction-specific modules in their skill directory.

| Jurisdiction | Law | Status | Key Feature | Source |
|-------------|-----|--------|-------------|--------|
| China | Personal Information Protection Law (PIPL) | In force (Nov 2021) | Consent-heavy, strict cross-border transfer rules, government access provisions | [NPC Standing Committee](http://www.npc.gov.cn/npc/c30834/202108/a8c4e3672c74491a80b53a172bb753fe.shtml) |
| India | Digital Personal Data Protection Act (DPDPA) | In force (Aug 2023, rules pending) | Consent managers, deemed consent for certain state processing, significant data fiduciary obligations | [MeitY](https://www.meity.gov.in/data-protection-framework) |
| US States | Colorado, Connecticut, Virginia, Texas, Oregon, Montana, + others | Various effective dates (2023–2025) | Generally follow CCPA model with variations. No federal comprehensive privacy law. | [IAPP US State Law Tracker](https://iapp.org/resources/article/us-state-privacy-legislation-tracker/) |
| Canada | PIPEDA / proposed CPPA | PIPEDA in force; CPPA (C-27) pending | Consent-based, accountability principle, proposed tribunal model | [OPC Canada](https://www.priv.gc.ca/en/) |
| South Korea | PIPA (amended 2023) | In force | Pseudonymised data framework, mandatory DPO, PIPC enforcement | [PIPC](https://www.pipc.go.kr/eng/index.do) |

**Note:** Regulatory landscapes change frequently. Verify current status before relying on these pointers. Last verified: 2026-03-15.
