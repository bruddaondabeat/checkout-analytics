-- ============================================
-- EXPORT DATA FOR TABLEAU PUBLIC
-- ============================================
--
-- INSTRUCTIONS:
-- 1. Copy this entire query
-- 2. Run in Snowflake UI (Snowflake - Checkout Analytics.session.sql)
-- 3. When results appear, click "Download" button (top-right of results pane)
-- 4. Save as: tableau_data_mart_payment_performance.csv
-- 5. Location: /Users/sov-t/checkout-analytics/data/

-- Full mart table export (optimized for Tableau)
SELECT
    -- Time dimensions
    transaction_date,
    transaction_week,
    transaction_month,
    transaction_quarter,
    transaction_year,

    -- Segment dimensions
    merchant_id,
    merchant_tier,
    payment_method,
    customer_country,

    -- Volume metrics
    total_transactions,
    approved_transaction_count,
    declined_transaction_count,

    -- Rate metrics (already in %)
    authorization_rate_pct,
    decline_rate_pct,

    -- Revenue metrics (USD)
    total_potential_revenue_usd,
    approved_revenue_usd,
    revenue_at_risk_usd,

    -- Decline breakdown by category (USD)
    customer_issue_revenue_loss_usd,
    fraud_system_revenue_loss_usd,
    technical_revenue_loss_usd,

    -- Specific decline reasons (counts)
    insufficient_funds_count,
    fraud_suspected_count,
    card_declined_count,
    processing_error_count,

    -- False decline metrics
    suspected_false_decline_count,
    suspected_false_decline_revenue_usd,

    -- Recovery potential
    estimated_recoverable_revenue_usd,

    -- Classification fields
    performance_tier,
    volume_tier,
    segment_health_score

FROM ANALYTICS.STAGING_marts.mart_payment_performance

-- Filter to reduce file size (optional - remove if you want all data)
-- WHERE transaction_date >= DATEADD(month, -3, CURRENT_DATE())  -- Last 3 months only

ORDER BY transaction_date DESC, merchant_id, customer_country, payment_method;

-- Expected row count: ~10,000 rows
-- Expected file size: ~2-3 MB
-- Export time: ~5-10 seconds
