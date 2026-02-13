/*
Quality Checks

Script Purpose:
    Performs quality checks to validate the integrity, consistency, 
    and accuracy of the business_intelligence Layer. These checks make sure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any mistakes found during the checks.
*/

-- Checking 'business_intelligence.dim_customers'
-- Check for Uniqueness of Customer Key in business_intelligence.dim_customers
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM business_intelligence.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Checking 'business_intelligence.product_key'
-- Check for Uniqueness of Product Key in business_intelligence.dim_products
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM business_intelligence.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Checking 'business_intelligence.fact_sales'
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM business_intelligence.fact_sales f
LEFT JOIN business_intelligence.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN business_intelligence.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  
