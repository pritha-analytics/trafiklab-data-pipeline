# Load credentials from .env file (not committed to git)
$envFile = Join-Path $PSScriptRoot ".env"
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*([^#][^=]+)=(.+)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
    }
}

Set-Location $PSScriptRoot

Write-Output "[$(Get-Date)] Step 1: Uploading stops to ADLS..."
python "C:\Users\Subrata\Desktop\trafiklab-repo\upload_stops.py"

Write-Output "[$(Get-Date)] Step 2: Running dbt models..."
& ".venv\Scripts\dbt.exe" run

Write-Output "[$(Get-Date)] Pipeline complete."
