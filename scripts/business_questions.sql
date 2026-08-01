-- ============================================================
-- PROJECT: Credit Card Fraud Detection
-- Table  : transactions

-- NOTE : You can find the dataset link in ReadMe File
-- ============================================================

-- =======================
-- Level - 1: Foundational
-- =======================

-- 1. What is the total transaction count and overall fraud rate (Class = 1 as % of total)?

SELECT 
    COUNT(*)                                AS total_transactions,
    COUNT(*) - SUM(Class)                   AS legitimate_transactions,
    SUM(Class)                              AS fraud_transactions,
    ROUND(SUM(Class) * 100.0 / COUNT(*), 4) As fraud_rate
FROM transactions;
--------------------------------------------------------------------------
-- 2. What is the average, minimum, and maximum transaction amount 
--    separately for fraud and legitimate transactions?

SELECT 
    Class AS transaction_type,    -- 1= Fraud, 0= Legitimate
    MIN(Amount) AS min_amount,
    MAX(Amount) AS max_amount,
    AVG(Amount) AS avg_amount
FROM transactions
GROUP BY Class;
--------------------------------------------------------------------------
-- 3. How many fraudulent transactions involve amounts under $10? What
--    percentage of all fraud does this represent?

SELECT
    COUNT(*) AS micro_fraud_count,
    ROUND(
        COUNT(*) * 100.0 / 
             NULLIF((SELECT COUNT(*) FROM transactions WHERE Class = 1), 0),
        2)   AS fraud_rate
FROM transactions
WHERE Amount < 10 AND Class = 1;
--------------------------------------------------------------------------
-- 4. Bucket transactions by amount range ($0–$10, $10–$100, $100–$500, $500+)
--    and show fraud count and fraud rate per bucket.

