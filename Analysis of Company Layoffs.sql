# EXPLORATORY ANALYSIS

Select *
from layoffs_staging2;

-- Maximum amount of layoofs and percentage wise
Select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- Companies that went bust
select *
from layoffs_staging2
where percentage_laid_off = 1;

-- Companies that have the most layoffs
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;  					 

-- Date of the data that was collected
SELECT min(date), max(date)
from layoffs_staging2;

-- Industries that laid off the most employees
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- Countries that laid off the most employees
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- Total laid off per year
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year (`date`)
order by 2 desc;

-- Total of employees laid off per month
select substring(`date`, 1, 7) as `Month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`;

with Rolling_total as 
(select substring(`date`, 1, 7) as `Month`, sum(total_laid_off) as TLO
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
)
select `Month`, TLO ,sum(TLO) over(order by `month`) as RT
from Rolling_total;

-- Year that individual companies laid off the most employees
select company, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, `date`
order by 3 desc;

-- Finding the top 5 companies with the most layoffs per year

with companyY (company, years, total_laid_off) as 
(select company, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, `date`
), 
companyR as
(
select *,  dense_rank () over(partition by years order by total_laid_off desc) as ranking
from companyY 
where years is not null
)
select *
from companyR
where ranking <= 5

