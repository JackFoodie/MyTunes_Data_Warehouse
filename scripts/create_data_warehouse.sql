-- Create the data warehouse database
CREATE DATABASE IF NOT EXISTS MyTunes_DWH;
USE MyTunes_DWH;

-- Time dimension table
CREATE TABLE dim_time (
    time_id INT NOT NULL AUTO_INCREMENT,
    day INT NOT NULL,
    month INT NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL,
    full_date DATE NOT NULL,
    CONSTRAINT PK_dim_time PRIMARY KEY (time_id)
);

-- Customer dimension table
CREATE TABLE dim_customer (
    customer_id INT NOT NULL,
    first_name NVARCHAR(40) NOT NULL,
    last_name NVARCHAR(20) NOT NULL,
    country NVARCHAR(40),
    email NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_dim_customer PRIMARY KEY (customer_id)
);

-- Track dimension table
CREATE TABLE dim_track (
    track_id INT NOT NULL,
    track_name NVARCHAR(200) NOT NULL,
    album_title NVARCHAR(160) NOT NULL,
    artist_name NVARCHAR(120) NOT NULL,
    genre_name NVARCHAR(120),
    unit_price NUMERIC(10,2) NOT NULL,
    CONSTRAINT PK_dim_track PRIMARY KEY (track_id)
);

-- Sales fact table
CREATE TABLE fact_sales (
    sales_id INT NOT NULL AUTO_INCREMENT,
    time_id INT NOT NULL,
    customer_id INT NOT NULL,
    track_id INT NOT NULL,
    quantity INT NOT NULL,
    total_price NUMERIC(10,2) NOT NULL,
    CONSTRAINT PK_fact_sales PRIMARY KEY (sales_id),
    CONSTRAINT FK_fact_sales_time FOREIGN KEY (time_id) REFERENCES dim_time (time_id),
    CONSTRAINT FK_fact_sales_customer FOREIGN KEY (customer_id) REFERENCES dim_customer (customer_id),
    CONSTRAINT FK_fact_sales_track FOREIGN KEY (track_id) REFERENCES dim_track (track_id)
);

-- Procedure to populate time dimension
DELIMITER //
CREATE PROCEDURE populate_dim_time()
BEGIN
    DECLARE start_date DATE;
    DECLARE end_date DATE;
    DECLARE curr_date DATE;
    
    -- Set date range (adjust as needed)
    SET start_date = '2009-01-01';  -- Earliest date in MyTunes
    SET end_date = '2025-12-31';    -- Future date for new records
    SET curr_date = start_date;
    
    -- Loop through dates and populate time dimension
    WHILE curr_date <= end_date DO
        INSERT INTO dim_time (day, month, quarter, year, full_date)
        VALUES (
            DAY(curr_date),
            MONTH(curr_date),
            QUARTER(curr_date),
            YEAR(curr_date),
            curr_date
        );
        SET curr_date = DATE_ADD(curr_date, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;

-- Procedure to populate dimension tables
DELIMITER //
CREATE PROCEDURE populate_dimensions()
BEGIN
    -- Populate customer dimension
    INSERT INTO dim_customer (customer_id, first_name, last_name, country, email)
    SELECT CustomerId, FirstName, LastName, Country, Email
    FROM MyTunes.Customer;
    
    -- Populate track dimension with artist and album info
    INSERT INTO dim_track (track_id, track_name, album_title, artist_name, genre_name, unit_price)
    SELECT t.TrackId, t.Name, a.Title, ar.Name, g.Name, t.UnitPrice
    FROM MyTunes.Track t
    JOIN MyTunes.Album a ON t.AlbumId = a.AlbumId
    JOIN MyTunes.Artist ar ON a.ArtistId = ar.ArtistId
    LEFT JOIN MyTunes.Genre g ON t.GenreId = g.GenreId;
END //
DELIMITER ;

-- Procedure to populate fact table
DELIMITER //
CREATE PROCEDURE populate_fact_sales()
BEGIN
    -- Populate fact table
    INSERT INTO fact_sales (time_id, customer_id, track_id, quantity, total_price)
    SELECT 
        dt.time_id,
        i.CustomerId,
        il.TrackId,
        il.Quantity,
        il.UnitPrice * il.Quantity
    FROM MyTunes.InvoiceLine il
    JOIN MyTunes.Invoice i ON il.InvoiceId = i.InvoiceId
    JOIN dim_time dt ON DATE(i.InvoiceDate) = dt.full_date;
END //
DELIMITER ;

-- Execute the procedures to populate the data warehouse
CALL populate_dim_time();
CALL populate_dimensions();
CALL populate_fact_sales();
