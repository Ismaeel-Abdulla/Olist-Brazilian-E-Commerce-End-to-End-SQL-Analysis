-- ============================================================
-- OLIST BRAZILIAN E-COMMERCE — SQL ANALYSIS
-- Author   : Ismaeel Abdulla
-- Dataset  : som3a-366421.olist
-- Period   : January 2017 – August 2018
-- Engine   : BigQuery SQL
-- Modules  : 14 queries across business overview, logistics,
--            customer behavior, product, and seller performance
-- ============================================================


-- ============================================================
-- MODULE 1 — BUSINESS OVERVIEW
-- ============================================================


-- 1 -- Year-over-Year (YoY) Revenue Growth Analysis
-- Purpose: Measuring monthly revenue momentum and growth rate against the prior year to identify scaling patterns and maturity signals.

WITH monthly_revenue AS (
  SELECT
    -- Truncating timestamp to monthly starting date for uniform aggregation
    DATE_TRUNC(o.order_purchase_timestamp, MONTH) AS month,
    ROUND(SUM(p.payment_value), 2) AS revenue
  FROM `som3a-366421.olist.orders_cleaned` o
  JOIN `som3a-366421.olist.order_payments_cleaned` p
    ON o.order_id = p.order_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
    -- Isolating the stable operational window
    AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
  GROUP BY month
)
SELECT
  month,
  revenue,
  -- Pulling revenue from exactly 12 months ago to align same-month comparison
  LAG(revenue, 12) OVER (ORDER BY month) AS revenue_same_month_prev_year,
  -- Calculating percentage growth rate between current month and previous year
  ROUND(
    100 * (revenue - LAG(revenue, 12) OVER (ORDER BY month))
    / LAG(revenue, 12) OVER (ORDER BY month), 1
  ) AS yoy_growth_pct
FROM monthly_revenue
ORDER BY month;

-- *RECOMMENDATION*

-- January 2018 posted the highest YoY growth in the dataset at 704.8% — R$1.10M vs
-- R$137K in January 2017. This is not organic growth, it is a base effect: January
-- 2017 was the platform's first full month of operation with only 752 new customers
-- from Q8. The triple-digit growth figures in early 2018 should be framed carefully
-- in any executive presentation — they reflect how small the starting base was, not
-- a repeatable growth rate.

-- November 2017 at R$1.17M is the single highest revenue month in the entire dataset
-- — Black Friday driven and consistent with the 7,190 new customer spike from Q8.
-- This is the platform's proven peak demand window. Inventory, logistics capacity,
-- and seller readiness must be pre-positioned for November every year. A failure to
-- fulfill during this month directly impacts the largest revenue opportunity in the
-- calendar.

-- YoY growth is decelerating sharply through 2018: from 704.8% in January down to
-- 50.6% in August — a 93% drop in growth rate across 8 months. The platform is
-- maturing and the hypergrowth phase is ending. Combined with the acquisition plateau
-- from Q8 and the 3.04% repeat rate from Q6, the data collectively argues for an
-- immediate strategic pivot — stop optimizing for new customer acquisition and start
-- optimizing for revenue per existing customer through retention, upsell, and
-- installment-driven AOV growth.


-- 2 -- Payment Methods & Revenue Share Analysis
-- Purpose: Mapping how customers pay and how much each method contributes to platform revenue, with installment behavior as a credit risk signal.

SELECT
  p.payment_type,
  COUNT(DISTINCT p.order_id) AS order_count,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  -- Calculates each payment method's share of total platform revenue dynamically using window functions
  ROUND(
    100 * SUM(p.payment_value) / SUM(SUM(p.payment_value)) OVER (), 1
  ) AS revenue_share_pct,
  -- Captures average installment duration per transaction; crucial for financial forecasting
  ROUND(AVG(p.payment_installments), 1) AS avg_installments
FROM `som3a-366421.olist.order_payments_cleaned` p
-- Enforcing date baseline and cleaning rules via orders_cleaned join
JOIN `som3a-366421.olist.orders_cleaned` o
  ON p.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY p.payment_type
ORDER BY total_revenue DESC;

-- *RECOMMENDATION*

