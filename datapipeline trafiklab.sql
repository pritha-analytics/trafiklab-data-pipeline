-- Create database
CREATE DATABASE TRAFIKLAB_DB;

-- Create medallion schemas
CREATE SCHEMA TRAFIKLAB_DB.BRONZE;
CREATE SCHEMA TRAFIKLAB_DB.SILVER;
CREATE SCHEMA TRAFIKLAB_DB.GOLD;

-- Create warehouse
CREATE WAREHOUSE TRAFIKLAB_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Create bronze raw stops table
CREATE TABLE TRAFIKLAB_DB.BRONZE.RAW_STOPS (
    stop_id     VARCHAR,
    stop_name   VARCHAR,
    stop_lat    FLOAT,
    stop_lon    FLOAT,
    stop_code   VARCHAR,
    loaded_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Create bronze raw departures table  
CREATE TABLE TRAFIKLAB_DB.BRONZE.RAW_DEPARTURES (
    trip_id         VARCHAR,
    route_id        VARCHAR,
    direction_id    INT,
    schedule_rel    VARCHAR,
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Create external stage pointing to your ADLS bronze container
CREATE OR REPLACE STAGE TRAFIKLAB_DB.BRONZE.ADLS_STAGE
  URL = 'azure://strafiklabpb.blob.core.windows.net/bronze/'
  CREDENTIALS = (AZURE_SAS_TOKEN = '<stored-in-key-vault>');
  -- Note: Store actual token in Azure Key Vault, retrieve at runtime


  
  LIST @TRAFIKLAB_DB.BRONZE.ADLS_STAGE;

  COPY INTO TRAFIKLAB_DB.BRONZE.RAW_STOPS (
    stop_id, stop_name, stop_lat, stop_lon, stop_code
)
FROM (
    SELECT 
        $1, $2, $3, $4, $5
    FROM @TRAFIKLAB_DB.BRONZE.ADLS_STAGE/stops/stops.txt
)
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


SELECT COUNT(*) FROM TRAFIKLAB_DB.BRONZE.RAW_STOPS;

SELECT * FROM TRAFIKLAB_DB.BRONZE.RAW_STOPS LIMIT 10;



SELECT COUNT(*) FROM TRAFIKLAB_DB.BRONZE.RAW_STOPS;

SELECT * FROM TRAFIKLAB_DB.SILVER.STG_STOPS LIMIT 10;


SELECT * FROM TRAFIKLAB_DB.GOLD.FCT_STOPS_SUMMARY LIMIT 10;
