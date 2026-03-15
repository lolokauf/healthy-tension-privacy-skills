# Privacy Principles & Frameworks

Cross-skill reference for foundational privacy frameworks. Skills reference this file when they need to ground analysis in established theory rather than (or in addition to) regulatory requirements.

**How to choose which framework applies:**
- **System design review?** → Privacy by Design (Cavoukian)
- **Evaluating whether a data flow is appropriate?** → Contextual Integrity (Nissenbaum)
- **Identifying what could go wrong?** → Taxonomy of Privacy (Solove)
- **No specific regulation applies?** → FIPPs as baseline

---

## Cavoukian's 7 Foundational Principles of Privacy by Design

Ann Cavoukian's PbD framework (2009) is the most widely adopted privacy engineering framework. It is referenced in GDPR Art. 25 ("data protection by design and by default") and ISO 31700.

| # | Principle | Definition | Engineering Implication | Example |
|---|-----------|-----------|------------------------|---------|
| 1 | Proactive not Reactive | Anticipate and prevent privacy-invasive events before they happen. | Every new data field needs a documented purpose BEFORE collection. Code review gates should catch unjustified PII. | Requiring a `purpose` annotation in DB schema comments for every PII column. |
| 2 | Privacy as the Default | Personal data is automatically protected. No action required by the individual. | All privacy-related config defaults to the most protective setting. Opt-in, never opt-out. | `analytics_enabled: false` as the default; user must actively enable. |
| 3 | Privacy Embedded into Design | Privacy is integral to the system architecture, not bolted on. | PII handled through dedicated abstraction layers, not scattered across the codebase. | A `PersonalDataStore` service that centralises all PII access with audit logging. |
| 4 | Full Functionality (Positive-Sum) | Privacy and functionality are not trade-offs. Accommodate both. | Find privacy-preserving alternatives that achieve the same business goal. | Aggregate analytics with k-anonymity instead of raw user-level event tracking. |
| 5 | End-to-End Security | Full lifecycle protection from collection to deletion. | Encryption at rest and in transit. Defined retention policies. Secure deletion mechanisms (not just soft-delete). | AES-256 at rest, TLS 1.3 in transit, automated hard-delete after retention period. |
| 6 | Visibility and Transparency | Operations are verifiable and auditable. | Machine-readable data inventories. Privacy policies that match actual code behaviour. Third-party dependency audits. | A `data_inventory.yaml` that is cross-referenced against the codebase in CI. |
| 7 | Respect for User Privacy | Keep the interests of the individual uppermost. User-centric defaults and controls. | Granular consent, easy-to-find privacy settings, complete account deletion, no dark patterns. | Account deletion that purges ALL data stores including analytics and backups. |

**Detailed review checklists per principle:** See `skills/pbd-code-review/checklists/cavoukian-7-principles.md`.

**Reference:** Cavoukian, A. (2009). *Privacy by Design: The 7 Foundational Principles.* Information and Privacy Commissioner of Ontario.

---

## Nissenbaum's Contextual Integrity

Helen Nissenbaum's Contextual Integrity (CI) framework (2004, expanded 2010) argues that privacy is not about secrecy or control, but about **appropriate information flows** relative to social context.

### Core Idea

Privacy norms are context-dependent. What is appropriate in a healthcare context (sharing medical records with a specialist) is inappropriate in a commercial context (sharing medical records with an advertiser). Privacy violations occur when information flows breach the norms of the context they occur in.

### The 5 Parameters

Every information flow can be described by 5 parameters:

| Parameter | Description | Example |
|-----------|-------------|---------|
| **Data subject** | Whose information is flowing | A patient |
| **Sender** | Who transmits the information | A primary care physician |
| **Recipient** | Who receives the information | A specialist physician |
| **Information type** | What kind of information | Diagnostic test results |
| **Transmission principle** | Under what conditions the flow occurs | With patient consent, for treatment purposes |

A flow is **contextually appropriate** if it conforms to the norms governing that context. A flow **violates contextual integrity** if it introduces a new pattern that breaks established norms — even if the data subject consented.

### Engineering Application

Use CI when regulatory guidance is ambiguous or absent. Ask:

1. **What is the context?** (healthcare, commerce, education, social, employment)
2. **What are the established norms for information flow in this context?**
3. **Does the proposed data flow conform to those norms?**
4. **If not, is there a compelling justification for the deviation?**

CI is particularly useful for evaluating:
- Third-party data sharing arrangements (does the recipient belong to the expected context?)
- Secondary use of data (was this data collected for a different context?)
- Inference and profiling (does deriving new information types change the context?)

**Reference:** Nissenbaum, H. (2010). *Privacy in Context: Technology, Policy, and the Integrity of Social Life.* Stanford University Press.

---

## Solove's Taxonomy of Privacy

Daniel Solove's taxonomy (2006) organises privacy harms into 4 categories with specific sub-types. This is useful for **threat identification** — mapping code patterns to the types of privacy harm they could cause.

### The 4 Categories

#### 1. Information Collection

Harms arising from how data is gathered.

| Sub-type | Definition | Code Pattern |
|----------|-----------|-------------|
| **Surveillance** | Watching, listening to, or recording an individual's activities | Always-on microphone, continuous location tracking, keystroke logging |
| **Interrogation** | Pressuring individuals to divulge information | Mandatory fields with no purpose justification, dark patterns in data collection forms |

