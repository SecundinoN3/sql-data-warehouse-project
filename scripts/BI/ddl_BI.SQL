/*
DDL Script: Create Gold Views

Script Purpose:
    This creates views for the business_intelligence layer in the data warehouse. 
    The business_intelligence layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the cleaning layer 
    to produce a cleaned, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
*/

IF OBJECT_ID('business_intelligence.dim_customers', 'V') IS NOT NULL
	DROP VIEW business_intelligence.dim_customers;
GO

CREATE VIEW business_intelligence.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id)AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry as country,
	ci.cst_marital_status AS marital_status,
	CASE
	WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE(ca.gen,'n/a')
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM cleaning.crm_cust_info ci
LEFT JOIN cleaning.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN cleaning.erp_loc_a101 la
	ON ci.cst_key = la.cid;
GO

IF OBJECT_ID('business_intelligence.dim_products', 'V') IS NOT NULL
	DROP VIEW business_intelligence.dim_products;
GO

CREATE VIEW business_intelligence.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY prd_id) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_name AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat as sub_category,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM cleaning.crm_prd_info pn
LEFT JOIN cleaning.erp_px_cat_g1v2 pc
	ON pn.cat_id = pc.id
WHERE pn.prd_end_dt is null;
GO

IF OBJECT_ID('business_intelligence.fact_sales', 'V') IS NOT NULL
	DROP VIEW business_intelligence.fact_sales;
GO

CREATE VIEW business_intelligence.fact_sales AS
SELECT 
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM cleaning.crm_sales_details sd
LEFT JOIN business_intelligence.dim_products pr
	ON sd.sls_prd_key = pr.product_number
LEFT JOIN business_intelligence.dim_customers cu
	ON sd.sls_cust_id = cu.customer_id
GO

