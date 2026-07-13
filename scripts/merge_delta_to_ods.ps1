param (
    [string]$BatchDate = "2026-07-02"
)

$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot

Push-Location $repositoryRoot

try {
    $mergeSql = @"
BEGIN;

INSERT INTO ods_transactions (
    transaction_id,
    user_id,
    merchant_id,
    amount,
    currency,
    transaction_status,
    payment_method,
    created_at,
    modified_at,
    last_batch_date,
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
    :'batch_date'::date AS last_batch_date,
    CURRENT_TIMESTAMP AS loaded_at,
    'delta_transactions' AS source_table
FROM delta_transactions
WHERE batch_date = :'batch_date'::date
ON CONFLICT (transaction_id) DO UPDATE
SET
    user_id = EXCLUDED.user_id,
    merchant_id = EXCLUDED.merchant_id,
    amount = EXCLUDED.amount,
    currency = EXCLUDED.currency,
    transaction_status = EXCLUDED.transaction_status,
    payment_method = EXCLUDED.payment_method,
    created_at = EXCLUDED.created_at,
    modified_at = EXCLUDED.modified_at,
    last_batch_date = EXCLUDED.last_batch_date,
    loaded_at = EXCLUDED.loaded_at,
    source_table = EXCLUDED.source_table
WHERE EXCLUDED.modified_at >= ods_transactions.modified_at;

COMMIT;
"@

    Write-Host "Merging delta_transactions into ods_transactions for batch_date $BatchDate..."

    $mergeSql |
        docker compose exec -T offline_postgres psql `
            -X `
            -q `
            -U postgres `
            -d offline_db `
            -v ON_ERROR_STOP=1 `
            -v "batch_date=$BatchDate"

    if ($LASTEXITCODE -ne 0) {
        throw "Merge from delta_transactions to ods_transactions failed."
    }

    Write-Host "ODS merge completed for batch_date $BatchDate."
}
finally {
    Pop-Location
}
