# EDPB Dark Patterns Taxonomy

Reference checklist for the Consent Flow Reviewer skill. Based on EDPB Guidelines 3/2022 Section 4 — six categories with approximately 14 sub-types. Each sub-type includes a code detectability rating.

---

## Code Detectability Ratings

| Rating | Definition | Action |
|--------|-----------|--------|
| **HIGH** | Pattern is detectable from code alone (DOM structure, CSS, default values, event handlers) | Include in automated review with HIGH confidence |
| **MEDIUM** | Partially detectable from code; full assessment requires understanding rendered UI | Include in review with MEDIUM confidence; recommend visual verification |
| **LOW** | Requires runtime observation or user flow testing to confirm | Flag as potential concern with LOW confidence |
| **VISUAL-ONLY** | Cannot be detected from code; requires screenshot or UI walkthrough | Flag as requiring manual UI review; do not assign confidence |

---

## Category 1: Overloading

Confronting users with excessive requests, information, or options to nudge them towards sharing more data.

### 1.1 Continuous Prompting

**Definition:** Repeatedly asking the user to provide data or reconsider a privacy choice they have already made. The user is prompted again after refusing, creating fatigue.

**Code indicators:** Re-display logic after dismissal (check for `localStorage`/cookie flags like `banner_dismissed` with expiry or counter), modal re-trigger on subsequent page loads, "remind me later" with short intervals.

**Code detectability:** HIGH — dismissal storage, re-trigger timers, and counter logic are visible in code.

### 1.2 Privacy Maze

**Definition:** Scattering privacy information and settings across multiple pages, menus, and sub-menus, making it difficult for users to find or understand their choices.

**Code indicators:** Privacy settings split across 3+ route paths, consent management in a different section from privacy settings, withdrawal mechanism on a different page from the granting mechanism.

**Code detectability:** MEDIUM — route structure is visible but whether the navigation is confusing requires UX judgment.

### 1.3 Too Many Options

**Definition:** Presenting an overwhelming number of granular choices that makes managing privacy exhausting, even if each individual choice is valid.

**Code indicators:** Consent UI with 15+ individual toggles without grouping, no "reject all" shortcut alongside granular options, no sensible category defaults.

**Code detectability:** MEDIUM — toggle count is visible but whether the quantity is genuinely overwhelming requires context.

---

## Category 2: Skipping

Designing the interface so that users forget or do not think about privacy aspects.

### 2.1 Deceptive Snugness

**Definition:** Privacy-invasive options are pre-selected or set as defaults. The user must actively opt out rather than opt in.

**Code indicators:** `defaultChecked={true}` or `checked` attribute on tracking/marketing toggles, consent state initialised to `true` before user action, "Accept All" as the primary (larger, coloured) button with "Manage" as secondary (smaller, text-only).

**Code detectability:** HIGH — default values, CSS classes, and button hierarchy are visible in code.

### 2.2 Look Over There

**Definition:** Drawing attention away from privacy-relevant information by emphasising unrelated content, benefits, or distractions at the moment of consent.

**Code indicators:** Modal or overlay that appears simultaneously with or immediately before the consent banner (e.g., newsletter signup, promotional popup), animated elements competing for attention near consent UI.

**Code detectability:** MEDIUM — co-timed modals are visible in code, but whether they effectively distract requires visual assessment.

---

## Category 3: Stirring

Using emotional manipulation or visual nudges to influence privacy decisions.

### 3.1 Emotional Steering

**Definition:** Using words, imagery, or framing that appeals to emotions (guilt, fear, reward) to steer the user toward the less private option.

**Code indicators:** Consent text containing phrases like "you'll miss out", "help us improve your experience", "we need your support", shaming language for refusal ("No, I don't care about a better experience").

**Code detectability:** LOW — requires natural language analysis of consent copy, which is often in translation files or CMS-managed content.

### 3.2 Hidden in Plain Sight

**Definition:** Using visual design (colour, size, contrast, positioning) to make the privacy-protective option less noticeable than the privacy-invasive option.

**Code indicators:** CSS differences between accept and reject buttons — check for asymmetric styling (primary vs. ghost/text variant), size differences, colour contrast differences, z-index or positioning that deprioritises the reject option.

**Code detectability:** HIGH — CSS class assignments and button variant props are visible in code. Whether the visual effect constitutes a dark pattern requires judgment, but the asymmetry itself is detectable.

---

## Category 4: Hindering

Making it difficult or impossible to manage privacy or access information.

### 4.1 Dead End

**Definition:** Privacy settings or withdrawal mechanisms that appear to exist but do not function, lead to error pages, or loop back without effect.

**Code indicators:** Links to `#` or empty `onClick` handlers on privacy setting controls, withdrawal endpoints that return success without updating consent state, settings pages that save without persisting.

**Code detectability:** HIGH — non-functional handlers and missing persistence logic are visible in code.

### 4.2 Longer Than Necessary

