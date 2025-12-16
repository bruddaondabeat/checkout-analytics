"""
Load stripe_transactions.csv to Snowflake using Python connector.
"""

import snowflake.connector
import pandas as pd
import os
from pathlib import Path

# Get project root
PROJECT_ROOT = Path(__file__).parent.parent
CSV_PATH = PROJECT_ROOT / "data" / "stripe_transactions.csv"

def load_to_snowflake():
    """Load CSV data to Snowflake RAW schema"""

    # Snowflake connection params
    # TODO: Replace with your actual credentials
    conn_params = {
        'account': 'xac70110.us-east-1',
        'user': 'YOUR_USERNAME',  # ← FILL THIS IN
        'password': 'YOUR_PASSWORD',  # ← FILL THIS IN
        'warehouse': 'COMPUTE_WH',
        'database': 'ANALYTICS',
        'schema': 'RAW',
    }

    print("Connecting to Snowflake...")
    conn = snowflake.connector.connect(**conn_params)
    cursor = conn.cursor()

    try:
        # Drop table if exists (for clean reload)
        print("Dropping existing table (if exists)...")
        cursor.execute("DROP TABLE IF EXISTS STRIPE_TRANSACTIONS")

        # Create table with proper schema
        print("Creating table...")
        create_table_sql = """
        CREATE TABLE STRIPE_TRANSACTIONS (
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
        )
        """
        cursor.execute(create_table_sql)
        print("✅ Table created")

        # Load CSV using Pandas (handles data types)
        print(f"Reading CSV from {CSV_PATH}...")
        df = pd.read_csv(CSV_PATH)
        print(f"  - Rows: {len(df):,}")

        # Write to Snowflake using write_pandas
        from snowflake.connector.pandas_tools import write_pandas

        print("Writing data to Snowflake...")
        success, nchunks, nrows, _ = write_pandas(
            conn=conn,
            df=df,
            table_name='STRIPE_TRANSACTIONS',
            database='ANALYTICS',
            schema='RAW',
            quote_identifiers=False
        )

        if success:
            print(f"✅ Loaded {nrows:,} rows to ANALYTICS.RAW.STRIPE_TRANSACTIONS")
        else:
            print("❌ Load failed")

        # Verify
        cursor.execute("SELECT COUNT(*) FROM STRIPE_TRANSACTIONS")
        count = cursor.fetchone()[0]
        print(f"✅ Verification: {count:,} rows in table")

        # Sample data
        print("\nSample data:")
        cursor.execute("SELECT * FROM STRIPE_TRANSACTIONS LIMIT 5")
        for row in cursor:
            print(row)

    finally:
        cursor.close()
        conn.close()
        print("\n✅ Connection closed")

if __name__ == "__main__":
    load_to_snowflake()
