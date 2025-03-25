USE MyTunes_DWH;

-- Procedure to update the data warehouse
DELIMITER //
CREATE PROCEDURE update_data_warehouse()
BEGIN
    -- Update customer dimension with any changes
    UPDATE dim_customer dc
    JOIN MyTunes.Customer c ON dc.customer_id = c.CustomerId
    SET 
        dc.first_name = c.FirstName,
        dc.last_name = c.LastName,
        dc.country = c.Country,
        dc.email = c.Email
    WHERE 
        dc.first_name != c.FirstName OR
        dc.last_name != c.LastName OR
        dc.country != c.Country OR
        dc.email != c.Email;
    
    -- Insert new customers
    INSERT INTO dim_customer (customer_id, first_name, last_name, country, email)
    SELECT c.CustomerId, c.FirstName, c.LastName, c.Country, c.Email
    FROM MyTunes.Customer c
    LEFT JOIN dim_customer dc ON c.CustomerId = dc.customer_id
    WHERE dc.customer_id IS NULL;
    
    -- Update track dimension with any changes
    UPDATE dim_track dt
    JOIN MyTunes.Track t ON dt.track_id = t.TrackId
    JOIN MyTunes.Album a ON t.AlbumId = a.AlbumId
    JOIN MyTunes.Artist ar ON a.ArtistId = ar.ArtistId
    LEFT JOIN MyTunes.Genre g ON t.GenreId = g.GenreId
    SET 
        dt.track_name = t.Name,
        dt.album_title = a.Title,
        dt.artist_name = ar.Name,
        dt.genre_name = g.Name,
        dt.unit_price = t.UnitPrice
    WHERE 
        dt.track_name != t.Name OR
        dt.album_title != a.Title OR
        dt.artist_name != ar.Name OR
        dt.genre_name != g.Name OR
        dt.unit_price != t.UnitPrice;
    
    -- Insert new tracks
    INSERT INTO dim_track (track_id, track_name, album_title, artist_name, genre_name, unit_price)
    SELECT t.TrackId, t.Name, a.Title, ar.Name, g.Name, t.UnitPrice
    FROM MyTunes.Track t
    JOIN MyTunes.Album a ON t.AlbumId = a.AlbumId
    JOIN MyTunes.Artist ar ON a.ArtistId = ar.ArtistId
    LEFT JOIN MyTunes.Genre g ON t.GenreId = g.GenreId
    LEFT JOIN dim_track dt ON t.TrackId = dt.track_id
    WHERE dt.track_id IS NULL;
    
    -- Insert new sales
    INSERT INTO fact_sales (time_id, customer_id, track_id, quantity, total_price)
    SELECT 
        dt.time_id,
        i.CustomerId,
        il.TrackId,
        il.Quantity,
        il.UnitPrice * il.Quantity
    FROM MyTunes.InvoiceLine il
    JOIN MyTunes.Invoice i ON il.InvoiceId = i.InvoiceId
    JOIN dim_time dt ON DATE(i.InvoiceDate) = dt.full_date
    LEFT JOIN fact_sales fs ON 
        fs.customer_id = i.CustomerId AND
        fs.track_id = il.TrackId AND
        fs.time_id = dt.time_id AND
        fs.quantity = il.Quantity
    WHERE fs.sales_id IS NULL;
END //
DELIMITER ;
