# Data Mapping — Ground Truth: Vataxia

## Metadata
- **Target:** vataxia
- **Repo:** https://github.com/buckyroberts/Vataxia.git
- **Pinned commit:** 6ae68e8602df3e0544a5ca62ffa847a8a1a83a90
- **Stack:** Django 1.11, Django REST Framework 3.6, PostgreSQL
- **Date audited:** 2026-03-15
- **Audited by:** Lauren Kaufman + Claude

## Expected PII Fields

### Must-Find Fields

| # | Data Element | Location | PII Category | Source | Storage | Expected Confidence | Acceptable Alternative Categories |
|---|-------------|----------|-------------|--------|---------|---------------------|----------------------------------|
| 1 | `User.email` | `v1/accounts/models/user.py` | contact | Registration (invitation-based) | PostgreSQL, plaintext, unique index | HIGH | identifier |
| 2 | `User.first_name` | User model | contact | Registration | PostgreSQL, plaintext | HIGH | identifier |
| 3 | `User.last_name` | User model | contact | Registration | PostgreSQL, plaintext | HIGH | identifier |
| 4 | `User.password` | AbstractBaseUser (Django) | authentication | Registration | PostgreSQL, Django password hasher | HIGH | — |
| 5 | `Profile.image` | `v1/accounts/models/profile.py` | biometric | Profile settings | Local filesystem or AWS S3 | HIGH | user_content |
| 6 | `PrivateMessage.body` | `v1/private_messages/models/private_message.py` | user_content | Direct messages between users | PostgreSQL, plaintext | HIGH | — |
| 7 | `PrivateMessage.subject` | PrivateMessage model | user_content | DM composition | PostgreSQL, plaintext | HIGH | — |
| 8 | `Post.body` | `v1/posts/models/post.py` | user_content | Post creation | PostgreSQL, plaintext | HIGH | — |
| 9 | `Post.image` | Post model | user_content | Post creation | Local filesystem or AWS S3 | HIGH | — |
| 10 | `PostReply.body` | `v1/replies/models/post_reply.py` | user_content | Reply to post | PostgreSQL, plaintext | HIGH | — |
| 11 | `Wallet.balance` | `v1/credits/models/wallet.py` | financial | Credits system | PostgreSQL | HIGH | — |
| 12 | `Transfer.amount` | `v1/credits/models/transfer.py` | financial | Credit transfers between users | PostgreSQL | HIGH | — |
| 13 | `PostVote.value` (linked to user) | `v1/votes/models/post_vote.py` | behavioural | Voting on posts | PostgreSQL | HIGH | user_content |
| 14 | `ResetPasswordCode.code` | `v1/accounts/models/reset_password_code.py` | authentication | Password reset flow | PostgreSQL, UUID plaintext | HIGH | — |

### Nice-to-Find Fields

| # | Data Element | Location | PII Category | Source | Expected Confidence |
|---|-------------|----------|-------------|--------|---------------------|
| 1 | `User.last_login` | AbstractBaseUser (Django internal) | behavioural | Login events | MEDIUM (Django internal, not in app model) |
| 2 | `User.date_joined` | User model | identifier | Registration | HIGH |
| 3 | `Post.title` | Post model | user_content | Post creation | MEDIUM (titles may contain PII) |
| 4 | `Invitation.code` | `v1/credits/models/invitation.py` | authentication | Invitation system | HIGH (UUID access token) |
| 5 | `Transfer.sender` / `Transfer.receiver` FK pairs | Transfer model | behavioural | Credit transfers | HIGH (reveals financial relationships) |
| 6 | DRF auth tokens | `rest_framework.authtoken` (Django table) | authentication | Login | MEDIUM (framework-managed, not in app models) |
| 7 | `Moderator.sponsor` FK | Moderator model | identifier | Moderator appointment | MEDIUM (reveals who promoted whom) |

## Expected Processors

| Processor | Data Received | Purpose | Expected Confidence |
|-----------|--------------|---------|---------------------|
| AWS S3 | Profile images, post images | File storage (production only) | HIGH |

**Note:** This is an unusually sparse processor list. The codebase has no analytics, no email service, no payment processor, and no AI integration. Skills should correctly report minimal third-party sharing rather than inventing processors.

## Expected Data Flows

1. **Registration**: Invitation code submitted → `accept_invitation` endpoint validates UUID → User record created with email + name + hashed password → Profile created → Wallet created (balance=0) → Auth token returned
2. **Login**: Email + password → DRF TokenAuthentication → 40-char hex token returned with full user object (including email)
3. **Post creation**: Authenticated user submits title + body + optional image → Post record + optional file to S3/local storage
4. **Private messaging**: Authenticated user sends DM → PrivateMessage record with sender/receiver FKs + subject + body (plaintext)
5. **Voting**: Authenticated user votes on post → PostVote record linking user to post with value (unique constraint)
6. **Credit transfer**: Authenticated user transfers credits → Transfer record linking sender/receiver → Wallet balances updated
7. **Profile image upload**: Authenticated user uploads image → stored at MEDIA_ROOT (local) or S3 (production) → Profile.image field updated
8. **API responses**: All list/detail endpoints return nested UserSerializer → email + first_name + last_name exposed in every response

## Expected Completeness

- **Approximate %:** 80-90%
- **Reasoning:** The Django models are straightforward and all in one directory structure (`v1/`). Must-find fields are clearly defined in Python model classes. The main gaps will be: Django-internal tables (auth tokens, sessions, permissions), the implicit `last_login` field from `AbstractBaseUser`, and understanding that `Transfer` records reveal financial relationships between users. The minimal third-party integration surface means processor coverage is simple.

## Known Ambiguities

| Data Element | Why It's Ambiguous | Acceptable Categories |
|-------------|-------------------|----------------------|
| `PostVote.value` | Individual voting behavior — behavioural data or user content? | behavioural, user_content |
| `Profile.image` | Profile photo — biometric (face photo) or user_content? | biometric, user_content, identifier |
| `Wallet.balance` | Internal credits, not real money — financial PII or application state? | financial, or not PII (application metric) |
| `Transfer.amount` | Internal credits transfer — financial PII? | financial, or not PII |
| `Post.title` | May or may not contain PII depending on content | user_content, or not PII |
| Django auth tokens | Framework-managed, not in application models | authentication (if discovered), or out-of-scope |

## Red Herrings

| Item | Why It Looks Like PII | Why It's Not |
|------|----------------------|-------------|
| `User.is_active` / `User.is_staff` | Per-user boolean flags stored in user table | Role/status flags, not PII — knowing someone is active or staff doesn't identify them |
| `Post.created_date` / `modified_date` | Stored per-user action | Metadata timestamps — not personal data on their own. Only PII when combined with user FK (which IS flagged). |
| `CreatedModified` base class timestamps | Inherited by many models | Infrastructure timestamps, not PII in isolation |
| `Invitation.code` as sensitive secret | Looks like it should be hashed | It's a UUID4 (128-bit random). While it should be treated as a secret, it's not PII itself — it's an access credential. Flagging it as PII would be imprecise; flagging it as a security token is correct. |
