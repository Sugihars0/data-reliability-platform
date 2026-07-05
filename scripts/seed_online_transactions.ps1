$ErrorActionPreference = "Stop"

# The insert may fail if the synthetic transaction IDs already exist.
Write-Warning "Seeding may fail if duplicate transaction_id values already exist."

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$seedPath = "sql/seeds/001_seed_online_transactions.sql"

Push-Location $repositoryRoot

try {
    Write-Host "Loading synthetic transactions into online_db..."

    Get-Content -Raw -LiteralPath $seedPath |
        docker compose exec -T online_postgres psql `
            -U postgres `
            -d online_db `
            -v ON_ERROR_STOP=1

    if ($LASTEXITCODE -ne 0) {
        throw "Seed load failed: $seedPath"
    }

    Write-Host "Synthetic online transactions loaded successfully."
}
finally {
    Pop-Location
}
