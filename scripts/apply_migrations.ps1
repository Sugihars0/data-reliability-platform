$ErrorActionPreference = "Stop"

# This script assumes the target tables do not already exist.
Write-Warning "Migrations will fail if the target tables already exist."

$repositoryRoot = Split-Path -Parent $PSScriptRoot

function Invoke-Migration {
    param (
        [string]$MigrationPath,
        [string]$ServiceName,
        [string]$DatabaseName
    )

    Write-Host "Applying $MigrationPath to $DatabaseName..."

    Get-Content -Raw -LiteralPath $MigrationPath |
        docker compose exec -T $ServiceName psql `
            -U postgres `
            -d $DatabaseName `
            -v ON_ERROR_STOP=1

    if ($LASTEXITCODE -ne 0) {
        throw "Migration failed: $MigrationPath"
    }
}

Push-Location $repositoryRoot

try {
    # The source transaction table belongs in the online database.
    Invoke-Migration `
        -MigrationPath "sql/migrations/001_create_online_transactions.sql" `
        -ServiceName "online_postgres" `
        -DatabaseName "online_db"

    # Offline pipeline and data quality tables belong in the offline database.
    Invoke-Migration `
        -MigrationPath "sql/migrations/002_create_lake_transactions.sql" `
        -ServiceName "offline_postgres" `
        -DatabaseName "offline_db"

    Invoke-Migration `
        -MigrationPath "sql/migrations/003_create_delta_transactions.sql" `
        -ServiceName "offline_postgres" `
        -DatabaseName "offline_db"

    Invoke-Migration `
        -MigrationPath "sql/migrations/004_create_ods_transactions.sql" `
        -ServiceName "offline_postgres" `
        -DatabaseName "offline_db"

    Invoke-Migration `
        -MigrationPath "sql/migrations/005_create_dq_results.sql" `
        -ServiceName "offline_postgres" `
        -DatabaseName "offline_db"

    Write-Host "All V1 migrations were applied successfully."
}
finally {
    Pop-Location
}
