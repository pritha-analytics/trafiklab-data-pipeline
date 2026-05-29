SELECT
    stop_id,
    stop_name,
    stop_lat,
    stop_lon,
    stop_code
FROM {{ source('bronze', 'RAW_STOPS') }}
WHERE stop_id IS NOT NULL
AND stop_name IS NOT NULL