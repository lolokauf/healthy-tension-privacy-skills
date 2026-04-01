# Code Pattern to Notice Section Mapping

Rules for translating code-level observations into privacy notice content. Use this reference during Step 2 (Map Data Collection Points to Notice Sections) and Step 6 (Generate Cookie & Tracking Notice Section).

---

## Collection Points → "What We Collect"

| Code Pattern | Notice Language | Notice Section | Confidence |
|-------------|----------------|---------------|------------|
| Registration form fields (`name`, `email`, `password`) | "When you create an account, we collect your name, email address, and a password." | 1. What We Collect → You Provide | HIGH |
| Profile update endpoints (`PATCH /profile`, `PUT /user`) | "When you update your profile, we collect [updated fields]." | 1. What We Collect → You Provide | HIGH |
| File upload handlers (`multer`, `formidable`, `<input type="file">`) | "When you upload files, we collect the file content and associated metadata." | 1. What We Collect → You Provide | HIGH |
| Contact/support forms (`POST /contact`, `POST /support`) | "When you contact us, we collect your name, email, and the content of your message." | 1. What We Collect → You Provide | HIGH |
| Payment form fields (`card_number`, `billing_address`, Stripe/PayPal SDK) | "When you make a purchase, we collect billing information such as [fields]. Payment processing is handled by [processor]." | 1. What We Collect → You Provide | HIGH |
| OAuth/social login (`passport-google`, `next-auth`, `@auth/core`) | "If you sign in with [provider], we receive your name, email, and profile picture from [provider]." | 1. What We Collect → Third Parties | HIGH |
| IP address logging (`req.ip`, `x-forwarded-for`, access logs) | "We automatically collect your IP address when you use our service." | 1. What We Collect → Automatically | HIGH |
| User-agent parsing (`ua-parser-js`, `req.headers['user-agent']`) | "We automatically collect information about your browser and device." | 1. What We Collect → Automatically | HIGH |
| Geolocation APIs (`navigator.geolocation`, IP geolocation services) | "We collect your approximate [or precise] location." | 1. What We Collect → Automatically | HIGH |
| Search/query logging (search endpoint logs, query parameters persisted) | "We collect your search queries to provide and improve search results." | 1. What We Collect → Automatically | MEDIUM |

---

## Processing Logic → "How We Use Your Information"

| Code Pattern | Notice Language | Notice Section | Confidence |
|-------------|----------------|---------------|------------|
| Authentication middleware (`isAuthenticated`, `requireAuth`, session checks) | "To verify your identity and maintain your session." | 2. How We Use It | HIGH |
| Email sending (`nodemailer`, `@sendgrid/mail`, `resend`, `ses.sendEmail`) | "To send you [transactional/marketing] emails." | 2. How We Use It | HIGH |
| Push notifications (`firebase-admin`, `web-push`, `expo-notifications`) | "To send you push notifications about [purpose]." | 2. How We Use It | HIGH |
| Rate limiting (`express-rate-limit`, `@upstash/ratelimit`) | "To protect our service from abuse and ensure fair usage." | 2. How We Use It | MEDIUM |
| Fraud detection / scoring (`risk_score`, `fraud_check`, IP reputation) | "To detect and prevent fraud and abuse." | 2. How We Use It | HIGH |
| Personalisation / recommendation (`recommend()`, `similar_items`, `for_you`) | "To personalise your experience and provide recommendations." | 2. How We Use It | HIGH |
| ML model inference (`predict()`, `model.run()`, TensorFlow/PyTorch imports) | "To provide [feature] using automated processing." | 2. How We Use It + Automated decisions | HIGH |
| A/B testing (`posthog.featureFlags`, `launchdarkly`, `split.io`, `optimizely`) | "To test and improve our service through experimentation." | 2. How We Use It | MEDIUM |
| Logging/monitoring (`winston`, `pino`, `console.log` with user data, Sentry) | "To monitor service performance and diagnose issues." | 2. How We Use It | MEDIUM |

---

## Third-Party SDKs → "Who We Share Your Information With"