-- Credit card dominates with 78.5% of total platform revenue (R$12.3M) and 3.5 avg
-- installments — confirming that installment credit is the primary purchase enabler
-- on Olist. From Q7 results high-value orders stretch to 7.4 avg installments meaning
-- the R$600+ tier is entirely dependent on credit card infrastructure. Any disruption
-- to credit card processing — gateway outages, fee increases, or fraud flags — would
-- immediately threaten the majority of platform GMV. Diversifying payment processing
-- across multiple gateway providers is a critical risk mitigation priority.

-- Boleto represents 18% of revenue (R$2.8M) across 19,479 orders with 1.0 avg
-- installments — meaning every boleto order is a full upfront cash payment. This is
-- a significant segment of budget-conscious buyers who cannot or will not use credit.
-- Boleto has a known abandonment problem in Brazil — customers generate the slip and
-- never pay. Introduce a time-limited discount (e.g. 3% off) for completed boleto
-- payments to reduce abandonment and convert more of these generated orders into
-- confirmed revenue.

-- Voucher and debit card combined represent only 3.6% of revenue despite 5,247 orders.
-- These are low-value, low-frequency payment methods that currently have no strategic
-- investment behind them. Vouchers specifically at R$348K suggest a promotional or
-- loyalty program already exists but is underutilized — cross-reference voucher usage
-- with repeat customer data from Q6 to determine if vouchers are actually driving
-- second purchases or just discounting orders that would have happened anyway.


-- ============================================================
-- MODULE 2 — LOGISTICS & DELIVERY
-- ============================================================


-- 3 -- Logistics & On-Time Delivery Performance Analysis
-- Purpose: Quantifying fulfillment reliability by measuring on-time delivery rate, average delivery duration, and average delay on breached SLAs.

SELECT
  COUNTIF(order_delivered_customer_date <= order_estimated_delivery_date) AS on_time_orders,
  COUNTIF(order_delivered_customer_date > order_estimated_delivery_date)  AS late_orders,
  COUNT(*)                                                                AS total_delivered,

  -- On-Time Delivery Rate (OTDR): The absolute core operational fulfillment metric
  ROUND(
    100 * COUNTIF(order_delivered_customer_date <= order_estimated_delivery_date) / COUNT(*), 1
  ) AS on_time_rate_pct,

  -- Tracks average actual delivery duration from initial purchase to final customer doorstep
  ROUND(
    AVG(DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY)), 1
  ) AS avg_delivery_days,

  -- Tracks average days late; only isolates and evaluates orders that breached the promised SLA
  ROUND(
    AVG(
      CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY)
        ELSE NULL
      END
    ), 1
  ) AS avg_delay_days
FROM `som3a-366421.olist.orders_cleaned`
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31';

-- *RECOMMENDATION*

-- 91.9% on-time rate across 96,203 delivered orders is a strong headline metric —
-- but the 7,822 late orders it masks represent real customer damage. From Q5 results
-- the Slow bucket (20+ days) carries a 38.3% bad review rate. If even a fraction of
-- these 7,822 late orders crossed the 20-day threshold, the review score impact is
-- significant and directly feeds the 3.04% repeat rate crisis from Q6.

-- avg_delivery_days of 12.1 means the typical customer waits nearly 2 weeks from
-- purchase to doorstep. From Q5 the Standard bucket (11-20 days) already shows
-- 10.7% bad review rate — meaning the average Olist order is sitting inside a
-- satisfaction risk zone by default. Reducing avg_delivery_days from 12.1 to under
-- 10 would move the majority of orders from the Standard bucket into the Fast bucket
-- and drop bad review rate from 10.7% to 8.5% platform-wide.

-- avg_delay_days of 8.9 on late orders means when Olist misses its delivery promise
-- it misses by nearly 9 days on average — not 1 or 2. This is not a last-mile
-- problem, it is a systemic carrier failure on specific routes. Cross-reference with
-- Q4 state delay data — AP (48.3 avg delay), AL (24.0% late rate) and MA (19.6%
-- late rate) are the primary contributors pulling this average up. Resolving these
-- three states alone would meaningfully improve the platform-wide avg_delay_days figure.


-- 4 -- Delivery Delay by State
-- Purpose: Identifying which Brazilian states suffer the worst delivery delays to pinpoint regional logistics bottlenecks.

