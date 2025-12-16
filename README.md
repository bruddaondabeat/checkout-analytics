# 💳 Checkout Americas: Payment Analytics Stack

**Mission:** Founding analytics infrastructure for Checkout.com Americas team
**Status:** 🟢 Active Sprint (Day 1 Complete)
**Role Context:** Founding Analytics Engineer (Staff-level responsibilities)

---

## 🎯 Business Problem

Checkout.com's Payment Success team optimizes **authorization rates** for Tier-1 merchants (eBay, ASOS, Uber Eats). Every 1% improvement in acceptance rate = millions in recovered revenue.

**This project demonstrates:**
1. Payment performance analytics (auth rates, decline analysis, fraud trade-offs)
2. Modern data stack implementation (Snowflake + dbt + testing)
3. Stakeholder-ready outputs (metrics that drive merchant ROI)

---

## 🛠 The Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Warehouse** | Snowflake | Raw data storage + compute |
| **Transformation** | dbt Core | Staging → Intermediate → Marts |
| **Data Quality** | dbt tests | Unique, not_null, relationships |
| **Documentation** | dbt docs | Lineage + business definitions |
| **Version Control** | GitHub | All code + standards documented |

**Snowflake Details:**
- Account: `xac70110.us-east-1`
- Database: `ANALYTICS`
- Schemas: `RAW` (source data), `STAGING`, `INTERMEDIATE`, `MARTS`

---

## 📊 Top 5 Payment Metrics (Industry Standard)

Based on Stripe API schema and fintech best practices:

| Metric | Definition | Business Impact | Benchmark |
|--------|-----------|-----------------|-----------|
| **1. Authorization Rate** | % of transactions approved by issuer | Core revenue metric | 95%+ healthy |
| **2. Decline Rate** | % declined, broken down by reason | Optimization opportunity | Minimize |
| **3. False Decline Rate** | % of legitimate transactions wrongly blocked | Revenue loss + churn | <2% ideal |
| **4. Chargeback Rate** | % of successful transactions disputed | Fraud balance indicator | <1% required |
| **5. Transaction Success Rate** | Auth → capture → settlement success | End-to-end funnel health | 98%+ target |

**Source:** Checkout.com blog, Stripe docs, industry research

---

## 🗂 Data Model Architecture

### Raw Layer (`ANALYTICS.RAW`)
- `STRIPE_TRANSACTIONS` - 150k synthetic transactions (based on official Stripe Balance Transaction schema)
- Fields: id, amount, fee, status, type, merchant_id, payment_method, decline_reason, etc.

### Staging Layer (`models/staging/`)
**Purpose:** Clean, rename, cast raw data
- `stg_stripe__transactions.sql` - One row per transaction, standardized columns
- `stg_stripe__merchants.sql` - Merchant dimension (tier, attributes)

### Intermediate Layer (`models/intermediate/`)
**Purpose:** Calculate business metrics
- `int_authorization_rates.sql` - Auth rate by merchant/method/country
- `int_decline_analysis.sql` - Decline reason breakdown + trends
- `int_false_decline_revenue_loss.sql` - Revenue impact calculation
- `int_chargeback_risk.sql` - Chargeback patterns + indicators
- `int_transaction_success_funnel.sql` - Auth → settlement funnel

### Marts Layer (`models/marts/`)
**Purpose:** Stakeholder-ready datasets for BI tools
- `mart_payment_performance.sql` - Executive dashboard (all 5 metrics)
- `mart_merchant_health.sql` - Per-merchant scorecard
- `mart_fraud_vs_acceptance.sql` - Trade-off analysis tool

---

## 🧠 Coding Standards (ENFORCED)

### SQL Style Guide
**The "Import → Logical → Final" Pattern (CTE-only)**

```sql
with source as (
    select * from {{ source('stripe', 'transactions') }}
),

renamed as (
    select
        id as transaction_id,
        amount / 100.0 as amount_usd,  -- Convert cents to dollars
        status
    from source
),

final as (
    select
        *,
        case when status = 'available' then true else false end as is_approved
    from renamed
)

select * from final
```

