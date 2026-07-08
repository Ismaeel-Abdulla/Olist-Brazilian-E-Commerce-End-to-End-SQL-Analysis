# Q14 — Freight Burden by State

## Results

| State | Orders | Avg Freight (R$) | Avg Item Price (R$) | Freight % of Price |
|-------|--------|-----------------|--------------------|--------------------|
| RR | 43 | 44.10 | 158.89 | 27.8% |
| MA | 732 | 38.35 | 146.22 | 26.2% |
| RO | 246 | 41.13 | 166.18 | 24.7% |
| AM | 147 | 33.21 | 135.50 | 24.5% |
| PI | 489 | 39.16 | 160.69 | 24.4% |
| SE | 342 | 36.78 | 153.50 | 24.0% |
| TO | 278 | 37.25 | 157.35 | 23.7% |
| AC | 81 | 40.07 | 173.73 | 23.1% |
| RN | 478 | 35.70 | 157.07 | 22.7% |
| PE | 1,636 | 32.86 | 145.13 | 22.6% |
| PB | 530 | 42.78 | 191.69 | 22.3% |
| PA | 965 | 35.85 | 165.64 | 21.6% |
| CE | 1,316 | 32.72 | 153.08 | 21.4% |
| AP | 68 | 34.01 | 164.32 | 20.7% |
| AL | 409 | 35.90 | 181.52 | 19.8% |
| BA | 3,340 | 26.37 | 133.88 | 19.7% |
| MT | 900 | 28.08 | 148.42 | 18.9% |
| GO | 1,990 | 22.68 | 123.92 | 18.3% |
| RS | 5,395 | 21.69 | 119.44 | 18.2% |
| ES | 2,014 | 22.01 | 121.49 | 18.1% |
| SC | 3,590 | 21.50 | 124.48 | 17.3% |
| PR | 4,962 | 20.54 | 118.63 | 17.3% |
| MG | 11,457 | 20.64 | 120.45 | 17.1% |
| DF | 2,114 | 21.05 | 125.51 | 16.8% |
| RJ | 12,654 | 20.96 | 124.65 | 16.8% |
| MS | 708 | 23.38 | 142.73 | 16.4% |
| SP | 41,021 | 15.15 | 109.51 | 13.8% |

## Recommendations

RR, MA, RO, AM and PI are the five highest freight burden states — customers there pay 24-28% of item price just in shipping. Combined with Q4 delay data, if these same states also show high late_order_pct they represent a double failure: customers pay the most and wait the longest. Cross-reference immediately and flag these as highest churn-risk regions on the platform.

SP sits at 13.8% freight burden — the lowest on the entire list — because proximity to the majority of Olist's seller base keeps logistics costs down. This freight gap between SP (13.8%) and RR (27.8%) is a 2x disparity that directly suppresses conversion in northern and northeastern states. Consider state-specific subsidized freight programs or regional warehouse partnerships to close this gap.

PB stands out as an anomaly: R$191 avg item price — highest in the entire dataset — yet 22.3% freight burden. Customers in PB are buying expensive items but still absorbing disproportionate shipping costs. A targeted free shipping threshold for orders above R$150 in high avg_item_price states like PB, AC and PI would reduce friction for buyers already committed to premium purchases.
