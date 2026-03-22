# CCPA Personal Information Categories

The 11 statutory categories of personal information under CCPA §1798.140(v), plus the sensitive PI overlay from §1798.140(ae). Use this checklist when performing Step 2 (PI Classification) of the CCPA review.

---

## 11 CCPA PI Categories

| # | Category | Statutory Reference | Code Patterns to Search |
|---|----------|--------------------:|-------------------------|
| 1 | **Identifiers** | §1798.140(v)(1) | `userId`, `email`, `accountId`, `customerId`, `ipAddress`, `deviceId`, `ssn`, `driverLicense`, `passport`, cookies, advertising IDs (`gclid`, `fbclid`, `_ga`) |
| 2 | **Customer records** | Cal. Civ. Code §1798.80(e) | `name`, `address`, `phone`, `creditCard`, `bankAccount`, `insurancePolicy`, billing tables, payment processing fields |
| 3 | **Protected classification characteristics** | §1798.140(v)(3) | `race`, `ethnicity`, `gender`, `age`, `dateOfBirth`, `disability`, `veteran`, `maritalStatus`, `religion`, `sexualOrientation`, demographic survey fields |
| 4 | **Commercial information** | §1798.140(v)(4) | `orders`, `purchases`, `cart`, `transactionHistory`, `subscriptions`, `returns`, product interest, consumption history tables |
| 5 | **Biometric information** | §1798.140(v)(5) | `fingerprint`, `faceId`, `voicePrint`, `retina`, `iris`, `keystrokeDynamics`, gait, physiological patterns, biometric template storage |
| 6 | **Internet or electronic network activity** | §1798.140(v)(6) | `browsing_history`, `search_queries`, `clickstream`, `pageViews`, `referrer`, `userAgent`, `sessionId`, analytics event tracking, ad interaction logs |
| 7 | **Geolocation data** | §1798.140(v)(7) | `latitude`, `longitude`, `gps`, `location`, `geofence`, `zipCode` (when precise), IP-based geolocation, `navigator.geolocation`, location permission requests |
| 8 | **Sensory data** | §1798.140(v)(8) | `audio`, `video`, `photo`, `recording`, `voicemail`, `surveillance`, thermal imaging, file upload endpoints accepting media |
| 9 | **Professional or employment information** | §1798.140(v)(9) | `jobTitle`, `employer`, `company`, `salary`, `performanceReview`, `workHistory`, `resume`, LinkedIn profile data, HR system fields |
| 10 | **Education information** | §1798.140(v)(10) | `studentId`, `gpa`, `enrollment`, `transcript`, `school`, `degree`, FERPA-protected records, `.edu` email addresses |
| 11 | **Inferences drawn from PI** | §1798.140(v)(11) | ML model outputs, recommendation scores, risk scores, user segments, predicted preferences, propensity models, classification labels derived from other PI |

---

## Sensitive PI Overlay (§1798.140(ae))

Sensitive PI triggers the right to limit use (§1798.121) and requires a "Limit the Use of My Sensitive Personal Information" link. Check for these categories independently of the 11 PI categories above — a data element can be both a PI category member AND sensitive PI.

| Sensitive PI Type | Statutory Reference | Code Patterns | Often Missed? |
|-------------------|--------------------:|---------------|---------------|
| SSN, driver's licence, state ID, passport | §1798.140(ae)(A) | `ssn`, `socialSecurity`, `driverLicense`, `stateId`, `passportNumber`, government ID upload | No |
| Financial account + credentials | §1798.140(ae)(B) | `bankAccount`, `routingNumber`, `accountNumber` combined with `pin`, `accessCode`, `securityCode` | No |
| Debit/credit card + credentials | §1798.140(ae)(B) | `cardNumber`, `cvv`, `expirationDate`, `billingZip`, PCI-scoped fields | No |
| Precise geolocation | §1798.140(ae)(C) | `latitude`/`longitude` (not IP-derived city), `navigator.geolocation.getCurrentPosition`, GPS coordinates | Sometimes |
| Racial or ethnic origin | §1798.140(ae)(D) | `race`, `ethnicity`, demographic fields, EEO data | No |
| Religious or philosophical beliefs | §1798.140(ae)(D) | `religion`, `faith`, dietary preference (if religion-linked) | Sometimes |
| Union membership | §1798.140(ae)(D) | `unionMember`, `laborOrg`, `collectiveBargaining` | Sometimes |
| Contents of mail, email, text | §1798.140(ae)(E) | `message.body`, `emailContent`, `smsText`, `chatMessage` — unless business is the intended recipient | Sometimes |
| Genetic data | §1798.140(ae)(F) | `dna`, `genetic`, `genome`, health-related biomarker data | No |
| Biometric data for identification | §1798.140(ae)(G) | `faceTemplate`, `fingerprintHash`, biometric authentication storage | No |
| Health data | §1798.140(ae)(H) | `diagnosis`, `medication`, `healthCondition`, `medicalRecord`, fitness tracker data, symptom logs | No |
| Sex life or sexual orientation | §1798.140(ae)(I) | `sexualOrientation`, `genderIdentity`, dating preferences, relationship status (in some contexts) | Sometimes |
| **Login credentials** | **§1798.140(ae)(C)** | `password`, `passwordHash`, `recoveryPhrase`, `mfaSecret`, `totpSeed`, `apiKey` (user-scoped) | **Yes — often missed** |

---

## Data-Mapping Taxonomy → CCPA Category Mapping

If using the data-mapping skill's PII Category Taxonomy as input, map categories as follows:

| Data-Mapping Category | CCPA PI Category | Sensitive PI? |
|-----------------------|------------------|---------------|
| `identifier` | 1. Identifiers | Only if government ID |
| `contact` | 2. Customer records | No |
| `authentication` | 1. Identifiers | **Yes** (login credentials §1798.140(ae)(C)) |
| `financial` | 2. Customer records | Yes (if account + credentials) |
| `biometric` | 5. Biometric information | Yes (if used for identification) |
| `health` | 3. Protected classifications | Yes |
| `location` | 7. Geolocation data | Yes (if precise) |
| `behavioral` | 6. Internet/network activity | No |
| `employment` | 9. Professional/employment | No |
| `education` | 10. Education information | No |
| `government_id` | 1. Identifiers | Yes |
| `demographic` | 3. Protected classifications | Yes (if race, religion, etc.) |
| `consent_preference` | Not PI (meta-data about PI) | No |
| `session_data` | 6. Internet/network activity | No |
| `user_content` | 8. Sensory data (if media) or varies | Yes (if mail/email/text contents) |
| `other` | Classify manually per §1798.140(v) | Evaluate per §1798.140(ae) |

---

## Household Data Note

CCPA extends to household-level data (§1798.140(v) — "identifies, relates to, describes, is reasonably capable of being associated with, or could reasonably be linked, directly or indirectly, with a particular consumer **or household**"). Data elements that identify a household (household income, family plan, shared device identifiers, address-linked records) are PI even if they do not identify an individual. Flag household-level data in the PI Classification table with a note.
