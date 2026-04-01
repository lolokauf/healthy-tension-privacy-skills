# LGPD Compliance Report Template

Blank template for the lgpd-review skill's output. Complete all sections — use "None identified", "N/A", or "Unknown" rather than leaving sections empty.

---

## LGPD Compliance Review — [Project/Repo identifier]

<!-- Replace [Project/Repo identifier] with the project name, PR number, or repository path. -->

### Summary

<!-- High-level compliance snapshot. Fill all fields. -->

- **Personal data categories found:** [count]
- **Sensitive personal data present:** [yes/no — list categories if yes]
- **Processing activities identified:** [count]
- **Legal bases assigned:** [count with basis] / [count without]
- **Data subject rights implemented:** [count] of 9 + Art. 20
- **International transfers identified:** [count]
- **DPO designated:** [yes/no/unknown]
- **Breach notification mechanism:** [exists/not found]
- **Applicability signals:** [brief note from Step 1, e.g., "Portuguese UI, CPF collection, BRL pricing, CEP address fields"]

---

### Section 1: Personal Data Classification

<!-- One row per personal data element. Use the functional categories from checklists/lgpd-data-categories.md.
     Sensitive per Art. 5(II): racial/ethnic origin, religious belief, political opinion, union membership,
     philosophical belief, health, sex life, genetic, biometric. -->

| Data Element | Category | Sensitive? | Source | Purpose | Confidence |
|-------------|----------|------------|--------|---------|------------|
| <!-- e.g., users.cpf --> | <!-- e.g., Direct identifier --> | <!-- yes/no --> | <!-- e.g., POST /api/register --> | <!-- e.g., Account identification --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | |

<!-- After the table, note any children's data identified (Art. 14 implications). -->
<!-- Note any Brazilian-specific data elements (CPF, CNPJ, CEP, Pix keys, etc.). -->

---

### Section 2: Legal Basis Mapping

<!-- One row per processing activity. Legal basis must be one of the 10 bases in Art. 7 (general data)
     or the restricted bases in Art. 11 (sensitive data).
     IMPORTANT: Legitimate interest (Art. 7(IX)) requires a mandatory documented LIA.
     Sensitive data CANNOT use legitimate interest. -->

| Processing Activity | Data Elements | Legal Basis (Art. 7/11) | Evidence | Documentation Required? | Confidence |
|---------------------|--------------|-------------------------|----------|------------------------|------------|
| <!-- e.g., Account registration --> | <!-- e.g., name, CPF, email --> | <!-- e.g., Art. 7(V) — contract performance --> | <!-- e.g., Required for service provisioning --> | <!-- yes/no --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | |

<!-- After the table, flag any processing activities with NO identified legal basis — these are blocking findings. -->
<!-- Flag any legitimate interest claims that lack a documented LIA. -->

---

### Section 3: Data Subject Rights Matrix

<!-- One row per right. Check both existence AND functionality.
     LGPD has 9 rights under Art. 18 plus Art. 20 (automated decisions).
     Response timeline: Immediate for simplified format (Art. 19(I)), 15 days for complete declaration (Art. 19(II)). -->

| Right (Art. 18) | Endpoint Exists? | Functional? | Identity Verification | Response Timeline | Gaps | Severity | Confidence |
|-----------------|-----------------|-------------|----------------------|-------------------|------|----------|------------|
| Confirmation of processing (I) | <!-- yes/no --> | <!-- yes/no/partial --> | <!-- method --> | <!-- timeline --> | <!-- gaps --> | <!-- severity --> | <!-- HIGH/MEDIUM/LOW --> |
| Access to data (II) | | | | | | | |
| Correction (III) | | | | | | | |
| Anonymisation/blocking/deletion (IV) | | | | | | | |
| Data portability (V) | | | | | | | |
| Deletion of consent data (VI) | | | | | | | |
| Sharing information (VII) | | | | | | | |
| Consent denial info (VIII) | | | | | | | |
| Consent revocation (IX) | | | | | | | |
| Automated decision review (Art. 20) | <!-- N/A if no automated decisions --> | | | | | | |

---

### Section 4: International Transfer Assessment

<!-- One row per cross-border data flow. LGPD Art. 33 requires adequate transfer mechanisms.
     ANPD adequacy list differs from EU adequacy decisions.
     Common mechanisms: ANPD adequacy determination, SCCs, BCRs, specific consent (Art. 33(VIII)). -->

