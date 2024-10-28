# Data-Cleaning-By-SQL

# Layoffs Data Cleaning Project
Overview
This project provides a structured approach to cleaning and standardizing a dataset containing information on company layoffs. The main goal is to prepare clean, reliable data by removing duplicates, standardizing fields, handling null and blank values, and ensuring consistent data types. This process is essential for producing insights and facilitating further analysis.

# Step 1: Create Staging Table
To protect the original dataset, a staging table layoffs_staging is created as a duplicate of the layoffs table. This allows safe data cleaning and experimentation without risking changes to the raw data.

# Step 2: Remove Duplicates
Identifies and removes duplicate entries based on key fields (e.g., company, location, industry, etc.) using the ROW_NUMBER() window function. Entries with a row_num greater than 1 are classified as duplicates.

# Step 3: Standardize Data
Standardization focuses on text fields, trimming excess whitespace and ensuring consistency across entries. The following transformations are applied:

Company Names: Removes leading and trailing whitespace.
Industry Field: Standardizes industry names by grouping similar terms under one label (e.g., consolidating all "Crypto" related terms).
Country Field: Removes extraneous characters and ensures uniform naming conventions.
Date Conversion: Converts the date field from text to a DATE data type.

# Step 4: Handle Null and Blank Values
Addresses missing data by either imputing based on available values or removing non-informative records:

Industry: Fills blank entries by matching companies with known industry data.
Critical Fields: Deletes rows where both total_laid_off and percentage_laid_off are null, as they lack meaningful information for analysis.

# Step 5: Finalize Cleaned Data
Removes temporary columns, such as row_num, used during cleaning.

