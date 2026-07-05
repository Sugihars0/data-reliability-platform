-- Stores the outcome of each data quality check for a pipeline batch.
CREATE TABLE dq_results (
    dq_result_id VARCHAR(50) PRIMARY KEY,
    check_name VARCHAR(255) NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    batch_date DATE NOT NULL,
    check_status VARCHAR(30) NOT NULL,
    failed_record_count NUMERIC(18,0) NOT NULL,
    checked_at TIMESTAMP NOT NULL,
    details TEXT
);
