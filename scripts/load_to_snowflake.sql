-- Load Stripe payment data to Snowflake
-- Run this in Snowflake worksheet or via SnowSQL

-- 1. Create raw table
CREATE OR REPLACE TABLE ANALYTICS.RAW.STRIPE_TRANSACTIONS (
    id VARCHAR(255),
    object VARCHAR(50),
    amount INTEGER,
    available_on TIMESTAMP,
    created TIMESTAMP,
    currency VARCHAR(3),
    description VARCHAR(500),
    exchange_rate FLOAT,
    fee INTEGER,
    net INTEGER,
    reporting_category VARCHAR(100),
    source VARCHAR(255),
    status VARCHAR(50),
    type VARCHAR(100),
    merchant_id VARCHAR(50),
    merchant_tier VARCHAR(20),
    payment_method VARCHAR(50),
    customer_country VARCHAR(3),
    decline_reason VARCHAR(100)
);

-- 2. Create stage for CSV upload
CREATE OR REPLACE STAGE ANALYTICS.RAW.payment_data_stage;

-- 3. Put file (run this from SnowSQL CLI or use Snowflake UI to upload)
-- PUT file:///Users/sov-t/ml-math-learning/data/stripe_transactions.csv @ANALYTICS.RAW.payment_data_stage;

-- 4. Load data from stage
COPY INTO ANALYTICS.RAW.STRIPE_TRANSACTIONS
FROM @ANALYTICS.RAW.payment_data_stage/stripe_transactions.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
);

-- 5. Verify load
SELECT COUNT(*) as total_rows FROM ANALYTICS.RAW.STRIPE_TRANSACTIONS;
SELECT * FROM ANALYTICS.RAW.STRIPE_TRANSACTIONS LIMIT 10;

-- 6. Basic data quality checks
SELECT
    status,
    COUNT(*) as transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct
FROM ANALYTICS.RAW.STRIPE_TRANSACTIONS
GROUP BY status
ORDER BY transaction_count DESC;
