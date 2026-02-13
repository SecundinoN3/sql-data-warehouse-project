CREATE OR ALTER PROCEDURE cleaning.load_cleaning_tables AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT('CLEANED (6 TOTAL)')

		SET @start_time = GETDATE();

		TRUNCATE TABLE cleaning.crm_cust_info;
		INSERT INTO cleaning.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,

			CASE UPPER(TRIM(cst_marital_status))
				 WHEN 'S' THEN 'Single'
				 WHEN 'M' THEN 'Married'
				 ELSE 'n/a'
			END cst_marital_status,

			CASE UPPER(TRIM(cst_gndr))
				 WHEN 'F' THEN 'Female'
				 WHEN 'M' THEN 'Male'
				 ELSE 'n/a'
			END cst_gndr,

			cst_create_date
		FROM (SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM staging.crm_cust_info
		WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1;

		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (crm_cust_info)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE cleaning.crm_prd_info;
		INSERT INTO cleaning.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_name,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, -- extract cat ID from
			SUBSTRING(prd_key,7,LEN(prd_key) - 6) AS prd_key, -- extract prd key
			prd_name,
			ISNULL(prd_cost,0) AS prd_cst,

			CASE UPPER(TRIM(prd_line)) 
				 WHEN 'M' THEN 'Mountain' 
				 WHEN 'R' THEN 'Road' 
				 WHEN 'T' THEN 'Touring' 
				 WHEN 'S' THEN 'Other Sales' 
				 ELSE 'n/a'
			END prd_line,

			prd_start_dt,
			DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
		FROM staging.crm_prd_info;

		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (crm_prd_info)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE cleaning.crm_sales_details;
		INSERT INTO cleaning.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE) 
			END AS sls_order_dt,

			CASE
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE) 
			END AS sls_ship_dt,

			CASE
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE) 
			END AS sls_due_dt,

			CASE
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,

			sls_quantity,

			CASE
				WHEN sls_price IS NULL OR sls_price <= 0 
				THEN sls_sales / NULLIF(sls_quantity,0)
				ELSE sls_price
			END AS sls_price
		FROM staging.crm_sales_details;

		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (crm_sales_details)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE cleaning.erp_cust_az12;
		INSERT INTO cleaning.erp_cust_az12 (
			cid,
			bdate, 
			gen)
		SELECT 
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)-3)
				ELSE cid
			END AS cid,

			CASE
				WHEN bdate > GETDATE() OR YEAR(bdate) < 1909 THEN NULL
				ELSE bdate
			END AS bdate,

			CASE
				WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
				ELSE 'Unknown'
			END AS gen
		FROM staging.erp_cust_az12;

		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (erp_cust_az12)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE cleaning.erp_loc_a101;
		INSERT INTO cleaning.erp_loc_a101 (
			cid, 
			cntry
		)
		SELECT
			REPLACE(cid,'-',''),

			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN NULL
				ELSE TRIM(cntry)
			END AS country_name

		FROM staging.erp_loc_a101;

		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (erp_loc_a101)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE cleaning.erp_px_cat_g1v2;
		INSERT INTO cleaning.erp_px_cat_g1v2 (
			id,
			cat, 
			subcat,
			maintenance)

		SELECT 
			CASE
				WHEN id = 'CO_PD' THEN 'CO_PE'
				ELSE id
			END as id,

			cat,
			subcat,
			maintenance
		FROM staging.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (erp_px_cat_g1v2)';
		PRINT '----------------------------------------'
		SET @batch_end_time = GETDATE();
		PRINT 'Total Duration ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time)AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT 'Error loading Cleaning tables: ' + ERROR_MESSAGE();
		PRINT 'Error Message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END
