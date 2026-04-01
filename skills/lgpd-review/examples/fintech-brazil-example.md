# LGPD Review — Brazilian Fintech Example

A worked example demonstrating the LGPD review skill applied to a fintech application serving Brazilian users with Pix payments, credit scoring, and KYC requirements.

---

## Input Description

A React + Node.js fintech application for a Brazilian digital bank with:

- **User accounts:** Email/CPF registration, profile with name, CPF, date of birth, address (CEP), phone, selfie for KYC
- **KYC:** Face verification via selfie + government ID photo comparison (biometric data), CPF validation against Receita Federal
- **Payments:** Pix integration (keys: CPF, email, phone, random), boleto generation, bank transfer
- **Credit:** Credit scoring model (ML-based), Serasa bureau integration for credit checks, credit limit decisions fully automated
- **Analytics:** Internal analytics with user behaviour tracking (page views, feature usage), no third-party advertising
- **Communication:** WhatsApp Business API for transaction notifications, email for account alerts
- **Storage:** PostgreSQL on AWS São Paulo (sa-east-1), daily backups to AWS US East (us-east-1)
- **Privacy notice** exists in Portuguese, mentions LGPD, but does not list specific third parties
- **No DPO contact** visible in the application or privacy notice
- **No consent mechanism** for credit scoring — credit check runs automatically on account creation

---

## Expected Output

### LGPD Compliance Review — Brazilian Digital Bank Fintech

#### Summary
- **Personal data categories found:** 9 (direct identifiers, contact, authentication, financial, behavioural, location, images/media, device/technical, inferences)
- **Sensitive personal data present:** yes — biometric data (KYC selfie/face verification)
- **Processing activities identified:** 12
- **Legal bases assigned:** 8 with basis / 4 without clear basis
- **Data subject rights implemented:** 3 of 9 + Art. 20 (partial access, partial deletion, partial consent revocation)
- **International transfers identified:** 1 (AWS US East backup)
- **DPO designated:** no
- **Breach notification mechanism:** not found

#### Section 1: Personal Data Classification (key rows)

| Data Element | Category | Sensitive? | Source | Purpose | Confidence |
|-------------|----------|------------|--------|---------|------------|
| users.cpf | Direct identifier | No | POST /api/register | Account identification, tax obligations | HIGH |
| users.name | Direct identifier | No | POST /api/register | Account identification | HIGH |
| users.email | Direct identifier | No | POST /api/register | Authentication, notifications | HIGH |
| users.phone | Contact | No | POST /api/register | Pix key, WhatsApp notifications | HIGH |
| users.dateOfBirth | Direct identifier | No | POST /api/register | Age verification, KYC | HIGH |
| users.address (CEP) | Location | No | POST /api/register | Billing, regulatory compliance | HIGH |
| users.passwordHash | Authentication | No | POST /api/register | Authentication (Art. 46 security) | HIGH |
| kyc.selfiePhoto | Images/media | **Yes (biometric)** | POST /api/kyc/verify | Face verification for identity | HIGH |
| kyc.documentPhoto | Images/media | No | POST /api/kyc/verify | Government ID verification | HIGH |
| pix.keys | Financial + identifier | No | POST /api/pix/register-key | Pix transactions | HIGH |
| credit.score | Inferences | No | ML model output | Credit limit determination | HIGH |
| credit.serasaReport | Financial | No | Serasa API response | Credit assessment | HIGH |
| analytics.pageViews | Behavioural | No | Client-side tracking | Product improvement | HIGH |
| analytics.deviceId | Device/technical | No | Client-side SDK | Session management | HIGH |

#### Section 2: Legal Basis Mapping (key rows)

