# Q4 — Delivery Delay by State

## Results

| State | Total Deliveries | Avg Delay Days | Avg Total Delivery Days | Late Order % |
|-------|----------------|---------------|----------------------|-------------|
| AP | 67 | 48.3 | 26.7 | 4.5% |
| RR | 40 | 36.4 | 29.5 | 12.5% |
| AM | 145 | 20.2 | 26.0 | 4.1% |
| AC | 80 | 18.7 | 20.6 | 3.8% |
| SE | 332 | 16.2 | 20.9 | 15.4% |
| CE | 1,273 | 13.6 | 20.8 | 15.4% |
| RN | 470 | 12.5 | 18.8 | 10.9% |
| RJ | 12,310 | 12.1 | 14.8 | 13.5% |
| PA | 942 | 11.6 | 23.3 | 12.4% |
| PI | 475 | 11.6 | 19.0 | 16.0% |
| PE | 1,587 | 10.6 | 18.0 | 10.8% |
| BA | 3,253 | 10.4 | 18.9 | 14.0% |
| ES | 1,992 | 9.9 | 15.3 | 12.2% |
| PB | 516 | 9.8 | 19.9 | 11.0% |
| MT | 885 | 9.4 | 17.6 | 6.8% |
| MA | 713 | 9.4 | 21.1 | 19.6% |
| GO | 1,950 | 9.1 | 15.2 | 8.2% |
| RS | 5,327 | 8.7 | 14.8 | 7.2% |
| AL | 396 | 8.5 | 24.0 | 24.0% |
| MS | 701 | 7.0 | 15.2 | 11.6% |
| SC | 3,537 | 7.0 | 14.5 | 9.8% |
| MG | 11,319 | 6.8 | 11.5 | 5.6% |
| PR | 4,903 | 6.7 | 11.5 | 5.0% |
| SP | 40,399 | 6.3 | 8.3 | 5.9% |
| DF | 2,074 | 6.0 | 12.5 | 7.1% |
| RO | 243 | 5.6 | 18.9 | 2.9% |
| TO | 274 | 5.0 | 17.2 | 12.8% |

## Recommendations

AP is the single worst delivery state on the platform: 48.3 avg delay days — more than 6 weeks behind schedule — despite only 4.5% late order rate. This means when AP orders are late, they are catastrophically late, not just a few days. The carrier network serving Amapá is structurally broken. Escalate to logistics partners immediately and consider temporarily restricting next-day or standard delivery promises in this state.

AL is the most dangerous combination in the dataset: 24.0% late order rate — highest on the entire list — AND 24.0 avg_total_delivery_days. Nearly 1 in 4 orders arrives late and the total journey takes over 3 weeks. Cross-reference with freight data from Q14 — AL also sits at 19.8% freight burden meaning customers pay high shipping costs and still receive late deliveries. Immediate carrier review is required here.

MA is the stealth problem: 19.6% late order rate — second highest on the list — combined with 9.4 avg_delay_days and 21.1 avg_total_delivery_days. From Q14 MA has the second highest freight burden at 26.2%. This confirms MA as a double failure state: customers pay near the most in freight and have the second worst on-time rate on the platform. Prioritize MA alongside AL for carrier contract renegotiation.

RJ deserves attention despite its scale: 12,310 deliveries with 12.1 avg delay days and 13.5% late order rate. As the second largest market on the platform after SP, even a modest improvement in RJ delivery performance would impact tens of thousands of customers and meaningfully move overall platform satisfaction scores.