**Rules:**
- ✅ Always use CTEs (never nested subqueries)
- ✅ snake_case for all identifiers
- ✅ Boolean fields start with `is_` or `has_`
- ✅ Timestamps end with `_at`, dates with `_date`
- ✅ Money fields specify currency (e.g., `amount_usd`)

### Naming Conventions
- **Models:** `stg_[source]__[entity].sql` (e.g., `stg_stripe__transactions.sql`)
- **Tests:** defined in `schema.yml` files (unique, not_null, relationships)
- **Documentation:** Every model + column described in schema.yml

---

## 🚀 Quick Start

**Prerequisites:**
- Python 3.13+ with venv activated
- Snowflake account with credentials configured
- dbt Core 1.8+ installed

**Setup:**
```bash
# 1. Navigate to project
cd /Users/sov-t/checkout-analytics

# 2. Data already generated (150k rows in data/stripe_transactions.csv)

# 3. Load to Snowflake
# Use Snowflake UI or SnowSQL to run scripts/load_to_snowflake.sql

# 4. Initialize dbt (when ready)
dbt init

# 5. Test connection
dbt debug

# 6. Run models
dbt run

# 7. Run tests
dbt test

# 8. Generate documentation
dbt docs generate
dbt docs serve
```

---

## 📈 Current Sprint Progress

**7-Day Sprint (Dec 12-18):**

| Day | Focus | Deliverable | Status |
|-----|-------|-------------|--------|
| 1 | Infrastructure | ✅ Data generated (150k rows, 82% approval rate) | DONE |
| 2 | Staging Layer | stg_stripe__transactions + tests | NEXT |
| 3 | Intermediate | Authorization + decline metrics | PENDING |
| 4 | Marts | Executive dashboard models | PENDING |
| 5 | Tests + Docs | Full test coverage, dbt docs live | PENDING |
| 6 | Loom | 5-7 min walkthrough video | PENDING |
| 7 | Interview Prep | Portfolio page + talking points | PENDING |

---

## 💼 Interview Context

**Checkout.com Round 3 (Hiring Manager):**
> "You're interviewing to be the FIRST analytics hire for the Americas team. You'll build the data function from scratch. What would you implement on day 1?"

**My Answer:**
> "Here's the exact stack I'd build [share this repo]. It follows payment industry best practices - the Top 5 metrics every fintech tracks. The architecture is scalable: staging for data quality, intermediate for business logic, marts for stakeholder self-service. I've prototyped it here with synthetic Stripe data. Here's the lineage [dbt docs], here's a sample analysis [Loom], and here's how I'd onboard the next analyst I hire [.claude/AGENT_CONTEXT.md]."

**This demonstrates:**
- ✅ Domain knowledge (payment metrics, Stripe schema)
- ✅ Technical execution (dbt, Snowflake, testing)
- ✅ Strategic thinking (team scalability, stakeholder enablement)
- ✅ Communication (docs, Loom, README)

---

## 📝 Key Architectural Decisions

### 1. Why Snowflake over BigQuery?
- **Decision:** Snowflake
- **Reasoning:** Industry standard for fintech/payments, separation of compute/storage
- **Trade-off:** More setup than serverless BQ

### 2. Why dbt Core over dbt Cloud?
- **Decision:** dbt Core (local development)
- **Reasoning:** Full version control, no vendor lock-in
- **Trade-off:** Manual setup vs Cloud's web IDE

### 3. Why synthetic data vs real datasets?
- **Decision:** Generate synthetic Stripe data
- **Reasoning:** Realistic schema, full control, no PII concerns
- **Trade-off:** Not "real" but proves architectural competence

### 4. Why Top 5 metrics only?
- **Decision:** Focus on core payment KPIs
- **Reasoning:** 80/20 rule - these drive 90% of merchant ROI
- **Trade-off:** Could add more, but better to nail the fundamentals

---

**Last Updated:** 2024-12-12
**Next Milestone:** Load data to Snowflake, begin staging layer
