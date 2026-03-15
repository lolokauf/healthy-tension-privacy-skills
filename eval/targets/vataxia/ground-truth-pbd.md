# PbD Code Review — Ground Truth: Vataxia

## Metadata
- **Target:** vataxia
- **Repo:** https://github.com/buckyroberts/Vataxia.git
- **Pinned commit:** 6ae68e8602df3e0544a5ca62ffa847a8a1a83a90
- **Stack:** Django 1.11, Django REST Framework 3.6, PostgreSQL
- **Date audited:** 2026-03-15
- **Audited by:** Lauren Kaufman + Claude

## Expected Findings

### Must-Find Items

| # | Finding | Principle | Expected Severity | Expected Confidence | Reasoning | Acceptable Alternatives |
|---|---------|-----------|-------------------|---------------------|-----------|------------------------|
| 1 | User email and full name exposed in ALL API responses via nested UserSerializer | 6 (Transparency) / 3 (Embedded) | HIGH | HIGH | Every endpoint (posts, replies, DMs, transfers, votes, wallets) returns full user details including email. This is massive PII over-exposure — the API leaks email addresses to any authenticated user. UserSerializer: `fields = ('id', 'email', 'first_name', 'last_name', ...)` | CRITICAL acceptable |
| 2 | Wallet balance endpoint accessible without authentication — anyone can view any user's balance | 5 (End-to-End) | CRITICAL | HIGH | `GET /wallets/{user_id}` has no authentication check. Any unauthenticated request can enumerate all user balances. | HIGH acceptable if reviewer classifies wallet as non-financial |
| 3 | Private messages stored plaintext with no encryption | 5 (End-to-End) | HIGH | HIGH | PrivateMessage.body and .subject stored as plaintext TextField in PostgreSQL. No field-level encryption. DM content visible to anyone with database access. | CRITICAL acceptable — DMs are highly sensitive |
| 4 | No account deletion mechanism for users — only moderators/admins can delete accounts | 7 (Respect) | HIGH | HIGH | DELETE on `/users/{user_id}` restricted to moderators and administrators (user.py lines 82-87). No self-service account deletion endpoint. Violates GDPR Art. 17. | CRITICAL acceptable |
| 5 | ForeignKey fields missing `on_delete` parameter — undefined cascade behavior on user deletion | 5 (End-to-End) | HIGH | HIGH | Every FK in the codebase omits `on_delete`. Django 1.11 defaulted to CASCADE but this was deprecated. Posts, DMs, votes, transfers, invitations may be orphaned or cascaded unpredictably. | MEDIUM acceptable if reviewer notes Django 1.11 implicit CASCADE |
| 6 | Hardcoded SECRET_KEY in base settings | 5 (End-to-End) | CRITICAL | HIGH | `config/settings/base.py` line 5: SECRET_KEY is hardcoded in source. Anyone with repo access can forge CSRF tokens, session cookies, and password reset tokens. | — |
| 7 | CORS_ORIGIN_ALLOW_ALL = True — accepts requests from any origin | 5 (End-to-End) | HIGH | HIGH | `config/settings/base.py` line 94. Allows any website to make authenticated API requests on behalf of logged-in users. Combined with session auth, enables CSRF-like attacks. | CRITICAL acceptable |
| 8 | No data export / portability feature | 7 (Respect) | HIGH | HIGH | No export endpoint. Users cannot obtain a copy of their data (posts, DMs, votes, transfers, profile). | MEDIUM acceptable |
| 9 | All profiles and user lists publicly accessible — no profile visibility controls | 2 (Privacy as Default) | HIGH | HIGH | `GET /users` and `GET /profiles` return all users with email + full name. `IsAuthenticatedOrReadOnly` allows unauthenticated read access. No private profile option. | — |
| 10 | Individual voting behaviour exposed — PostVoteSerializer reveals who voted and how | 3 (Embedded) | MEDIUM | HIGH | PostSerializer includes nested PostVoteSerializer showing every user's vote value (upvote/downvote). Reveals individual political/social preferences. | HIGH acceptable |

### Nice-to-Find Items

