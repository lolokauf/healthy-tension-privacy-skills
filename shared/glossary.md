# Privacy Glossary

Consistent terminology for use across all skills in this library. Terms are grouped by category and include cross-jurisdictional equivalents where applicable.

**Convention:** Skills should use the term as defined here. Where a term has jurisdiction-specific equivalents, use the jurisdiction-neutral term by default and note the jurisdiction-specific term in Jurisdiction Notes sections.

---

## Core Privacy Terms

**Adequacy decision** — A determination by a regulatory authority that a third country provides an adequate level of data protection, enabling data transfers without additional safeguards. *GDPR: Art. 45 adequacy decision. CCPA: no equivalent.*

**Anonymisation** — The irreversible process of altering personal data so that the individual is no longer identifiable, directly or indirectly. Truly anonymised data is no longer personal data and falls outside the scope of privacy regulations. Contrast with *pseudonymisation*, which is reversible.

**Consent** — A freely given, specific, informed, and unambiguous indication of a data subject's agreement to the processing of their personal data. *GDPR: Art. 7. CCPA: opt-in consent required for sensitive PI and minors; opt-out model for sale/sharing. LGPD: Art. 8.*

**Cross-border transfer** — The movement of personal data from one jurisdiction to another. Most privacy frameworks restrict transfers to countries without adequate data protection unless safeguards are in place. *GDPR: Art. 44–49 (SCCs, BCRs, adequacy). CCPA: no direct restriction, but contractual obligations flow through. LGPD: Art. 33.*

**Data breach** — A security incident leading to the accidental or unlawful destruction, loss, alteration, unauthorised disclosure of, or access to personal data. *GDPR: Art. 4(12), notification within 72 hours (Art. 33). CCPA: §1798.150 (private right of action for breaches of non-encrypted/non-redacted PI). LGPD: Art. 48.*

**Data controller** — The entity that determines the purposes and means of processing personal data. *GDPR: controller (Art. 4(7)). CCPA: business (§1798.140(d)). LGPD: controlador (Art. 5(VI)).*

**Data minimisation** — The principle that personal data collected should be adequate, relevant, and limited to what is necessary for the stated purpose. *GDPR: Art. 5(1)(c). CCPA: §1798.100(c) (collection proportional to purpose). LGPD: Art. 6(III).*

**Data processor** — An entity that processes personal data on behalf of a controller, under the controller's instructions. *GDPR: processor (Art. 4(8)). CCPA: service provider (§1798.140(ag)) or contractor (§1798.140(j)). LGPD: operador (Art. 5(VII)).*

**Data Protection Impact Assessment (DPIA)** — A systematic assessment of a processing activity's impact on data subjects' privacy rights, required when processing is likely to result in high risk. Also called Privacy Impact Assessment (PIA). *GDPR: Art. 35. CCPA: no direct equivalent (risk assessments proposed under CPRA regulations). LGPD: Art. 38 (relatório de impacto).*

**Data subject** — The identified or identifiable natural person whose personal data is processed. *GDPR: data subject (Art. 4(1)). CCPA: consumer (§1798.140(i)). LGPD: titular (Art. 5(V)).*

**Data subject rights** — The rights of individuals regarding their personal data, including access, rectification, erasure, portability, and objection. See `shared/jurisdiction-profiles.md` for jurisdiction-specific rights.

**Legitimate interest** — A lawful basis for processing where the controller or a third party has a legitimate interest that is not overridden by the data subject's rights and freedoms. Requires a balancing test. *GDPR: Art. 6(1)(f). CCPA: no direct equivalent. LGPD: Art. 7(IX) (requires prior documented balancing assessment).*

**Personal data** — Any information relating to an identified or identifiable natural person. *GDPR: personal data (Art. 4(1)). CCPA: personal information (§1798.140(v)). LGPD: dados pessoais (Art. 5(I)).* Note: CCPA's definition extends to household-level data.

**Processing** — Any operation performed on personal data, including collection, recording, organisation, structuring, storage, adaptation, alteration, retrieval, consultation, use, disclosure, dissemination, alignment, combination, restriction, erasure, or destruction. *GDPR: Art. 4(2). CCPA: §1798.140(y) (uses "collects, sells, shares" rather than a unified "processing" concept). LGPD: tratamento (Art. 5(X)).*

**Purpose limitation** — The principle that personal data should be collected for specified, explicit, and legitimate purposes and not further processed in a manner incompatible with those purposes. *GDPR: Art. 5(1)(b). CCPA: §1798.100(a)(1). LGPD: Art. 6(I).*

**Records of Processing Activities (RoPA)** — A documented inventory of processing activities maintained by controllers and processors. *GDPR: Art. 30. CCPA: no direct equivalent (data inventories encouraged but not mandated). LGPD: recommended by ANPD guidance.*

