/*
  Mart Model: Payment Performance Dashboard

  Purpose:
    Executive-ready dashboard table that combines authorization rates and decline
    analysis into a single, wide table optimized for Tableau/Looker consumption.
    This is the "one-stop shop" for payment performance metrics.

  Grain: One row per date + merchant + payment_method + country combination

  Materialization: TABLE (not view)
    - Pre-aggregated for fast dashboard load times
    - Refreshed daily via dbt job
    - Tableau/Looker connects directly to this table

  Business Context:
    This powers the executive dashboard that answers:
    - "What's our overall auth rate this month?"
    - "Which merchants are underperforming?"
    - "What are our top decline reasons?"
    - "How much revenue are we losing to false declines?"

  Stakeholders:
    - CFO: Overall revenue metrics, revenue at risk
    - VP Product: Auth rate trends, UX improvement opportunities
    - Fraud team: False decline analysis, fraud system tuning
    - Merchant Success: Per-merchant health scorecards
*/

with auth_rates as (
    -- Import authorization rate metrics
    select * from {{ ref('int_authorization_rates') }}
),

decline_data as (
    -- Import decline analysis metrics
    select * from {{ ref('int_decline_analysis') }}
),

-- Aggregate decline data to match auth_rates grain (remove decline_reason dimension)
decline_summary as (
    select
        transaction_date,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country,

        -- Total decline metrics
        sum(declined_transaction_count) as total_declined_transactions,
        sum(declined_revenue_usd) as total_declined_revenue_usd,

        -- Decline category breakdown (PIVOT into columns for dashboard)
        sum(case when decline_category = 'customer_issue' then declined_revenue_usd else 0 end) as customer_issue_revenue_loss_usd,
        sum(case when decline_category = 'fraud_system' then declined_revenue_usd else 0 end) as fraud_system_revenue_loss_usd,
        sum(case when decline_category = 'technical_validation' then declined_revenue_usd else 0 end) as technical_revenue_loss_usd,

        -- Recoverability analysis
        sum(case when recoverability_potential = 'high' then declined_revenue_usd else 0 end) as high_recoverability_revenue_usd,
        sum(case when recoverability_potential = 'medium' then declined_revenue_usd else 0 end) as medium_recoverability_revenue_usd,
        sum(case when recoverability_potential = 'low' then declined_revenue_usd else 0 end) as low_recoverability_revenue_usd,

        -- False decline flag analysis
        sum(case when potential_false_decline_flag then declined_revenue_usd else 0 end) as suspected_false_decline_revenue_usd,
        sum(case when potential_false_decline_flag then declined_transaction_count else 0 end) as suspected_false_decline_count

    from decline_data
    group by
        transaction_date,
        merchant_id,
        merchant_tier,
        payment_method,
        customer_country
),

combined as (
    -- Join auth rates with decline summary
    -- LEFT JOIN because some segments may have 100% auth rate (no declines)
    select
        -- Dimensions
        a.transaction_date,
        a.merchant_id,
        a.merchant_tier,
        a.payment_method,
        a.customer_country,

        -- Time period rollups (for Tableau date filters)
        date_trunc('week', a.transaction_date) as transaction_week,
        date_trunc('month', a.transaction_date) as transaction_month,
        date_trunc('quarter', a.transaction_date) as transaction_quarter,
        date_trunc('year', a.transaction_date) as transaction_year,

        -- Volume metrics
        a.total_transactions,
        a.approved_transactions,
        a.declined_transactions,

        -- Core KPIs (authorization performance)
        a.authorization_rate_pct,
        a.decline_rate_pct,
        a.performance_tier,
        a.volume_tier,

        -- Revenue metrics
        a.approved_revenue_usd,
        a.declined_revenue_usd as revenue_at_risk_usd,
        a.avg_approved_amount_usd,
        a.avg_declined_amount_usd,

        -- Total revenue (approved + declined potential)
        a.approved_revenue_usd + coalesce(a.declined_revenue_usd, 0) as total_potential_revenue_usd,

        -- Decline analysis (from decline_summary)
        coalesce(d.total_declined_transactions, 0) as decline_analysis_transaction_count,
        coalesce(d.total_declined_revenue_usd, 0) as decline_analysis_revenue_usd,

        -- Decline category breakdown
        coalesce(d.customer_issue_revenue_loss_usd, 0) as customer_issue_revenue_loss_usd,
        coalesce(d.fraud_system_revenue_loss_usd, 0) as fraud_system_revenue_loss_usd,
        coalesce(d.technical_revenue_loss_usd, 0) as technical_revenue_loss_usd,

        -- Recoverability scoring (where to focus optimization)
        coalesce(d.high_recoverability_revenue_usd, 0) as high_recoverability_revenue_usd,
        coalesce(d.medium_recoverability_revenue_usd, 0) as medium_recoverability_revenue_usd,
        coalesce(d.low_recoverability_revenue_usd, 0) as low_recoverability_revenue_usd,

        -- False decline analysis (ML optimization opportunity)
        coalesce(d.suspected_false_decline_revenue_usd, 0) as suspected_false_decline_revenue_usd,
        coalesce(d.suspected_false_decline_count, 0) as suspected_false_decline_count

    from auth_rates a
    left join decline_summary d
        on a.transaction_date = d.transaction_date
        and a.merchant_id = d.merchant_id
        and a.payment_method = d.payment_method
        and a.customer_country = d.customer_country
),

final as (
    -- Add calculated fields and business-friendly labels
    select
        *,

        -- False decline rate (% of declined revenue that's likely false positives)
        case
            when revenue_at_risk_usd > 0 then
                round(
                    (suspected_false_decline_revenue_usd * 100.0) / revenue_at_risk_usd,
                    2
                )
            else 0
        end as false_decline_rate_pct,

        -- Recovery opportunity score (revenue * recoverability weight)
        -- High recovery potential = 0.35 (can recover 35% via ML tuning)
        -- Medium recovery potential = 0.15 (can recover 15% via UX improvements)
        -- Low recovery potential = 0.05 (can recover 5% via retry logic)
        round(
            (high_recoverability_revenue_usd * 0.35) +
            (medium_recoverability_revenue_usd * 0.15) +
            (low_recoverability_revenue_usd * 0.05),
            2
        ) as estimated_recoverable_revenue_usd,

        -- Health score (0-100, weighted combination of metrics)
        -- Auth rate: 70% weight (most important)
        -- Low false decline rate: 20% weight
        -- Volume tier bonus: 10% weight (high volume = more stable)
        round(
            (authorization_rate_pct * 0.70) +
            (case
                when revenue_at_risk_usd > 0
                then (100 - (suspected_false_decline_revenue_usd * 100.0 / revenue_at_risk_usd)) * 0.20
                else 20  -- Perfect score if no declines
            end) +
            (case
                when volume_tier = 'high_volume' then 10
                when volume_tier = 'medium_volume' then 7
                else 5
            end),
            0
        ) as segment_health_score

    from combined
)

select * from final
