import requests
import zipfile
import io
from azure.storage.filedatalake import DataLakeServiceClient

# Credentials stored in Azure Key Vault
TRAFIKLAB_KEY = "<trafiklab-static-key>"
STORAGE_ACCOUNT = "strafiklabpb"
STORAGE_KEY = "<adls-connection-string>"

# Download GTFS static zip from Trafiklab
print("Downloading GTFS data from Trafiklab...")
url = f"https://opendata.samtrafiken.se/gtfs/sl/sl.zip?key={TRAFIKLAB_KEY}"
headers = {"Accept": "application/zip"}
response = requests.get(url, headers=headers)
print(f"Status code: {response.status_code}")

# Extract stops.txt from zip
zip_file = zipfile.ZipFile(io.BytesIO(response.content))
stops_data = zip_file.read("stops.txt")
print(f"stops.txt extracted: {len(stops_data)} bytes")

# Upload to ADLS bronze container
print("Uploading to ADLS bronze...")
service_client = DataLakeServiceClient(
    account_url=f"https://{STORAGE_ACCOUNT}.dfs.core.windows.net",
    credential=STORAGE_KEY
)
file_system = service_client.get_file_system_client("bronze")
file_client = file_system.get_file_client("stops/stops.txt")
file_client.upload_data(stops_data, overwrite=True)
print("Upload successful! stops.txt is now in bronze/stops/")