| Processing Activity | Data Elements | Legal Basis (Art. 7/11) | Evidence | Documentation Required? | Confidence |
|---------------------|--------------|-------------------------|----------|------------------------|------------|
| Account registration | name, CPF, email, phone, DOB, address | Art. 7(V) — contract performance | Required for banking service provisioning | No (contract) | HIGH |
| Authentication | passwordHash, session tokens | Art. 7(V) — contract performance | Necessary for account access | No (contract) | HIGH |
| KYC face verification | selfiePhoto, documentPhoto | Art. 11(II)(g) — fraud prevention/security | Biometric processing for identity verification in authentication | Yes — must be strictly necessary | HIGH |
| CPF validation | cpf | Art. 7(II) — legal obligation | Receita Federal requirement for financial institutions | Yes — identify regulation | HIGH |
| Pix transactions | pixKeys, transaction data | Art. 7(V) — contract performance + Art. 7(II) — legal obligation (Bacen Pix regulation) | Core banking service | No (contract + regulation) | HIGH |
| Credit scoring (ML model) | income, transaction history, Serasa data | **No clear basis** | Automated credit decision runs on registration without consent; legitimate interest requires LIA; not contract performance (not requested by user) | **Yes — LIA mandatory if Art. 7(IX); consent if Art. 7(I)** | HIGH |
| Serasa bureau check | cpf, name | Art. 7(X) — credit protection | Credit bureau query for credit assessment | Yes — limited to credit purpose | HIGH |
| Internal analytics | pageViews, deviceId, feature usage | Art. 7(IX) — legitimate interest | Internal product improvement, no third-party sharing | **Yes — LIA required** | MEDIUM |
| WhatsApp notifications | phone, transaction details | Art. 7(V) — contract performance | Transaction alerts requested by user | No (contract) | HIGH |
| Email notifications | email, account alerts | Art. 7(V) — contract performance | Account security and service updates | No (contract) | HIGH |
| Daily backup to US | All personal data | **No adequate transfer mechanism identified** | `pg_dump` cron to AWS us-east-1 S3 bucket | **Yes — transfer mechanism required** | HIGH |
| Boleto generation | name, CPF, amount | Art. 7(II) — legal obligation + Art. 7(V) — contract | Fiscal document generation required by regulation | No (regulation + contract) | HIGH |

#### Section 3: Data Subject Rights Matrix

| Right (Art. 18) | Endpoint Exists? | Functional? | Identity Verification | Response Timeline | Gaps | Severity | Confidence |
|-----------------|-----------------|-------------|----------------------|-------------------|------|----------|------------|
| Confirmation (I) | No | No | N/A | N/A | No dedicated endpoint — profile page implicitly confirms | HIGH | HIGH |
| Access (II) | Partial | Partial | Session auth | N/A (no formal flow) | Profile page shows basic data but not credit score, Serasa data, analytics, or KYC images | HIGH | HIGH |
| Correction (III) | Partial | Partial | Session auth | N/A | Can edit name/phone/address but not CPF or credit data | MEDIUM | HIGH |
| Anonymisation/blocking/deletion (IV) | No | No | N/A | N/A | No mechanism to anonymise or block specific data | HIGH | HIGH |
| Portability (V) | No | No | N/A | N/A | No data export in structured format | HIGH | HIGH |
| Deletion of consent data (VI) | Partial | Partial | Session auth | N/A | Account deletion exists but does not purge: backups, Serasa query logs, WhatsApp message history, analytics | HIGH | HIGH |
| Sharing information (VII) | No | No | N/A | N/A | Privacy notice does not list specific third parties (Serasa, AWS, WhatsApp/Meta) | HIGH | HIGH |
| Consent denial info (VIII) | No | No | N/A | N/A | No explanation of consequences of denying consent at any consent point | MEDIUM | HIGH |
| Consent revocation (IX) | Partial | Partial | Session auth | N/A | Analytics opt-out exists but no mechanism to revoke KYC biometric consent or marketing consent | HIGH | HIGH |
| Automated decision review (Art. 20) | No | No | N/A | N/A | Credit limit is fully automated (ML model) with no human review mechanism — **CRITICAL gap** | CRITICAL | HIGH |

#### Section 4: International Transfer Assessment

| Destination | Vendor/Service | Data Transferred | Transfer Mechanism | Adequacy Status | Gaps | Severity | Confidence |
|-------------|---------------|-----------------|-------------------|-----------------|------|----------|------------|
| US (AWS us-east-1) | AWS S3 | Full database backup (all personal data including biometric) | None identified | No ANPD adequacy determination for US | No SCCs, no specific consent, no BCRs — backup contains sensitive biometric data | CRITICAL | HIGH |

#### Section 5: Vendor Classification

| Vendor | LGPD Role | Contract Type | Data Access | International Transfer? | Confidence |
|--------|-----------|---------------|-------------|------------------------|------------|
| AWS (sa-east-1) | PROCESSOR | DPA (AWS standard) | All data (hosting) | No (Brazil region) | MEDIUM |
| AWS (us-east-1) | PROCESSOR | DPA (AWS standard) | Full backup | **Yes — US** | MEDIUM |
| Serasa | CONTROLLER (joint) | Commercial agreement | CPF, name → credit data | No (Brazil) | MEDIUM |
| WhatsApp/Meta | PROCESSOR | Business API terms | Phone, message content | Requires review — Meta infrastructure may route outside Brazil | MEDIUM |

