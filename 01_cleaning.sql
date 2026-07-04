-- ============================================================
-- OLIST BRAZILIAN E-COMMERCE — DATA CLEANING PIPELINE
-- Author   : Ismaeel Abdulla
-- Dataset  : som3a-366421.olist
-- Engine   : BigQuery SQL
-- Tables   : 8 materialized cleaned tables
-- Strategy : Materialized tables — cleaning logic executes once,
--            results cached, zero reprocessing on every analysis run
-- ============================================================


-- ============================================================
-- TABLE 1 — customers_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.customers_cleaned`
OPTIONS(
  description="Materialized dimensions for customers, normalizing text fields and enforcing unique order-session tokens."
) AS

WITH source_data AS (
  SELECT * FROM `som3a-366421.olist.customers`
),

deduplicated_stage AS (
  SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY customer_id) as row_num
  FROM source_data
),

clean_dimensions AS (
  SELECT
    -- Primary Key token for joining with orders table
    TRIM(customer_id) AS customer_id,
    
    -- Actual unique human identifier
    TRIM(customer_unique_id) AS customer_unique_id,
    
    -- Cast to STRING to preserve potential leading zeros, no TRIM needed on INT64
    CAST(customer_zip_code_prefix AS STRING) AS customer_zip_code_prefix,
    
    -- Normalizing location strings for clean dashboard filters
    LOWER(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
  FROM deduplicated_stage
  WHERE row_num = 1
)

SELECT * FROM clean_dimensions;


-- ============================================================
-- TABLE 2 — order_items_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.order_items_cleaned`
OPTIONS(description="Materialized table mapping orders to products with parsed financial figures and timestamps.") AS

WITH deduplicated_stage AS (
  SELECT * FROM `som3a-366421.olist.order_items`
  -- Enforce uniqueness across the composite key (Order + Item Sequence)
  QUALIFY ROW_NUMBER() OVER(PARTITION BY order_id, order_item_id) = 1
),

clean_metrics AS (
  SELECT
    TRIM(order_id) AS order_id,
    CAST(order_item_id AS INT64) AS order_item_id,
    TRIM(product_id) AS product_id,
    TRIM(seller_id) AS seller_id,
    
    SAFE_CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
    SAFE_CAST(price AS FLOAT64) AS price,
    SAFE_CAST(freight_value AS FLOAT64) AS freight_value
  FROM deduplicated_stage
)

SELECT * FROM clean_metrics;


-- ============================================================
-- TABLE 3 — order_payments_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.order_payments_cleaned`
OPTIONS(description="Materialized transactional data detailing financial values and installment counts.") AS

WITH deduplicated_stage AS (
  SELECT * FROM `som3a-366421.olist.order_payments`
  -- Prevent any rogue technical duplicate entries on the sequence token
  QUALIFY ROW_NUMBER() OVER(PARTITION BY order_id, payment_sequential) = 1
),

clean_payments AS (
  SELECT
    TRIM(order_id) AS order_id,
    CAST(payment_sequential AS INT64) AS payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    CAST(payment_installments AS INT64) AS payment_installments,
    SAFE_CAST(payment_value AS FLOAT64) AS payment_value
  FROM deduplicated_stage
)

SELECT * FROM clean_payments;


-- ============================================================
-- TABLE 4 — order_reviews_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.order_reviews_cleaned`
OPTIONS(description="Materialized order reviews keeping the latest customer feedback entry per order.") AS

WITH deduplicated_stage AS (
  SELECT * FROM `som3a-366421.olist.order_reviews`
  -- Keep only the absolute latest review submission for each order ID
  QUALIFY ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY review_answer_timestamp DESC) = 1
),

clean_reviews AS (
  SELECT
    TRIM(review_id) AS review_id,
    TRIM(order_id) AS order_id,
    CAST(review_score AS INT64) AS review_score,
    
    -- Convert blank string spaces into true database NULLs
    NULLIF(TRIM(review_comment_title), '') AS review_comment_title,
    NULLIF(TRIM(review_comment_message), '') AS review_comment_message,
    
    SAFE_CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
    SAFE_CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
  FROM deduplicated_stage
)

SELECT * FROM clean_reviews;


