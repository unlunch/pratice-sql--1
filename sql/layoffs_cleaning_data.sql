-- Menampilkan seluruh data dari tabel layoffs
SELECT * FROM world_layoffs_2.layoffs l;

-- 1. Backup Dataset
-- Membuat tabel `layoffs_staging` sebagai salinan dari tabel `world_layoffs_2.layoffs`
-- untuk memastikan data asli tetap aman selama proses pembersihan dan transformasi data.
CREATE TABLE layoffs_staging LIKE world_layoffs_2.layoffs;
SELECT * FROM layoffs_staging ls;
INSERT INTO layoffs_staging SELECT * FROM world_layoffs_2.layoffs;

-- 2. Remove Duplicates
-- Menggunakan CTE (Common Table Expression) untuk mengidentifikasi data duplikat
-- berdasarkan kolom-kolom tertentu. Data duplikat ditandai dengan `row_num > 1`.
-- Selanjutnya, data duplikat dihapus dari tabel `layoffs_staging_2`.
WITH duplicate_table AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ls.company, ls.location, ls.industry, ls.total_laid_off, 
            ls.percentage_laid_off, ls.`date`, ls.stage, ls.funds_raised
        ) AS row_num
    FROM layoffs_staging ls
)
SELECT * FROM duplicate_table WHERE row_num > 1;

-- Menampilkan data spesifik berdasarkan perusahaan "Beyond Meat"
SELECT * FROM layoffs_staging ls WHERE company = "Beyond Meat";

-- Membuat tabel baru `layoffs_staging_2` dengan kolom tambahan `row_num`
CREATE TABLE `layoffs_staging_2` (
    `company` VARCHAR(50) DEFAULT NULL,
    `location` VARCHAR(50) DEFAULT NULL,
    `industry` VARCHAR(50) DEFAULT NULL,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` VARCHAR(50) DEFAULT NULL,
    `stage` VARCHAR(50) DEFAULT NULL,
    `country` VARCHAR(50) DEFAULT NULL,
    `funds_raised` INT DEFAULT NULL,
    `row_num` INT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Menampilkan data dari `layoffs_staging_2`
SELECT * FROM world_layoffs_2.layoffs_staging_2 ls;

-- Memasukkan data ke dalam `layoffs_staging_2` dan menambahkan row_num
INSERT INTO world_layoffs_2.layoffs_staging_2 
SELECT 
    *, 
    ROW_NUMBER() OVER (
        PARTITION BY ls.company, ls.location, ls.industry, ls.total_laid_off, 
        ls.percentage_laid_off, ls.`date`, ls.stage, ls.funds_raised
    ) AS row_num
FROM layoffs_staging ls;

-- Menghapus duplikasi berdasarkan row_num
DELETE FROM world_layoffs_2.layoffs_staging_2 ls WHERE ls.row_num > 1;

-- Mengecek apakah masih ada data duplikat
SELECT * FROM world_layoffs_2.layoffs_staging_2 ls WHERE ls.row_num > 1;

-- 3. Standardizing Data and Fix Errors
-- Membersihkan dan menstandarisasi data dalam tabel staging:
-- Menghapus spasi di awal dan akhir nama perusahaan menggunakan fungsi `TRIM()`
SELECT company, TRIM(ls.company) FROM world_layoffs_2.layoffs_staging_2 ls;
UPDATE world_layoffs_2.layoffs_staging_2 ls SET ls.company = TRIM(ls.company);

-- Menampilkan daftar industry yang unik
SELECT DISTINCT industry FROM world_layoffs_2.layoffs_staging_2 ORDER BY 1;

-- Mengecek apakah ada nilai industry yang kosong atau null
SELECT * FROM layoffs_staging_2 ls WHERE ls.industry = "" OR ls.industry IS NULL;

-- Menghapus data dengan industry kosong
DELETE FROM layoffs_staging_2 ls WHERE industry = "";

-- Menampilkan daftar perusahaan unik
SELECT DISTINCT company FROM layoffs_staging_2 ls ORDER BY company;

-- Menampilkan daftar negara unik
SELECT DISTINCT ls.country FROM layoffs_staging_2 ls ORDER BY country;

-- Melihat struktur tabel `layoffs_staging_2`
DESC layoffs_staging_2;

-- Mengubah tipe data kolom `date` dari VARCHAR menjadi DATE
ALTER TABLE layoffs_staging_2 MODIFY COLUMN `date` DATE;

-- Mengecek apakah ada nilai NULL dalam kolom company
SELECT * FROM layoffs_staging_2 ls WHERE ls.company IS NULL;

-- Mengecek apakah ada data dengan `total_laid_off` dan `percentage_laid_off` NULL
SELECT * FROM layoffs_staging_2 ls WHERE ls.total_laid_off IS NULL AND ls.percentage_laid_off IS NULL;

-- Mengekstrak tahun dari kolom `date`
SELECT YEAR(ls.`date`) FROM layoffs_staging_2 ls;

-- Menampilkan contoh data tanggal untuk validasi
SELECT `date` FROM world_layoffs_2.layoffs_staging_2 LIMIT 10;

-- Mengubah tipe data kolom `date` dari VARCHAR menjadi DATE pada tabel asli
ALTER TABLE world_layoffs_2.layoffs_staging_2 MODIFY COLUMN `date` DATE;

-- Menghapus data dengan `total_laid_off` dan `percentage_laid_off` NULL
DELETE FROM layoffs_staging_2 ls WHERE ls.total_laid_off IS NULL AND ls.percentage_laid_off IS NULL;

-- Menghapus kolom `row_num` yang digunakan untuk identifikasi duplikat
ALTER TABLE layoffs_staging_2 DROP COLUMN row_num;

-- Menampilkan seluruh data dari `layoffs_staging_2`
SELECT * FROM layoffs_staging_2 ls;
