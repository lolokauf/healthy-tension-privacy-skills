# LGPD Personal Data Categories

LGPD uses a principle-based definition of personal data (Art. 5(I)): "information related to an identified or identifiable natural person." Unlike CCPA's 11 enumerated categories, LGPD does not prescribe fixed categories. This checklist organises personal data into functional categories for actionable code review.

---

## General Personal Data (*Dados Pessoais*)

Any information that identifies or can identify a natural person. Use these functional categories when performing Step 2 (Personal Data Classification) of the LGPD review.

| # | Category | LGPD Basis | Code Patterns to Search |
|---|----------|-----------|-------------------------|
| 1 | **Direct identifiers** | Art. 5(I) — identified person | `userId`, `email`, `cpf`, `cnpj`, `rg`, `cnh`, `passportNumber`, `name`, `fullName`, `firstName`, `lastName`, account IDs, customer IDs |
| 2 | **Contact information** | Art. 5(I) — identifiable person | `phone`, `celular`, `address`, `endereco`, `cep`, `city`, `state`, `zipCode`, `whatsapp`, emergency contacts |
| 3 | **Authentication credentials** | Art. 5(I) + Art. 46 (security) | `password`, `passwordHash`, `token`, `apiKey`, `mfaSecret`, `recoveryPhrase`, `sessionToken`, OAuth tokens, JWT secrets |
| 4 | **Financial data** | Art. 5(I) | `bankAccount`, `agencia`, `conta`, `pix`, `pixKey`, `creditCard`, `boleto`, `salary`, `income`, `renda`, billing tables, payment processor fields |
| 5 | **Employment/professional** | Art. 5(I) | `jobTitle`, `cargo`, `employer`, `empresa`, `ctps`, `pis`, `salary`, `salario`, `department`, `admissionDate`, HR system fields |
| 6 | **Behavioural/usage data** | Art. 5(I) — identifiable via linkage | `pageViews`, `clickstream`, `searchHistory`, `browsing`, `sessionId`, `deviceId`, `userAgent`, analytics events, interaction logs |
| 7 | **Location data** | Art. 5(I) | `latitude`, `longitude`, `gps`, `location`, `cep` (when precise), IP-based geolocation, `navigator.geolocation`, delivery addresses |
| 8 | **Communication content** | Art. 5(I) | `message`, `chatMessage`, `emailBody`, `comment`, `feedback`, `review`, support ticket content, notification content |
| 9 | **Device/technical identifiers** | Art. 5(I) — identifiable via linkage | `ipAddress`, `macAddress`, `deviceFingerprint`, `advertisingId`, cookies, `localStorage` user keys, browser fingerprinting APIs |
| 10 | **Images and media** | Art. 5(I) | `avatar`, `profilePhoto`, `upload`, `attachment`, `video`, `audio`, `recording`, file upload endpoints accepting media |
| 11 | **Inferences and profiles** | Art. 5(I) — derived data | ML model outputs, recommendation scores, risk scores, user segments, predicted preferences, credit scores, classification labels |
| 12 | **Children's data** | Art. 14 (special protections) | `age`, `dateOfBirth`, `birthDate`, age gate fields, parental consent flags, minor indicators — triggers Art. 14 requirements |

---

## Sensitive Personal Data (*Dados Pessoais Sensíveis* — Art. 5(II))

Sensitive data has a restricted set of legal bases (Art. 11). Legitimate interest is NOT available for sensitive data. Check for these categories independently of general personal data — a data element can be both general and sensitive.

| Sensitive Data Type | LGPD Reference | Code Patterns | Often Missed? |
|---------------------|---------------|---------------|---------------|
| Racial or ethnic origin | Art. 5(II) | `race`, `raca`, `ethnicity`, `etnia`, `cor`, demographic survey fields, EEO data | No |
| Religious belief | Art. 5(II) | `religion`, `religiao`, `faith`, `fe`, dietary preferences (if religion-linked) | Sometimes |
| Political opinion | Art. 5(II) | `politicalParty`, `partido`, `politicalAffiliation`, voter registration data | Sometimes |
| Trade union membership | Art. 5(II) | `union`, `sindicato`, `unionMember`, labour organisation data | Sometimes |
| Philosophical belief | Art. 5(II) | `worldview`, philosophical affiliation fields — rare in most codebases | Sometimes |
| Health data | Art. 5(II) | `diagnosis`, `diagnostico`, `medication`, `medicamento`, `healthCondition`, `planoSaude`, medical records, fitness data, symptom logs | No |
| Sex life data | Art. 5(II) | `sexualOrientation`, `orientacaoSexual`, dating preferences, reproductive health data | Sometimes |
| Genetic data | Art. 5(II) | `dna`, `genetic`, `genetico`, `genome`, biomarker data | No |
| Biometric data | Art. 5(II) | `fingerprint`, `impressaoDigital`, `faceTemplate`, `faceId`, `voicePrint`, biometric authentication storage | No |

