
SELECT
    s.stop_id,
    s.stop_name,
    s.stop_lat,
    s.stop_lon,
    COUNT(st.trip_id) AS total_departures
FROM {{ ref('stg_stops') }} s
JOIN {{ ref('stg_stop_times') }} st
ON s.stop_id = st.stop_id
GROUP BY 1, 2, 3, 4
ORDER BY total_departures DESC