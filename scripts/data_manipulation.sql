-- Back up transactions
SELECT *
INTO backup_transactions
FROM transactions

SELECT * FROM backup_transactions
---------------------------------------------------------------------------------
-- 1. Deleting Duplicate rows

WITH DuplicateCTE AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY
                   [Time], V1, V2, V3, V4, V5,
                   V6, V7, V8, V9, V10, V11,
                   V12, V13, V14, V15, V16,
                   V17, V18, V19, V20, V21,
                   V22, V23, V24, V25, V26,
                   V27, V28, Amount, Class
               ORDER BY [Time]
           ) AS rn
    FROM transactions
)
DELETE
FROM DuplicateCTE
WHERE rn > 1;