SELECT 
    CASE WHEN Amount < 10    THEN 'Less than $10'
         WHEN Amount < 100   THEN 'Between $10 - $100'
         WHEN Amount < 500   THEN 'Betweem $100 - $500'
         ELSE 'More than $500'
    END  AS amount_range,
    COUNT(*) AS total_transactions,
    SUM(Class) AS fraud_transactions,
    ROUND(SUM(Class) * 100.0 
                  / COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY 
    CASE WHEN Amount < 10    THEN 'Less than $10'
         WHEN Amount < 100   THEN 'Between $10 - $100'
         WHEN Amount < 500   THEN 'Betweem $100 - $500'
         ELSE 'More than $500'
    END
ORDER BY MIN(Amount);

-- ======================= 
-- Level - 2: Intermediate
-- =======================

-- 5. Convert the Time column (seconds) into hour-of-day buckets (0–23). Which hours have 
--    the highest fraud rate? Which have the highest absolute fraud count?

SELECT 
    CAST([Time] / 3600 AS INT) % 24         AS hour_of_day,
    COUNT(*)                                AS total_transactions,
    SUM(Class)                              AS fraud_transactions,
    ROUND(SUM(Class) * 100.0 / COUNT(*), 3) AS fraud_rate
FROM transactions
GROUP BY  CAST([Time] / 3600 AS INT) % 24
ORDER BY fraud_rate;
------------------------------------------------------------------------------------------
-- 6. Calculate the z-score of transaction Amount across the full dataset. Flag 
--    transactions more than 3 standard deviations above the mean — what fraction of those 
--    are actually fraud?

WITH stats AS
(
    SELECT
        AVG(Amount) AS mean_amt,
        SQRT(AVG(Amount * Amount) - AVG(Amount) * AVG(Amount)) AS staddev_amt
    FROM transactions
)
SELECT 
    t.[Time], t.Amount, t.Amount,
    ROUND(s.mean_amt, 2)                     AS global_mean,
    ROUND(s.staddev_amt, 2)                  AS global_staddev,
    ROUND((t.Amount - s.mean_amt) / NULLIF(s.staddev_amt, 0), 3) AS z_score,
    CASE WHEN (t.Amount - s.mean_amt)/NULLIF(s.staddev_amt, 0) > 3
         THEN '⚠ ANOMALY' ELSE 'NORMAL'
    END                                      AS anomaly_flag
FROM transactions t, stats s
ORDER BY z_score DESC;
------------------------------------------------------------------------------------------
-- 7. What is the median transaction amount for fraud vs. non-fraud?
--    why does median tell a different story than mean here?

WITH ranked AS(
    SELECT 
        Class, Amount,
        ROW_NUMBER() OVER(PARTITION BY Class ORDER BY Amount) AS rn,
        COUNT(*) OVER(PARTITION BY Class) AS cnt
    FROM transactions
)
SELECT 
    CASE Class WHEN 1 THEN 'Fraud' ELSE 'Legitimate' END AS transaction_type,
    ROUND(AVG(Amount), 2) AS median_amt
FROM ranked
WHERE rn IN ((cnt+1)/2, (cnt+2)/2)
GROUP BY Class;
-------------------------------------------------------------------------------------------------
-- 8. Build a rule-based fraud flag: transactions where Amount > $500 AND hour is between 0 
--    and 5 (midnight–5AM). What is the fraud rate for this specific segment vs. the global baseline?

SELECT 
   SUM(CASE WHEN Amount > 500 AND
                 CAST([Time]/3600 AS INT) % 24 BETWEEN 0 and 5 THEN 1 ELSE 0 
       END) AS flagged_txns,
   SUM(CASE WHEN Amount > 500 AND
                 CAST([Time]/3600 AS INT) % 24 BETWEEN 0 and 5 AND Class = 1 THEN 1 ELSE 0
       END) AS flagged_fraud,
    ROUND(
        SUM(CASE WHEN Amount > 500 AND
                 CAST([Time]/3600 AS INT) % 24 BETWEEN 0 and 5 AND Class = 1 THEN 1 ELSE 0
             END) * 100.0 / 
                   NULLIF(SUM(CASE WHEN Amount > 500 AND
                                        CAST([Time]/3600 AS INT) % 24 BETWEEN 0 and 5 THEN 1 ELSE 0 
                              END), 0), 2) AS segment_fraud_rate_prcnt,
    ROUND(SUM(Class) * 100.0 / COUNT(*), 4) AS global_fraud_txns
FROM transactions;
-------------------------------------------------------------------------------------------------
-- 9. For each of the top 5 most divergent PCA features (V1–V28), compute AVG(feature) WHERE Class=1
--     vs AVG(feature) WHERE Class=0. Which features show the greatest separation between fraud and non-fraud?

SELECT 'V1' AS feature,
       ROUND(AVG(CASE WHEN Class = 1 THEN V1 END), 4) AS avg_fraud,
       ROUND(AVG(CASE WHEN Class = 0 THEN V1 END), 4) AS avg_legit,
       ROUND(ABS(AVG(CASE WHEN Class = 1 THEN V1 END)
                 - AVG(CASE WHEN Class = 0 THEN V1 END)), 4) AS divergence
FROM   transactions
UNION ALL
SELECT 'V2',
       ROUND(AVG(CASE WHEN Class = 1 THEN V2 END), 4),
       ROUND(AVG(CASE WHEN Class = 0 THEN V2 END), 4),
       ROUND(ABS(AVG(CASE WHEN Class = 1 THEN V2 END)
                 - AVG(CASE WHEN Class = 0 THEN V2 END)), 4)
FROM   transactions
UNION ALL
SELECT 'V3',
       ROUND(AVG(CASE WHEN Class = 1 THEN V3 END), 4),
       ROUND(AVG(CASE WHEN Class = 0 THEN V3 END), 4),
       ROUND(ABS(AVG(CASE WHEN Class = 1 THEN V3 END)
                 - AVG(CASE WHEN Class = 0 THEN V3 END)), 4)
FROM   transactions
UNION ALL
SELECT 'V4',
       ROUND(AVG(CASE WHEN Class = 1 THEN V4 END), 4),
       ROUND(AVG(CASE WHEN Class = 0 THEN V4 END), 4),
       ROUND(ABS(AVG(CASE WHEN Class = 1 THEN V4 END)
                 - AVG(CASE WHEN Class = 0 THEN V4 END)), 4)
FROM   transactions
UNION ALL
SELECT 'V5',
       ROUND(AVG(CASE WHEN Class = 1 THEN V5 END), 4),
       ROUND(AVG(CASE WHEN Class = 0 THEN V5 END), 4),
       ROUND(ABS(AVG(CASE WHEN Class = 1 THEN V5 END)
                 - AVG(CASE WHEN Class = 0 THEN V5 END)), 4)
FROM   transactions
ORDER  BY divergence DESC;

-- =======================
-- LEVEL 3 — ADVANCED 
-- =======================

--10. Using window functions, calculate transaction velocity: for each transaction,
--    count how many other transactions occurred within the preceding 600 seconds 
--    (Time window). Flag transactions where velocity > 5 as suspicious. What is the 
--    fraud rate among high-velocity transactions?

SELECT t1.rowid     AS txn_id,
       t1.Time,
       t1.Amount,
       t1.Class,
       COUNT(t2.rowid)                                                AS txns_in_600s_window,
       CASE WHEN COUNT(t2.rowid) > 3 THEN 'HIGH VELOCITY' ELSE 'Normal' END AS velocity_flag
FROM   transactions t1
LEFT   JOIN transactions t2
       ON  t2.Time BETWEEN t1.Time - 600 AND t1.Time
       AND t2.rowid <> t1.rowid
GROUP  BY t1.rowid
ORDER  BY txns_in_600s_window DESC;
----------------------------------------------------------------------------------------------
-- 11.  Build a multi-signal fraud score (0–100) using weighted CASE WHEN logic across at 
--      least 4 signals: amount tier, time-of-day risk, velocity score, and V-feature anomaly. 
--      Return the top 100 highest-scored transactions and show how many are actually Class = 1

WITH scored AS (
    SELECT Time, Amount, Class,
           CAST(Time / 3600 AS INT) % 24 AS hour_of_day,
           -- Signal 1: Amount tier (0-30 pts)
           CASE
               WHEN Amount > 500  THEN 30
               WHEN Amount > 200  THEN 20
               WHEN Amount < 1    THEN 15
               ELSE 5
           END AS amount_score,
           -- Signal 2: Time of day risk (0-30 pts)
           CASE
               WHEN CAST(Time / 3600 AS INT) % 24 BETWEEN 0 AND 4  THEN 30
               WHEN CAST(Time / 3600 AS INT) % 24 BETWEEN 22 AND 23 THEN 20
               ELSE 5
           END AS time_score,
           -- Signal 3: V1 anomaly (0-20 pts) — highly divergent feature
           CASE
               WHEN V1 < -2 THEN 20
               WHEN V1 < -1 THEN 10
               ELSE 0
           END AS v1_score,
           -- Signal 4: V3 anomaly (0-20 pts)
           CASE
               WHEN V3 > 2 THEN 20
               WHEN V3 > 1 THEN 10
               ELSE 0
           END AS v3_score
    FROM   transactions
)
SELECT Time, Amount, Class,
       amount_score, time_score, v1_score, v3_score,
       amount_score + time_score + v1_score + v3_score AS fraud_risk_score,
       CASE
           WHEN amount_score + time_score + v1_score + v3_score >= 70 THEN '🔴 BLOCK'
           WHEN amount_score + time_score + v1_score + v3_score >= 40 THEN '🟡 REVIEW'
           ELSE '🟢 PASS'
       END AS decision
FROM   scored
ORDER  BY fraud_risk_score DESC;
-----------------------------------------------------------------------------------------
-- 12. Write a confusion matrix query: given a threshold rule (e.g., Amount > $200 AND hour 
--     between 0–5), compute True Positives, False Positives, True Negatives, and False 
--     Negatives. Then derive Precision, Recall, and F1 Score — all in a single SQL query.

WITH predictions AS (
    SELECT Class AS actual,
           CASE WHEN Amount > 200
                AND  CAST(Time / 3600 AS INT) % 24 BETWEEN 0 AND 5
                THEN 1 ELSE 0
           END AS predicted
    FROM   transactions
),
matrix AS (
    SELECT
        SUM(CASE WHEN predicted = 1 AND actual = 1 THEN 1 ELSE 0 END) AS tp,
        SUM(CASE WHEN predicted = 1 AND actual = 0 THEN 1 ELSE 0 END) AS fp,
        SUM(CASE WHEN predicted = 0 AND actual = 1 THEN 1 ELSE 0 END) AS fn,
        SUM(CASE WHEN predicted = 0 AND actual = 0 THEN 1 ELSE 0 END) AS tn
    FROM predictions
)
SELECT tp, fp, fn, tn,
       ROUND(tp * 1.0 / NULLIF(tp + fp, 0), 4)       AS precision,
       ROUND(tp * 1.0 / NULLIF(tp + fn, 0), 4)       AS recall,
       ROUND(2.0 * tp / NULLIF(2*tp + fp + fn, 0), 4) AS f1_score,
       ROUND((tp + tn) * 1.0 / NULLIF(tp+fp+fn+tn, 0), 4) AS accuracy
FROM   matrix;
-----------------------------------------------------------------------------------------
-- 13. Perform a feature distribution comparison using UNION: for features V1 through V5, 
--     compute mean and stddev separately for fraud and non-fraud and return results in a 
--     long format table with columns feature, class, mean, stddev — useful for feeding 
--     into a visualization tool.

SELECT feature, class_label, mean_val, stddev_val FROM (
    SELECT 'V1' AS feature,
           'Fraud'     AS class_label,
           ROUND(AVG(V1), 4)                                             AS mean_val,
           ROUND(SQRT(AVG(V1*V1) - AVG(V1)*AVG(V1)), 4)                AS stddev_val
    FROM transactions WHERE Class = 1
    UNION ALL
    SELECT 'V1', 'Legitimate',
           ROUND(AVG(V1), 4), ROUND(SQRT(AVG(V1*V1) - AVG(V1)*AVG(V1)), 4)
    FROM transactions WHERE Class = 0
    UNION ALL
    SELECT 'V2', 'Fraud',
           ROUND(AVG(V2), 4), ROUND(SQRT(AVG(V2*V2) - AVG(V2)*AVG(V2)), 4)
    FROM transactions WHERE Class = 1
    UNION ALL
    SELECT 'V2', 'Legitimate',
           ROUND(AVG(V2), 4), ROUND(SQRT(AVG(V2*V2) - AVG(V2)*AVG(V2)), 4)
    FROM transactions WHERE Class = 0
    UNION ALL
    SELECT 'V3', 'Fraud',
           ROUND(AVG(V3), 4), ROUND(SQRT(AVG(V3*V3) - AVG(V3)*AVG(V3)), 4)
    FROM transactions WHERE Class = 1
    UNION ALL
    SELECT 'V3', 'Legitimate',
           ROUND(AVG(V3), 4), ROUND(SQRT(AVG(V3*V3) - AVG(V3)*AVG(V3)), 4)
    FROM transactions WHERE Class = 0
)
ORDER BY feature, class_label;
---------------------------------------------------------------------------------------
-- 14. Simulate a fraud detection pipeline using a CTE chain: Stage 1 — flag high-amount 
--     night transactions. Stage 2 — flag high-velocity transactions. Stage 3 — combine 
--     both signals with OR logic. Stage 4 — compute the fraud capture rate (% of actual 
--     fraud caught) and false positive rate (% of legitimate transactions flagged). 
--     What is the trade-off between capture rate and false positive rate?

WITH stage1_high_amount_night AS (
    SELECT Time, Amount, Class, V1, V2, V3, V4, V5,
           ROW_NUMBER() OVER (ORDER BY Time) AS txn_id,
           1 AS stage1_flag
    FROM   transactions
    WHERE  Amount > 200
      AND  CAST(Time / 3600 AS INT) % 24 BETWEEN 0 AND 5
),
all_with_id AS (
    SELECT Time, Amount, Class,
           ROW_NUMBER() OVER (ORDER BY Time) AS txn_id
    FROM   transactions
),
stage2_velocity AS (
    SELECT t1.txn_id, 1 AS stage2_flag
    FROM   all_with_id t1
    WHERE  (SELECT COUNT(*)
            FROM   all_with_id t2
            WHERE  t2.Time BETWEEN t1.Time - 600 AND t1.Time
              AND  t2.txn_id <> t1.txn_id) > 3
),
stage3_combined AS (
    SELECT a.txn_id, a.Time, a.Amount, a.Class,
           COALESCE(s1.stage1_flag, 0) AS flagged_by_stage1,
           COALESCE(s2.stage2_flag, 0) AS flagged_by_stage2,
           CASE WHEN COALESCE(s1.stage1_flag, 0) = 1
                  OR COALESCE(s2.stage2_flag, 0) = 1
                THEN 1 ELSE 0
           END AS final_flag
    FROM   all_with_id a
    LEFT   JOIN stage1_high_amount_night s1 ON a.txn_id = s1.txn_id
    LEFT   JOIN stage2_velocity s2          ON a.txn_id = s2.txn_id
),
stage4_metrics AS (
    SELECT
        SUM(final_flag)                                                AS total_flagged,
        SUM(CASE WHEN final_flag = 1 AND Class = 1 THEN 1 ELSE 0 END) AS fraud_caught,
        SUM(CASE WHEN final_flag = 1 AND Class = 0 THEN 1 ELSE 0 END) AS false_positives,
        SUM(Class)                                                     AS total_fraud
    FROM stage3_combined
)
SELECT total_flagged,
       fraud_caught,
       false_positives,
       total_fraud,
       ROUND(fraud_caught * 100.0 / NULLIF(total_fraud, 0), 2)       AS fraud_capture_rate_pct,
       ROUND(false_positives * 100.0 / NULLIF(total_flagged, 0), 2)  AS false_positive_rate_pct
FROM   stage4_metrics;


