-- Stores the latest changed transaction record processed in each daily batch.
CREATE TABLE delta_transactions (
    transaction_id VARCHAR(50) NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    merchant_id VARCHAR(50) NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    transaction_status VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30),
    created_at TIMESTAMP NOT NULL,
    modified_at TIMESTAMP NOT NULL,
    batch_date DATE NOT NULL,
    loaded_at TIMESTAMP NOT NULL,
    source_table VARCHAR(255) NOT NULL,
    PRIMARY KEY (transaction_id, batch_date)
);