SELECT
  c.customer_state,

  -- Total volume of completed deliveries per state
  COUNT(DISTINCT o.order_id) AS total_deliveries,

  -- Service Level Agreement (SLA) Breach: Measures the average magnitude of delay
  -- ONLY for orders that missed their estimated delivery window
  ROUND(
    AVG(
      CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY)
        ELSE NULL
      END
    ), 1
  ) AS avg_delay_days,

  -- Total Lead Time: Average days from initial customer purchase to doorstep delivery
  ROUND(
    AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)), 1
  ) AS avg_total_delivery_days,

  -- Late Delivery Rate: Percentage of total orders that breached the promised SLA
  ROUND(
    100 * COUNTIF(o.order_delivered_customer_date > o.order_estimated_delivery_date)
    / COUNT(*), 1
  ) AS late_order_pct

FROM `som3a-366421.olist.orders_cleaned` o
JOIN `som3a-366421.olist.customers_cleaned` c
  ON o.customer_id = c.customer_id

-- Data Quality & Scope Filters
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'

GROUP BY c.customer_state
-- Order by the severity of actual delays to highlight the worst performing states
ORDER BY avg_delay_days DESC;

-- *RECOMMENDATION*

-- AP is the single worst delivery state on the platform: 48.3 avg delay days — more
-- than 6 weeks behind schedule — despite only 4.5% late order rate. This means when
-- AP orders are late, they are catastrophically late, not just a few days. The carrier
-- network serving Amapá is structurally broken. Escalate to logistics partners immediately
-- and consider temporarily restricting next-day or standard delivery promises in this state.

-- AL is the most dangerous combination in the dataset: 24.0% late order rate — highest
-- on the entire list — AND 24.0 avg_total_delivery_days. Nearly 1 in 4 orders arrives
-- late and the total journey takes over 3 weeks. Cross-reference with freight data from
-- Q14 — AL also sits at 19.8% freight burden meaning customers pay high shipping costs
-- and still receive late deliveries. Immediate carrier review is required here.

-- MA is the stealth problem: 19.6% late order rate — second highest on the list —
-- combined with 9.4 avg_delay_days and 21.1 avg_total_delivery_days. From Q14 MA has
-- the second highest freight burden at 26.2%. This confirms MA as a double failure
-- state: customers pay near the most in freight and have the second worst on-time rate
-- on the platform.


-- 5 -- Delivery Speed vs Review Score
-- Purpose: Quantifying the direct impact of delivery duration on customer satisfaction to build the business case for logistics investment.

WITH delivery_data AS (
  SELECT
    o.order_id,
    DATE_DIFF(o.order_delivered_customer_date,
              o.order_purchase_timestamp, DAY)   AS delivery_days,
    r.review_score
  FROM `som3a-366421.olist.orders_cleaned` o
  JOIN `som3a-366421.olist.order_reviews_cleaned` r
    ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
)
SELECT
  CASE
    WHEN delivery_days <= 5  THEN '1. Express (≤5 days)'
    WHEN delivery_days <= 10 THEN '2. Fast (6–10 days)'
    WHEN delivery_days <= 20 THEN '3. Standard (11–20 days)'
    ELSE                          '4. Slow (20+ days)'
  END                             AS delivery_bucket,
  COUNT(DISTINCT order_id)        AS orders,
  ROUND(AVG(review_score), 2)     AS avg_review_score,
  ROUND(
    100 * COUNTIF(review_score <= 2) / COUNT(*), 1
  )                               AS bad_review_pct
FROM delivery_data
GROUP BY delivery_bucket
ORDER BY delivery_bucket;

-- *RECOMMENDATION*

-- The Slow bucket (20+ days) is the single most damaging operational failure in the
-- entire project: 38.3% bad review rate — more than 4x the Express bucket (7.3%).
-- avg_review drops to 3.12, well below the platform average. 12,216 orders fell into
-- this bucket meaning roughly 4,680 customers left a bad review purely because of
-- delivery speed. Every day this segment exists unaddressed is compounding churn given
-- the already critical 3.04% repeat purchase rate established in Q6.

-- The drop between Standard (11–20 days) and Slow (20+ days) is the sharpest cliff
-- in the dataset: bad_review_pct jumps from 10.7% to 38.3% — a 258% increase.
-- This means 20 days is the breaking point for customer tolerance. Any order
-- approaching this threshold should trigger an automatic customer notification with
-- a discount voucher for the next purchase to preemptively absorb the dissatisfaction
-- before the review is submitted.

