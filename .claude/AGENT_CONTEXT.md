# Agent Context (Read This First)

**Last Updated:** 2024-12-16 09:30 by Claude Code
**Project:** Checkout Americas Payment Analytics Stack

---

## 🎯 Current Sprint State

**Day:** 2 of 7
**Focus:** Intermediate layer models (2 of 5 complete)
**Blocker:** None
**Next Action:** Build remaining intermediate models OR move to marts layer

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
- [x] **Created `models/staging/stripe/schema.yml`** (11 tests: unique, not_null, accepted_values)
- [x] **Ran `dbt test --select stg_stripe__transactions`** (11 of 11 tests PASSED ✅)
- [x] **Validated transformations in Snowflake** (approval rate 81.95%, 150k rows confirmed)
- [x] **Created `int_authorization_rates.sql`** (Metric #1 - auth rate by merchant/method/country/time)
- [x] **Ran `dbt run --select int_authorization_rates`** (SUCCESS in 0.40s)
- [x] **Created `int_decline_analysis.sql`** (Metric #2 - decline reason breakdown + revenue impact)
- [x] **Ran `dbt run --select int_decline_analysis`** (SUCCESS in 0.51s)
- [x] **Git repository initialized** (Dec 16, 2024)
- [x] **Configured Git identity** (bruddaondabeat <bruddaondabeat@gmail.com>)
- [x] **Created `.gitignore`** (excludes target/, logs/, dbt_packages/, .venv/, *.session.sql)
- [x] **Initial commit created** (15 files: models, configs, scripts, docs)
- [x] **Connected to GitHub** (github.com/bruddaondabeat/checkout-analytics - PRIVATE)
- [x] **Renamed branch** master → main (modern standard)
- [x] **Pushed to GitHub** (initial commit now on remote)

---

## 🔄 Active Tasks

- [ ] Decide: Build remaining 3 intermediate models OR skip to marts layer for interview demo

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

**Staging Layer Complete! ✅**

1. **Created `stg_stripe__transactions.sql`:**
   - Implemented source → renamed → final CTE pattern
   - Converted cents to dollars (`amount_usd = amount / 100.0`) while preserving `amount_cents`
   - Added `is_approved` boolean (TRUE when status = 'available')
   - Added `is_refund` boolean for revenue calculations
   - Standardized timestamps with `_at` suffix
   - Model ran successfully: `dbt run --select stg_stripe__transactions` (SUCCESS in 0.41s)

2. **Created `models/staging/stripe/schema.yml`:**
   - Added 11 data quality tests (unique, not_null, accepted_values)
   - Comprehensive column documentation for all 20+ fields
   - Business context and use case examples included
   - All tests passed: `dbt test` (11 of 11 PASSED ✅)

3. **Validated in Snowflake:**
   - Row count: 150,000 (matches raw data ✅)
   - Approval rate: 81.95% (expected ~82% ✅)
   - Boolean logic verified (is_approved, is_refund working correctly)

**Intermediate Layer Progress (2 of 5 models complete):**

4. **Created `int_authorization_rates.sql`:**
   - Calculates auth rate % by merchant/payment_method/country/date
   - Adds performance_tier flags (excellent/good/needs_improvement/critical)
   - Includes revenue_at_risk_usd metric (how much $ are we losing?)
   - Ran successfully: `dbt run --select int_authorization_rates` (0.40s)
   - Validation queries added to session.sql

5. **Created `int_decline_analysis.sql`:**
   - Deep-dive on WHY transactions decline (by decline_reason)
   - Categories: customer_issue vs fraud_system vs technical_validation
   - Recoverability scoring (high/medium/low - where to focus optimization)
   - potential_false_decline_flag for high-value fraud suspects
   - Ran successfully: `dbt run --select int_decline_analysis` (0.51s)
   - Validation queries added to session.sql

**Next decision:**
- Option A: Build remaining 3 intermediate models (false_decline_revenue_loss, chargeback_risk, transaction_success_funnel)
- Option B: Skip to marts layer with existing 2 models (enough to demo architecture for interview)

**Recommendation:** Option B - we have enough to show:
1. Staging → Intermediate → Marts architecture
2. CTE pattern mastery
3. Business metrics (auth rate + decline analysis covers 80% of use cases)
4. dbt lineage with ref()
5. Data quality testing

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
