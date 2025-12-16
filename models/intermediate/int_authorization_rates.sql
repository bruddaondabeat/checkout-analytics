/*
  Intermediate Model: Authorization Rates

  Purpose:
    Calculate authorization rate (% of transactions approved by issuing banks)
    segmented by key business dimensions. This is THE core metric for payment
    performance analysis - every 1% improvement = millions in recovered revenue.

  Grain: One row per unique combination of:
    - merchant_id + merchant_tier
    - payment_method
    - customer_country
    - transaction_date (daily granularity)

  Business Context:
    Checkout.com's Payment Success team uses this to:
    1. Identify underperforming merchant/method/geography combinations
    2. A/B test Intelligent Acceptance optimizations
    3. Track auth rate trends over time
    4. Benchmark merchants against tier averages

  Answers Assessment Questions:
    - Q2: "Analyze acceptance rate by geography, card scheme, payment method"
    - Q4: "Profile detection - segment low AR combinations"
    - Q5: "Troubleshoot AR drops - time-series analysis"
*/

with transactions as (
    -- Import cleaned staging data
    -- Using ref() instead of hardcoded table name creates lineage tracking
    select * from {{ ref('stg_stripe__transactions') }}
),

daily_aggregates as (
    -- Calculate metrics at daily granularity by all key dimensions
    -- This is the finest grain - marts can roll up to weekly/monthly
    select
        -- Dimensions (segmentation fields)
        date_trunc('day', created_at) as transaction_date,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country,

        -- Metrics (aggregated counts and amounts)
        count(*) as total_transactions,

        sum(case when is_approved then 1 else 0 end) as approved_transactions,
        sum(case when not is_approved then 1 else 0 end) as declined_transactions,

        -- Revenue metrics (only count approved transactions)
        sum(case when is_approved then amount_usd else 0 end) as approved_revenue_usd,
        sum(case when not is_approved then amount_usd else 0 end) as declined_revenue_usd,

        -- Average transaction value (useful for identifying high-value decline patterns)
        avg(case when is_approved then amount_usd else null end) as avg_approved_amount_usd,
        avg(case when not is_approved then amount_usd else null end) as avg_declined_amount_usd

    from transactions
    where
        -- Exclude refunds from auth rate calculations
        -- (refunds are a separate flow, not an authorization decision)
        not is_refund
    group by
        transaction_date,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country
),

final as (
    -- Calculate percentage metrics and add business-friendly labels
    select
        -- Dimensions
        transaction_date,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country,

        -- Core counts
        total_transactions,
        approved_transactions,
        declined_transactions,

        -- KEY METRIC: Authorization Rate
        -- This is what executives look at every morning
        case
            when total_transactions > 0 then
                round(
                    (approved_transactions * 100.0) / total_transactions,
                    2
                )
            else null
        end as authorization_rate_pct,

        -- Decline Rate (inverse of auth rate, useful for troubleshooting)
        case
            when total_transactions > 0 then
                round(
                    (declined_transactions * 100.0) / total_transactions,
                    2
                )
            else null
        end as decline_rate_pct,

        -- Revenue metrics
        approved_revenue_usd,
        declined_revenue_usd,

        -- Revenue at Risk (how much money are we losing to declines?)
        -- This is the $ impact that Intelligent Acceptance aims to recover
        declined_revenue_usd as revenue_at_risk_usd,

        -- Average transaction values
        round(avg_approved_amount_usd, 2) as avg_approved_amount_usd,
        round(avg_declined_amount_usd, 2) as avg_declined_amount_usd,

        -- Performance flags (for filtering in BI tools)
        case
            when authorization_rate_pct >= 95 then 'excellent'
            when authorization_rate_pct >= 85 then 'good'
            when authorization_rate_pct >= 75 then 'needs_improvement'
            else 'critical'
        end as performance_tier,

        -- Volume tier (helps identify statistical significance)
        -- Low-volume segments may have volatile auth rates
        case
            when total_transactions >= 1000 then 'high_volume'
            when total_transactions >= 100 then 'medium_volume'
            else 'low_volume'
        end as volume_tier

    from daily_aggregates
)

select * from final
