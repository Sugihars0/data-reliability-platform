-- Adds synthetic e-wallet transactions for local development and testing.
INSERT INTO online_transactions (
    transaction_id,
    user_id,
    merchant_id,
    amount,
    currency,
    transaction_status,
    payment_method,
    created_at,
    modified_at
)
VALUES
    ('txn_0001', 'user_001', 'merchant_001', 25000.00, 'IDR', 'SUCCESS', 'EWALLET_BALANCE', '2026-07-01 08:15:00', '2026-07-01 08:15:10'),
    ('txn_0002', 'user_002', 'merchant_002', 47500.00, 'IDR', 'SUCCESS', 'QR_PAYMENT', '2026-07-01 09:05:00', '2026-07-01 09:05:08'),
    ('txn_0003', 'user_003', 'merchant_003', 120000.00, 'IDR', 'FAILED', 'BANK_TRANSFER', '2026-07-01 10:20:00', '2026-07-01 10:21:30'),
    ('txn_0004', 'user_004', 'merchant_001', 18500.00, 'IDR', 'PENDING', 'EWALLET_BALANCE', '2026-07-01 11:45:00', '2026-07-01 11:45:00'),
    ('txn_0005', 'user_005', 'merchant_004', 76000.00, 'IDR', 'SUCCESS', 'QR_PAYMENT', '2026-07-01 13:10:00', '2026-07-01 13:10:12'),
    ('txn_0006', 'user_001', 'merchant_005', 32000.00, 'IDR', 'REFUNDED', 'EWALLET_BALANCE', '2026-07-01 14:30:00', '2026-07-02 09:15:00'),
    ('txn_0007', 'user_006', 'merchant_002', 55000.00, 'IDR', 'SUCCESS', 'BANK_TRANSFER', '2026-07-02 07:50:00', '2026-07-02 07:50:09'),
    ('txn_0008', 'user_007', 'merchant_006', 15000.00, 'IDR', 'FAILED', 'QR_PAYMENT', '2026-07-02 08:40:00', '2026-07-02 08:41:05'),
    ('txn_0009', 'user_008', 'merchant_003', 210000.00, 'IDR', 'SUCCESS', 'EWALLET_BALANCE', '2026-07-02 09:25:00', '2026-07-02 09:25:15'),
    ('txn_0010', 'user_009', 'merchant_007', 42500.00, 'IDR', 'PENDING', 'BANK_TRANSFER', '2026-07-02 10:55:00', '2026-07-02 10:55:00'),
    ('txn_0011', 'user_010', 'merchant_008', 89000.00, 'IDR', 'SUCCESS', 'QR_PAYMENT', '2026-07-02 12:05:00', '2026-07-02 12:05:11'),
    ('txn_0012', 'user_003', 'merchant_004', 64000.00, 'IDR', 'REFUNDED', 'EWALLET_BALANCE', '2026-07-02 15:35:00', '2026-07-03 08:20:00'),
    ('txn_0013', 'user_004', 'merchant_005', 27500.00, 'IDR', 'SUCCESS', 'EWALLET_BALANCE', '2026-07-03 08:10:00', '2026-07-03 08:10:07'),
    ('txn_0014', 'user_005', 'merchant_001', 135000.00, 'IDR', 'FAILED', 'BANK_TRANSFER', '2026-07-03 09:45:00', '2026-07-03 09:46:20'),
    ('txn_0015', 'user_006', 'merchant_006', 22000.00, 'IDR', 'SUCCESS', 'QR_PAYMENT', '2026-07-03 10:30:00', '2026-07-03 10:30:06'),
    ('txn_0016', 'user_007', 'merchant_007', 99000.00, 'IDR', 'PENDING', 'EWALLET_BALANCE', '2026-07-03 11:15:00', '2026-07-03 11:15:00'),
    ('txn_0017', 'user_008', 'merchant_008', 51000.00, 'IDR', 'SUCCESS', 'BANK_TRANSFER', '2026-07-03 13:20:00', '2026-07-03 13:20:14'),
    ('txn_0018', 'user_009', 'merchant_002', 38000.00, 'IDR', 'REFUNDED', 'QR_PAYMENT', '2026-07-03 14:40:00', '2026-07-04 09:05:00'),
    ('txn_0019', 'user_010', 'merchant_003', 175000.00, 'IDR', 'SUCCESS', 'EWALLET_BALANCE', '2026-07-04 08:25:00', '2026-07-04 08:25:10'),
    ('txn_0020', 'user_002', 'merchant_005', 29500.00, 'IDR', 'FAILED', 'QR_PAYMENT', '2026-07-04 10:10:00', '2026-07-04 10:11:12');
