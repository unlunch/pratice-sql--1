-- Melihat seluruh data dari tabel layoffs_staging_2
SELECT *
FROM layoffs_staging_2 ls;

-- Mencari jumlah PHK terbesar dalam satu kejadian
SELECT MAX(ls.total_laid_off)
FROM layoffs_staging_2 ls;

-- Mencari 5 perusahaan dengan jumlah PHK terbesar yang memberhentikan seluruh karyawannya
SELECT *
FROM layoffs_staging_2 ls
WHERE ls.percentage_laid_off = 1
ORDER BY total_laid_off DESC
LIMIT 5;

-- Menghitung total PHK per perusahaan dan menampilkan 10 perusahaan dengan PHK tertinggi
SELECT 
    ls.company, 
    SUM(ls.total_laid_off) AS total_laid_off
FROM layoffs_staging_2 ls
GROUP BY ls.company 
ORDER BY 2 DESC
LIMIT 10;

-- Menghitung total PHK per industri dan menampilkan 10 industri dengan PHK tertinggi
SELECT 
    ls.industry, 
    SUM(ls.total_laid_off) AS total_laid_off
FROM layoffs_staging_2 ls
GROUP BY ls.industry 
ORDER BY 2 DESC
LIMIT 10;

-- Menghitung total PHK per negara dan menampilkan 10 negara dengan PHK tertinggi
SELECT 
    ls.country, 
    SUM(ls.total_laid_off) AS total_laid_off
FROM layoffs_staging_2 ls
GROUP BY ls.country
ORDER BY 2 DESC
LIMIT 10;

-- Menghitung total PHK per tahun
SELECT 
    YEAR(STR_TO_DATE(ls.date, '%Y-%m-%d')) AS year,
    SUM(ls.total_laid_off) AS total_laid_off
FROM world_layoffs_2.layoffs_staging_2 ls
GROUP BY year 
ORDER BY 1 DESC;

-- Menghitung total PHK per bulan
SELECT 
    SUBSTRING(ls.`date`, 1, 7) AS `month`,
    SUM(ls.total_laid_off) AS total_laid_off
FROM world_layoffs_2.layoffs_staging_2 ls
GROUP BY 1
ORDER BY 2 DESC;

-- Menghitung total PHK per perusahaan per tahun dan menampilkan 10 perusahaan dengan PHK tertinggi
SELECT 
    ls.company, 
    YEAR(STR_TO_DATE(ls.date, '%Y-%m-%d')) AS `Year`,
    SUM(ls.total_laid_off) AS total_laid_off
FROM world_layoffs_2.layoffs_staging_2 ls
GROUP BY ls.company, YEAR(STR_TO_DATE(ls.date, '%Y-%m-%d'))
ORDER BY 3 DESC
LIMIT 10;

-- Menentukan peringkat perusahaan dengan PHK tertinggi tiap tahun dan menampilkan 5 perusahaan teratas pada tahun 2023
WITH company_year AS (
    SELECT 
        ls.company, 
        YEAR(STR_TO_DATE(ls.date, '%Y-%m-%d')) AS years,
        SUM(ls.total_laid_off) AS total_laid_off
    FROM world_layoffs_2.layoffs_staging_2 ls
    GROUP BY ls.company, years
),
company_year_rank AS (
    SELECT 
        *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
    WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5 AND years = 2023;
