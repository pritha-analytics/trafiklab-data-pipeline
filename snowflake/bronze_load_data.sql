-- Load routes
COPY INTO TRAFIKLAB_DB.BRONZE.RAW_ROUTES (
    route_id, agency_id, route_short_name, route_long_name, route_type
)
FROM (
    SELECT $1, $2, $3, $4, $5
    FROM @TRAFIKLAB_DB.BRONZE.ADLS_STAGE/routes/routes.txt
)
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);

-- Load trips
COPY INTO TRAFIKLAB_DB.BRONZE.RAW_TRIPS (
    route_id, service_id, trip_id, trip_headsign, direction_id
)
FROM (
    SELECT $1, $2, $3, $4, $5
    FROM @TRAFIKLAB_DB.BRONZE.ADLS_STAGE/trips/trips.txt
)
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);

-- Load stop_times (large file - may take 2-3 minutes)
COPY INTO TRAFIKLAB_DB.BRONZE.RAW_STOP_TIMES (
    trip_id, arrival_time, departure_time, stop_id, stop_sequence
)
FROM (
    SELECT $1, $2, $3, $4, $5
    FROM @TRAFIKLAB_DB.BRONZE.ADLS_STAGE/stop_times/stop_times.txt
)
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


SELECT COUNT(*) FROM TRAFIKLAB_DB.BRONZE.RAW_ROUTES;
SELECT COUNT(*) FROM TRAFIKLAB_DB.BRONZE.RAW_TRIPS;
SELECT COUNT(*) FROM TRAFIKLAB_DB.BRONZE.RAW_STOP_TIMES;
