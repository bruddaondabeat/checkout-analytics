# Claude Code CLI Prompts

**Use these prompts when you start Claude Code CLI in the checkout-analytics project.**

---

## Initial Handoff Prompt (Start Here)

```
I'm building a payment analytics stack for a Checkout.com founding team interview.

Read these files first:
1. README.md (project overview)
2. .claude/AGENT_CONTEXT.md (current state)
3. .claude/WORKFLOW.md (how we work together)

I'm ready to start Day 2: Build the staging layer. Please:
1. Confirm you understand the project context
2. Tell me what we're building today
3. Walk me through the first step

Follow the CTE-only SQL style from README.md.
```

---

## Day 2: Staging Layer

### Task 1: Create Sources File

```
Create models/staging/stripe/_sources.yml that declares ANALYTICS.RAW.STRIPE_TRANSACTIONS as a dbt source.

Include:
- Source name: stripe
- Database: ANALYTICS
- Schema: RAW
- Table: stripe_transactions (map to STRIPE_TRANSACTIONS)
- Description of the dataset
- Key column descriptions (id, amount, status, decline_reason, etc.)
- Tests: unique and not_null on id

Explain what dbt sources are and why we use them instead of hardcoding table names.
```

### Task 2: Create Staging Model

```
Create models/staging/stripe/stg_stripe__transactions.sql

Requirements:
1. Use the CTE pattern: source → renamed → final
2. Reference the source using {{ source('stripe', 'stripe_transactions') }}
3. Clean and rename columns:
   - id → transaction_id
   - amount → amount_cents (keep as integer)
   - Add amount_usd (amount / 100.0)
   - status → status (keep as-is)
   - Add is_approved boolean (status = 'available')
   - decline_reason → decline_reason
   - merchant_id, merchant_tier, payment_method, customer_country (keep)
   - created → created_at, available_on → available_on_at
4. Add comment explaining what staging models do

Explain:
- Why we convert cents to dollars
- Why we create is_approved boolean
- What the CTE pattern achieves
```

### Task 3: Add Tests and Documentation

```
Create models/staging/stripe/schema.yml

Include:
1. Model: stg_stripe__transactions
2. Description: "Cleaned and standardized Stripe balance transactions"
3. Column tests:
   - transaction_id: unique, not_null
   - status: not_null, accepted_values (available, pending)
   - is_approved: accepted_values (true, false)
4. Column descriptions for key fields

Explain what dbt tests do and why they matter.
```

### Task 4: Run and Validate

```
Help me run these commands and interpret the results:

1. dbt run --select stg_stripe__transactions
2. dbt test --select stg_stripe__transactions
3. Show me how to query the staging model in Snowflake

Expected outcomes:
- Model creates successfully as a view in ANALYTICS.STAGING
- All tests pass
- Row count matches raw (150k)
```

---

## Day 3: Intermediate Layer

### Authorization Rate Model

```
Create models/intermediate/int_authorization_rates.sql

Calculate authorization rate by:
- merchant_id, merchant_tier
- payment_method
- customer_country
- date (created_at truncated to day)

Metrics:
- total_transactions (count)
- approved_transactions (count where is_approved)
- authorization_rate (approved / total * 100)

Use {{ ref('stg_stripe__transactions') }} to reference staging model.

Explain:
- Why we use ref() instead of hardcoded table names
- What authorization rate means for Checkout's business
- Why we segment by merchant/method/country
```

### Decline Analysis Model

```
Create models/intermediate/int_decline_analysis.sql

Analyze declined transactions (where is_approved = false):
- Group by decline_reason
- Count transactions
- Calculate % of total declines
- Sum revenue lost (amount_usd)
- Add time trends (by day)

Explain how this helps identify optimization opportunities.
```

---

## Day 4: Marts Layer

### Executive Dashboard Mart

```
Create models/marts/mart_payment_performance.sql

Combine metrics from intermediate models into one BI-ready table:
- Authorization rate (from int_authorization_rates)
- Decline breakdown (from int_decline_analysis)
- Top merchants (from int_authorization_rates)
- Daily trends

Materialize as TABLE (not view) for dashboard performance.

Explain:
- Why marts are tables vs staging/intermediate views
- What makes this "BI-ready"
- How stakeholders would use this
```

---

## General Guidance for All Tasks

**When you generate code:**
1. Follow the CTE-only pattern (no subqueries)
2. Use snake_case for all identifiers
3. Add comments explaining business logic
4. Reference other models with {{ ref() }} or {{ source() }}

**When you explain:**
1. Start with "what" (what this model does)
2. Then "why" (business context, interview relevance)
3. Then "how" (technical implementation)
4. Highlight trade-offs or decisions made

**After each task:**
1. Show me how to run it (`dbt run --select model_name`)
2. Show me how to test it (`dbt test --select model_name`)
3. Update .claude/AGENT_CONTEXT.md to mark the task complete

---

## Quick Reference Commands

```bash
# Run all models
dbt run

# Run specific model
dbt run --select stg_stripe__transactions

# Run model and everything downstream
dbt run --select stg_stripe__transactions+

# Test specific model
dbt test --select stg_stripe__transactions

# Generate documentation
dbt docs generate
dbt docs serve

# Debug connection
dbt debug

# Compile model to see SQL
dbt compile --select stg_stripe__transactions
```

---

## Interview Talking Points

**For each model, prepare to say:**
1. What problem it solves for the Payment Success team
2. Why you structured it this way (staging → intermediate → marts)
3. How it scales (tests, documentation, modularity)
4. What you'd build next (if you had more time)

---

**Remember:** This isn't just a dbt project. It's a **founding team architecture proposal**. Every decision demonstrates your ability to build scalable data systems.