#### Section 6: DPO & Governance

**DPO Designation:**
- Not found. No DPO contact in privacy notice, no `/dpo` endpoint, no `encarregado` configuration. LGPD Art. 41 mandates DPO for controllers. Small-scale exemption (ANPD Resolution CD/ANPD No. 2/2022) unlikely to apply — fintech processing financial and biometric data at scale.
- **Severity: HIGH**

**Breach Notification:**
- No incident response mechanism found. No breach notification endpoint, no alerting infrastructure for data breaches. Art. 48 requires notification to ANPD and affected data subjects within "reasonable time."
- **Severity: HIGH**

**Records of Processing:**
- No data inventory or processing activity records found in the codebase.
- **Severity: MEDIUM**

**Privacy Notice (Art. 9):**
- Present in Portuguese at `/privacidade`. Mentions LGPD and data subject rights generally. Missing: specific third-party names (says "partners" not "Serasa, AWS, Meta"), specific legal bases per processing activity, DPO contact, retention periods.
- **Severity: MEDIUM**

#### Section 7: Recommended Fixes (top items)

1. **[BLOCKING]** Implement human review mechanism for automated credit decisions — Art. 20 requires data subjects to request review of ML-based credit limit decisions. No review path exists. — CRITICAL, HIGH confidence
2. **[BLOCKING]** Establish adequate international transfer mechanism for US backup — biometric data (sensitive) transferred to AWS us-east-1 without SCCs, adequacy, or specific consent. Move backup to sa-east-1 or implement SCCs. — CRITICAL, HIGH confidence
3. **[BLOCKING]** Establish legal basis for automated credit scoring — currently no consent and no documented LIA. Either obtain specific consent before running credit check or complete a mandatory LIA under Art. 7(IX). — HIGH, HIGH confidence
4. **[BLOCKING]** Designate a DPO (*encarregado*) and publish contact information — Art. 41 mandatory for controllers; fintech scale does not qualify for small-agent exemption. — HIGH, HIGH confidence
5. **[BLOCKING]** Implement data subject rights endpoints — only 3 of 9 rights partially implemented. Priority: Art. 18(VII) sharing disclosure, Art. 18(V) portability, Art. 18(IV) anonymisation/deletion. — HIGH, HIGH confidence
6. Implement breach notification infrastructure — logging, alerting, and notification workflow to comply with Art. 48. — HIGH, HIGH confidence
7. Complete mandatory LIA documentation for internal analytics processing under legitimate interest. — HIGH, MEDIUM confidence
8. Update privacy notice to list specific third parties, legal bases per activity, DPO contact, and retention periods. — MEDIUM, HIGH confidence
9. Add consent denial consequences (Art. 18(VIII)) to all consent collection points. — MEDIUM, HIGH confidence

---

## Key Findings Demonstrated

| Finding | Step | Why It Matters |
|---------|------|---------------|
| Biometric KYC uses Art. 11(II)(g), not consent | Step 3 | KYC face verification is biometric (sensitive) data. Art. 11(II)(g) — fraud prevention in identification/authentication — is the most defensible basis. Consent would also work but is revocable, which creates a problem for ongoing KYC obligations. |
| Automated credit decisions are a critical gap | Step 4 | Art. 20 right to review automated decisions is broader than GDPR Art. 22. Fully automated credit limit decisions with no human review path are a CRITICAL finding — they affect the data subject's financial interests. |
| US backup = international transfer of sensitive data | Step 5 | Database backups containing biometric data sent to US infrastructure constitute an international transfer of sensitive personal data. No ANPD adequacy determination exists for the US. The simplest fix is moving the backup to the Brazil AWS region. |
| Credit scoring needs an explicit legal basis | Step 3 | Running a credit check automatically on registration is not "contract performance" (user requested a bank account, not a credit assessment). It requires either consent (Art. 7(I)) or legitimate interest with a mandatory LIA (Art. 7(IX)). Credit protection (Art. 7(X)) covers the Serasa query but not the internal ML scoring. |
| DPO is mandatory for fintech | Step 7 | Unlike GDPR (conditional DPO), LGPD mandates DPO for all controllers. The small-scale exemption is narrow and unlikely to apply to a fintech processing financial and biometric data. This is a quick governance fix but frequently missed. |
