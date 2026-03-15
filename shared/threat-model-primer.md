# Privacy Threat Model Primer

A reference for identifying privacy threats in code and assessing the risk of privacy skills giving incorrect guidance.

**When to invoke threat modelling:**
- When a skill is being authored (assess blast radius of bad advice)
- When a skill identifies a data flow that doesn't fit established patterns
- When evaluating third-party integrations or cross-border transfers

**Scope:** This covers privacy threats, not general security threats. Security and privacy overlap (e.g., data breaches), but this primer focuses on threats to informational self-determination — the individual's ability to control how their data is collected, used, and shared.

---

## Privacy Threat Categories

These are the common ways software systems can harm individuals' privacy. For each: a definition, the code pattern that creates the risk, and an example finding a skill might produce.

| Threat | Definition | Code Pattern | Example Finding |
|--------|-----------|-------------|-----------------|
| **Overcollection** | Collecting more personal data than necessary for the stated purpose. | Form fields with no documented purpose, mandatory fields that should be optional, collecting precise location when city-level suffices. | "The signup form collects date of birth, phone number, and gender. Only email is required for account creation. The remaining fields have no documented purpose." |
| **Unauthorised access** | Personal data accessible to individuals or systems that should not have access. | Overly broad database permissions, PII in shared logs, API endpoints missing authentication, PII in error responses. | "The /admin/users endpoint returns full user records including email and recovery phrase hints without role-based access control." |
| **Re-identification** | Linking anonymised or pseudonymised data back to specific individuals. | Unique identifiers in "anonymised" datasets, insufficient k-anonymity, combining datasets that enable triangulation. | "The analytics export includes timestamp + browser fingerprint + page sequence, which is sufficient to re-identify users with >80% accuracy." |
| **Function creep** | Using data for purposes beyond the original stated purpose, often incrementally. | Analytics data repurposed for personalisation, support logs used for marketing targeting, health data used for insurance scoring. | "User location data collected for delivery tracking is also passed to the recommendation engine. No consent was obtained for this secondary use." |
| **Inference** | Deriving sensitive information about individuals from non-sensitive data. | Purchase history revealing health conditions, browsing patterns revealing political affiliation, location data revealing religious practices. | "The recommendation algorithm can infer pregnancy status from purchase patterns. This derived data is not classified as health data in the data inventory." |
| **Linkage** | Combining data from multiple sources to create a more complete profile than any single source would allow. | Cross-device tracking, merging first-party data with purchased datasets, combining service data with social media profiles. | "The user profile service merges data from the web app, mobile app, and customer support tool using email as the join key, creating a comprehensive behavioural profile not disclosed in the privacy policy." |
| **Surveillance** | Continuous or systematic monitoring of individuals' activities. | Always-on location tracking, continuous screen recording, keystroke logging, ambient audio collection. | "The mobile SDK polls GPS location every 30 seconds in the background, even when the app is not in active use." |
| **Secondary use** | Processing data for purposes different from those for which it was originally collected. | Marketing emails sent using support ticket contact info, training ML models on user content, sharing analytics with advertisers. | "Customer support email addresses are passed to the marketing automation platform. The privacy policy states support data is used only for 'resolving your inquiry.'" |
| **Exclusion** | Failing to provide individuals with knowledge about or participation in decisions made about their data. | No data access mechanism, opaque algorithmic decisions, no correction process, no notification of data sharing. | "The credit scoring module uses third-party data to adjust user limits, but there is no mechanism for users to view, challenge, or correct this data." |

---

## LINDDUN Methodology

LINDDUN is a systematic privacy threat modelling framework developed by KU Leuven. It provides structured threat enumeration complementary to Solove's taxonomy.

### The 7 Threat Types

| LINDDUN Type | Definition | Solove Equivalent | Typical Code Pattern |
|-------------|-----------|-------------------|---------------------|
| **Linking** | Associating data items or actions with an individual or linking information across sources. | Aggregation, Identification | Cross-device identifiers, email as universal join key, tracking cookies across domains |
| **Identifying** | Learning the identity of an individual from a dataset or system. | Identification | Insufficient anonymisation, unique behavioural patterns, browser fingerprinting |
| **Non-repudiation** | Being unable to deny having performed an action (when deniability is expected). | — (not directly mapped) | Immutable audit logs of sensitive actions, blockchain-based identity records |
| **Detecting** | Determining that an individual is the subject of data in a system. | Surveillance | Membership inference attacks on ML models, confirming account existence via error messages |
| **Data disclosure** | Unauthorised exposure of personal data. | Disclosure, Breach of confidentiality | API responses leaking PII, PII in log files, unencrypted data at rest |
| **Unawareness** | Individuals not knowing what data is collected, how it is used, or what rights they have. | Exclusion | Missing privacy notices, no data access mechanism, opaque automated decisions |
| **Non-compliance** | Failing to comply with privacy legislation, policies, or best practices. | — (meta-category) | Missing consent mechanisms, no retention policy, inadequate DSAR response |

### When to Use LINDDUN

