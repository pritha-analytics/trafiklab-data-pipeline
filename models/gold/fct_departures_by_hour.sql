SELECT
    departure_hour,
    COUNT(*) AS total_departures
FROM {{ ref('stg_stop_times') }}
WHERE departure_hour BETWEEN 0 AND 23
GROUP BY 1
ORDER BY 1