-- Express (≤5 days) at 4.43 avg review and only 7.3% bad review rate is the clearest
-- ROI argument for logistics investment in the entire analysis. Getting orders under
-- 5 days is not just an operational metric — it is directly correlated with platform
-- reputation and repeat purchase likelihood. Present this alongside Q6 retention data
-- to justify warehouse expansion or priority carrier contracts in high-volume states.


-- ============================================================
-- MODULE 3 — CUSTOMER BEHAVIOR
-- ============================================================


-- 6 -- Customer Retention & Repeat Purchase Rate Analysis
-- Purpose: Measuring what share of the customer base returns for a second purchase, exposing the platform's retention health and LTV ceiling.

WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    -- Utilizing the unique permanent citizen ID instead of the volatile customer token
    COUNT(o.order_id) AS order_count
  FROM `som3a-366421.olist.orders_cleaned` o
  JOIN `som3a-366421.olist.customers_cleaned` c
    ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
    AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
  GROUP BY c.customer_unique_id
)
SELECT
  -- Aggregating volume of one-time buyers vs loyal returning cohorts
  COUNTIF(order_count = 1) AS one_time_customers,
  COUNTIF(order_count >= 2) AS repeat_customers,
  COUNT(*) AS total_customers,
  -- Repeat Purchase Rate: Crucial health indicator for customer lifetime value and brand loyalty
  ROUND(100 * COUNTIF(order_count >= 2) / COUNT(*), 2) AS repeat_rate_pct
FROM customer_orders;

-- *RECOMMENDATION*

-- 3.04% repeat rate across 94,707 customers means 91,832 customers bought once and
-- never returned. At an average order value of ~R$160 from Q10, every 1% improvement
-- in repeat rate converts roughly 947 customers into repeat buyers — adding ~R$151K
-- in revenue without acquiring a single new customer. Retention is the highest ROI
-- lever available to Olist right now.

-- The platform is functioning as a discovery channel, not a loyalty platform. Customers
-- arrive, buy once, and leave. This pattern combined with Q8 showing consistent monthly
-- acquisition of 6,500+ new customers suggests the business is masking the retention
-- crisis with raw acquisition volume. CAC is growing while LTV stays flat — this is
-- unsustainable as acquisition costs rise.

-- Immediate action: launch a post-purchase email sequence triggered 7 days after
-- confirmed delivery offering a time-limited discount on the next order. Target the
-- Express and Fast delivery buckets from Q5 first — customers who received their
-- order in under 10 days and left a positive review are the highest conversion
-- probability segment for a second purchase. Converting even 2% of the 91,832
-- one-time buyers adds over 1,800 repeat customers to the base.


-- 7 -- Credit & Installment Behavior Analysis
-- Purpose: Investigating if higher order values trigger dependency on longer credit installment terms.

SELECT
  -- Bucketizing credit card payment values into distinct commercial tiers
  CASE
    WHEN p.payment_value < 100  THEN '1. Under R$100'
    WHEN p.payment_value < 300  THEN '2. R$100–299'
    WHEN p.payment_value < 600  THEN '3. R$300–599'
    ELSE                             '4. R$600+'
  END AS value_tier,

  -- Total credit card transactions within each specific value tier (Distinct to prevent split-payment inflation)
  COUNT(DISTINCT p.order_id) AS unique_orders,

  -- Average installment duration to verify if higher cart values lead to extended credit terms
  ROUND(AVG(p.payment_installments), 1) AS avg_installments,

  -- Maximum installment duration offered/taken within this tier
  ROUND(MAX(p.payment_installments), 0) AS max_installments
FROM `som3a-366421.olist.order_payments_cleaned` p
-- Joining with orders to filter out canceled noise and enforce the uniform temporal baseline
JOIN `som3a-366421.olist.orders_cleaned` o
  ON p.order_id = o.order_id
WHERE p.payment_type = 'credit_card'
  AND o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY value_tier
ORDER BY value_tier;

-- *RECOMMENDATION*

-- Installment usage scales perfectly linearly with order value — 2.3 months for
-- sub-R$100 orders up to 7.4 months for R$600+ orders. This confirms that installments
-- are the primary mechanism enabling high-ticket purchases on the platform. Without
-- credit options the R$600+ tier (generating R$3.4M from Q10) would likely collapse
-- as Brazilian consumers cannot absorb large lump-sum payments.

