select *
from layoffs;

-- Data Cleaning

-- step 1 remove duplicates 
-- step 2 standardize data
-- step 3 finding null values or blanks
-- step 4 remove any unnecessary columns  

-- 
# STAGING

create table layoffs_staging1
like layoffs ;

select * 
from layoffs_staging1;

insert into layoffs_staging1
select * from layoffs;

-- 
# ASSINGNING ROW NUMBERS

select *,
row_number () over (
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging1 ;

--
# FINDING DUPLICATES USING CTE'S

with duplicate_cte as 
(select *,
row_number () over (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging1 
)
select*
from duplicate_cte
where row_num > 1;

-- 
#FINDING SPECIFIC DUPLICATES

Select *
from layoffs_staging1
where company = 'casper';

--

with duplicate_cte as 
(select *,
row_number () over (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging1 
)
Delete
from duplicate_cte
where row_num > 1;

# Create staging 2 to Delete unwanted duplicates

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
  `row_num` int                                              # ADD ROW NUM TO NEW TABLE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *,
row_number () over (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging1;

delete
from layoffs_staging2
where row_num > 1;

select * 
from layoffs_staging2
where row_num > 1;

# DELETE THE DUPLICATES 

-- STANDARDIZING THE DATA

SELECT *
FROM layoffs_staging2;

# TRIM AND UPDATE

select distinct trim(company)
from layoffs_staging2;

select company, trim(company)
from layoffs_staging2;

UPDATE layoffs_staging2
set company = trim(company);

# GROUPING LIKE INDUSTRIES INTO ONE

SELECT *
FROM layoffs_staging2;

select distinct industry
from layoffs_staging2
order by 1 ;

SELECT *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

select distinct country   #UPDATING BY COUNTRY
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = 'United States'
where country like 'United States.';

-- FIXING DATES FOR TIME SERIES 
select date
from layoffs_staging2;

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set date = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;
 

-- FIXING NULL VALUES 

update industry
set industry = null
where industry = '';

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null
or industry = '';

# Populating Null values that have like values 
Select *
from layoffs_staging2
where company = 'airbnb';

select i1.industry, i2.industry
from layoffs_staging2 i1
join layoffs_staging2 i2
	on i1.company = i2.company
where i1.industry is null or i1.industry = ''
and i2.industry is not null;

-- Update the data

update layoffs_staging2 i1
join layoffs_staging2 i2
	on i1.company = i2.company
set i1.industry = i2.industry
where i1.industry is null or i1.industry = ''
and i2.industry is not null;

select*
from layoffs_staging2
where industry is null or industry = '';
               