-- ============================================================
-- TABLE 5 — orders_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.orders_cleaned`
OPTIONS(
  description="Materialized table of orders with properly parsed timestamps and enforced primary key uniqueness."
) AS

WITH source_data AS (
  SELECT * FROM `som3a-366421.olist.orders`
),

deduplicated_stage AS (
  SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY order_purchase_timestamp) as row_num
  FROM source_data
),

type_casting AS (
  SELECT
    -- Keys & Status
    TRIM(order_id) AS order_id,
    TRIM(customer_id) AS customer_id,
    LOWER(TRIM(order_status)) AS order_status,

    -- Safely converting string dates to real BigQuery Timestamps
    SAFE_CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    SAFE_CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
    SAFE_CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
    SAFE_CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
    SAFE_CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date
  FROM deduplicated_stage
  -- Enforce that we only keep unique primary keys
  WHERE row_num = 1
)

SELECT * FROM type_casting;


-- ============================================================
-- TABLE 6 — product_category_name_translation_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.product_category_name_translation_cleaned`
OPTIONS(description="Materialized lookup table for translating product category names from Portuguese to English.") AS

WITH deduplicated_stage AS (
  SELECT * FROM `som3a-366421.olist.product_category_name_translation`
  QUALIFY ROW_NUMBER() OVER(PARTITION BY product_category_name) = 1
)

SELECT
  TRIM(product_category_name) AS product_category_name,
  TRIM(product_category_name_english) AS product_category_name_english
FROM deduplicated_stage;


-- ============================================================
-- TABLE 7 — products_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.products_cleaned`
OPTIONS(
  description="Materialized product dimensions with standardized physical metrics and clean categories."
) AS

WITH deduplicated_stage AS (
  SELECT * FROM `som3a-366421.olist.products`
  -- Enforce primary key uniqueness on product_id
  QUALIFY ROW_NUMBER() OVER(PARTITION BY product_id) = 1
)

SELECT
  TRIM(product_id) AS product_id,
  TRIM(product_category_name) AS product_category_name,
  
  -- Explicitly cast dimensional and physical metrics to allow downstream math calculations
  SAFE_CAST(product_name_length AS INT64) AS product_name_length,
  SAFE_CAST(product_description_length AS INT64) AS product_description_length,
  SAFE_CAST(product_photos_qty AS INT64) AS product_photos_qty,
  SAFE_CAST(product_weight_g AS FLOAT64) AS product_weight_g,
  SAFE_CAST(product_length_cm AS FLOAT64) AS product_length_cm,
  SAFE_CAST(product_height_cm AS FLOAT64) AS product_height_cm,
  SAFE_CAST(product_width_cm AS FLOAT64) AS product_width_cm
FROM deduplicated_stage;


-- ============================================================
-- TABLE 8 — sellers_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.sellers_cleaned`
OPTIONS(
  description="Materialized sellers master data with normalized text fields and safe string zip codes."
) AS

WITH deduplicated_stage AS (
  SELECT * FROM `som3a-366421.olist.sellers`
  -- Enforce primary key uniqueness on seller_id
  QUALIFY ROW_NUMBER() OVER(PARTITION BY seller_id) = 1
)

SELECT
  TRIM(seller_id) AS seller_id,
  -- Cast to STRING to safeguard leading zeros for postal mapping
  CAST(seller_zip_code_prefix AS STRING) AS seller_zip_code_prefix,
  
  -- Align city naming standards with geolocation and customer dimension rules
  REGEXP_REPLACE(NORMALIZE(LOWER(TRIM(seller_city)), NFD), r"[\pM]", "") AS seller_city,
  UPPER(TRIM(seller_state)) AS seller_state
FROM deduplicated_stage;


-- ============================================================
-- TABLE 9 — geolocation_cleaned
-- ============================================================

CREATE OR REPLACE TABLE `som3a-366421.olist.geolocation_cleaned`
OPTIONS(
  description="Materialized and highly deduplicated geolocation data grouped by unique ZIP code prefix."
) AS

WITH deduplicated_stage AS (
  SELECT * FROM `som3a-366421.olist.geolocation`
  -- Pick the first coordinates per ZIP code to enforce a unique 1:1 ZIP code relation
  QUALIFY ROW_NUMBER() OVER(PARTITION BY geolocation_zip_code_prefix) = 1
)

SELECT
  -- Cast to STRING to ensure standard join alignment with customers and sellers
  CAST(geolocation_zip_code_prefix AS STRING) AS geolocation_zip_code_prefix,
  SAFE_CAST(geolocation_lat AS FLOAT64) AS geolocation_lat,
  SAFE_CAST(geolocation_lng AS FLOAT64) AS geolocation_lng,
  
  -- Maintain warehouse text uniformity (Trim + Lowercase + Strip Accents)
  REGEXP_REPLACE(NORMALIZE(LOWER(TRIM(geolocation_city)), NFD), r"[\pM]", "") AS geolocation_city,
  UPPER(TRIM(geolocation_state)) AS geolocation_state
FROM deduplicated_stage;