---

## Brazilian-Specific Data Elements

These data elements are common in Brazilian applications and should be specifically checked during LGPD reviews.

| Data Element | Description | Code Patterns | Notes |
|-------------|-------------|---------------|-------|
| **CPF** | Cadastro de Pessoas Físicas (individual taxpayer ID, 11 digits) | `cpf`, `cpfNumber`, regex `\d{3}\.\d{3}\.\d{3}-\d{2}` | Universal identifier in Brazil — present in nearly all Brazilian-facing applications |
| **CNPJ** | Cadastro Nacional da Pessoa Jurídica (company taxpayer ID, 14 digits) | `cnpj`, `cnpjNumber`, regex `\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}` | Not personal data unless linked to a sole proprietor (*empresário individual*) |
| **RG** | Registro Geral (national ID card) | `rg`, `rgNumber`, `identidade` | State-issued, format varies by state |
| **CNH** | Carteira Nacional de Habilitação (driver's licence) | `cnh`, `cnhNumber`, `habilitacao` | Functions as secondary ID |
| **CTPS** | Carteira de Trabalho e Previdência Social (employment record book) | `ctps`, `ctpsNumber`, `carteiraTrabalho` | Employment context — links to labour history |
| **PIS/PASEP** | Social integration programme number | `pis`, `pasep`, `pisPasep` | Employment and social security context |
| **CEP** | Código de Endereçamento Postal (postal code, 8 digits) | `cep`, regex `\d{5}-\d{3}` | Can be precise location when combined with street number |
| **Pix key** | Instant payment identifier (CPF, email, phone, or random key) | `pixKey`, `chavePix`, `pix` | Often links to CPF — treat as financial + identifier |
| **SUS card** | Cartão Nacional de Saúde (national health card) | `sus`, `cartaoSus`, `cns` | Health data identifier — sensitive |

---

## Data-Mapping Taxonomy → LGPD Category Mapping

If using the data-mapping skill's PII Category Taxonomy as input, map categories as follows:

| Data-Mapping Category | LGPD Functional Category | Sensitive? |
|-----------------------|-------------------------|------------|
| `identifier` | 1. Direct identifiers | No (unless government ID like CPF/RG) |
| `contact` | 2. Contact information | No |
| `authentication` | 3. Authentication credentials | No (but Art. 46 security obligations apply) |
| `financial` | 4. Financial data | No |
| `biometric` | 10. Images/media or Sensitive (biometric) | **Yes** if used for identification |
| `health` | Sensitive (health data) | **Yes** |
| `location` | 7. Location data | No (but may be sensitive if precise + linked to habits) |
| `behavioral` | 6. Behavioural/usage data | No |
| `employment` | 5. Employment/professional | No |
| `education` | General personal data | No |
| `government_id` | 1. Direct identifiers | No (not sensitive under LGPD, but high-risk) |
| `demographic` | Varies — check for sensitive categories | **Yes** if racial, ethnic, religious, or political |
| `consent_preference` | Not personal data (meta-data about processing) | No |
| `session_data` | 9. Device/technical identifiers | No |
| `user_content` | 8. Communication content or 10. Images/media | Only if contains sensitive categories |
| `other` | Classify manually per Art. 5(I) | Evaluate per Art. 5(II) |

---

## Children's Data Note (Art. 14)

LGPD Art. 14 requires that processing of children's and adolescents' personal data be performed in their best interest. Brazilian law (Estatuto da Criança e do Adolescente, Lei No. 8.069/1990) distinguishes:

- **Children (*crianças*) — under 12:** Processing requires **specific and prominent consent from a parent or legal guardian** (Art. 14(§1)). The controller must make reasonable efforts to verify that consent was given by the parent/guardian (Art. 14(§5)).
- **Adolescents (*adolescentes*) — 12 to 17:** Art. 14's best-interest standard applies, but the strict parental consent requirement of §1 is specific to children. Adolescents may have greater capacity to consent, though the best-interest standard and proportionality principles still govern. ANPD guidance on this age group is evolving.

Applications that may be used by minors must implement age verification and, for children, parental consent mechanisms. Flag any `dateOfBirth`, `age`, or age gate field and assess whether Art. 14 protections are implemented.
