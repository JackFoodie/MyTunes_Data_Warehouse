USE MyTunes_DWH;

-- Sales per artist
SELECT 
    dt.artist_name,
    SUM(fs.total_price) as total_sales
FROM fact_sales fs
JOIN dim_track dt ON fs.track_id = dt.track_id
GROUP BY dt.artist_name
ORDER BY total_sales DESC;

-- Sales per album
SELECT 
    dt.album_title,
    dt.artist_name,
    SUM(fs.total_price) as total_sales
FROM fact_sales fs
JOIN dim_track dt ON fs.track_id = dt.track_id
GROUP BY dt.album_title, dt.artist_name
ORDER BY total_sales DESC;

-- Sales per customer
SELECT 
    dc.first_name,
    dc.last_name,
    dc.country,
    SUM(fs.total_price) as total_spent
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.customer_id, dc.first_name, dc.last_name, dc.country
ORDER BY total_spent DESC;

-- Sales per billing country
SELECT 
    dc.country,
    SUM(fs.total_price) as total_sales
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.country
ORDER BY total_sales DESC;

-- Sales by day
SELECT 
    dt.full_date,
    SUM(fs.total_price) as daily_sales
FROM fact_sales fs
JOIN dim_time dt ON fs.time_id = dt.time_id
GROUP BY dt.full_date
ORDER BY dt.full_date;

-- Sales by month
SELECT 
    CONCAT(dt.year, '-', LPAD(dt.month, 2, '0')) as month,
    SUM(fs.total_price) as monthly_sales
FROM fact_sales fs
JOIN dim_time dt ON fs.time_id = dt.time_id
GROUP BY dt.year, dt.month
ORDER BY dt.year, dt.month;

-- Sales by quarter
SELECT 
    CONCAT(dt.year, ' Q', dt.quarter) as quarter,
    SUM(fs.total_price) as quarterly_sales
FROM fact_sales fs
JOIN dim_time dt ON fs.time_id = dt.time_id
GROUP BY dt.year, dt.quarter
ORDER BY dt.year, dt.quarter;

-- Sales by year
SELECT 
    dt.year,
    SUM(fs.total_price) as yearly_sales
FROM fact_sales fs
JOIN dim_time dt ON fs.time_id = dt.time_id
GROUP BY dt.year
ORDER BY dt.year;