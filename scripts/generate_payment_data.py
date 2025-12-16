"""
Generate synthetic Stripe Balance Transaction data for payment analytics.
Based on official Stripe API schema and realistic fintech patterns.
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Set seed for reproducibility
np.random.seed(42)
random.seed(42)

# Configuration
N_TRANSACTIONS = 150_000
N_MERCHANTS = 25
START_DATE = datetime.now() - timedelta(days=365)
END_DATE = datetime.now()

# Merchant tiers (mimics Checkout's Tier-1 focus)
MERCHANT_TIERS = {
    'tier_1': {'count': 5, 'volume_weight': 0.6},   # High volume (eBay, ASOS-like)
    'tier_2': {'count': 10, 'volume_weight': 0.3},  # Medium volume
    'tier_3': {'count': 10, 'volume_weight': 0.1},  # Long tail
}

# Transaction type distribution (realistic Stripe pattern)
TRANSACTION_TYPES = [
    ('charge', 0.70),
    ('payment', 0.15),
    ('refund', 0.08),
    ('payment_refund', 0.03),
    ('payout', 0.02),
    ('stripe_fee', 0.015),
    ('application_fee', 0.005),
]

# Payment method distribution
PAYMENT_METHODS = [
    ('credit_card', 0.60),
    ('debit_card', 0.25),
    ('digital_wallet', 0.12),
    ('bank_transfer', 0.03),
]

# Decline reasons (realistic distribution based on industry data)
DECLINE_REASONS = {
    'none': 0.82,  # 82% approval rate (healthy benchmark)
    'insufficient_funds': 0.06,
    'fraud_suspected': 0.04,
    'invalid_card': 0.03,
    'technical_error': 0.02,
    'do_not_honor': 0.015,
    'expired_card': 0.01,
    'card_velocity_exceeded': 0.005,
}

# Geographic distribution
COUNTRIES = [
    ('US', 0.50),
    ('GB', 0.15),
    ('DE', 0.10),
    ('FR', 0.08),
    ('CA', 0.07),
    ('AU', 0.05),
    ('NL', 0.03),
    ('ES', 0.02),
]

def generate_merchant_id(tier, tier_index):
    """Generate merchant ID based on tier"""
    tier_prefix = tier.split('_')[1]
    return f"MERCH_T{tier_prefix}_{str(tier_index).zfill(3)}"

def generate_transaction_amount(tx_type, merchant_tier):
    """Generate realistic transaction amounts based on type and merchant tier"""
    base_amounts = {
        'tier_1': 75,   # Higher average transaction value
        'tier_2': 45,
        'tier_3': 25,
    }

    base = base_amounts.get(merchant_tier, 50)

    if tx_type in ['refund', 'payment_refund']:
        # Refunds are typically smaller than original charges
        amount = abs(np.random.exponential(base * 0.6))
    elif tx_type == 'payout':
        # Payouts are large (accumulated balance)
        amount = abs(np.random.exponential(base * 100))
    else:
        # Regular transactions
        amount = abs(np.random.exponential(base))

    # Convert to cents (Stripe uses smallest currency unit)
    return int(amount * 100)

def calculate_stripe_fee(amount, tx_type):
    """Calculate Stripe fee (simplified model: 2.9% + 30¢ for cards)"""
    if tx_type in ['charge', 'payment']:
        return int(amount * 0.029 + 30)
    elif tx_type in ['refund', 'payment_refund']:
        return 0  # Refunds don't incur new fees
    else:
        return 0

def generate_transactions():
    """Generate synthetic transaction dataset"""

    # Create merchant list with tiers
    merchants = []
    for tier, config in MERCHANT_TIERS.items():
        for i in range(config['count']):
            merchants.append({
                'merchant_id': generate_merchant_id(tier, i),
                'tier': tier,
                'volume_weight': config['volume_weight']
            })

    # Normalize weights
    total_weight = sum(m['volume_weight'] for m in merchants)
    for m in merchants:
        m['probability'] = m['volume_weight'] / total_weight

    # Generate transactions
    transactions = []

    for i in range(N_TRANSACTIONS):
        # Select merchant (weighted by tier)
        merchant = random.choices(merchants, weights=[m['probability'] for m in merchants])[0]

        # Select transaction type
        tx_type = random.choices(
            [t[0] for t in TRANSACTION_TYPES],
            weights=[t[1] for t in TRANSACTION_TYPES]
        )[0]

        # Select payment method
        payment_method = random.choices(
            [pm[0] for pm in PAYMENT_METHODS],
            weights=[pm[1] for pm in PAYMENT_METHODS]
        )[0]

        # Select country
        country = random.choices(
            [c[0] for c in COUNTRIES],
            weights=[c[1] for c in COUNTRIES]
        )[0]

        # Generate amount
        amount = generate_transaction_amount(tx_type, merchant['tier'])

        # Calculate fee
        fee = calculate_stripe_fee(amount, tx_type)

        # Net amount
        net = amount - fee

        # Determine status and decline reason
        decline_reason = random.choices(
            list(DECLINE_REASONS.keys()),
            weights=list(DECLINE_REASONS.values())
        )[0]

        if decline_reason == 'none':
            status = 'available'
            reporting_category = tx_type
        else:
            status = 'pending'
            reporting_category = 'declined'
            net = 0  # Declined transactions don't add to balance

        # Generate timestamps
        created_ts = START_DATE + timedelta(
            seconds=random.randint(0, int((END_DATE - START_DATE).total_seconds()))
        )

        # available_on is typically 2-7 days after created for cards
        days_until_available = random.randint(2, 7) if status == 'available' else random.randint(0, 30)
        available_on_ts = created_ts + timedelta(days=days_until_available)

        # Currency (mostly USD, some EUR/GBP based on country)
        currency = 'usd'
        if country in ['GB']:
            currency = 'gbp'
        elif country in ['DE', 'FR', 'NL', 'ES']:
            currency = 'eur'

        # Build transaction record
        transaction = {
            'id': f"txn_{str(i+1).zfill(8)}",
            'object': 'balance_transaction',
            'amount': amount,
            'available_on': available_on_ts,
            'created': created_ts,
            'currency': currency,
            'description': f"{tx_type} for {merchant['merchant_id']}",
            'exchange_rate': None,  # Simplified - only set for cross-currency
            'fee': fee,
            'net': net,
            'reporting_category': reporting_category,
            'source': f"ch_{str(random.randint(100000, 999999))}",
            'status': status,
            'type': tx_type,
            # Additional metadata for analysis
            'merchant_id': merchant['merchant_id'],
            'merchant_tier': merchant['tier'],
            'payment_method': payment_method,
            'customer_country': country,
            'decline_reason': decline_reason if decline_reason != 'none' else None,
        }

        transactions.append(transaction)

    return pd.DataFrame(transactions)

def main():
    """Generate and save synthetic payment data"""
    print("Generating synthetic Stripe payment data...")
    print(f"  - Transactions: {N_TRANSACTIONS:,}")
    print(f"  - Merchants: {N_MERCHANTS}")
    print(f"  - Date range: {START_DATE.date()} to {END_DATE.date()}")

    df = generate_transactions()

    # Data quality summary
    print("\nData Summary:")
    print(f"  - Total rows: {len(df):,}")
    print(f"  - Approval rate: {(df['status'] == 'available').mean():.1%}")
    print(f"  - Average transaction: ${df['amount'].mean()/100:.2f}")
    print(f"  - Total volume: ${df['amount'].sum()/100:,.2f}")
    print(f"\nDecline reasons:")
    print(df['decline_reason'].value_counts())

    # Save to CSV
    output_path = 'data/stripe_transactions.csv'
    df.to_csv(output_path, index=False)
    print(f"\n✅ Saved to {output_path}")

    return df

if __name__ == "__main__":
    df = main()
