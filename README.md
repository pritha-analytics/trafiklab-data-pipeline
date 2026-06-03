# Trafiklab Data Pipeline

An end-to-end data pipeline that fetches public transport data from Trafiklab (Sweden), loads it into Azure Data Lake Storage, transforms it in Snowflake using dbt, and visualises it in Power BI.

---

## Architecture

```
Trafiklab API (GTFS)
       |
       v
upload_stops.py
       |
       v
Azure Data Lake Storage (Bronze layer)
       |
       v
Snowflake (TRAFIKLAB_DB)
  BRONZE schema  →  dbt silver models  →  dbt gold models
                     (views)               (tables)
       |
       v
Power BI Dashboard
```

---

## Project Structure

```
trafiklab-repo/
├── upload_stops.py          # Fetches GTFS zip from Trafiklab, uploads stops.txt to ADLS
├── run_pipeline.ps1         # Runs full pipeline: upload + dbt (scheduled daily at 6am)
├── dbt_project.yml          # dbt project config
├── models/
│   ├── silver/
│   │   ├── stg_stops.sql        # Staged stops data
│   │   ├── stg_routes.sql       # Staged routes data
│   │   ├── stg_stop_times.sql   # Staged stop times data
│   │   └── sources.yml          # Source definitions (BRONZE schema)
│   └── gold/
│       ├── fct_busiest_stops.sql        # Top stops ranked by total departures
│       ├── fct_departures_by_hour.sql   # Departures grouped by hour of day
│       ├── fct_routes_by_mode.sql       # Routes grouped by transport mode
│       └── schema.yml                   # Model docs and tests
├── .env.example             # Template for required credentials
└── .gitignore
```

---

## Setup

### 1. Clone the repo
```bash
git clone https://github.com/pritha-analytics/trafiklab-repo.git
cd trafiklab-repo
```

### 2. Create a Python virtual environment (requires Python 3.12)
```bash
python -m venv .venv
.venv\Scripts\activate
pip install dbt-core dbt-snowflake azure-storage-file-datalake requests
```

### 3. Set up credentials
Copy `.env.example` to `.env` and fill in your values:
```
TRAFIKLAB_KEY=your_trafiklab_api_key
ADLS_ACCOUNT_KEY=your_azure_storage_account_key
```

### 4. Configure dbt profile
Create `~/.dbt/profiles.yml`:
```yaml
default:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_snowflake_account
      user: your_username
      password: your_password
      role: ACCOUNTADMIN
      warehouse: TRAFIKLAB_WH
      database: TRAFIKLAB_DB
      schema: BRONZE
      threads: 4
```

---

## Running the Pipeline

### Run manually
```powershell
powershell -ExecutionPolicy Bypass -File run_pipeline.ps1
```

### Automated schedule
The pipeline is scheduled via Windows Task Scheduler to run every day at **6:00 AM**, which:
1. Downloads the latest GTFS static data from Trafiklab
2. Uploads `stops.txt` to Azure Data Lake Storage (bronze layer)
3. Runs all dbt models to refresh Snowflake silver and gold tables

---

## dbt Models

| Layer | Model | Description |
|-------|-------|-------------|
| Silver | `stg_stops` | Cleaned stops with stop_id, stop_name, lat/lon |
| Silver | `stg_routes` | Cleaned routes with route type and names |
| Silver | `stg_stop_times` | Departure times per stop and trip |
| Gold | `fct_busiest_stops` | Top stops ranked by total departures (11,809 rows) |
| Gold | `fct_departures_by_hour` | Departures grouped by hour of day (24 rows) |
| Gold | `fct_routes_by_mode` | Route count grouped by transport mode (5 rows) |

---

## Power BI Dashboard

Connected to Snowflake GOLD layer. Scheduled to auto-refresh daily at **6:30 AM** after the pipeline completes.

Report: https://app.powerbi.com/groups/me/reports/05ec3cc9-b344-45c5-8136-f8c559cbfcad/521c1560736a97860a61