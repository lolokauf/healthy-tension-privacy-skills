# Data Inventory Template

Blank template for the data-mapping skill's output. This defines the output schema — the "contract" that downstream skills (DPIA, DSAR, compliance reviews) depend on.

---

## Data Inventory Table

<!-- Primary output. One row per personal data field. All columns required — use "TBD", "Undefined", "None", or "Unknown" rather than leaving cells blank. -->

| Data Element | PII Category | Source | Storage | Purpose | Legal Basis | Retention | Deletion | Shared With | Cross-Border | Confidence |
|-------------|-------------|--------|---------|---------|-------------|-----------|----------|-------------|-------------|------------|
| | | | | | | | | | | |

### Column Definitions

| Column | Description | Required | Example Values |
|--------|-----------|----------|---------------|
| **Data Element** | Field name and location (table.column, storage key, API param) | Yes | `users.email`, `localStorage:cart`, `req.body.phone` |
| **PII Category** | Classification from the PII Category Taxonomy below | Yes | `contact`, `authentication`, `financial` |
| **Source** | Where the data is first collected (endpoint, form, SDK) | Yes | `POST /api/auth/register`, `signup form`, `Google OAuth` |
| **Storage** | Where the data is persisted (database/table, storage service) | Yes | `PostgreSQL users table`, `Redis cache`, `chrome.storage.sync` |
| **Purpose** | Why the data is collected (technical purpose from code) | Yes | `Account authentication`, `Payment processing`, `Analytics` |
| **Legal Basis** | Applicable legal basis, or "TBD" if requires legal review | Yes | `contract`, `consent`, `legitimate_interest`, `TBD` |
| **Retention** | How long the data is kept, or "Undefined" if no policy exists | Yes | `1 year inactivity`, `7-day TTL`, `Undefined` |
| **Deletion** | How the data is removed, or "None" if no mechanism exists | Yes | `CASCADE delete`, `Hard delete + backup purge`, `None` |
| **Shared With** | Third parties the data is sent to, or "None" | Yes | `PostHog (analytics)`, `Stripe (payments)`, `None` |
| **Cross-Border** | Whether data crosses jurisdiction boundaries | Yes | `Yes (US)`, `No`, `Unknown` |
| **Confidence** | Assessment confidence level | Yes | `HIGH`, `MEDIUM`, `LOW` |

---

## Third-Party Processor Table

<!-- One row per third-party service that receives personal data. -->

| Processor | Data Received | Purpose | DPA Required | Sub-processors | Transfer Mechanism | Confidence |
|-----------|--------------|---------|-------------|----------------|-------------------|------------|
| | | | | | | |

### Column Definitions

| Column | Description | Required | Example Values |
|--------|-----------|----------|---------------|
| **Processor** | Service name and type | Yes | `PostHog (analytics)`, `Stripe (payments)` |
| **Data Received** | Specific data elements shared with this processor | Yes | `userId, event names, pageUrl` |
| **Purpose** | Why data is shared with this processor | Yes | `Product analytics`, `Payment processing` |
| **DPA Required** | Whether a Data Processing Agreement is needed | Yes | `Yes`, `No`, `Unknown` |
| **Sub-processors** | Known sub-processors, or "Unknown" | Yes | `AWS (hosting)`, `Unknown` |
| **Transfer Mechanism** | Cross-border transfer safeguard if applicable | Yes | `SCCs`, `Adequacy`, `None`, `N/A (same jurisdiction)` |
| **Confidence** | Assessment confidence level | Yes | `HIGH`, `MEDIUM`, `LOW` |

---

## PII Category Taxonomy

Categories the skill uses for classifying personal data fields. Based on GDPR special categories, CCPA PI categories, and common engineering classifications.