-- The R$100–299 tier has the highest order volume at 32,071 unique orders and already
-- uses 4.1 avg installments. This is the sweet spot for installment-driven upselling —
-- customers in this tier are already comfortable with credit. A targeted "add R$50 more
-- and split into 6 installments" prompt at checkout would push Mid-tier buyers into
-- Premium territory and lift AOV without requiring new customer acquisition.

-- Max installments of 24 appear in all tiers above R$100 meaning some customers are
-- stretching payments across 2 full years even for R$100–299 purchases. Finance must
-- audit the default installment options shown at checkout — if 24 installments is being
-- offered on low-value orders it signals either predatory UX design or customers in
-- genuine financial distress. Either scenario carries regulatory and reputational risk
-- that needs immediate review.


-- 8 -- Customer Acquisition Trend Analysis
-- Purpose: Tracking new customer volume month by month to measure organic growth velocity and identify seasonal acquisition spikes.

WITH first_orders AS (
  SELECT
    c.customer_unique_id,
    -- Pinpointing the exact definitive timestamp of the customer's first-ever purchase
    MIN(o.order_purchase_timestamp) AS first_order_ts
  FROM `som3a-366421.olist.orders_cleaned` o
  JOIN `som3a-366421.olist.customers_cleaned` c
    ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
  GROUP BY c.customer_unique_id
)
SELECT
  -- Truncating the acquisition timestamp to a monthly starting point
  DATE_TRUNC(first_order_ts, MONTH) AS acquisition_month,
  -- Counting absolute unique entities acquired in this cohort
  COUNT(*) AS new_customers
FROM first_orders
-- Enforcing our established stable operational window on the cohort birth dates
WHERE first_order_ts BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY acquisition_month
ORDER BY acquisition_month;

-- *RECOMMENDATION*

-- November 2017 is the single largest acquisition spike in the dataset at 7,190 new
-- customers — a 63.7% jump from October's 4,392. This is Black Friday driven and
-- confirms the platform has strong seasonal demand capacity. Supply chain, server
-- infrastructure, and seller inventory must be pre-positioned for this window every
-- year — a failure to fulfill during peak acquisition directly converts new customers
-- into one-time buyers, worsening the already critical 3.04% repeat rate from Q6.

-- 2018 shows a plateau: monthly acquisition stabilized between 5,920 and 6,951 new
-- customers with no meaningful growth trend across 8 months. The platform grew
-- aggressively through 2017 (752 in January to 7,190 in November) but has hit a
-- ceiling in 2018. This signals the low-hanging acquisition fruit has been exhausted
-- and continued raw customer growth will require either new geographic markets or
-- paid channel investment — both of which carry rising CAC. The business case for
-- shifting budget toward retention over acquisition has never been stronger.

-- January 2017 started at only 752 new customers — the lowest month in the dataset
-- outside the 2016 noise. By August 2018 the platform was acquiring 6,209 monthly,
-- an 825% increase in 20 months. This growth trajectory is the strongest portfolio
-- narrative in the entire project — frame it in your README as evidence of a
-- hypergrowth phase with a clear inflection point at November 2017.


-- ============================================================
-- MODULE 4 — PRODUCT & CATEGORY
-- ============================================================


-- 9 -- Product Category Performance Matrix (Revenue vs. Customer Satisfaction)
-- Purpose: Identifying top 10 revenue-driving categories intersected with quality signals (review scores) within our standard baseline window (2017-01-01 to 2018-08-31).

SELECT
  t.product_category_name_english                                    AS category_en,
  COUNT(DISTINCT oi.order_id)                                        AS orders,
  ROUND(SUM(oi.price), 2)                                            AS category_revenue,
  ROUND(AVG(oi.price), 2)                                            AS avg_item_price,
  ROUND(AVG(r.review_score), 2)                                      AS avg_review
FROM `som3a-366421.olist.order_items_cleaned` oi
JOIN `som3a-366421.olist.products_cleaned` p
  ON oi.product_id = p.product_id
JOIN `som3a-366421.olist.product_category_name_translation_cleaned` t
  ON p.product_category_name = t.product_category_name
LEFT JOIN `som3a-366421.olist.order_reviews_cleaned` r
  ON oi.order_id = r.order_id
JOIN `som3a-366421.olist.orders_cleaned` o
  ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY t.product_category_name_english
ORDER BY category_revenue DESC
LIMIT 10;

-- *RECOMMENDATION*

