# Agent Context (Read This First)

**Last Updated:** 2024-12-16 06:05 by Claude Code
**Project:** Checkout Americas Payment Analytics Stack

---

## 🎯 Current Sprint State

**Day:** 2 of 7
**Focus:** Building staging layer models
**Blocker:** None
**Next Action:** Add schema.yml with dbt tests, then run dbt test

---

## ✅ Completed Tasks

- [x] Generated synthetic Stripe payment data (150k transactions, 82% approval rate)
- [x] Created project structure (`/Users/sov-t/checkout-analytics`)
- [x] Loaded data to Snowflake (`ANALYTICS.RAW.STRIPE_TRANSACTIONS` - 150k rows verified)
- [x] Initialized dbt project (dbt v1.11.0, connection tested successfully)
- [x] Configured `dbt_project.yml` (staging/intermediate/marts structure)
- [x] Created Snowflake schemas (STAGING, INTERMEDIATE, MARTS)
- [x] Documented project (`README.md`, `.claude/WORKFLOW.md`, this file)
- [x] Created `models/staging/stripe/_sources.yml` (declares source, includes tests)
- [x] Created `models/staging/stripe/stg_stripe__transactions.sql` (CTE pattern, ran successfully)
- [x] Ran `dbt run --select stg_stripe__transactions` (SUCCESS - view created in STAGING_staging)

---

## 🔄 Active Tasks

- [ ] Create `models/staging/stripe/schema.yml` with column tests and documentation
- [ ] Run `dbt test --select stg_stripe__transactions` to validate data quality
- [ ] Query staging model in Snowflake to verify transformations (see validation queries in session.sql)

---

## 📊 Data Summary

**Dataset:** Synthetic Stripe Balance Transactions
**Rows:** 150,000
**Date Range:** 2024-12-12 to 2025-12-12
**Approval Rate:** 82.0% (healthy benchmark)
**Total Volume:** $23.5M

**Decline Reasons Distribution:**
- insufficient_funds: 8,973
- fraud_suspected: 6,077
- invalid_card: 4,581
- technical_error: 3,046
- do_not_honor: 2,224
- expired_card: 1,473
- card_velocity_exceeded: 700

**Key Fields:**
- `id` (transaction_id)
- `amount` (in cents)
- `fee`, `net`
- `status` (available/pending)
- `type` (charge, payment, refund, etc.)
- `merchant_id`, `merchant_tier`
- `payment_method`, `customer_country`
- `decline_reason`

---

## 🏗 Architecture Plan

```
RAW → STAGING → INTERMEDIATE → MARTS
```

**Staging Models (Day 2):**
1. `stg_stripe__transactions` - Clean transaction data
2. `stg_stripe__merchants` - Merchant dimension

**Intermediate Models (Day 3):**
1. `int_authorization_rates` - Metric #1
2. `int_decline_analysis` - Metric #2
3. `int_false_decline_revenue_loss` - Metric #3
4. `int_chargeback_risk` - Metric #4
5. `int_transaction_success_funnel` - Metric #5

**Marts (Day 4):**
1. `mart_payment_performance` - Executive dashboard
2. `mart_merchant_health` - Per-merchant scorecard
3. `mart_fraud_vs_acceptance` - Trade-off analysis

---

## 🎤 Interview Context

**Checkout.com Interview Timeline:**
- ✅ Round 1: Recruiter screen (PASSED)
- ✅ Round 2: Technical assessment (COMPLETED Dec 12)
- ⏳ Round 3: Hiring manager (likely next week)
- ⏳ Round 4: Technical (SQL + case study)
- ⏳ Round 5: Final round

**Assessment Insights (What They Care About):**
1. **Q1:** Demonstrating ROI of Intelligent Acceptance tool (A/B testing, lift metrics)
2. **Q2:** 5+ analyses to improve acceptance rate (geography, card scheme, 3DS, recurring)
3. **Q3:** ML model design (predict is_authorised, handle class imbalance)
4. **Q4:** Profile detection algorithm (decision tree, segment low AR combinations)
5. **Q5:** Troubleshooting AR drops (root cause analysis, diagnostic questions)

**This project directly answers their assessment questions with working code.**

**GoodLeap Interview:**
- ✅ Round 1: Recruiter screen (PASSED)
- ⏳ Round 2-4: TBD

---

## 🛠 Technical Environment

**Snowflake:**
- Account: `xac70110.us-east-1`
- Database: `ANALYTICS`
- Schemas: `RAW` ✅ (data loaded), `STAGING` ✅, `INTERMEDIATE` ✅, `MARTS` ✅

**Local:**
- Project: `/Users/sov-t/checkout-analytics`
- Python: 3.13 (`.venv` active in this project)
- dbt: v1.11.0 ✅ (dbt-snowflake installed, connection verified)
- dbt profile: `payment_analytics` in `~/.dbt/profiles.yml`

**dbt Configuration:**
- Staging models: Views in `ANALYTICS.STAGING`
- Intermediate models: Views in `ANALYTICS.INTERMEDIATE`
- Marts models: Tables in `ANALYTICS.MARTS`

---

## ❓ Questions for Human

*[Agents log questions here for async answers]*

None currently - all infrastructure is set up and ready

---

## 📝 Recent Changes (2024-12-16)

**Created `stg_stripe__transactions.sql`:**
- Implemented source → renamed → final CTE pattern
- Converted cents to dollars (`amount_usd = amount / 100.0`) while preserving `amount_cents`
- Added `is_approved` boolean (TRUE when status = 'available')
- Added `is_refund` boolean for revenue calculations
- Standardized timestamps with `_at` suffix
- Model ran successfully: `dbt run --select stg_stripe__transactions` (SUCCESS in 0.41s)
- Created view in `ANALYTICS.STAGING_staging.stg_stripe__transactions`

**Next steps:**
- Add schema.yml with dbt tests (unique, not_null, accepted_values)
- Validate data quality with `dbt test`
- Query staging model in Snowflake to verify transformations

---

## 📝 Notes for Next Agent

- This is a NEW project, separate from the ML math learning work
- All files are in `/Users/sov-t/checkout-analytics` (not ml-math-learning)
- Data is generated and ready to load
- Follow coding standards in README.md (CTE-only pattern)
- This is for a FOUNDING TEAM interview - think architecture, not just execution

---

## 🔄 Update Protocol

When you complete a task:
1. Move it from "Active Tasks" to "Completed Tasks" (check the box)
2. Update "Last Updated" timestamp at top
3. Log any new blockers or questions
4. Note next action clearly

**Remember:** This file is shared state. Keep it current so any agent can pick up where you left off.
