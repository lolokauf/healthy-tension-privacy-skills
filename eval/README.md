# Privacy Skills Evaluation Suite

A repeatable evaluation framework for testing privacy skills against real open-source codebases. Scores skill output against human-authored ground truth using LLM-as-judge.

**This is not automated CI.** The eval suite produces scores and evidence. A human reviewer makes the final merge decision.

---

## How It Works

The eval suite runs each skill against curated target codebases, then scores the output:

1. **Clone** target repos at pinned commits (ground truth is tied to a specific codebase state)
2. **Run** each skill via `claude -p` — the agent explores the codebase autonomously using Read, Grep, Glob, and Bash
3. **Judge** each output against ground truth using a structured rubric (LLM-as-judge)
4. **Aggregate** scores into a summary with per-dimension ratings and a verdict

### Two-Tier Evaluation

The suite uses a **public/private split**, a standard practice in projects with quality gates (mirrors the ML validation/test set pattern):

- **Public tier** (in this repo, `eval/targets/`) — 3 target codebases with visible ground truth. Contributors run these locally to self-assess before submitting PRs.
- **Private holdout tier** (maintained separately by the repo maintainer) — additional target codebases with ground truth that contributors cannot see. The maintainer runs these during PR review.

**Why?** If all ground truth were public, contributors could overfit skills to pass specific test cases without genuinely improving quality. The public tier gives enough signal for self-assessment; the private tier ensures honest evaluation. The target repo URLs are visible in `targets.yaml` — knowing *which* repos are tested doesn't enable gaming because the ground truth (expected findings, severity judgments, must-find items) is what matters.

---

## Prerequisites

| Tool | Install | Purpose |
|------|---------|---------|
| `claude` | [claude.ai/code](https://claude.ai/code) (requires active subscription or API key) | Runs skills and judges output |
| `git` | Pre-installed on macOS/Linux | Clones target repos at pinned commits |
| `bash` | Pre-installed on macOS/Linux | Orchestration script |
| `yq` | `brew install yq` ([mikefarah/yq](https://github.com/mikefarah/yq), not the Python kislyuk/yq) | Parses `targets.yaml` |
| `jq` | `brew install jq` | Parses JSON transcripts from `claude` |

Verify your setup:

```bash
claude --version && git --version && yq --version && jq --version
```

---

## Running the Eval Suite

### Basic Usage

```bash
# Run all skills against all public targets (default)
./eval/run-eval.sh

# Run a specific skill against all public targets
./eval/run-eval.sh --skill pbd-code-review

# Run all skills against a specific target
./eval/run-eval.sh --target documenso

# Run a specific skill × target pair
./eval/run-eval.sh --skill data-mapping --target open-saas

# Validate setup without spending API credits
./eval/run-eval.sh --dry-run
```

### Maintainer: Running the Private Holdout

```bash
# Run private tier only
./eval/run-eval.sh --tier private --holdout-path /path/to/eval-holdout

# Run both public and private tiers
./eval/run-eval.sh --tier all --holdout-path /path/to/eval-holdout
```

### Reading Results

Results are written to `eval/results/<timestamp>/`:

```
eval/results/2026-03-15-14-30/
├── summary.md                              # Aggregate scores + verdicts
├── pbd-code-review--documenso--output.md   # Extracted skill output
├── pbd-code-review--documenso--scores.md   # Judge scores + evidence
├── data-mapping--documenso--output.md
├── data-mapping--documenso--scores.md
├── ...
├── transcripts/                            # Full JSON session transcripts
│   ├── pbd-code-review--documenso--transcript.json
│   └── ...
└── errors.log                              # Any failures during the run
```

The `summary.md` file contains the scoring table:

| Skill | Target | D1 | D2 | D3 | D4 | D5 | Total | Verdict |
|-------|--------|----|----|----|----|----|----|---------|
| pbd-code-review | documenso | 4 | 5 | 3 | 4 | 4 | 20 | PASS |
| data-mapping | documenso | 4 | 4 | 4 | 5 | 4 | 21 | STRONG PASS |

---

## Expected Cost

Each skill run involves an interactive Claude session (agent explores a codebase) plus a judge session.

| Component | Estimated Cost | Notes |
|-----------|---------------|-------|
| Skill run (interactive) | ~$2–5 | Depends on codebase size and turns used |
| Judge run (non-interactive) | ~$0.30–0.50 | Single prompt/response |
| **Full public suite** (3 targets × 2 skills) | **~$15–35** | 6 skill runs + 6 judge runs |

Each invocation is capped at `--max-budget-usd 5.00` as a safety net. The summary includes total actual cost from all invocations.

---

## Scoring Guide

### Verdict Meanings

| Verdict | Score Range | What It Means |
|---------|------------|---------------|
| **STRONG PASS** | 21–25/25 | Skill output is accurate, complete, and stakeholder-ready |
| **PASS** | 16–20/25 | Useful output with minor gaps; acceptable quality |
| **MARGINAL** | 11–15/25 | Significant gaps; needs improvement before relying on it |
| **FAIL** | 5–10/25 | Unreliable or largely inaccurate output |

### Scoring Dimensions

**PbD Code Review:** Finding Coverage, False Positive Rate, Severity Accuracy, Confidence Calibration, Output Quality

**Data Mapping:** Field Recall, Field Precision, Category Accuracy, Processor Coverage, Output Quality

See `judge-prompt.md` for full calibration tables.

---

## For Contributors

### Submitting a New Skill

1. **Write your skill** following `SKILL-TEMPLATE.md`
2. **Write ground truth** for each public target using `ground-truth-template.md`. Your skill needs a ground truth file for each of the 3 public targets:
   - `eval/targets/documenso/ground-truth-<your-skill-type>.md`
   - `eval/targets/open-saas/ground-truth-<your-skill-type>.md`
   - `eval/targets/vataxia/ground-truth-<your-skill-type>.md`
3. **Run the public eval suite:**
   ```bash
   ./eval/run-eval.sh --skill <your-skill-name>
   ```
4. **Include eval results** in your PR description (copy the summary table)
5. The **maintainer will run the full suite** (public + private holdout) during review

### Adding a New Eval Target

1. Choose a well-maintained open-source repo with real privacy patterns
2. Pin it to a specific commit SHA
3. Manually audit the codebase and write ground truth using `ground-truth-template.md`
4. Add the target to `targets.yaml`
5. Submit a PR with the ground truth files

---

## Limitations

- **LLM-as-judge has variance.** Running the same eval twice may produce slightly different scores (typically ±1 per dimension). The consistency test in the validation step measures this.
- **Ground truth reflects one auditor's judgment.** Privacy assessments are interpretive. The "acceptable alternatives" columns in ground truth docs account for reasonable disagreement.
- **Human review is the final gate.** Scores inform the maintainer's decision but do not replace judgment. A MARGINAL score with good reasoning may be more valuable than a PASS with superficial output.
- **Cost.** Each full suite run costs real API credits. Use `--dry-run` to validate setup, and `--skill`/`--target` flags to run targeted subsets during development.
