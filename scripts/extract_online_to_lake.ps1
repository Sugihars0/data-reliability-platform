param (
    [string]$BatchDate = "2026-07-02",
    [string]$WindowStart = "2026-07-02 00:00:00",
    [string]$WindowEnd = "2026-07-03 00:00:00"
)

$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$tempFolder = Join-Path ([System.IO.Path]::GetTempPath()) "data-reliability-platform"
$tempCsvPath = Join-Path $tempFolder "online_to_lake_transactions_$([System.Guid]::NewGuid()).csv"
$loadSucceeded = $false

Push-Location $repositoryRoot

try {
    New-Item -ItemType Directory -Force -Path $tempFolder | Out-Null

    $extractSql = @"
COPY (
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
        CURRENT_TIMESTAMP AS extracted_at,
        'online_transactions' AS source_table
    FROM online_transactions
    WHERE modified_at >= :'window_start'::timestamp
      AND modified_at < :'window_end'::timestamp
    ORDER BY transaction_id
) TO STDOUT WITH CSV HEADER;
"@

    Write-Host "Extracting online_transactions rows changed from $WindowStart to $WindowEnd..."

    $csvRows = $extractSql |
        docker compose exec -T online_postgres psql `
            -X `
            -q `
            -U postgres `
            -d online_db `
            -v ON_ERROR_STOP=1 `
            -v "batch_date=$BatchDate" `
            -v "window_start=$WindowStart" `
            -v "window_end=$WindowEnd"

    if ($LASTEXITCODE -ne 0) {
        throw "Extract from online_db.online_transactions failed."
    }

    $csvLines = @($csvRows)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($tempCsvPath, $csvLines, $utf8NoBom)

    $extractedRowCount = [Math]::Max($csvLines.Count - 1, 0)
    Write-Host "Extracted $extractedRowCount row(s) to $tempCsvPath."

    $deleteSql = @"
DELETE FROM lake_transactions
WHERE batch_date = :'batch_date'::date;
"@

    Write-Host "Removing existing lake_transactions rows for batch_date $BatchDate..."

    $deleteSql |
        docker compose exec -T offline_postgres psql `
            -X `
            -q `
            -U postgres `
            -d offline_db `
            -v ON_ERROR_STOP=1 `
            -v "batch_date=$BatchDate"

    if ($LASTEXITCODE -ne 0) {
        throw "Delete from offline_db.lake_transactions failed."
    }

    $copyCommand = @"
COPY lake_transactions (
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
        extracted_at,
        source_table
    ) FROM STDIN WITH CSV HEADER;
"@

    Write-Host "Loading extracted rows into offline_db.lake_transactions..."

    Get-Content -LiteralPath $tempCsvPath |
    Where-Object { $_.Trim().Length -gt 0 } |
    docker compose exec -T offline_postgres psql `
            -X `
            -q `
            -U postgres `
            -d offline_db `
            -v ON_ERROR_STOP=1 `
            -c $copyCommand

    if ($LASTEXITCODE -ne 0) {
        throw "Load into offline_db.lake_transactions failed."
    }

    $loadSucceeded = $true
    Write-Host "Loaded $extractedRowCount row(s) into lake_transactions for batch_date $BatchDate."
}
finally {
    Pop-Location

    if ($loadSucceeded -and (Test-Path -LiteralPath $tempCsvPath)) {
        Remove-Item -LiteralPath $tempCsvPath
        Write-Host "Cleaned up temporary CSV file."
    }
}