**Definition:** The process for exercising privacy rights requires more steps than necessary, especially compared to the process for granting consent.

**Code indicators:** Withdrawal requiring navigation through 3+ pages or modals when granting was a single click, additional confirmation dialogs on withdrawal not present on granting, mandatory wait periods or "cooling off" screens.

**Code detectability:** HIGH — step count and confirmation dialogs are visible in code. Compare click/step count between granting and withdrawal paths.

### 4.3 Misleading Action

**Definition:** UI elements suggest one action but perform another. A button labelled "manage cookies" that actually accepts all cookies.

**Code indicators:** Button text/label does not match the handler function it triggers, "manage preferences" button that calls an `acceptAll()` function, "skip" button that sets consent to true.

**Code detectability:** HIGH — label-to-handler mismatch is visible in code.

---

## Category 5: Fickle

Designing interfaces inconsistently so users cannot build reliable expectations.

### 5.1 Lacking Hierarchy

**Definition:** Privacy information is presented without clear structure, making it difficult to distinguish important details from boilerplate.

**Code indicators:** Consent text rendered as a single block without headings, sections, or visual hierarchy, all options presented at the same visual weight regardless of privacy impact.

**Code detectability:** MEDIUM — DOM structure is visible but whether the hierarchy is sufficient requires UX judgment.

### 5.2 Decontextualising

**Definition:** Consent requests or privacy information presented out of context — divorced from the processing activity they relate to.

**Code indicators:** Consent collected at registration for processing that only occurs later in a different feature, consent banner on the homepage covering processing that only happens in a specific tool.

**Code detectability:** LOW — requires understanding the relationship between consent timing and processing activities, which involves cross-referencing multiple code paths.

---

## Category 6: Left in the Dark

Providing unclear, incomplete, or misleading information about privacy.

### 6.1 Language Discontinuity

**Definition:** Privacy information provided in a language different from the interface language, or using legal/technical jargon inaccessible to the target audience.

**Code indicators:** Consent text hardcoded in a single language while the app supports i18n, consent text not included in translation files, legal Latin or technical terms without plain-language equivalents.

**Code detectability:** MEDIUM — language file coverage is visible but readability assessment requires human judgment.

### 6.2 Conflicting Information

**Definition:** Different parts of the interface provide contradictory information about data processing, creating confusion about what the user has consented to.

**Code indicators:** Consent banner text contradicts privacy policy text (e.g., banner says "no third-party sharing" while code sends data to third parties), toggle labels that contradict their behaviour.

**Code detectability:** MEDIUM — requires cross-referencing consent UI text with actual code behaviour and privacy policy content.

### 6.3 Ambiguous Wording

**Definition:** Consent text uses vague, non-committal language that does not clearly describe what the user is consenting to ("we may share", "data might be used", "to improve services").

**Code indicators:** Consent copy containing hedging words: "may", "might", "could", "from time to time", "certain partners", "improve your experience". Purpose descriptions that do not specify concrete processing activities.

**Code detectability:** LOW — requires natural language analysis of consent copy.

---

## Quick Reference Table

| # | Category | Sub-Type | Code Detectability | Typical Severity |
|---|----------|----------|-------------------|-----------------|
| 1.1 | Overloading | Continuous prompting | HIGH | MEDIUM |
| 1.2 | Overloading | Privacy maze | MEDIUM | MEDIUM |
| 1.3 | Overloading | Too many options | MEDIUM | LOW |
| 2.1 | Skipping | Deceptive snugness | HIGH | HIGH |
| 2.2 | Skipping | Look over there | MEDIUM | MEDIUM |
| 3.1 | Stirring | Emotional steering | LOW | MEDIUM |
| 3.2 | Stirring | Hidden in plain sight | HIGH | HIGH |
| 4.1 | Hindering | Dead end | HIGH | CRITICAL |
| 4.2 | Hindering | Longer than necessary | HIGH | HIGH |
| 4.3 | Hindering | Misleading action | HIGH | CRITICAL |
| 5.1 | Fickle | Lacking hierarchy | MEDIUM | LOW |
| 5.2 | Fickle | Decontextualising | LOW | MEDIUM |
| 6.1 | Left in the dark | Language discontinuity | MEDIUM | MEDIUM |
| 6.2 | Left in the dark | Conflicting information | MEDIUM | HIGH |
| 6.3 | Left in the dark | Ambiguous wording | LOW | MEDIUM |

---

## Agent Behaviour Notes

- When reviewing consent UX, check all 6 categories. A consent banner may pass the GDPR validity checklist but still deploy dark patterns.
- For patterns rated HIGH code detectability, include specific file paths and line references in the Code Evidence column of the Dark Pattern Findings table.
- For patterns rated VISUAL-ONLY or LOW, note the potential concern and recommend manual UI review. Do not assign HIGH confidence to findings you cannot verify from code.
- Multiple dark patterns in the same consent flow compound severity. A banner with both deceptive snugness (2.1) and hidden in plain sight (3.2) is more severe than either alone.
