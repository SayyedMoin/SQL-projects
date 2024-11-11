-- Data cleaning

-- Create a staging table with the same structure as the layoffs table
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Verify the structure of the new table
SELECT * FROM layoffs_staging;

-- Copy all data from the layoffs table to the staging table
INSERT layoffs_staging SELECT * FROM layoffs;

-- Verify the data has been copied correctly
SELECT * FROM layoffs_staging;

-- Add a row number to each record, partitioning by the specified columns to identify duplicates
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`,
 stage, country, funds_raised_millions) AS number_of_items FROM layoffs_staging;

-- Create a Common Table Expression (CTE) to select duplicates
WITH duplicate_cte AS (
    SELECT *, ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, 
    total_laid_off, percentage_laid_off, `date`,
    stage, country, funds_raised_millions) AS number_of_items FROM layoffs_staging
)
-- Select all records from the CTE where the row number is greater than 1 (i.e., duplicates)
SELECT *
FROM duplicate_cte
WHERE number_of_items > 1;

-- Create a second staging table with an additional column for the row number
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `number_of_items` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Verify the structure of the new table
SELECT * FROM layoffs_staging2;

-- Insert data into the second staging table with the row number added
INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, 
    total_laid_off, percentage_laid_off, `date`,
    stage, country, funds_raised_millions) AS number_of_items FROM layoffs_staging;

-- Verify the data has been inserted correctly
SELECT * FROM layoffs_staging2;

-- Delete duplicate records from the second staging table
DELETE FROM layoffs_staging2 WHERE number_of_items > 1;

-- Verify the final dataset
SELECT * FROM layoffs_staging2;

-- Trim leading and trailing spaces from the 'company' column
UPDATE layoffs_staging2 
SET company = TRIM(company);

-- Display all records from the 'layoffs_staging2' table
SELECT * FROM layoffs_staging2;

-- Display unique values in the 'industry' column, sorted alphabetically
SELECT DISTINCT(industry) FROM layoffs_staging2 ORDER BY 1;

-- Standardize the 'industry' names starting with 'Crypto' by setting them all to 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Display unique values in the 'country' column, sorted alphabetically
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;

-- Remove trailing periods from 'country' names that start with 'United States'
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Remove the column 'number_of_items' from the 'layoffs_staging2' table
ALTER TABLE layoffs_staging2
DROP COLUMN number_of_items;

-- Convert the text 'date' column to a datetime format and select the updated 'date' column
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') AS date
FROM layoffs_staging2;

-- Update the 'date' column with the converted datetime values
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify the 'date' column to have a DATE data type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Set 'industry' to NULL where the 'industry' column is empty
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Select records where 'industry' is either NULL or an empty string
SELECT * FROM layoffs_staging2 WHERE industry IS NULL OR industry = '';

-- Select records for specific companies
SELECT * 
FROM layoffs_staging2 
WHERE company = 'Airbnb' OR company = 'Bally''s Interactive' OR company = 'Carvana' OR company = 'Juul';

-- Join the table with itself to find rows where 'industry' is NULL or empty, and update 'industry' with values from matching rows
SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Update 'industry' values by copying from matching rows where 'industry' is not NULL
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;

-- Delete rows where the company name starts with 'Bally'
DELETE FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Select all rows from the 'layoffs_staging2' table to verify the deletion
SELECT * FROM layoffs_staging2;

-- Select all rows where the 'stage' column has the value 'Unknown', ordered by the first column
SELECT *
FROM layoffs_staging2
WHERE stage = 'Unknown'
ORDER BY 1;

-- Select rows where both 'total_laid_off' and 'percentage_laid_off' columns are NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Delete rows where both 'total_laid_off' and 'percentage_laid_off' columns are NULL
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Select all rows from the 'layoffs_staging2' table to verify the deletion
SELECT *
FROM layoffs_staging2;