-- health_beauty leads on both revenue (R$1.25M) and satisfaction (4.15) simultaneously
-- — the only category in the top 10 that wins on both dimensions. This is the platform's
-- anchor category. Maximize seller recruitment, marketing spend, and promotional slots
-- here before any other category. Losing ground in health_beauty would have the single
-- largest negative impact on overall platform GMV.

-- watches_gifts generates R$1.19M from only 5,599 orders at R$200 avg item price —
-- the highest avg price in the top 10. Revenue here is driven entirely by price point
-- not volume. Catalog depth is the only constraint — more verified premium sellers in
-- this category would translate directly to revenue without needing more customers.

-- bed_bath_table and furniture_decor are the two largest risk positions: combined
-- R$1.76M in revenue but satisfaction scores of 3.90 and 3.92 — lowest in the top 10.
-- From Q11 results these categories also carry 16.66% and 16.33% bad order rates.
-- At 9,394 and 6,373 orders respectively the volume of unhappy customers is compounding
-- daily. Cross-reference with seller data from Q12 to identify the bottom performing
-- merchants in these two categories and apply immediate SLA penalties.

-- cool_stuff is the most underexploited category: R$164 avg item price and 4.16
-- satisfaction — highest in the top 10 — but only 3,609 orders, the second lowest
-- volume. High margin, high satisfaction, low volume is the definition of an
-- undermarketed category. Push it via homepage placement and bundle it with auto
-- and sports_leisure buyers who already spend in a similar price range.


-- 10 -- Price Tier Distribution Analysis
-- Purpose: Mapping order volume and revenue across price segments to identify where the catalog's commercial weight actually sits.

SELECT
  CASE
    WHEN oi.price < 50   THEN '1. Budget (<R$50)'
    WHEN oi.price < 150  THEN '2. Mid (R$50–149)'
    WHEN oi.price < 400  THEN '3. Premium (R$150–399)'
    ELSE                      '4. Luxury (R$400+)'
  END                             AS price_tier,
  COUNT(*)                        AS item_count,
  ROUND(SUM(oi.price), 2)         AS tier_revenue,
  ROUND(AVG(r.review_score), 2)   AS avg_review
FROM `som3a-366421.olist.order_items_cleaned` oi
-- Enforcing our uniform operational timeline by joining orders_cleaned
JOIN `som3a-366421.olist.orders_cleaned` o
  ON oi.order_id = o.order_id
LEFT JOIN `som3a-366421.olist.order_reviews_cleaned` r
  ON oi.order_id = r.order_id
-- Keeping the exact same time window across all analysis scripts
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY price_tier
ORDER BY price_tier;

-- *RECOMMENDATION*

-- Mid tier (R$50–149) dominates on both dimensions: highest item count (50,509)
-- and highest revenue (R$4.67M / 35% of total GMV). This is the platform's core
-- engine — protect and grow this segment before anything else.

-- Luxury tier (R$400+) is only 4,188 items (4% of volume) but generates R$3.4M
-- (25% of total GMV) with satisfaction at 4.03. Revenue per item here is the
-- highest on the platform. Every verified high-ticket seller added is
-- disproportionately valuable — prioritize onboarding in watches and electronics.

-- Budget tier (<R$50) is the efficiency problem: 38,718 items shipped for only
-- R$1.21M revenue. Fulfillment cost per shipment is roughly equal regardless of
-- price — meaning Budget orders are the least profitable per shipment. Set a
-- minimum order value for free shipping to nudge buyers into adding items and
-- crossing into Mid tier.


-- 11 -- Category Quality & Complaint Concentration Analysis
-- Purpose: Isolating categories with the highest bad review rates to pinpoint where customer dissatisfaction is structurally concentrated.

SELECT
  t.product_category_name_english                                    AS category_en,
  COUNT(DISTINCT oi.order_id)                                        AS order_count,
  ROUND(AVG(r.review_score), 2)                                      AS avg_review,
  COUNT(DISTINCT CASE WHEN r.review_score <= 2 THEN oi.order_id END) AS bad_orders,
  ROUND(
    100 * COUNT(DISTINCT CASE WHEN r.review_score <= 2 THEN oi.order_id END)
    / COUNT(DISTINCT oi.order_id), 2
  )                                                                  AS bad_order_pct
FROM `som3a-366421.olist.order_items_cleaned` oi
JOIN `som3a-366421.olist.products_cleaned` p
  ON oi.product_id = p.product_id
