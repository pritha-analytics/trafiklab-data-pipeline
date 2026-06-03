SELECT
    trip_id,
    stop_id,
    departure_time,
    stop_sequence,
    SPLIT_PART(departure_time, ':', 1)::INT AS departure_hour
FROM {{ source('bronze', 'RAW_STOP_TIMES') }}
WHERE trip_id IS NOT NULL