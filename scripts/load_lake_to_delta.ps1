param (
    [string]$BatchDate = "2026-07-02"
)

$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot

Push-Location $repositoryRoot

try {
    $loadSql = @"
BEGIN;

DELETE FROM delta_transactions
WHERE batch_date = :'batch_date'::date;

INSERT INTO delta_transactions (
    transaction_id,
    user_id,
    merchant_id,
    amount,
    currency,
    transaction_status,
    payment_method,
    created_at,
    modified_at,
    batch_date,
    loaded_at,
    source_table
)
SELECT
    transaction_id,
    user_id,
    merchant_id,
    amount,
    currency,
    transaction_status,
    payment_method,
    created_at,
    modified_at,
    :'batch_date'::date AS batch_date,
    CURRENT_TIMESTAMP AS loaded_at,
    'lake_transactions' AS source_table
FROM lake_transactions
WHERE batch_date = :'batch_date'::date;

COMMIT;
"@

    Write-Host "Loading lake_transactions into delta_transactions for batch_date $BatchDate..."

    $loadSql |
        docker compose exec -T offline_postgres psql `
            -X `
            -q `
            -U postgres `
            -d offline_db `
            -v ON_ERROR_STOP=1 `
            -v "batch_date=$BatchDate"

    if ($LASTEXITCODE -ne 0) {
        throw "Load from lake_transactions to delta_transactions failed."
    }

    Write-Host "Delta load completed for batch_date $BatchDate."
}
finally {
    Pop-Location
}
