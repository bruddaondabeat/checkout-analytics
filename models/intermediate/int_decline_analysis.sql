/*
  Intermediate Model: Decline Analysis

  Purpose:
    Deep-dive analysis of declined transactions to understand WHY payments fail
    and quantify the revenue impact. This model powers root cause analysis and
    helps prioritize which decline reasons to tackle first.

  Grain: One row per unique combination of:
    - decline_reason
    - merchant_id + merchant_tier
    - payment_method
    - customer_country
    - transaction_date (daily granularity)

  Business Context:
    Not all declines are created equal:
    - "insufficient_funds" → Customer problem (can't fix)
    - "fraud_suspected" → Fraud system being too aggressive (can optimize)
    - "invalid_card" → Merchant checkout UX issue (can improve)

    This model helps Payment Success teams answer:
    - Which decline reasons cost us the most revenue?
    - Are certain merchants/countries getting more fraud flags?
    - Is our fraud system creating too many false declines?

  Answers Assessment Questions:
    - Q2: "Analyze acceptance rate by decline reason patterns"
    - Q4: "Profile detection - identify problematic decline clusters"
    - Q5: "Troubleshoot AR drops - has a specific decline reason spiked?"
*/

with transactions as (
    -- Import clean staging data
    select * from {{ ref('stg_stripe__transactions') }}
),

declined_transactions as (
    -- Filter to ONLY declined transactions for this analysis
    -- (Approved transactions don't have decline reasons)
    select
        transaction_id,
        transaction_date,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country,
        decline_reason,
        amount_usd,
        is_refund,
        created_at
    from (
        select
            transaction_id,
            date_trunc('day', created_at) as transaction_date,
            merchant_id,
            merchant_tier,
            payment_method,
            customer_country,
            decline_reason,
            amount_usd,
            is_refund,
            created_at
        from transactions
        where
            not is_approved  -- Only declined transactions
            and not is_refund  -- Exclude refunds (separate workflow)
    )
),

daily_decline_aggregates as (
    -- Roll up declines by key dimensions
    select
        -- Dimensions
        transaction_date,
        decline_reason,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country,

        -- Metrics
        count(*) as declined_transaction_count,
        sum(amount_usd) as declined_revenue_usd,
        avg(amount_usd) as avg_declined_amount_usd,

        -- Extremes (useful for fraud detection)
        min(amount_usd) as min_declined_amount_usd,
        max(amount_usd) as max_declined_amount_usd

    from declined_transactions
    group by
        transaction_date,
        decline_reason,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country
),

decline_reason_categories as (
    -- Add human-friendly categorization of decline reasons
    -- This groups 100+ raw decline codes into actionable buckets
    select
        *,

        case
            -- Customer-side issues (low recoverability)
            when decline_reason in ('insufficient_funds', 'card_velocity_exceeded', 'expired_card')
                then 'customer_issue'

            -- Fraud system flags (high recoverability via ML tuning)
            when decline_reason in ('fraud_suspected', 'do_not_honor')
                then 'fraud_system'

            -- Technical/validation errors (high recoverability via UX improvements)
            when decline_reason in ('invalid_card', 'technical_error')
                then 'technical_validation'

            -- Other/unknown
            else 'other'
        end as decline_category,

        -- Recoverability score: How easily can we fix this?
        case
            when decline_reason in ('fraud_suspected', 'do_not_honor')
                then 'high'  -- ML optimization can reduce false positives
            when decline_reason in ('invalid_card', 'technical_error')
                then 'medium'  -- UX improvements can help
            when decline_reason in ('insufficient_funds', 'expired_card')
                then 'low'  -- Customer must resolve
            else 'unknown'
        end as recoverability_potential

    from daily_decline_aggregates
),

final as (
    -- Add business-friendly metrics and flags
    select
        -- Dimensions
        transaction_date,
        decline_reason,
        decline_category,
        recoverability_potential,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country,

        -- Core metrics
        declined_transaction_count,
        round(declined_revenue_usd, 2) as declined_revenue_usd,
        round(avg_declined_amount_usd, 2) as avg_declined_amount_usd,
        round(min_declined_amount_usd, 2) as min_declined_amount_usd,
        round(max_declined_amount_usd, 2) as max_declined_amount_usd,

        -- Priority flags (for stakeholder dashboards)
        case
            when declined_revenue_usd >= 10000 then 'critical'  -- $10K+ in lost revenue
            when declined_revenue_usd >= 5000 then 'high'
            when declined_revenue_usd >= 1000 then 'medium'
            else 'low'
        end as revenue_impact_tier,

        -- Volume flags (statistical significance)
        case
            when declined_transaction_count >= 100 then 'high_volume'
            when declined_transaction_count >= 20 then 'medium_volume'
            else 'low_volume'
        end as decline_volume_tier,

        -- Fraud flag (potential false decline indicator)
        -- High-value transactions flagged as fraud are worth investigating
        case
            when decline_reason = 'fraud_suspected'
                and avg_declined_amount_usd > 200  -- Above-average transaction value
                then true
            else false
        end as potential_false_decline_flag

    from decline_reason_categories
)

select * from final
