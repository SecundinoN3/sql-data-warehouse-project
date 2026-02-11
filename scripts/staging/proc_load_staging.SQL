/*
stored procedure: Load staging layer

Script Purpose: Loads data into 'staging' schema from external csv files
1.Truncates tables before loading data.
2.Uses the 'BULK INSERT' command to load data from csv files onto tables

PARAMETERS: None

USAGE EX: EXEC staging.load_staging_tables;
*/

CREATE OR ALTER PROCEDURE staging.load_staging_tables AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT'loading staging layer (6 in total)'

		SET @start_time = GETDATE();

		TRUNCATE TABLE staging.crm_cust_info;
		BULK INSERT staging.crm_cust_info
		FROM 'C:\Users\Dino\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (crm_cust_info)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE staging.crm_prd_info;
		BULK INSERT staging.crm_prd_info
		FROM 'C:\Users\Dino\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (crm_prd_info)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE staging.crm_sales_details;
		BULK INSERT staging.crm_sales_details
		FROM 'C:\Users\Dino\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (crm_sales_details)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE staging.erp_cust_az12;
		BULK INSERT staging.erp_cust_az12
		FROM 'C:\Users\Dino\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (erp_cust_az12)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE staging.erp_loc_a101;
		BULK INSERT staging.erp_loc_a101
		FROM 'C:\Users\Dino\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (erp_loc_a101)';
		PRINT '----------------------------------------'

		SET @start_time = GETDATE();

		TRUNCATE TABLE staging.erp_px_cat_g1v2;
		BULK INSERT staging.erp_px_cat_g1v2
		FROM 'C:\Users\Dino\Desktop\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds (erp_px_cat_g1v2)';
		PRINT '----------------------------------------'
		SET @batch_end_time = GETDATE();
		PRINT 'Total Duration ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time)AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT 'Error loading staging tables: ' + ERROR_MESSAGE();
		PRINT 'Error Message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END
