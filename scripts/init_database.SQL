/*
Script: Create Data Warehouse Database and Schemas

Purpose:
  This script initializes a new data warehouse environment by:
  1. Creating a new 'DataWarehouse' database if non existent
  2. Setting up three schemas for data pipeline organization

Details:
  - If 'DataWarehouse' doesnt exist makes 'DataWarehouse' database
  - Creates three schemas to support a typical ETL/ELT workflow:
    * staging: For raw, unprocessed data imports
    * cleaning: For data transformation and quality checks
    * business_intelligence: For final, analysis-ready tables and views
*/

USE master;
GO

-- Create the 'DataWarehouse' database
IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    CREATE DATABASE DataWarehouse;
END;
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
