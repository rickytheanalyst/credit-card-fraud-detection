SELECT * FROM transactions

-- 1. Verify Total Rows

SELECT 
    COUNT(*) AS total_rows
FROM transactions;

-- output : Positive
----------------------------------------------------------
-- 2. Verify Total Columns

SELECT 
    COUNT(*) AS total_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'transactions';

-- output : Positive
----------------------------------------------------------
-- 3. Check data types

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'transactions';

----------------------------------------------------------
-- 4. Check null values.

SELECT 
    SUM(CASE WHEN [Time] IS NULL THEN 1 ELSE 0 END) AS time_nulls,   -- 0 nulls
    SUM(CASE WHEN Amount IS NULL THEN 1 ELSE 0 END) AS amount_nulls, -- 0 nulls
    SUM(CASE WHEN Class IS NULL THEN 1 ELSE 0 END) AS class_nulls    -- 0 nulls
FROM transactions;

----------------------------------------------------------
-- 5. Check Duplicate Rows.

SELECT TOP(20)
    [Time], V1, V2, V3, V4, V5,
    V6, V7, V8, V9, V10, V11,
    V12, V13, V14, V15, V16,
    V17, V18, V19, V20, V21,
    V22, V23, V24, V25, V26,
    V27, V28, Amount, Class,
    COUNT(*) AS duplicate_rows
FROM transactions
GROUP BY 
    [Time], V1, V2, V3, V4, V5,
    V6, V7, V8, V9, V10, V11,
    V12, V13, V14, V15, V16,
    V17, V18, V19, V20, V21,
    V22, V23, V24, V25, V26,
    V27, V28, Amount, Class
HAVING COUNT(*) > 1

-- Result : True
----------------------------------------------------------
-- 6. Check Class Distribution
SELECT
    Class,
    COUNT(*) total
FROM transactions
GROUP BY Class

----------------------------------------------------------