JOIN `som3a-366421.olist.product_category_name_translation_cleaned` t
  ON p.product_category_name = t.product_category_name
JOIN `som3a-366421.olist.order_reviews_cleaned` r
  ON oi.order_id = r.order_id
JOIN `som3a-366421.olist.orders_cleaned` o
  ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY t.product_category_name_english
HAVING order_count >= 100
ORDER BY avg_review ASC
LIMIT 15;

-- *RECOMMENDATION*

-- fashion_male_clothing has the highest bad order rate on the entire platform at 24.77%
-- — nearly 1 in 4 customers is dissatisfied. At only 109 orders it is low volume but the
-- rate is too extreme to ignore. Root cause is almost certainly misleading size charts or
-- product photos not matching reality. Force merchants to implement standardized sizing
-- widgets before new listings go live.

-- office_furniture is the highest volume problem: 1,257 orders with 22.43% bad order rate
-- — 282 absolute bad orders. Heavy items with complex assembly are the likely cause.
-- Mandate stricter packaging standards for bulky items and consider bundling third-party
-- assembly services at checkout to reduce post-delivery complaints.

-- bed_bath_table and furniture_decor combined represent 15,614 orders with ~16.5% bad
-- order rate — generating over 2,500 bad reviews between them. At this volume the damage
-- to platform reputation is compounding daily. Implement merchant-level penalties for
-- sellers in the bottom 10% of these categories and cross-reference with Q12 seller data
-- to identify and suspend repeat offenders immediately.


-- ============================================================
-- MODULE 5 — SELLER & GEOGRAPHIC PERFORMANCE
-- ============================================================


-- 12 -- Top 20 Sellers Performance & SLA Matrix
-- Purpose: Evaluating top revenue-driving sellers against fulfillment speed (Handling SLA) and quality metrics.

SELECT
  oi.seller_id,
  COUNT(DISTINCT oi.order_id)                                         AS orders_fulfilled,
  ROUND(SUM(oi.price + oi.freight_value), 2)                          AS total_gmv,
  ROUND(AVG(oi.price), 2)                                             AS avg_item_price,
  -- Measuring internal seller processing speed (Handling time before carrier handover)
  ROUND(
    AVG(DATE_DIFF(o.order_delivered_carrier_date, o.order_purchase_timestamp, DAY)), 1
  )                                                                   AS avg_days_to_ship,
  ROUND(AVG(r.review_score), 2)                                       AS avg_review
FROM `som3a-366421.olist.order_items_cleaned` oi
JOIN `som3a-366421.olist.orders_cleaned` o
  ON oi.order_id = o.order_id
LEFT JOIN `som3a-366421.olist.order_reviews_cleaned` r
  ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
  -- Enforcing the uniform project timeframe baseline
  AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY oi.seller_id
ORDER BY total_gmv DESC
LIMIT 20;

-- *RECOMMENDATION*

-- Top seller (4869f7a5) leads with R$247K GMV and ships in 2.2 days with 4.14 review —
-- the benchmark every other seller should be measured against.
-- Seller 7c67e1448b stands out negatively: R$237K GMV but 11.7 avg days to ship and 3.35
-- review — the slowest and lowest-rated in the top 20, despite being #2 in revenue.
-- High-ticket sellers (53243585 at R$544/item, 7e93a43e at R$512/item) maintain strong
-- reviews (4.13, 4.36) proving premium pricing doesn't hurt satisfaction when fulfilled well.

-- Investigate seller 7c67e1448b urgently: 11.7 days to ship is 5x slower than the
-- top performer. At R$237K GMV it is too valuable to lose but too slow to ignore.
-- Set a shipping SLA warning — if not resolved, demote their listing visibility.

-- Use sellers fa1c13f2 and edb1ef5e as quality benchmarks: both combine fast shipping
-- (2.2 and 1.2 days) with the highest review scores in the top 20 (4.37 and 4.45).
-- Study their fulfillment process and apply it as the platform standard.


-- 13 -- Seller Composite Performance Score
-- Purpose: Ranking sellers on a balanced three-dimensional score combining revenue, fulfillment speed, and customer satisfaction using NTILE.

