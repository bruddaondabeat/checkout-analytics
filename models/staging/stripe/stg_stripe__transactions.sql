/*
  Staging Model: Stripe Transactions

  Purpose:
    Clean and standardize raw Stripe transaction data for downstream analytics.
    The staging layer handles:
    - Column renaming for consistency (snake_case, clear semantics)
    - Type conversions (cents → dollars, status → boolean)
    - No business logic yet - just data preparation

  Grain: One row per transaction

  Business Context:
    This is the foundation for all payment performance analytics. Every metric
    (authorization rate, decline analysis, false decline revenue) starts here.
*/

with source as (
    -- Import raw data from Snowflake using dbt source() function
    -- This creates explicit lineage tracking vs hardcoding table names
    select * from {{ source('stripe', 'stripe_transactions') }}
),

renamed as (
    -- Standardize column names following project conventions:
    -- - snake_case for all identifiers
    -- - timestamps end with _at
    -- - money fields specify currency (amount_usd)
    -- - preserve raw cents for precision-critical calculations
    select
        id as transaction_id,

        -- Money fields: Keep both cents (for precision) and dollars (for readability)
        -- Why both? Cents avoid floating-point errors in aggregations,
        -- dollars make dashboards human-friendly
        amount as amount_cents,
        amount / 100.0 as amount_usd,

        fee as fee_cents,
        fee / 100.0 as fee_usd,

        net as net_cents,
        net / 100.0 as net_usd,

        currency,

        -- Transaction attributes
        status,
        decline_reason,
        type as transaction_type,
        reporting_category,

        -- Merchant dimensions
        merchant_id,
        merchant_tier,

        -- Payment method & geography (key segmentation fields)
        payment_method,
        customer_country,

        -- Timestamps: Standardize naming with _at suffix
        created as created_at,
        available_on as available_on_at

    from source
),

final as (
    -- Add business-friendly boolean flags
    -- These make SQL easier to read downstream (WHERE is_approved vs WHERE status = 'available')
    select
        *,

        -- Authorization flag: Core metric for payment success team
        -- TRUE = transaction approved by issuing bank
        -- FALSE = declined (see decline_reason for why)
        case
            when status = 'available' then true
            else false
        end as is_approved,

        -- Refund flag: Useful for net revenue calculations
        case
            when transaction_type in ('refund', 'payment_refund') then true
            else false
        end as is_refund

    from renamed
)

select * from final
