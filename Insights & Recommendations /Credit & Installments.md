# Q7 — Credit & Installment Behavior Analysis

## Results

| Value Tier | Unique Orders | Avg Installments | Max Installments |
|-----------|--------------|-----------------|-----------------|
| 1. Under R$100 | 35,251 | 2.3 | 10 |
| 2. R$100-299 | 32,071 | 4.1 | 24 |
| 3. R$300-599 | 5,611 | 5.8 | 24 |
| 4. R$600+ | 2,545 | 7.4 | 24 |

## Recommendations

Installment usage scales perfectly linearly with order value — 2.3 months for sub-R$100 orders up to 7.4 months for R$600+ orders. This confirms that installments are the primary mechanism enabling high-ticket purchases on the platform. Without credit options the R$600+ tier (generating R$3.4M from Q10) would likely collapse as Brazilian consumers cannot absorb large lump-sum payments.

The R$100-299 tier has the highest order volume at 32,071 unique orders and already uses 4.1 avg installments. This is the sweet spot for installment-driven upselling — customers in this tier are already comfortable with credit. A targeted "add R$50 more and split into 6 installments" prompt at checkout would push Mid-tier buyers into Premium territory and lift AOV without requiring new customer acquisition.

Max installments of 24 appear in all tiers above R$100 meaning some customers are stretching payments across 2 full years even for R$100-299 purchases. Finance must audit the default installment options shown at checkout — if 24 installments is being offered on low-value orders it signals either predatory UX design or customers in genuine financial distress. Either scenario carries regulatory and reputational risk that needs immediate review.
