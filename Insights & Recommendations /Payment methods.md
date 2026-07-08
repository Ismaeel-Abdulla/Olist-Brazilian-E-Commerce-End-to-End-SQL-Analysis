# Q2 — Payment Methods & Revenue Share Analysis

## Results

| Payment Type | Order Count | Total Revenue (R$) | Revenue Share % | Avg Installments |
|-------------|------------|-------------------|----------------|-----------------|
| credit_card | 75,390 | 12,308,514.90 | 78.5% | 3.5 |
| boleto | 19,479 | 2,817,575.39 | 18.0% | 1.0 |
| voucher | 3,734 | 348,890.86 | 2.2% | 1.0 |
| debit_card | 1,513 | 212,176.02 | 1.4% | 1.0 |

## Recommendations

Credit card dominates with 78.5% of total platform revenue (R$12.3M) and 3.5 avg installments — confirming that installment credit is the primary purchase enabler on Olist. From Q7 results high-value orders stretch to 7.4 avg installments meaning the R$600+ tier is entirely dependent on credit card infrastructure. Any disruption to credit card processing — gateway outages, fee increases, or fraud flags — would immediately threaten the majority of platform GMV. Diversifying payment processing across multiple gateway providers is a critical risk mitigation priority.

Boleto represents 18% of revenue (R$2.8M) across 19,479 orders with 1.0 avg installments — meaning every boleto order is a full upfront cash payment. This is a significant segment of budget-conscious buyers who cannot or will not use credit. Boleto has a known abandonment problem in Brazil — customers generate the slip and never pay. Introduce a time-limited discount (e.g. 3% off) for completed boleto payments to reduce abandonment and convert more of these generated orders into confirmed revenue.

Voucher and debit card combined represent only 3.6% of revenue despite 5,247 orders. These are low-value, low-frequency payment methods that currently have no strategic investment behind them. Vouchers specifically at R$348K suggest a promotional or loyalty program already exists but is underutilized — cross-reference voucher usage with repeat customer data from Q6 to determine if vouchers are actually driving second purchases or just discounting orders that would have happened anyway.
