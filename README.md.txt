# Data Cleaning Project for Layoff Data

This project demonstrates a comprehensive data cleaning process on a dataset containing layoff information. The goal is to standardize, deduplicate, and correct inconsistencies within the data, using SQL commands to perform transformations and validations.

## Project Overview

The dataset includes layoff records from various companies with columns for company name, location, industry, and other relevant details. This project includes creating staging tables, identifying duplicates, and applying multiple transformations to clean and prepare the data for analysis.

### Key Objectives

- **Remove duplicates**: Identify and delete duplicate entries to ensure data accuracy.
- **Standardize formats**: Normalize data formats, such as date conversions and industry name standardization.
- **Correct inconsistencies**: Trim extra spaces, fix formatting issues, and handle missing values appropriately.

## Project Structure

1. **Create Staging Tables**: 
   - Create a staging table (`layoffs_staging`) that replicates the structure of the main layoffs table for initial data manipulation.
   - Verify the table structure and data.

2. **Copy Data and Add Row Number**:
   - Insert data from the original `layoffs` table into the `layoffs_staging` table.
   - Use SQL window functions to assign row numbers to duplicate records for easy identification.

3. **Identify and Remove Duplicates**:
   - Create a Common Table Expression (CTE) to partition data by specific columns and mark duplicates.
   - Copy data with row numbers into a second staging table (`layoffs_staging2`), then delete rows where duplicates are identified.

4. **Standardize and Clean Data**:
   - Trim spaces in text fields (e.g., `company`).
   - Standardize industry names that start with "Crypto" to ensure consistency.
   - Normalize country names by removing unnecessary periods.
   - Convert the `date` column from text to a proper `DATE` format.
   - Set empty `industry` fields to `NULL`.

5. **Fill Missing Values and Delete Unwanted Rows**:
   - Use self-joins to populate missing `industry` values based on matching company entries.
   - Delete specific records based on company name patterns or conditions (e.g., rows starting with "Bally").
   - Remove rows where both `total_laid_off` and `percentage_laid_off` are `NULL` to clean the data further.

## Prerequisites

To run the SQL code in this project, you'll need:
- A SQL database (e.g., MySQL, PostgreSQL) where you can create tables and perform queries.
- Basic SQL knowledge to understand and execute the commands.

## SQL Code

Each section of the code has been structured to perform specific cleaning operations. You can refer to the comments in the SQL code for a detailed understanding of each step. Here's a summary of the key operations:

```sql
-- Create a staging table for data manipulation
CREATE TABLE layoffs_staging LIKE layoffs;

-- Copy data and verify
INSERT INTO layoffs_staging SELECT * FROM layoffs;
SELECT * FROM layoffs_staging;

-- Add row numbers to identify duplicates
WITH duplicate_cte AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, ...) AS number_of_items
    FROM layoffs_staging
)
SELECT * FROM duplicate_cte WHERE number_of_items > 1;

-- Clean and standardize fields
UPDATE layoffs_staging2 SET company = TRIM(company);
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Delete unwanted rows
DELETE FROM layoffs_staging2 WHERE company LIKE 'Bally%';
DELETE FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