| Category | Description | GDPR Special Category? | CCPA Equivalent |
|----------|-----------|----------------------|-----------------|
| `identifier` | Unique IDs that can identify an individual (userId, account number, SSN) | No (unless government ID) | Identifiers |
| `contact` | Email, phone, postal address, social media handles | No | Personal information categories |
| `authentication` | Passwords, tokens, recovery phrases, API keys tied to a user | No | Identifiers |
| `financial` | Payment card info, bank accounts, transaction history, billing addresses | No | Financial information |
| `biometric` | Fingerprints, facial recognition, voice prints, retinal scans | **Yes** | Biometric information |
| `health` | Medical records, health conditions, fitness data, disability status | **Yes** | Protected classification characteristics |
| `location` | GPS coordinates, IP-derived location, geofence data, address history | No | Geolocation data |
| `behavioural` | Browsing history, search queries, click patterns, purchase history, app usage | No | Internet or electronic network activity |
| `employment` | Job title, employer, salary, performance reviews | No | Professional or employment information |
| `education` | Student records, enrollment data, grades | No | Education information |
| `government_id` | SSN, passport number, driver's license, national ID | No (but high sensitivity) | Government-issued ID |
| `demographic` | Age, gender, race, ethnicity, religion, political opinions | **Some** (race, religion, politics) | Protected classification characteristics |
| `consent_preference` | User's opt-in/opt-out choices, privacy settings | No | N/A |
| `session_data` | Session tokens, cookies, device fingerprints | No | Internet or electronic network activity |
| `user_content` | User-generated text, uploads, messages, reviews | No | Audio, electronic, visual, or similar information |
| `other` | Data that doesn't fit the above categories — describe in notes | Varies | Varies |

---

## YAML Schema (Optional Machine-Readable Output)

For teams that want version-controlled, machine-readable inventories. This schema is compatible with CI validation and consumption by other tools.

```yaml
# Data Inventory — [Project Name]
# Generated by data-mapping skill v1.0.0
# Date: YYYY-MM-DD

data_controller:
  name: "[Organisation name]"
  contact: "[Contact email]"
  privacy_policy: "[URL]"

pii_fields:
  # Required fields: field, pii_category, source, storage, purpose
  # Optional fields: legal_basis, retention, deletion_mechanism, shared_with,
  #                  cross_border, encrypted_at_rest, encrypted_in_transit,
  #                  log_scrubbed, confidence, notes

  - field: "[field name]"              # Required — e.g., "email"
    table: "[table or storage key]"    # Required — e.g., "users"
    type: "[data type]"                # Optional — e.g., "varchar", "text"
    pii_category: "[category]"         # Required — from taxonomy above
    description: "[plain language]"    # Optional — what the field contains
    source: "[collection point]"       # Required — e.g., "POST /api/register"
    purpose: "[why collected]"         # Required — e.g., "Account authentication"
    legal_basis: "[basis]"             # Optional — e.g., "contract", "consent", "TBD"
    encrypted_at_rest: "[method]"      # Optional — e.g., "AES-256-GCM", "plaintext"
    encrypted_in_transit: "[method]"   # Optional — e.g., "tls"
    retention: "[period]"              # Optional — e.g., "1 year inactivity"
    deletion_mechanism: "[method]"     # Optional — e.g., "CASCADE delete"
    shared_with: "[processor]"         # Optional — e.g., "PostHog (analytics)"
    cross_border: "[yes/no/unknown]"   # Optional
    log_scrubbed: "[true/false]"       # Optional
    confidence: "[HIGH/MEDIUM/LOW]"    # Required
    notes: "[additional context]"      # Optional

processors:
  - name: "[processor name]"           # Required
    type: "[analytics/payments/email]"  # Required
    data_received: "[data elements]"   # Required
    purpose: "[why shared]"            # Required
    data_region: "[location]"          # Optional — e.g., "EU", "US"
    dpa_status: "[status]"             # Optional — e.g., "Standard DPA", "Not documented"
    consent_mechanism: "[how gated]"   # Optional — e.g., "Opt-in toggle"
    confidence: "[HIGH/MEDIUM/LOW]"    # Required
```

---

## Regulatory Field Mapping

How the template's fields map to regulatory requirements:

| Template Field | GDPR Art. 30 RoPA | CCPA §1798.100(b) |
|---------------|-------------------|-------------------|
| Data Element + PII Category | Categories of personal data | Categories of PI collected |
| Purpose | Purposes of processing | Business or commercial purposes |
| Legal Basis | Lawful basis (Art. 6) | N/A (CCPA doesn't require legal basis disclosure) |
| Shared With + Processor Table | Categories of recipients | Categories of third parties shared with |
| Cross-Border | Transfers to third countries | N/A |
| Retention | Retention time limits | N/A (CPRA adds retention disclosure) |
| Storage (encryption) | Security measures (Art. 30(1)(g)) | N/A |
| Source | — (not required by Art. 30) | Sources of PI |
