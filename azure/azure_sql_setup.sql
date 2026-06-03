-- Azure SQL Database Staging Tables
-- Stockholm Transport Analytics Pipeline

CREATE TABLE stg_departures (
    trip_id         VARCHAR(50),
    route_id        VARCHAR(50),
    direction_id    INT,
    schedule_rel    VARCHAR(20),
    loaded_at       DATETIME DEFAULT GETDATE()
);

CREATE TABLE stg_stops (
    stop_id         VARCHAR(20),
    stop_name       NVARCHAR(200),
    stop_lat        FLOAT,
    stop_lon        FLOAT,
    stop_code       VARCHAR(20),
    loaded_at       DATETIME DEFAULT GETDATE()
);
