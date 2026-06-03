SELECT
    transport_mode,
    COUNT(DISTINCT route_id) AS total_routes
FROM {{ ref('stg_routes') }}
GROUP BY transport_mode