LINDDUN is most useful for **systematic threat enumeration during design reviews**. It pairs naturally with the PbD Code Review skill — after identifying data flows (Principles 1, 3, 6), use LINDDUN categories to systematically check for threats at each flow point.

**Process:**
1. Map data flows (use the Data Mapping skill output)
2. For each flow, walk through the 7 LINDDUN categories
3. For each applicable threat, assess likelihood and impact
4. Document findings with confidence levels

**Reference:** Deng, M., Wuyts, K., Scandariato, R., Preneel, B., & Joosen, W. (2011). *A Privacy Threat Analysis Framework: Supporting the Elicitation and Fulfillment of Privacy Requirements.* Requirements Engineering, 16(1), 3–32.

---

## Skill Blast Radius Assessment

When authoring a skill, assess: **what happens if this skill gives wrong advice?**

### Risk Factors

| Factor | Description | Assessment Questions |
|--------|-------------|---------------------|
| **Regulatory consequence** | Could incorrect guidance lead to fines or enforcement actions? | Does the skill's output serve as input to a compliance artifact (DPIA, RoPA)? Could a user submit the output to a regulator? |
| **User harm** | Could incorrect guidance lead to individuals' data being exposed, misused, or used for discrimination? | Does the skill assess data handling that affects real people's privacy? Could a false "all clear" lead to a data breach going undetected? |
| **Organisational impact** | Could incorrect guidance lead to breach notifications, lawsuits, or reputational damage? | Does the skill evaluate security measures? Does it assess data sharing arrangements? |
| **False confidence** | Could the skill cause users to believe they are compliant when they are not? | Does the skill produce assessments that users might treat as certification? Does it use language that implies legal sufficiency? |

### Blast Radius Calibration

| Blast Radius | Description | Skill Examples | Mitigation |
|-------------|-------------|---------------|------------|
| **HIGH** | Output could directly cause regulatory non-compliance or user harm if incorrect. | DPIA Generator (false compliance), Privacy Policy Drafter (legally insufficient policies), DSAR Planner (incomplete deletion). | Aggressive "consult a professional" triggers. Lower confidence thresholds (default to MEDIUM/LOW). Prominent disclaimers. Require human review before submission. |
| **MEDIUM** | Output informs decisions but is not directly a compliance artifact. Errors are discoverable through other means. | PbD Code Review (missed findings may be caught in testing), Consent Flow Reviewer (issues visible to users), Data Mapping (incomplete inventory is better than none). | Standard confidence levels. "What This Skill Cannot Do" section covers known blind spots. Recommend periodic re-runs. |
| **LOW** | Output is informational or educational. Errors have limited downstream impact. | Glossary lookups, general privacy guidance, threat enumeration (identifying possible threats, not assessing compliance). | Standard disclaimers sufficient. |

**Rule:** A skill's blast radius determines how aggressively it should recommend human review. HIGH blast radius skills should default to lower confidence levels and include more explicit "consult a professional" triggers.

---

## When to Recommend Human Review

Skills should recommend human review when any of the following conditions are met. This is a heuristic, not a rigid rule — apply judgment based on context.

### Trigger Conditions

| Condition | Why | Phrasing Guidance |
|-----------|-----|-------------------|
| **Confidence is LOW on any finding** | LOW confidence means the skill encountered an ambiguous situation. A human can apply judgment the skill cannot. | "This finding has LOW confidence. A privacy professional should review [specific area] before acting on this assessment." |
| **Cross-border data transfer identified** | Transfer mechanisms (SCCs, adequacy, derogations) require legal analysis beyond code review. | "This data flow involves a cross-border transfer to [country]. Verify that an appropriate transfer mechanism is in place. See `shared/jurisdiction-profiles.md` for transfer mechanism options." |
| **Special categories of data involved** | Health, biometric, genetic, children's data, and other special categories have heightened requirements across all jurisdictions. | "This processing involves [special category] data, which is subject to additional legal requirements. Consult a privacy professional before proceeding." |
| **Balancing test required** | Legitimate interest assessments, proportionality evaluations, and necessity tests require human judgment. | "This processing relies on legitimate interest as the legal basis. A formal balancing assessment (controller's interest vs. data subject's rights) should be conducted by a privacy professional." |
| **Output will be used as a compliance artifact** | DPIAs, RoPAs, and privacy policies submitted to regulators must be reviewed by qualified professionals. | "This output is a draft [DPIA/RoPA/policy]. It must be reviewed and approved by a qualified privacy professional before submission or publication." |
| **Unrecognised pattern** | When the skill encounters a data handling pattern it wasn't designed for. | "This data flow does not match any pattern this skill is designed to evaluate. Manual review is recommended." |

### Phrasing Principles

- **Be firm but not alarming.** "Consult a privacy professional" not "WARNING: CRITICAL COMPLIANCE RISK."
- **Be specific about what needs review.** "Review the cross-border transfer mechanism for the PostHog integration" not "Have a lawyer check everything."
- **Provide context for the recommendation.** Explain why human review is needed so the reviewer knows what to focus on.
- **Never imply that skipping review is acceptable.** The recommendation is a gate, not a suggestion.
