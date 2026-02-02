/*
Script: Create Data Warehouse Database and Schemas

Purpose:
  This script initializes a new data warehouse environment by:
  1. Dropping the existing 'DataWarehouse' database if it exists
  2. Creating a new 'DataWarehouse' database
  3. Setting up three schemas for data pipeline organization

Details:
  - If 'DataWarehouse' exists, it forces all connections to close 
    (using SINGLE_USER mode with immediate rollback) before dropping it
  - Creates three schemas to support a typical ETL/ELT workflow:
    * staging: For raw, unprocessed data imports
    * cleaning: For data transformation and quality checks
    * business_intelligence: For final, analysis-ready tables and views

Note: This is a destructive operation that will permanently delete 
      any data in the database.
*/

USE master;
GO

-- drop and recreate the 'DataWarehouse' database
If EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
Begin
	ALTER DATABASE DataWarehouse SET SIGNLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

Use DataWarehouse;
GO

-- Schema creation
CREATE SCHEMA staging;
GO

CREATE SCHEMA cleaning;
GO

CREATE SCHEMA business_intelligence;
GO