| Destination | Vendor/Service | Data Transferred | Transfer Mechanism | Adequacy Status | Gaps | Severity | Confidence |
|-------------|---------------|-----------------|-------------------|-----------------|------|----------|------------|
| <!-- e.g., US --> | <!-- e.g., AWS --> | <!-- e.g., All personal data --> | <!-- e.g., SCCs --> | <!-- e.g., No ANPD adequacy for US --> | <!-- gaps --> | <!-- severity --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | | | |

<!-- If all data is stored outside Brazil, note this as a systemic finding. -->

---

### Section 5: Vendor Classification

<!-- One row per vendor. LGPD Role values: CONTROLLER, PROCESSOR, JOINT_CONTROLLER.
     Use LGPD-native terminology: controlador, operador.
     Vendor classification confidence is typically MEDIUM (requires contract review). -->

| Vendor | LGPD Role | Contract Type | Data Access | International Transfer? | Confidence |
|--------|-----------|---------------|-------------|------------------------|------------|
| <!-- e.g., Serasa --> | <!-- e.g., CONTROLLER (joint) --> | <!-- e.g., Commercial agreement --> | <!-- e.g., CPF, name → credit data --> | <!-- yes — destination / no --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | |

---

### Section 6: DPO & Governance

#### DPO Designation (*Encarregado* — Art. 41)

<!-- LGPD mandates DPO for all controllers. ANPD Resolution CD/ANPD No. 2/2022 exempts
     small-scale processing agents under certain conditions. -->

- **DPO designated:** [yes/no/unknown]
- **Contact published:** [yes/no — location if yes]
- **Small-scale exemption applicable:** [yes/no/uncertain — reasoning]
- **Gaps:** [list any issues]
- **Severity:** [severity — HIGH if no DPO and exemption does not apply]

#### Breach Notification (Art. 48)

<!-- LGPD requires notification to ANPD and affected data subjects within "reasonable time"
     for security incidents that may create risk or relevant harm. -->

- **Incident response mechanism:** [exists/not found]
- **ANPD notification workflow:** [exists/not found]
- **Data subject notification mechanism:** [exists/not found]
- **Logging infrastructure:** [adequate/insufficient/not found]
- **Gaps:** [list any issues]
- **Severity:** [severity]

#### Records of Processing

<!-- Recommended by ANPD guidance. Not strictly mandated by LGPD text but strongly recommended
     and may be required by future ANPD regulations. -->

- **Data inventory exists:** [yes/no]
- **Processing activity records:** [yes/no]
- **Gaps:** [list any issues]
- **Severity:** [severity]

#### Privacy Notice (Art. 9)

<!-- Must include: purpose, form and duration of processing, controller identity,
     contact info, sharing information, data subject rights, transfer information. -->

- **Present:** [yes/no]
- **Language:** [Portuguese/English/other — Portuguese required for Brazilian users]
- **Controller identity disclosed:** [yes/no]
- **Purposes disclosed:** [yes/no — per processing activity?]
- **Legal bases per activity:** [yes/no]
- **Third parties named:** [yes/no — specific names or generic categories?]
- **Data subject rights described:** [yes/no — LGPD-specific Art. 18 rights?]
- **DPO/encarregado contact:** [yes/no]
- **Retention periods:** [yes/no]
- **International transfer information:** [yes/no]
- **Gaps:** [list any missing required elements]
- **Severity:** [severity]

---

### Section 7: Recommended Fixes (ordered by severity)

<!-- Order: CRITICAL first, then HIGH, MEDIUM, LOW. Mark blocking findings. -->

1. **[BLOCKING]** [fix description — severity, confidence]
2. **[BLOCKING]** [fix description — severity, confidence]
3. [fix description — severity, confidence]

---

### Severity Levels

| Level | Definition |
|-------|-----------|
| **CRITICAL** | Sensitive data processed without valid legal basis, data subject rights non-functional, international transfers without adequate safeguards, no consent mechanism where required, automated decisions without review mechanism |
| **HIGH** | Missing data subject rights endpoint, no DPO designation, no breach notification mechanism, legitimate interest without LIA, processing without identified legal basis |
| **MEDIUM** | Incomplete identity verification, vendor contract status unknown, privacy notice missing elements, transfer adequacy uncertain |
| **LOW** | Documentation gap, minor notice deficiency, defensive recommendation, records of processing incomplete |

### Confidence Levels

| Level | Definition | Action |
|-------|-----------|--------|
| **HIGH** | Unambiguous code pattern or clear statutory requirement | Finding can be acted on directly |
| **MEDIUM** | Requires contract review, business context, or legal interpretation | Review recommended before acting |
| **LOW** | Ambiguous data flow, multiple valid classifications, or evolving ANPD guidance | Consult a privacy attorney before acting |