**Special categories of data** — Personal data revealing racial or ethnic origin, political opinions, religious or philosophical beliefs, trade union membership, genetic data, biometric data, health data, or data concerning sex life or sexual orientation. Subject to additional protections. *GDPR: Art. 9. CCPA: sensitive personal information (§1798.140(ae)). LGPD: dados pessoais sensíveis (Art. 5(II)).*

**Storage limitation** — The principle that personal data should be kept for no longer than is necessary for the purposes for which it was processed. *GDPR: Art. 5(1)(e). CCPA: §1798.100(a)(3) (retention proportional to purpose). LGPD: Art. 15–16.*

**Supervisory authority** — An independent public authority responsible for monitoring the application of data protection law. *GDPR: supervisory authority / DPA (Art. 51). CCPA: California Privacy Protection Agency (CPPA). LGPD: ANPD (Autoridade Nacional de Proteção de Dados).*

---

## Technical Privacy Terms

**Differential privacy** — A mathematical framework providing provable privacy guarantees by adding calibrated noise to data queries or outputs. Ensures that the inclusion or exclusion of any single individual's data does not significantly affect the output.

**Federated learning** — A machine learning approach where models are trained across decentralised devices holding local data, without exchanging the raw data. Reduces the need for centralised data collection.

**Homomorphic encryption** — An encryption scheme that allows computations on encrypted data without decrypting it first. Enables processing while maintaining confidentiality.

**k-anonymity** — A property of a dataset where each record is indistinguishable from at least k-1 other records with respect to certain identifying attributes. Vulnerable to homogeneity and background knowledge attacks.

**l-diversity** — An extension of k-anonymity that ensures each equivalence class contains at least l "well-represented" values for the sensitive attribute. Addresses the homogeneity weakness of k-anonymity.

**Data masking** — The process of replacing sensitive data with realistic but non-sensitive substitutes. Used in non-production environments and for display purposes (e.g., showing only last 4 digits of a card number).

**Privacy budget (epsilon)** — In differential privacy, the parameter ε (epsilon) that quantifies the maximum privacy loss. Smaller ε = stronger privacy guarantee but less data utility. A finite resource that is consumed with each query.

**Privacy-enhancing technologies (PETs)** — Technologies that protect personal data by minimising collection, preventing unnecessary processing, or enabling data utility without exposing individual records. Includes differential privacy, homomorphic encryption, secure multi-party computation, federated learning, and synthetic data generation.

**Pseudonymisation** — The processing of personal data such that it can no longer be attributed to a specific individual without additional information (the "key"), provided that key is kept separately. Unlike anonymisation, pseudonymisation is reversible and the data remains personal data. *GDPR: Art. 4(5).*

**Record linkage** — The process of identifying records in one or more datasets that refer to the same entity. A key technique in re-identification attacks.

**Re-identification** — The process of matching anonymised or pseudonymised data back to specific individuals, often through linkage with other datasets. Demonstrates that a dataset was not truly anonymised.

**Synthetic data** — Artificially generated data that preserves the statistical properties of real data without containing actual personal information. Used for testing, development, and research.

**t-closeness** — An extension of l-diversity that requires the distribution of sensitive attributes in each equivalence class to be close to the distribution of the attribute in the overall dataset.

**Tokenisation** — Replacing sensitive data elements with non-sensitive equivalents (tokens) that have no exploitable meaning. Unlike encryption, tokenisation does not use a mathematical algorithm — the mapping is stored in a secure token vault.

---

## Regulatory Role Terms

**Business** — CCPA term for an entity that determines the purposes and means of processing consumers' personal information. Equivalent to GDPR *controller*.

**Contractor** — CCPA/CPRA term for an entity that receives personal information from a business under a written contract with additional audit and certification requirements. Similar to *service provider* but with stricter obligations.

**Data Protection Officer (DPO)** — A designated individual responsible for overseeing data protection strategy and compliance. *GDPR: mandatory for public authorities and organisations conducting large-scale systematic monitoring or processing special categories (Art. 37). LGPD: mandatory for all controllers (encarregado).*

**Joint controller** — Two or more controllers that jointly determine the purposes and means of processing. Must have a transparent arrangement determining their respective responsibilities. *GDPR: Art. 26.*

**Representative** — An entity designated by a controller or processor not established in the EU to act as a contact point for supervisory authorities and data subjects. *GDPR: Art. 27.*

**Service provider** — CCPA term for an entity that processes personal information on behalf of a business under a written contract prohibiting selling/sharing the data. Equivalent to GDPR *processor*.

**Sub-processor** — A processor engaged by another processor to carry out processing activities on behalf of the controller. Requires prior authorisation from the controller. *GDPR: Art. 28(2).*

**Third party** — An entity that is not the controller, processor, or data subject, and is not authorised to process data under the controller's direct authority. *GDPR: Art. 4(10). CCPA: third party (§1798.140(ai)).*
