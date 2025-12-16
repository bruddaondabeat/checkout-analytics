# Conversation Backups

**Purpose:** If Claude Code chat resets, paste these to resume context

---

## Day 2 Session 1 (Dec 12, 2024)

### Initial Context Prompt
```
I'm building a payment analytics stack for Checkout.com's Payment Success team.

Assessment intel (what they tested):
- Q1: Demonstrate ROI of Intelligent Acceptance (A/B testing, lift metrics)
- Q2: Analyze acceptance rate by geography, card scheme, 3DS, payment method
- Q4: Profile detection (segment low AR combinations)
- Q5: Troubleshoot AR drops (time-series analysis)

Read context files:
1. README.md (project overview, CTE-only SQL pattern)
2. .claude/AGENT_CONTEXT.md (current state - Day 2)
3. .claude/CLAUDE_CODE_PROMPTS.md (task prompts)

IMPORTANT: After completing each task, update .claude/AGENT_CONTEXT.md

Current task: Create models/staging/stripe/stg_stripe__transactions.sql
[Full requirements listed above]
```

### Completed Tasks
- [x] Created _sources.yml
- [ ] Building stg_stripe__transactions.sql

### Key Decisions Made
- Using CTE pattern (import → logical → final)
- Converting cents to dollars (amount_usd = amount / 100.0)
- Adding is_approved boolean (status = 'available')

### Next Steps
- Finish staging model
- Add tests in schema.yml
- Run dbt and validate

---

## Day 2 Session 2 (if chat resets)

### Resume Prompt
```
Resuming Day 2 staging layer work.

Already completed:
- _sources.yml ✓
- stg_stripe__transactions.sql ✓ (if done by then)

Next task: [whatever is next]

Read .claude/AGENT_CONTEXT.md for full state.
[Add specific instructions for next task]
```

---

## Important Context to Preserve

**Coding standards:**
- CTE-only (never nested subqueries)
- snake_case naming
- Booleans start with is_/has_
- Money fields specify currency (amount_usd)

**Project structure:**
- RAW → STAGING (views) → INTERMEDIATE (views) → MARTS (tables)
- Each layer has specific purpose (see README.md)

**Assessment alignment:**
- Our models directly answer their test questions
- Q1 = mart_intelligent_acceptance_demo
- Q2 = int_acceptance_by_geography/method/etc
- Q4 = mart_profile_detection
- Q5 = mart_troubleshooting_dashboard
