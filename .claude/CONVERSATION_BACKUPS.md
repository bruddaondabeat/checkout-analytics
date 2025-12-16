# Conversation Backups

**Purpose:** If Claude Code chat resets, paste these to resume context

---

## 🚀 UNIVERSAL RESUME PROMPT (Use This Every Time)

**Copy/paste this into any new Claude Code chat to resume your project:**

```
Resuming checkout-analytics project (Checkout.com interview prep).

IMPORTANT: Read these files FIRST to get full context:
1. .claude/AGENT_CONTEXT.md (current state, completed tasks, next actions)
2. README.md (project overview, coding standards)
3. .claude/WORKFLOW.md (workflow guide)

After reading, tell me:
- What tasks are completed
- What's currently in progress
- What should we work on next

Then wait for my instructions.
```

---

## Day 2 Session 3 (Dec 16, 2024) - Git Setup Complete

### Session Summary
**What we accomplished:**
- Initialized Git repository
- Created comprehensive .gitignore (dbt artifacts, Python, OS files)
- Made initial commit with all project files (15 files)
- Connected to GitHub at github.com/bruddaondabeat/checkout-analytics (PRIVATE)
- Renamed master → main branch
- Pushed to remote successfully
- Updated AGENT_CONTEXT.md and CONVERSATION_BACKUPS.md
- Learned Git concepts: identity, authentication, commit structure, branch naming

**Git configuration:**
- Identity: bruddaondabeat <bruddaondabeat@gmail.com>
- Repository: github.com/bruddaondabeat/checkout-analytics
- Branch: main
- Commits: 2 (initial + docs update)

### Quick Resume (If Starting New Chat)
```
Read .claude/AGENT_CONTEXT.md and continue from where we left off.

Last completed: Git setup and initial commits
Next task: Add schema.yml with dbt tests to staging models
```

### What We Just Completed (Git Setup)
- Initialized Git repository
- Created comprehensive .gitignore (dbt artifacts, Python, OS files)
- Made initial commit with all project files
- Connected to GitHub at github.com/bruddaondabeat/checkout-analytics
- Renamed master → main branch
- Pushed to remote successfully

### Git Learning Topics Covered
- .gitignore syntax and purpose
- Git identity vs GitHub authentication
- Commit message structure (title + body + footer)
- Branch naming (master vs main)
- Email matching for GitHub attribution
- Heredoc syntax (cat << 'EOF')

---

## Day 2 Session 1-2 (Dec 12-15, 2024)

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