#### 2. Information Processing

Harms arising from how stored data is used.

| Sub-type | Definition | Code Pattern |
|----------|-----------|-------------|
| **Aggregation** | Combining data to create a more complete profile | Merging datasets across services, cross-device tracking |
| **Identification** | Linking data to a specific individual | Joining anonymised datasets with identifiers, fingerprinting |
| **Insecurity** | Failing to protect stored data | Unencrypted PII, overly broad database access, PII in logs |
| **Secondary use** | Using data for purposes beyond the original collection reason | Analytics data used for targeted advertising, health data used for insurance pricing |
| **Exclusion** | Failing to give individuals knowledge or input about their data | No data access mechanism, no correction process, opaque automated decisions |

#### 3. Information Dissemination

Harms arising from how data is shared or disclosed.

| Sub-type | Definition | Code Pattern |
|----------|-----------|-------------|
| **Breach of confidentiality** | Breaking a promise about data handling | Sharing data contrary to privacy policy commitments |
| **Disclosure** | Revealing truthful information that causes harm | Exposing sensitive data through API responses, error messages, or logs |
| **Exposure** | Revealing intimate or embarrassing information | Displaying health conditions, financial status, or personal preferences publicly |
| **Distortion** | Disseminating misleading information | Inaccurate profile data used for decisions, uncorrected records |

#### 4. Invasion

Harms from intrusion into an individual's life.

| Sub-type | Definition | Code Pattern |
|----------|-----------|-------------|
| **Intrusion** | Disturbing an individual's solitude or tranquillity | Excessive notifications, unwanted contact based on tracked behaviour |
| **Decisional interference** | Influencing personal decisions through information asymmetry | Manipulative recommendation algorithms, dark patterns in consent flows |

**Reference:** Solove, D. (2006). *A Taxonomy of Privacy.* University of Pennsylvania Law Review, 154(3), 477–564.

---

## FIPPs — Fair Information Practice Principles

The FIPPs originate from the OECD Guidelines on the Protection of Privacy (1980) and the US FTC's Fair Information Practice Principles. They underpin virtually every modern privacy law and provide the **baseline principles** when no specific regulation applies.

| Principle | Definition | Modern Regulatory Expression |
|-----------|-----------|------------------------------|
| **Collection limitation** | Collect only what is necessary, by lawful and fair means, with knowledge/consent. | GDPR Art. 5(1)(c) (data minimisation), CCPA §1798.100 |
| **Data quality** | Personal data should be accurate, complete, and kept up-to-date. | GDPR Art. 5(1)(d) (accuracy), CCPA right to correct (§1798.106) |
| **Purpose specification** | Purposes should be specified at the time of collection. | GDPR Art. 5(1)(b) (purpose limitation), CCPA §1798.100(a) |
| **Use limitation** | Data should not be used for purposes other than those specified, except with consent or legal authority. | GDPR Art. 5(1)(b), CCPA §1798.100(a)(1) |
| **Security safeguards** | Protect data with reasonable security measures. | GDPR Art. 5(1)(f) (integrity and confidentiality), CCPA §1798.150 |
| **Openness** | There should be a general policy of openness about data practices. | GDPR Art. 12–14 (transparency), CCPA §1798.100(b) |
| **Individual participation** | Individuals should have the right to access, correct, and challenge their data. | GDPR Art. 15–22 (data subject rights), CCPA §1798.100–110 |
| **Accountability** | Data controllers should be accountable for complying with these principles. | GDPR Art. 5(2) (accountability), CCPA enforcement mechanisms |

**Why FIPPs matter for skills:** When a skill operates in a jurisdiction without specific privacy legislation, or when the user doesn't specify a jurisdiction, FIPPs provide the floor. They are never wrong to apply.

**Reference:** OECD (1980, updated 2013). *Guidelines on the Protection of Privacy and Transborder Flows of Personal Data.* [oecd.org](https://www.oecd.org/sti/ieconomy/oecdguidelinesontheprotectionofprivacyandtransborderflowsofpersonaldata.htm)

---

## Framework Comparison

| Framework | Best For | Regulatory Alignment | Used By Skills |
|-----------|---------|---------------------|----------------|
| **Privacy by Design** (Cavoukian) | System design reviews, code audits, architecture assessment | GDPR Art. 25, ISO 31700 | pbd-code-review |
| **Contextual Integrity** (Nissenbaum) | Evaluating data flow appropriateness, third-party sharing decisions | Principle-based (no direct regulatory mandate) | data-mapping (context assessment), consent-flow-reviewer |
| **Taxonomy of Privacy** (Solove) | Threat identification, privacy impact categorisation | Principle-based (maps to regulatory harms) | threat modelling in any skill |
| **FIPPs** (OECD/FTC) | Baseline principles when no regulation specified | Underpins GDPR, CCPA, LGPD, and most modern privacy laws | All skills (default fallback) |

**Rule of thumb:** Start with FIPPs as the floor. Layer PbD for design reviews. Use CI when evaluating whether a specific data flow is appropriate. Use Solove when cataloguing what could go wrong.
