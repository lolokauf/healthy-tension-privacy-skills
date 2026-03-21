# WP29 DPIA Criteria Checklist

Reference checklist for the DPIA Generator skill. Contains the two-tier trigger assessment logic: Art. 35(3) mandatory triggers evaluated independently, then the WP29 9-criteria heuristic.

---

## Two-Tier Trigger Logic

**Tier 1 — Art. 35(3) Mandatory Triggers** are each independently sufficient to require a DPIA. If any one is met, a DPIA is required regardless of the WP29 criteria count.

**Tier 2 — WP29 9-Criteria Heuristic** supplements Art. 35(3). Each criterion is scored as PRESENT, ABSENT, or BORDERLINE. Per WP248 rev.01, if 2 or more criteria are PRESENT, a DPIA should generally be conducted.

Both tiers are always assessed. A processing operation may trigger a mandatory DPIA under Tier 1 AND meet multiple WP29 criteria — document both for completeness.

---

## Tier 1: Art. 35(3) Mandatory Triggers

| Trigger | Description | Code Patterns to Search | Example Match |
|---------|-------------|-------------------------|---------------|
| **(a)** Automated evaluation with significant effects | Systematic and extensive evaluation of personal aspects based on automated processing, including profiling, producing legal or similarly significant effects | `predict`, `score`, `classify`, `recommend`, `ml.predict`, `model.infer`, credit scoring functions, loan approval logic, automated hiring/screening pipelines | ML model scores user creditworthiness; output feeds automatic loan approval/denial |
| **(b)** Large-scale special categories | Processing on a large scale of special categories (Art. 9) or criminal conviction data (Art. 10) | `health`, `diagnosis`, `medical`, `biometric`, `ethnicity`, `religion`, `political`, `sexual_orientation`, `trade_union`, `genetic`, `criminal`, health record schemas, biometric template storage | Database table storing patient diagnoses for a health platform serving thousands of users |
| **(c)** Systematic public monitoring | Systematic monitoring of a publicly accessible area on a large scale | `cctv`, `camera`, `surveillance`, `wifi_probe`, `bluetooth_beacon`, `facial_recognition`, `license_plate`, geofence on public areas, footfall tracking | Wi-Fi probe collection in a shopping centre tracking device MAC addresses |

---

## Tier 2: WP29 9-Criteria Table

