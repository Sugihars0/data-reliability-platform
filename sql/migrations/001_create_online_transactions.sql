-- Stores source-like operational transaction records.
CREATE TABLE online_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    merchant_id VARCHAR(50) NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    transaction_status VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30),
    created_at TIMESTAMP NOT NULL,
    modified_at TIMESTAMP NOT NULL
);
