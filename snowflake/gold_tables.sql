-- Gold table 1: Busiest stops
CREATE OR REPLACE TABLE TRAFIKLAB_DB.GOLD.FCT_BUSIEST_STOPS AS
SELECT
    s.stop_id,
    s.stop_name,
    s.stop_lat,
    s.stop_lon,
    COUNT(st.trip_id) AS total_departures
FROM TRAFIKLAB_DB.BRONZE.RAW_STOPS s
JOIN TRAFIKLAB_DB.BRONZE.RAW_STOP_TIMES st ON s.stop_id = st.stop_id
WHERE s.stop_id IS NOT NULL
AND s.stop_name IS NOT NULL
GROUP BY 1, 2, 3, 4
ORDER BY total_departures DESC;

-- Gold table 2: Departures by hour
CREATE OR REPLACE TABLE TRAFIKLAB_DB.GOLD.FCT_DEPARTURES_BY_HOUR AS
SELECT
    SPLIT_PART(departure_time, ':', 1)::INT AS departure_hour,
    COUNT(*) AS total_departures
FROM TRAFIKLAB_DB.BRONZE.RAW_STOP_TIMES
WHERE departure_time IS NOT NULL
AND SPLIT_PART(departure_time, ':', 1)::INT BETWEEN 0 AND 23
GROUP BY 1
ORDER BY 1;

-- Gold table 3: Routes by transport mode
CREATE OR REPLACE TABLE TRAFIKLAB_DB.GOLD.FCT_ROUTES_BY_MODE AS
SELECT
    CASE route_type
        WHEN 0 THEN 'Tram'
        WHEN 1 THEN 'Metro'
        WHEN 2 THEN 'Rail'
        WHEN 3 THEN 'Bus'
        WHEN 4 THEN 'Ferry'
        ELSE 'Other'
    END AS transport_mode,
    COUNT(DISTINCT route_id) AS total_routes,
    COUNT(DISTINCT route_short_name) AS unique_lines
FROM TRAFIKLAB_DB.BRONZE.RAW_ROUTES
GROUP BY 1
ORDER BY total_routes DESC;


SELECT COUNT(*) FROM TRAFIKLAB_DB.GOLD.FCT_BUSIEST_STOPS;
SELECT COUNT(*) FROM TRAFIKLAB_DB.GOLD.FCT_DEPARTURES_BY_HOUR;
SELECT COUNT(*) FROM TRAFIKLAB_DB.GOLD.FCT_ROUTES_BY_MODE;



SELECT DISTINCT route_type, COUNT(*) 
FROM TRAFIKLAB_DB.BRONZE.RAW_ROUTES 
GROUP BY route_type;


CREATE OR REPLACE TABLE TRAFIKLAB_DB.GOLD.FCT_ROUTES_BY_MODE AS
SELECT
    CASE route_type
        WHEN 100 THEN 'Commuter Rail'
        WHEN 401 THEN 'Metro'
        WHEN 700 THEN 'Bus'
        WHEN 900 THEN 'Tram'
        WHEN 1000 THEN 'Ferry'
        ELSE 'Other'
    END AS transport_mode,
    COUNT(DISTINCT route_id) AS total_routes,
    COUNT(DISTINCT route_short_name) AS unique_lines
FROM TRAFIKLAB_DB.BRONZE.RAW_ROUTES
GROUP BY 1
ORDER BY total_routes DESC;

SELECT * FROM TRAFIKLAB_DB.GOLD.FCT_ROUTES_BY_MODE;
