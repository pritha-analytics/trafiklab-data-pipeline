-- Create bronze tables for new files
CREATE TABLE IF NOT EXISTS TRAFIKLAB_DB.BRONZE.RAW_ROUTES (
    route_id        VARCHAR,
    agency_id       VARCHAR,
    route_short_name VARCHAR,
    route_long_name  VARCHAR,
    route_type      INT,
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS TRAFIKLAB_DB.BRONZE.RAW_TRIPS (
    route_id        VARCHAR,
    service_id      VARCHAR,
    trip_id         VARCHAR,
    trip_headsign   VARCHAR,
    direction_id    INT,
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS TRAFIKLAB_DB.BRONZE.RAW_STOP_TIMES (
    trip_id         VARCHAR,
    arrival_time    VARCHAR,
    departure_time  VARCHAR,
    stop_id         VARCHAR,
    stop_sequence   INT,
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