| Code Pattern | Notice Language | Relationship | Notice Section | Confidence |
|-------------|----------------|-------------|---------------|------------|
| Stripe SDK (`stripe`, `@stripe/stripe-js`) | "[Company] uses Stripe to process payments. Stripe receives your payment information." | Processor | 3. Who We Share With | HIGH |
| PayPal SDK (`@paypal/checkout-server-sdk`) | "[Company] uses PayPal to process payments." | Processor | 3. Who We Share With | HIGH |
| SendGrid/Mailgun/SES (`@sendgrid/mail`, `mailgun-js`, `aws-sdk ses`) | "[Company] uses [provider] to deliver emails." | Processor | 3. Who We Share With | HIGH |
| Twilio (`twilio`) | "[Company] uses Twilio for SMS/voice communications." | Processor | 3. Who We Share With | HIGH |
| AWS S3/GCS storage (`aws-sdk s3`, `@google-cloud/storage`) | "Your data is stored using [provider] cloud infrastructure." | Processor (infrastructure) | 3. Who We Share With | HIGH |
| Sentry (`@sentry/node`, `@sentry/react`) | "[Company] uses Sentry for error monitoring. Error reports may include technical details about your session." | Processor | 3. Who We Share With | HIGH |
| Google Analytics (`gtag.js`, `@google-analytics/data`) | "[Company] uses Google Analytics to understand how our service is used." | Controller (joint or independent) | 3. Who We Share With + 7. Cookies | HIGH |
| Meta Pixel (`fbq()`, `facebook-pixel`, `meta-pixel`) | "[Company] uses Meta Pixel for advertising measurement." | Controller (independent) | 3. Who We Share With + 7. Cookies | HIGH |
| PostHog (`posthog-js`, `posthog-node`) | "[Company] uses PostHog for product analytics." | Processor (self-hosted) or Controller (cloud) | 3. Who We Share With | MEDIUM |
| Intercom (`intercom-client`, `Intercom()`) | "[Company] uses Intercom for customer support. Intercom receives your name, email, and conversation history." | Processor | 3. Who We Share With | HIGH |
| Segment (`analytics-node`, `@segment/analytics-next`) | "[Company] uses Segment to route analytics data to our analysis tools." | Processor | 3. Who We Share With | HIGH |
| Auth0/Clerk/Supabase Auth (`@auth0/auth0-react`, `@clerk/nextjs`, `supabase.auth`) | "[Company] uses [provider] for authentication services." | Processor | 3. Who We Share With | HIGH |

---

## Database & Storage → "How Long We Keep Your Information"

| Code Pattern | Notice Language | Notice Section | Confidence |
|-------------|----------------|---------------|------------|
| TTL/expiry settings (`TTL: 86400`, `expireAfterSeconds`, Redis `EX`) | "We retain [data type] for [duration]." | 5. Retention | HIGH |
| Soft delete (`deleted_at`, `is_deleted`, `paranoid: true`) | "When you delete your account, we mark your data for deletion and remove it after [period]." | 5. Retention | HIGH |
| Hard delete (`DELETE FROM`, `destroy()`, `remove()`) | "When you delete [item], it is permanently removed from our systems." | 5. Retention | HIGH |
| Cron/scheduled deletion (`cron.schedule`, retention worker, cleanup job) | "We automatically delete [data type] after [period] of inactivity." | 5. Retention | HIGH |
| Backup retention (`pg_dump`, backup schedules, S3 lifecycle rules) | "Backup copies may persist for up to [period] after deletion from primary systems." | 5. Retention | MEDIUM |
| Session expiry (`maxAge`, `cookie.expires`, JWT `expiresIn`) | "Session data expires after [duration]." | 5. Retention | HIGH |
| Audit log retention (`audit_log`, `activity_log`, event sourcing tables) | "We retain activity logs for [period] for security and compliance purposes." | 5. Retention | MEDIUM |
| No deletion logic found | "[TODO: Specify retention period — no automated deletion mechanism found in code]" | 5. Retention | LOW |

---

## Rights Endpoints → "Your Rights"

| Code Pattern | Notice Language | Right (GDPR) | Notice Section | Confidence |
|-------------|----------------|-------------|---------------|------------|
| Data export endpoint (`GET /export`, `GET /download-data`, ZIP generation) | "You can request a copy of your personal data." | Access (Art. 15) / Portability (Art. 20) | 6. Your Rights | HIGH |
| Account deletion endpoint (`DELETE /account`, `DELETE /user`) | "You can request deletion of your account and personal data." | Erasure (Art. 17) | 6. Your Rights | HIGH |
| Profile edit endpoints (`PATCH /profile`, `PUT /user`) | "You can correct inaccurate personal data through your account settings." | Rectification (Art. 16) | 6. Your Rights | HIGH |
| Consent preference centre (`PUT /preferences`, consent toggles) | "You can withdraw your consent at any time through your privacy settings." | Withdraw consent (Art. 7(3)) | 6. Your Rights | HIGH |
| Opt-out endpoint (`POST /opt-out`, `PUT /do-not-sell`, GPC handling) | "You can opt out of the sale or sharing of your personal information." | Opt-out (CCPA §1798.120) | 6. Your Rights | HIGH |
| DSAR form/endpoint (`POST /privacy-request`, `POST /dsar`) | "You can submit a data subject access request through [mechanism]." | Access (Art. 15) | 6. Your Rights | HIGH |
| No rights endpoints found | "[TODO: Implement data subject rights mechanisms — no endpoints found]" | All applicable | 6. Your Rights | LOW |

---

## Cookies & Tracking → "Cookies and Tracking Technologies"

