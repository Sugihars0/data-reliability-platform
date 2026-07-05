-- Stores the latest known state of each transaction from the offline pipeline.
CREATE TABLE ods_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    merchant_id VARCHAR(50) NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    transaction_status VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30),
    created_at TIMESTAMP NOT NULL,
    modified_at TIMESTAMP NOT NULL,
    last_batch_date DATE NOT NULL,
    loaded_at TIMESTAMP NOT NULL,
    source_table VARCHAR(255) NOT NULL
);