| # | Criterion | Definition | Code Patterns to Search | Example Match | Art. 35(3) Cross-Reference |
|---|-----------|-----------|-------------------------|---------------|---------------------------|
| 1 | **Evaluation or scoring** | Profiling and predicting, especially aspects concerning data subject's performance, economic situation, health, preferences, interests, reliability, behaviour, location, or movements | `score`, `rank`, `predict`, `classify`, `profile`, `segment`, `cluster`, `recommend`, `risk_score`, `credit_check`, `fraud_score`, `churn_prediction`, `sentiment_analysis` | `calculateRiskScore(user)` returns a numeric rating used in downstream decisions | Overlaps Art. 35(3)(a) — if evaluation produces legal/significant effects, the mandatory trigger is also met |
| 2 | **Automated decision-making with legal or similar effect** | Processing that produces decisions with legal or similarly significant effects on data subjects | `auto_approve`, `auto_reject`, `auto_deny`, `decision_engine`, `eligibility_check`, `automated_review`, `no_human_review`, `instant_decision`, approval/rejection without human-in-the-loop flags | `if (score < threshold) return { decision: 'DENIED' }` with no manual review pathway | Overlaps Art. 35(3)(a) — automated decisions with significant effects directly trigger the mandatory requirement |
| 3 | **Systematic monitoring** | Observation, monitoring, or control of data subjects, including data collected via networks or systematic tracking | `track`, `monitor`, `observe`, `log_activity`, `session_recording`, `heatmap`, `keylog`, `mouse_tracking`, `screen_capture`, `location_history`, `geofence`, `beacon`, `analytics.track`, `event_stream`, continuous sensor data collection | `trackUserBehaviour({ clicks: true, scrolls: true, sessionReplay: true })` recording all user interactions | Overlaps Art. 35(3)(c) — if monitoring covers a publicly accessible area at large scale, the mandatory trigger is also met |
| 4 | **Sensitive data or data of a highly personal nature** | Special categories per Art. 9, criminal conviction data per Art. 10, or highly personal data (communications content, location, financial, children's data) | `health_data`, `medical_record`, `biometric`, `genetic`, `ethnicity`, `religion`, `political_opinion`, `trade_union`, `sexual_orientation`, `criminal_record`, `message_content`, `call_log`, `gps_coordinates`, `bank_account`, `salary`, `child`, `minor`, `age_gate`, `parental_consent` | Schema column `diagnosis: text` in a `patient_records` table | Overlaps Art. 35(3)(b) — if sensitive data is processed at large scale, the mandatory trigger is also met |
| 5 | **Data processed on a large scale** | Volume of data subjects, data volume, duration, geographic extent, or proportion of relevant population | Large batch processing, `bulk_import`, `batch_process`, `stream_processor`, database tables with millions of rows (pagination patterns suggesting scale), `kafka`, `rabbitmq`, `pubsub`, `event_bus`, distributed processing frameworks, sharding configurations | Kafka consumer processing 500K user events per day across EU markets | Scale factor for Art. 35(3)(a), (b), and (c) |
| 6 | **Matching or combining datasets** | Combining data from two or more processing operations performed for different purposes or by different controllers | `merge`, `join`, `enrich`, `combine`, `match`, `link`, `deduplicate`, `cross_reference`, `data_fusion`, `identity_resolution`, `unified_profile`, multi-source data pipelines, CRM enrichment from external APIs | `enrichUserProfile(userData, purchaseHistory, thirdPartyDemographics)` merging 3 data sources | No direct Art. 35(3) overlap, but combining increases re-identification and purpose creep risk |
| 7 | **Data concerning vulnerable data subjects** | Children, employees, mentally ill persons, asylum seekers, elderly, patients, or any subjects in an asymmetric power relationship | `child`, `minor`, `student`, `patient`, `employee`, `inmate`, `refugee`, `asylum`, `elderly`, `disability`, `parental_consent`, `age_verification`, `COPPA`, `child_safety`, school/hospital/employer-specific schemas | `parental_consent_required: true` flag in user registration for a children's education platform | Vulnerability is an amplifying factor — heightens severity of any Art. 35(3) trigger |
| 8 | **Innovative use or applying new technological or organisational solutions** | Using new technology whose privacy impact is not yet fully understood | `ml`, `ai`, `neural_network`, `deep_learning`, `llm`, `generative_ai`, `blockchain`, `smart_contract`, `iot`, `edge_computing`, `federated_learning`, `homomorphic_encryption`, `facial_recognition`, `voice_recognition`, `fingerprint`, `wearable`, novel combinations of existing technologies | `const model = new OpenAI({ model: 'gpt-4' })` processing personal data through an LLM | No direct Art. 35(3) overlap, but novel technology combined with criteria #1 or #2 strengthens the case for a mandatory trigger |
| 9 | **Processing that prevents data subjects from exercising a right or using a service or contract** | Processing that blocks or restricts data subject access to a service, contract, or their data protection rights | `block_user`, `restrict_access`, `deny_service`, `suspend_account`, `gate_feature`, `mandatory_consent`, `consent_wall`, `take_it_or_leave_it`, forced data sharing as precondition, no opt-out mechanism, bundled consent | `if (!consentToAllTracking) return redirect('/access-denied')` — no granular consent, service gated on blanket tracking acceptance | No direct Art. 35(3) overlap, but preventing rights exercise is a significant harm indicator |

---

## Borderline Case Guidance

When a criterion is difficult to classify as PRESENT or ABSENT:

- **Default to PRESENT with MEDIUM confidence.** It is safer to conduct an unnecessary DPIA than to skip a necessary one.
- Document the specific uncertainty: what code pattern was ambiguous and what additional information would resolve it.
- Common borderline scenarios:
  - Scale is unclear (no explicit user counts, but infrastructure suggests growth)
  - Profiling-like patterns exist but may not produce "significant effects"
  - Data is sensitive-adjacent (e.g., fitness data that may reveal health conditions)
  - Technology is established but used in a novel combination

---

## DPA-Published Additional Trigger Lists

National supervisory authorities publish their own lists of processing types that require a DPIA. These extend Art. 35(3) with jurisdiction-specific requirements. When assessing triggers, check whether the processing type appears on the relevant DPA's list:

- **ICO (UK):** "When do we need to do a DPIA?" — 10 processing types including profiling for direct marketing, biometric recognition in public, and large-scale financial data processing
- **CNIL (France):** List of processing types requiring a DPIA — 14 categories including HR data processing, whistleblowing schemes, and housing management data
- **DSB (Austria):** DPIA blacklist — processing types that always require a DPIA
- **Other DPAs:** Most EEA DPAs publish equivalent lists per Art. 35(4)

If the processing type appears on a DPA list for the target jurisdiction, flag it as an additional trigger regardless of WP29 criteria count.