| Code Pattern | Notice Language | Consent Category | Notice Section | Confidence |
|-------------|----------------|-----------------|---------------|------------|
| Session cookie (`express-session`, `connect.sid`, `__session`) | "We use a session cookie to keep you logged in." | Strictly necessary | 7. Cookies | HIGH |
| CSRF token (`csurf`, `csrf-token`, `_csrf`) | "We use a CSRF token cookie to protect against cross-site request forgery." | Strictly necessary | 7. Cookies | HIGH |
| Google Analytics (`gtag.js`, `_ga`, `_gid`, `_gat`) | "We use Google Analytics cookies to understand how visitors use our site." | Analytics | 7. Cookies | HIGH |
| Meta Pixel (`_fbp`, `_fbc`, `fbq()`) | "We use Meta (Facebook) Pixel to measure advertising effectiveness." | Advertising | 7. Cookies | HIGH |
| HotJar (`_hj*`, `hotjar.js`) | "We use HotJar to understand how users interact with our pages (heatmaps and session recordings)." | Analytics | 7. Cookies | HIGH |
| localStorage/sessionStorage (`localStorage.setItem`, `sessionStorage.setItem`) | "We use browser storage to [purpose]." | Varies — classify by purpose | 7. Cookies | MEDIUM |
| Fingerprinting APIs (`canvas.toDataURL`, `AudioContext`, `navigator.plugins`) | "We use browser fingerprinting techniques for [purpose]." | Analytics or Advertising | 7. Cookies | HIGH |
| Consent Management Platform (`cookieconsent`, `onetrust`, `osano`, `klaro`) | "We use [CMP] to manage your cookie preferences." | Strictly necessary | 7. Cookies | HIGH |
| No cookies or tracking found | "We do not use cookies or tracking technologies on this site." | N/A | 7. Cookies | HIGH |

---

## Automated Decisions → Notice Section 2 & Compliance Mapping

| Code Pattern | Notice Language | Notice Section | Confidence |
|-------------|----------------|---------------|------------|
| Credit scoring (`credit_score`, `risk_score`, approval/denial logic) | "We use automated processing to [assess creditworthiness/determine eligibility]. You have the right to request human review of this decision." | 2. How We Use It + GDPR Art. 22 | HIGH |
| Content moderation (`automod`, `spam_filter`, automated ban/flag) | "We use automated systems to moderate content and enforce community guidelines." | 2. How We Use It | MEDIUM |
| Pricing algorithms (`dynamic_price`, personalised pricing) | "We use automated processing to determine pricing." | 2. How We Use It + GDPR Art. 22 | HIGH |
| Recommendation engines (collaborative filtering, content-based) | "We use automated systems to recommend content based on your activity." | 2. How We Use It | MEDIUM |
| Automated account decisions (`suspend()`, `ban()`, automated `verified` status) | "We use automated systems to make decisions about account status. You can request human review." | 2. How We Use It + GDPR Art. 22 | HIGH |

---

## International Transfers → Notice Section 4

| Code Pattern | Notice Language | Notice Section | Confidence |
|-------------|----------------|---------------|------------|
| Cloud provider region config (`region: 'us-east-1'`, `location: 'US'`) | "Your data is processed in [regions]. We rely on [mechanism] for transfers outside [your jurisdiction]." | 4. Transfers | HIGH |
| CDN configuration (`cloudflare`, `cloudfront`, `fastly`) | "Content delivery may involve processing in multiple countries." | 4. Transfers | MEDIUM |
| Third-party API with known US hosting (`api.stripe.com`, `api.sendgrid.com`) | "Data shared with [vendor] may be transferred to the United States under [mechanism]." | 4. Transfers | HIGH |
| No transfer indicators | "Your data is processed in [TODO: specify location]. [TODO: confirm no international transfers]." | 4. Transfers | LOW |

---

## Children's Data → Notice Section 8

| Code Pattern | Notice Language | Notice Section | Confidence |
|-------------|----------------|---------------|------------|
| Age gate (`age >= 13`, `dateOfBirth`, age verification) | "We do not knowingly collect data from children under [age]. If you are under [age], please do not use this service." | 8. Children's Privacy | HIGH |
| Parental consent flow (`parent_email`, `guardian_consent`) | "If you are under [age], a parent or guardian must provide consent before you use this service." | 8. Children's Privacy | HIGH |
| Child-directed features (`kids_mode`, `child_profile`, COPPA compliance code) | "We offer features directed at children. We comply with [COPPA/GDPR Art. 8/LGPD Art. 14] by [measures]." | 8. Children's Privacy | HIGH |
| No age-related code found | "This service is not directed at children under [13/16]. We do not knowingly collect personal data from children." | 8. Children's Privacy | MEDIUM |

---

## Mapping Priority Rules

When multiple code patterns map to the same notice section, apply these rules:

1. **Specificity wins.** A specific vendor name (e.g., "Stripe") produces better notice language than a generic pattern (e.g., "payment processor"). Use the most specific pattern available.
2. **Code behaviour over labels.** If a function named `anonymize()` still retains identifiable data, the notice must describe the actual behaviour.
3. **Completeness over brevity.** Every identified data element must appear in at least one notice section. Missing disclosures are CRITICAL findings.
4. **Confidence propagation.** A notice statement inherits the lowest confidence of its constituent data elements. If one element is LOW confidence, the statement is LOW.
5. **TODO placeholders.** Use `[TODO: ...]` for items requiring human input: legal entity names, DPO contact, legal basis choices, retention period decisions, supervisory authority details.
