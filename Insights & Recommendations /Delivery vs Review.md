# Q5 — Delivery Speed vs Review Score

## Results

| Delivery Bucket | Orders | Avg Review Score | Bad Review % |
|----------------|--------|-----------------|-------------|
| 1. Express (<=5 days) | 19,150 | 4.43 | 7.3% |
| 2. Fast (6-10 days) | 32,608 | 4.35 | 8.5% |
| 3. Standard (11-20 days) | 31,586 | 4.19 | 10.7% |
| 4. Slow (20+ days) | 12,216 | 3.12 | 38.3% |

## Recommendations

The Slow bucket (20+ days) is the single most damaging operational failure in the entire project: 38.3% bad review rate — more than 4x the Express bucket (7.3%). avg_review drops to 3.12, well below the platform average. 12,216 orders fell into this bucket meaning roughly 4,680 customers left a bad review purely because of delivery speed. Every day this segment exists unaddressed is compounding churn given the already critical 3.04% repeat purchase rate established in Q6.

The drop between Standard (11-20 days) and Slow (20+ days) is the sharpest cliff in the dataset: bad_review_pct jumps from 10.7% to 38.3% — a 258% increase. This means 20 days is the breaking point for customer tolerance. Any order approaching this threshold should trigger an automatic customer notification with a discount voucher for the next purchase to preemptively absorb the dissatisfaction before the review is submitted.

Express (<=5 days) at 4.43 avg review and only 7.3% bad review rate is the clearest ROI argument for logistics investment in the entire analysis. Getting orders under 5 days is not just an operational metric — it is directly correlated with platform reputation and repeat purchase likelihood. Present this alongside Q6 retention data to justify warehouse expansion or priority carrier contracts in high-volume states.
