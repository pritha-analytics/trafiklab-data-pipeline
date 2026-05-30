SELECT
    route_id,
    route_short_name,
    route_long_name,
    CASE route_type
        WHEN 100 THEN 'Commuter Rail'
        WHEN 401 THEN 'Metro'
        WHEN 700 THEN 'Bus'
        WHEN 900 THEN 'Tram'
        WHEN 1000 THEN 'Ferry'
        ELSE 'Other'
    END AS transport_mode
FROM {{ source('bronze', 'RAW_ROUTES') }}
WHERE route_id IS NOT NULL