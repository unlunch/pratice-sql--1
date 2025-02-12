# **Layoffs Data Analysis**  

## 📌 Overview  
Proyek ini bertujuan untuk mengeksplorasi dan menganalisis data **PHK (layoffs)** dari berbagai perusahaan di berbagai industri. Dataset yang digunakan mencakup informasi seperti jumlah karyawan yang terkena PHK, persentase PHK, lokasi, industri, dan tahap perusahaan saat PHK terjadi.  

## 🎯 Objectives  
- **Data Cleaning:** Menghapus duplikat, memperbaiki format tanggal, dan menghapus data yang tidak relevan.  
- **Exploratory Data Analysis (EDA):** Melakukan analisis jumlah PHK berdasarkan perusahaan, industri, dan lokasi.  
- **Data Standardization:** Menghapus spasi berlebih, mengonversi tipe data, dan menyusun data agar lebih rapi.  
- **Tren & Insight:** Mengidentifikasi pola PHK berdasarkan tahun, bulan, perusahaan, industri, dan negara.  

## 📊 Dataset
Dataset yang digunakan berasal dari https://www.kaggle.com/datasets/swaptr/layoffs-2022, yang mencakup kolom berikut:  
- `company`: Nama perusahaan  
- `location`: Lokasi perusahaan  
- `industry`: Industri perusahaan  
- `total_laid_off`: Jumlah karyawan yang terkena PHK  
- `percentage_laid_off`: Persentase PHK  
- `date`: Tanggal kejadian PHK  
- `stage`: Tahap perusahaan (Startup, Growth, dll.)  
- `country`: Negara perusahaan  
- `funds_raised`: Jumlah dana yang telah dikumpulkan  

## 🛠️ Tools & Technologies  
- **Database:** MySQL  
- **Query Language:** SQL 

## 🔍 Steps Taken  
### 1️⃣ **Data Cleaning & Preprocessing**  
- Membuat backup dataset (`layoffs_staging`).  
- Menghapus duplikat menggunakan **CTE (Common Table Expression)**.  
- Menghapus data dengan nilai kosong atau tidak relevan.  
- Mengubah tipe data `date` dari **VARCHAR** ke **DATE**.  
- Menghapus kolom `row_num` setelah digunakan untuk deduplikasi.  

### 2️⃣ **Exploratory Data Analysis (EDA)**  
- Menganalisis jumlah PHK berdasarkan tahun dan bulan.  
- Mengidentifikasi perusahaan dengan jumlah PHK tertinggi setiap tahun.  
- Menganalisis PHK berdasarkan industri dan lokasi perusahaan.  
- Menghitung total PHK per negara untuk mengetahui wilayah dengan tingkat PHK tertinggi.  

### 3️⃣ **Query Highlights**  
Berikut beberapa query utama yang digunakan dalam analisis:  

- **Total PHK berdasarkan tahun**  
  ```sql
  SELECT 
      YEAR(STR_TO_DATE(date, '%Y-%m-%d')) AS year,
      SUM(total_laid_off) AS total_laid_off
  FROM world_layoffs_2.layoffs_staging_2
  GROUP BY year
  ORDER BY year DESC;
- **Top 10 perusahaan dengan PHK terbanyak**
    ```sql
    SELECT 
        company, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging_2
    GROUP BY company
    ORDER BY total_laid_off DESC
    LIMIT 10;
- **Top 5 perusahaan dengan PHK terbanyak di tahun 2023**
    ```sql
    WITH company_year AS (
    SELECT 
        company, 
        YEAR(STR_TO_DATE(date, '%Y-%m-%d')) AS years,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging_2
    GROUP BY company, years
    ),company_year_rank AS (
    SELECT *, 
           DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
    WHERE years IS NOT NULL)
    SELECT 
        * 
    FROM company_year_rank 
    WHERE ranking <= 5 AND years = 2023;
## 🚀 Results & Insights
- Tahun dengan PHK terbanyak pada 2023: `2023, PHK 264,185`
- Perusahaan dengan PHK terbanyak: `Amazon, 27,840`
- Industri yang paling terbanyak PHK: `Consumer, 74,646`
- Negara dengan tingkat PHK tertinggi: `United States, 460,131`

## 📌 Future Improvements
- Menganalisis dampak ekonomi dari PHK pada industri tertentu.
- Memprediksi tren PHK di masa depan berdasarkan data historis.
- Menggunakan visualisasi data untuk mendapatkan insight lebih dalam.
#
