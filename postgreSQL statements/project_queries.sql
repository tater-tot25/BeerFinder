-- For easy rewriting, drop all functions before running
DROP FUNCTION IF EXISTS getNearestDistributors(VARCHAR(50), INT);
DROP FUNCTION IF EXISTS getTopDistributorsByBeerType(VARCHAR(50), INT);
DROP FUNCTION IF EXISTS getDistributorsWhoSellBeerFrom(CHAR(2), INT);
DROP FUNCTION IF EXISTS getDistributorWithMostLocalBeers(VARCHAR(50), INT);
DROP FUNCTION IF EXISTS getBestRatedBeerFromDistributor(VARCHAR(50), INT);
DROP FUNCTION IF EXISTS getBestRatedBeerFromDistributor(VARCHAR(50), INT);
DROP FUNCTION IF EXISTS getDistributorFromSameStateWithBestVariety(VARCHAR(50), INT);
-- function to get the nearest distributors ordered by distance. WORKS
CREATE OR REPLACE FUNCTION getNearestDistributors(sellerName VARCHAR(50), numOfResults INT)
RETURNS TABLE (
    distributor_ID INT,
    name VARCHAR(50),
    distance_in_km FLOAT,
    city VARCHAR(50),
    state VARCHAR(50)
)
LANGUAGE SQL
AS $$
    WITH seller_location AS (
        SELECT l.location_ID, l.lat AS seller_lat, l.long AS seller_long
        FROM Seller s
        JOIN Location l ON s.location_ID = l.location_ID
        WHERE s.name = sellerName
    ),
    distributor_distances AS (
        SELECT d.distributor_ID, d.name, l.lat AS dist_lat, l.long AS dist_long,
            6371 * 2 * ASIN(SQRT(
                POWER(SIN(RADIANS(seller_lat - l.lat) / 2), 2) +
                COS(RADIANS(seller_lat)) * COS(RADIANS(l.lat)) *
                POWER(SIN(RADIANS(seller_long - l.long) / 2), 2)
            )) AS distance_in_km, l.state AS state, l.city AS city,
            seller_lat, seller_long
        FROM Distributor d
        JOIN Location l ON d.location_ID = l.location_ID
        CROSS JOIN seller_location
    )
    SELECT distributor_ID, name, distance_in_km, city, state
    FROM distributor_distances
    ORDER BY distance_in_km
    LIMIT numOfResults;