| # | Finding | Principle | Expected Severity | Expected Confidence | Reasoning |
|---|---------|-----------|-------------------|---------------------|-----------|
| 1 | Auth tokens valid indefinitely — no expiration until logout | 5 (End-to-End) | MEDIUM | HIGH | DRF TokenAuthentication issues tokens on login with no TTL. Stolen tokens grant permanent access. |
| 2 | No rate limiting on any endpoint | 5 (End-to-End) | MEDIUM | HIGH | Login, password reset, invitation acceptance, transfers — all unbounded. Enables brute force and enumeration. |
| 3 | BasicAuthentication enabled alongside TokenAuthentication | 5 (End-to-End) | MEDIUM | HIGH | base.py includes BasicAuthentication, which sends plaintext credentials in Authorization header. Risk if HTTPS not enforced. |
| 4 | ALLOWED_HOSTS = ['*'] — accepts requests from any domain | 5 (End-to-End) | HIGH | HIGH | Host header injection vulnerability. Attacker can manipulate password reset URLs. |
| 5 | FILE_UPLOAD_PERMISSIONS = 0o644 — world-readable uploaded files | 5 (End-to-End) | MEDIUM | HIGH | Profile images and post images readable by any process on the server. |
| 6 | Login endpoint leaks email existence | 1 (Proactive) | MEDIUM | HIGH | Login returns 404 when email not found vs. 401 for wrong password. Enables email enumeration. |
| 7 | No data retention policy — all content retained indefinitely | 5 (End-to-End) | MEDIUM | HIGH | No `deletedAt`, no TTL, no cleanup job on any model. Posts, DMs, transfers, votes stored forever. |
| 8 | Transfer history fully transparent to all authenticated users | 6 (Transparency) | MEDIUM | MEDIUM | `GET /transfers` returns all transfers with sender/receiver details. Financial transaction graph fully visible. |
| 9 | No blocking or muting mechanism | 7 (Respect) | MEDIUM | HIGH | Users cannot block other users from sending DMs, viewing profiles, or interacting with their content. |
| 10 | Django 1.11 (2017, EOL) with severely outdated dependencies | 5 (End-to-End) | HIGH | HIGH | All dependencies from 2016-2017. Known CVEs in Django, DRF, Pillow, psycopg2. |

### Expected Severity Distribution

- **CRITICAL:** 2 (hardcoded SECRET_KEY, unauthenticated wallet endpoint)
- **HIGH:** 6-8 (PII over-exposure in all responses, DMs plaintext, no account deletion, missing on_delete, CORS wide open, no data export, all profiles public)
- **MEDIUM:** 5-7 (voting behaviour, token expiry, no rate limiting, BasicAuth, file permissions, email enumeration, no retention, transfer visibility, no blocking)
- **LOW:** 0-1

### Expected Artifacts

| Artifact | Expected? | Key Content Expectations |
|----------|-----------|------------------------|
| PII Touchpoint Manifest | Yes | Should list 14+ PII fields across User, Profile, Post, PostReply, PrivateMessage, PostVote, Wallet, Transfer |
| Default Configuration Audit | Yes | Should flag: all profiles public by default, no privacy settings, CORS open, ALLOWED_HOSTS open, BasicAuth enabled |
| PII Data Flow Heatmap | Yes | Should show: UserSerializer nested everywhere — PII leaks through every endpoint. DM content in plaintext. |
| Privacy-Preserving Alternatives Table | Yes | Should suggest: minimal UserSerializer for public endpoints (id + username only), DM encryption, token expiration, scoped CORS |
| Data Lifecycle Table | Yes | Should flag: no retention policy, no deletion mechanism (self-service), no soft delete, undefined cascade |
| Transparency Audit | Yes | Should identify: 1 processor (AWS S3). Should note minimal third-party surface. |
| User Privacy Controls Checklist | Yes | Should check for: account deletion (missing — mod-only), data export (missing), blocking (missing), profile visibility (missing), DM controls (missing) |
| Delete-My-Account Trace | Yes | Should note: no self-service path exists. Mod-initiated DELETE on `/users/{user_id}`. Cascade behavior undefined (on_delete missing). Posts, DMs, votes, transfers may be orphaned. |

### Known Ambiguities

| Finding | Why It's Ambiguous | Acceptable Interpretations |
|---------|-------------------|---------------------------|
| Internal credits as financial data | Wallet/Transfer use virtual credits, not real money. Privacy implications differ from real payment data. | HIGH (financial PII regardless of currency) or MEDIUM (lower impact since credits aren't real money) |
| Django 1.11 implicit CASCADE | Missing `on_delete` defaulted to CASCADE in 1.11, which was deprecated but functional. | HIGH (undefined behavior, data integrity risk) or MEDIUM (implicit CASCADE was safe default) |
| Voting behaviour exposure | Cultural norm varies — public voting is common on some platforms (Reddit). | HIGH (reveals individual preferences) or MEDIUM (acceptable in social platform context) |
| UserSerializer email exposure | Some social platforms expose emails by design (open communities). | CRITICAL (mass PII leak) or HIGH (design choice, common in older APIs) |

### Red Herrings

| Item | Why It Looks Like an Issue | Why It's Not |
|------|--------------------------|-------------|
| `User.is_active` / `User.is_staff` flags | Per-user fields in user table | Boolean role flags, not PII — knowing someone's admin status doesn't identify them |
| `CreatedModified` timestamps on all models | Tracks when content was created/modified | Metadata timestamps in isolation are not PII — they become PII only when combined with user FKs (which ARE flagged) |
| `Invitation.code` as a PII field | UUID stored per-invitation, linked to users | It's an access credential (security token), not PII. The sender/receiver FKs are PII, but the UUID itself doesn't identify a person. |
| Missing email service integration | Looks like password reset can't work | Password reset uses UUID codes (ResetPasswordCode model) retrieved via API, not emailed. The lack of email integration is a feature limitation, not a privacy gap. |
| `Post.title` as always-PII | Post titles stored per-user | Titles are user-generated content that may or may not contain PII. Flagging every post title as PII is overly broad — it should be flagged as user_content with MEDIUM confidence. |