WITH seller_metrics AS (
  SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id)                                        AS orders,
    SUM(oi.price)                                                      AS revenue,
    AVG(DATE_DIFF(o.order_delivered_carrier_date,
                  o.order_purchase_timestamp, DAY))                    AS avg_ship_days,
    AVG(r.review_score)                                                AS avg_review
  FROM `som3a-366421.olist.order_items_cleaned` oi
  JOIN `som3a-366421.olist.orders_cleaned` o
    ON oi.order_id = o.order_id
  LEFT JOIN `som3a-366421.olist.order_reviews_cleaned` r
    ON oi.order_id = r.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
  GROUP BY oi.seller_id
  HAVING orders >= 10
),
ranked AS (
  SELECT
    seller_id,
    orders,
    ROUND(revenue, 0)                                  AS revenue,
    ROUND(avg_ship_days, 1)                            AS avg_ship_days,
    ROUND(avg_review, 2)                               AS avg_review,
    NTILE(100) OVER (ORDER BY revenue)                 AS revenue_pct,
    -- Higher speed rank = lower ship days (DESC so fast shippers score higher)
    NTILE(100) OVER (ORDER BY avg_ship_days DESC)      AS speed_pct,
    NTILE(100) OVER (ORDER BY avg_review)              AS review_pct
  FROM seller_metrics
)
SELECT
  seller_id,
  orders,
  revenue,
  avg_ship_days,
  avg_review,
  ROUND((revenue_pct + speed_pct + review_pct) / 3.0, 1) AS composite_score
FROM ranked
ORDER BY composite_score DESC
LIMIT 20;

-- *RECOMMENDATION*

-- The top composite scorers (ba90964c, d921b68b) both ship in under 1 day with review
-- scores above 4.4 — proving that speed is the single strongest driver of composite rank.
-- Every seller in the top 20 here ships in 1.3 days or less. Use this as the platform
-- SLA benchmark: any seller exceeding 2 days handling time should receive a formal warning.

-- b410bdd3 and d9bd94811 stand out on satisfaction: 4.81 and 4.82 review scores —
-- the highest in the entire top 20. Study their order handling, packaging, and
-- communication process and publish it as a seller best practice guide on the platform.

-- Cross-reference this list with Q12 top 20 by GMV — edb1ef5e appears in both lists
-- (R$79K revenue, 1.2 days, 4.45 review) making it the most well-rounded seller on
-- the platform. Sellers appearing in Q12 but absent here are generating revenue while
-- underperforming on speed or satisfaction and should be flagged immediately.


-- 14 -- Freight Burden by State
-- Purpose: Measuring freight cost as a percentage of item price per state to identify where customers face disproportionate shipping costs.

SELECT
  c.customer_state,
  COUNT(DISTINCT o.order_id)                               AS orders,
  ROUND(AVG(oi.freight_value), 2)                          AS avg_freight,
  ROUND(AVG(oi.price), 2)                                  AS avg_item_price,
  ROUND(
    100 * AVG(oi.freight_value) / NULLIF(AVG(oi.price), 0), 1
  )                                                        AS freight_pct_of_price
FROM `som3a-366421.olist.orders_cleaned` o
JOIN `som3a-366421.olist.customers_cleaned` c
  ON o.customer_id = c.customer_id
JOIN `som3a-366421.olist.order_items_cleaned` oi
  ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY c.customer_state
ORDER BY freight_pct_of_price DESC;

-- *RECOMMENDATION*

-- RR, MA, RO, AM and PI are the five highest freight burden states — customers there
-- pay 24–28% of item price just in shipping. Combined with Q4 delay data, if these
-- same states also show high late_order_pct they represent a double failure: customers
-- pay the most and wait the longest. Cross-reference immediately and flag these as
-- highest churn-risk regions on the platform.

-- SP sits at 13.8% freight burden — the lowest on the entire list — because proximity
-- to the majority of Olist's seller base keeps logistics costs down. This freight gap
-- between SP (13.8%) and RR (27.8%) is a 2x disparity that directly suppresses
-- conversion in northern and northeastern states. Consider state-specific subsidized
-- freight programs or regional warehouse partnerships to close this gap.

-- PB stands out as an anomaly: R$191 avg item price — highest in the entire dataset —
-- yet 22.3% freight burden. Customers in PB are buying expensive items but still
-- absorbing disproportionate shipping costs. A targeted free shipping threshold for
-- orders above R$150 in high avg_item_price states like PB, AC and PI would reduce
-- friction for buyers already committed to premium purchases.
