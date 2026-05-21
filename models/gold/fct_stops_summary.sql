SELECT
    REGEXP_SUBSTR(stop_id, '^[0-9]+') AS region_code,
    COUNT(*) AS total_stops,
    AVG(stop_lat) AS avg_latitude,
    AVG(stop_lon) AS avg_longitude,
    MIN(loaded_at) AS first_loaded
FROM {{ ref('stg_stops') }}
GROUP BY 1
ORDER BY 2 DESC