$$;
-- Function to get the top distributors of a given beer type ordered by number of beers of the type. WORKS
CREATE OR REPLACE FUNCTION getTopDistributorsByBeerType(beerTypeColumnName VARCHAR(50), numOfRows INT)
RETURNS TABLE (
    distributor_ID INT,
    name VARCHAR(50),
    beer_count BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
    'SELECT d.distributor_ID, d.name, COUNT(*) AS beer_count
     FROM Distributor d
     JOIN Distributes dis ON d.distributor_ID = dis.distributor_ID
     JOIN Beer b ON dis.beer_ID = b.beer_ID
     JOIN BeerType bt ON b.type_ID = bt.type_ID
     WHERE bt.' || quote_ident(beerTypeColumnName) || ' = true
     GROUP BY d.distributor_ID, d.name
     ORDER BY beer_count DESC
     LIMIT ' || quote_literal(numOfRows) || ';';
END;
$$;
-- Function to get the distributors who sell the most beers from a given state. WORKS
CREATE OR REPLACE FUNCTION getDistributorsWhoSellBeerFrom(state CHAR(2), numOfResults INT)
RETURNS TABLE (
    distributor_ID INT,
    name VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    state CHAR(2),
    zipcode INT,
    numOfBeersFromState INT
)
LANGUAGE SQL
AS $$
SELECT d.distributor_ID, d.name, bl.address, bl.city, bl.state, bl.zipCode, COUNT(DISTINCT b.beer_id) AS numOfBeersFromState
FROM Distributor d
JOIN Distributes dis ON d.distributor_ID = dis.distributor_ID
JOIN Beer b ON dis.beer_ID = b.beer_ID
JOIN Brewery br ON b.brewery_ID = br.brewery_ID
JOIN location l ON br.location_ID = l.location_ID
JOIN location bl ON d.location_ID = bl.location_ID
WHERE l.state = $1
GROUP BY d.distributor_ID, d.name, bl.address, bl.city, bl.state, bl.zipCode
ORDER BY numOfBeersFromState DESC
LIMIT numOfResults;
$$;
-- Get the distributors that sells the highest percentage of local beers based on the seller's state
-- with a numOfResults parameter to limit results. WORKS
CREATE OR REPLACE FUNCTION getDistributorWithMostLocalBeers(sellerName VARCHAR(50), numOfResults INT)
RETURNS TABLE (
    distributor_name VARCHAR(50),
    local_beers_count INT,
    toal_stock INT,
    local_beer_percentage FLOAT
)
LANGUAGE SQL
AS $$
    WITH SellerState AS (
        SELECT 
            s.location_ID,
            LEFT(l.state, 2) AS seller_state
        FROM Seller s
        JOIN location l ON s.location_ID = l.location_ID
        WHERE s.name = sellerName
    ),
    DistributorBeers AS (
        SELECT 
            d.distributor_ID,
            COUNT(b.beer_ID) AS local_beers_count
        FROM Beer b
        JOIN Distributes dis ON b.beer_ID = dis.beer_ID
        JOIN Distributor d ON dis.distributor_ID = d.distributor_ID
        JOIN Brewery br ON b.brewery_ID = br.brewery_ID
        JOIN location l ON br.location_ID = l.location_ID
        JOIN SellerState ss ON LEFT(l.state, 2) = ss.seller_state
        GROUP BY d.distributor_ID
    ),
    TotalStock AS (
        SELECT 
            distributor_ID,
            COUNT(beer_ID) AS total_stock
        FROM Distributes
        GROUP BY distributor_ID
    )
    SELECT 
        d.name AS distributor_name,
        COALESCE(db.local_beers_count, 0) AS local_beers_count,
        COALESCE(ts.total_stock, 0) AS total_stock,
        CASE 
            WHEN ts.total_stock = 0 THEN 0
            ELSE ROUND(COALESCE(db.local_beers_count * 100.0 / ts.total_stock, 0), 2)
        END AS local_beer_percentage
    FROM Distributor d
    LEFT JOIN DistributorBeers db ON d.distributor_ID = db.distributor_ID
    LEFT JOIN TotalStock ts ON d.distributor_ID = ts.distributor_ID
    ORDER BY local_beer_percentage DESC NULLS LAST
    LIMIT numOfResults;
$$;
-- Query to get the best rated beer from a given distributor with a numOfResults paremeter to limit results
CREATE OR REPLACE FUNCTION getBestRatedBeerFromDistributor(distributorName VARCHAR(50), numOfResults INT)
RETURNS TABLE (
    beer_id INT,
    beer_name VARCHAR(50),
    rating CHAR(1),
    beer_description VARCHAR(500)
)
LANGUAGE SQL
AS $$
  SELECT DISTINCT b.beer_id, b.name, b.rating, b.description
  FROM distributor d
  JOIN distributes dis on dis.distributor_id = d.distributor_id
  JOIN beer b on b.beer_id = dis.beer_id
  WHERE d.name = distributorName
  ORDER BY b.rating, b.beer_id
  LIMIT numOfResults;
$$;
-- Get the distributor who sells X beer for the cheapest, with numOfResults parameter to limit results
CREATE OR REPLACE FUNCTION whichDistributorSellXBeerForCheapest(beerName VARCHAR(50), numOfResults INT)
RETURNS TABLE (
    distributor_id INT,
    distributor_name VARCHAR(50),
    price_per_ounce FLOAT
)
LANGUAGE SQL
AS $$
  SELECT DISTINCT d.distributor_id, d.name, dis.price
  FROM distributor d
  JOIN distributes dis ON dis.distributor_id = d.distributor_id
  JOIN beer b ON b.beer_id = dis.beer_id
  WHERE b.name = beerName
  ORDER BY dis.price
  LIMIT numOfResults;
$$;
-- Return the distributors who sell the largest variety of beer in the same state as a given seller, with limiting results
CREATE OR REPLACE FUNCTION getDistributorFromSameStateWithBestVariety(seller_name VARCHAR(50), numOfResults INT)
RETURNS TABLE (
    distributor_name VARCHAR(50),
    distributor_address VARCHAR(100),
    distributor_city VARCHAR(50),
    distributor_state CHAR(2),
    variety_count INT
)
LANGUAGE SQL 
AS $$
    SELECT 
        d.name AS distributor_name,
        dist_loc.address AS distributor_address,
        dist_loc.city AS distributor_city,
        dist_loc.state AS distributor_state,
        COUNT(DISTINCT CONCAT(
            AmericanAle::TEXT, 
            pilsner::TEXT, 
            bock::TEXT, 
            dunkel::TEXT, 
            blondAle::TEXT, 
            belgianTripel::TEXT, 
            bitter::TEXT, 
            barleyWine::TEXT, 
            irishRed::TEXT, 
            caskAle::TEXT, 
            indianPaleAle::TEXT, 
            hazy::TEXT, 
            sour::TEXT, 
            irishDryStout::TEXT, 
            stout::TEXT, 
            porter::TEXT
        )) AS variety_count
    FROM Distributor d
    JOIN Distributes dis ON d.distributor_ID = dis.distributor_ID
    JOIN Beer b ON dis.beer_ID = b.beer_ID
    JOIN BeerType bt ON b.type_ID = bt.type_ID
    JOIN Seller s ON s.name = seller_name
    JOIN Location seller_loc ON s.location_id = seller_loc.location_id
    JOIN Location dist_loc ON d.location_id = dist_loc.location_id
    WHERE dist_loc.state = seller_loc.state
    GROUP BY d.name, dist_loc.address, dist_loc.city, dist_loc.state
    ORDER BY variety_count DESC
    LIMIT numOfResults;
$$;