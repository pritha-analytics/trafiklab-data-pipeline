import os
import requests
import zipfile
import io
import snowflake.connector
from azure.storage.filedatalake import DataLakeServiceClient

TRAFIKLAB_KEY = os.environ["TRAFIKLAB_KEY"]
STORAGE_ACCOUNT = "strafiklabpb"
STORAGE_KEY = os.environ["ADLS_ACCOUNT_KEY"]
SNOWFLAKE_PASSWORD = os.environ["SNOWFLAKE_PASSWORD"]

GTFS_FILES = {
    "stops.txt":      "stops/stops.txt",
    "routes.txt":     "routes/routes.txt",
    "trips.txt":      "trips/trips.txt",
    "stop_times.txt": "stop_times/stop_times.txt",
}

# Download GTFS static zip from Trafiklab
print("Downloading GTFS data from Trafiklab...")
url = f"https://opendata.samtrafiken.se/gtfs/sl/sl.zip?key={TRAFIKLAB_KEY}"
response = requests.get(url, headers={"Accept": "application/zip"})
print(f"Status code: {response.status_code}")

zip_file = zipfile.ZipFile(io.BytesIO(response.content))

# Upload all GTFS files to ADLS bronze container
service_client = DataLakeServiceClient(
    account_url=f"https://{STORAGE_ACCOUNT}.dfs.core.windows.net",
    credential=STORAGE_KEY
)
file_system = service_client.get_file_system_client("bronze")

print("Uploading GTFS files to ADLS bronze...")
for gtfs_file, adls_path in GTFS_FILES.items():
    data = zip_file.read(gtfs_file)
    file_system.get_file_client(adls_path).upload_data(data, overwrite=True)
    print(f"  Uploaded {gtfs_file} ({len(data):,} bytes) -> bronze/{adls_path}")

# Load from ADLS into Snowflake BRONZE tables via COPY INTO
print("\nLoading data into Snowflake BRONZE tables...")
conn = snowflake.connector.connect(
    account="ESJZAWT-EP87416",
    user="pbanerjee1989",
    password=SNOWFLAKE_PASSWORD,
    warehouse="TRAFIKLAB_WH",
    database="TRAFIKLAB_DB",
    schema="BRONZE",
    role="ACCOUNTADMIN"
)
cur = conn.cursor()

copy_statements = [
    ("RAW_STOPS", """
        TRUNCATE TABLE TRAFIKLAB_DB.BRONZE.RAW_STOPS
    """),
    ("RAW_STOPS", """
        COPY INTO TRAFIKLAB_DB.BRONZE.RAW_STOPS (stop_id, stop_name, stop_lat, stop_lon)
        FROM (SELECT $1, $2, $3, $4 FROM @TRAFIKLAB_DB.BRONZE.ADLS_STAGE/stops/stops.txt)
        FILE_FORMAT = (TYPE='CSV' SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        FORCE = TRUE
    """),
    ("RAW_ROUTES", "TRUNCATE TABLE TRAFIKLAB_DB.BRONZE.RAW_ROUTES"),
    ("RAW_ROUTES", """
        COPY INTO TRAFIKLAB_DB.BRONZE.RAW_ROUTES (route_id, agency_id, route_short_name, route_long_name, route_type)
        FROM (SELECT $1,$2,$3,$4,$5 FROM @TRAFIKLAB_DB.BRONZE.ADLS_STAGE/routes/routes.txt)
        FILE_FORMAT = (TYPE='CSV' SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        FORCE = TRUE
    """),
    ("RAW_TRIPS", "TRUNCATE TABLE TRAFIKLAB_DB.BRONZE.RAW_TRIPS"),
    ("RAW_TRIPS", """
        COPY INTO TRAFIKLAB_DB.BRONZE.RAW_TRIPS (route_id, service_id, trip_id, trip_headsign, direction_id)
        FROM (SELECT $1,$2,$3,$4,$5 FROM @TRAFIKLAB_DB.BRONZE.ADLS_STAGE/trips/trips.txt)
        FILE_FORMAT = (TYPE='CSV' SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        FORCE = TRUE
    """),
    ("RAW_STOP_TIMES", "TRUNCATE TABLE TRAFIKLAB_DB.BRONZE.RAW_STOP_TIMES"),
    ("RAW_STOP_TIMES", """
        COPY INTO TRAFIKLAB_DB.BRONZE.RAW_STOP_TIMES (trip_id, arrival_time, departure_time, stop_id, stop_sequence)
        FROM (SELECT $1,$2,$3,$4,$5 FROM @TRAFIKLAB_DB.BRONZE.ADLS_STAGE/stop_times/stop_times.txt)
        FILE_FORMAT = (TYPE='CSV' SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        FORCE = TRUE
    """),
]

for table, sql in copy_statements:
    print(f"  Loading {table}...")
    cur.execute(sql)
    print(f"  {table} loaded.")

cur.close()
conn.close()
print("\nAll BRONZE tables updated successfully.")
