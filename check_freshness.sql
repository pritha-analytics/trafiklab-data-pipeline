-- Check when each table was last updated in Snowflake
SELECT
    table_schema,
    table_name,
    last_altered AS last_updated,
    row_count,
    DATEDIFF(hour, last_altered, CURRENT_TIMESTAMP()) AS hours_since_update
FROM TRAFIKLAB_DB.information_schema.tables
WHERE table_schema IN ('BRONZE', 'BRONZE_SILVER', 'BRONZE_GOLD')
ORDER BY table_schema, table_name;
