-- Data Cleaning Project - Layoffs Data

-- Display original data from layoffs table
SELECT * 
FROM layoffs;

-- Steps for Data Cleaning:
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Handle Null or Blank Values
-- 4. Remove Unnecessary Columns

-- Create a staging table to work on a copy of the raw data
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Insert data into staging table from the original layoffs table
INSERT layoffs_staging 
SELECT * 
FROM layoffs;

-- Check data in the staging table
SELECT * 
FROM layoffs_staging;

-- Step 1: Remove Duplicates

-- Identify duplicates by using ROW_NUMBER() to mark duplicates based on key fields
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Use CTE to label duplicates with row numbers
WITH duplicate_cte AS 
(
    SELECT *, 
    ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
-- Select rows marked as duplicates (row_num > 1)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- Check duplicates after using CTE
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- Create a new table `layoffs_staging2` with a row_num column to store deduplicated data
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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert data into `layoffs_staging2` with row numbers to track duplicates
INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Check data in `layoffs_staging2` table
SELECT * 
FROM layoffs_staging2;

-- Filter rows in `layoffs_staging2` marked as duplicates (row_num > 1)
SELECT * 
FROM layoffs_staging2 
WHERE row_num > 1;

-- Temporarily disable SQL_SAFE_UPDATES to allow deletion
SET SQL_SAFE_UPDATES = 0;

-- Delete duplicate rows where row_num > 1 in `layoffs_staging2`
DELETE
FROM layoffs_staging2 
WHERE row_num > 1;

-- Verify deletion of duplicates
SELECT * 
FROM layoffs_staging2 
WHERE row_num > 1;

-- View all data after deduplication
SELECT * 
FROM layoffs_staging2;

-- Step 2: Standardize the Data

-- Trim excess whitespace from `company` names
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Update `company` column with trimmed values
UPDATE layoffs_staging2
SET company = TRIM(company);

-- View unique values in `industry` column for standardization
SELECT DISTINCT industry 
FROM layoffs_staging2 
ORDER BY 1;

-- Select records with `industry` values related to "Crypto"
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Standardize "Crypto" industry values
UPDATE layoffs_staging2 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Confirm standardization of "Crypto" industry
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Standardize `country` values, removing trailing periods
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) 
FROM layoffs_staging2
ORDER BY 1;

-- Update `country` values for consistency
UPDATE layoffs_staging2 
SET country = TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'United States%';

-- Check unique standardized `country` values
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Convert `date` column from text to date format
SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Update `date` column to actual date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Verify `date` values post-conversion
SELECT `date` 
FROM layoffs_staging2;

-- Modify `date` column data type from text to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 3: Handle Null or Blank Values

-- Identify rows with NULL or blank values in `industry`
SELECT *
FROM layoffs_staging2 
WHERE industry IS NULL 
OR industry = "";

-- Check `industry` values for specific company (e.g., Airbnb)
SELECT *
FROM layoffs_staging2
WHERE company = "Airbnb";

-- Find corresponding industry values for missing data in `industry`
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '')  
AND t2.industry IS NOT NULL;

-- Convert blank `industry` values to NULL for easier updates
UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

-- Update missing `industry` values by matching `company` names
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL   
AND t2.industry IS NOT NULL;

-- Verify that blanks and NULLs are updated in `industry`
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '')  
AND t2.industry IS NOT NULL;

-- Confirm update for specific company (e.g., Airbnb)
SELECT *
FROM layoffs_staging2
WHERE company = "Airbnb";

-- Identify records where both `total_laid_off` and `percentage_laid_off` are NULL
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Delete rows with both `total_laid_off` and `percentage_laid_off` as NULL
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Step 4: Remove Unnecessary Columns

-- Remove the `row_num` column to finalize the cleaned data in `layoffs_staging2`
ALTER TABLE layoffs_staging2 
DROP COLUMN row_num;

-- Final view of cleaned data
SELECT * 
FROM layoffs_staging2;
