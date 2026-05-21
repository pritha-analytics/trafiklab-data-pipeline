import asyncio, requests
from azure.eventhub.aio import EventHubProducerClient
from azure.eventhub import EventData

# Credentials stored in Azure Key Vault
CONN_STR = "<eventhub-connection-string>"
TRAFIKLAB_KEY = "<trafiklab-realtime-key>"

CHUNK_SIZE = 200000  # 200KB chunks, safely under 256KB limit

async def send_departures():
    producer = EventHubProducerClient.from_connection_string(
        CONN_STR, eventhub_name="eh-departures"
    )
    async with producer:
        for i in range(3):
            url = f"https://opendata.samtrafiken.se/gtfs-rt/sl/TripUpdates.pb?key={TRAFIKLAB_KEY}"
            headers = {"Accept": "application/x-protobuf"}
            response = requests.get(url, headers=headers)
            data = response.content
            print(f"Round {i+1}: downloaded {len(data)} bytes")

            # Split into chunks and send
            chunks = [data[j:j+CHUNK_SIZE] for j in range(0, len(data), CHUNK_SIZE)]
            for k, chunk in enumerate(chunks):
                batch = await producer.create_batch()
                batch.add(EventData(chunk))
                await producer.send_batch(batch)
                print(f"  Sent chunk {k+1}/{len(chunks)}")

            print(f"Round {i+1} complete!")
            await asyncio.sleep(10)

asyncio.run(send_departures())