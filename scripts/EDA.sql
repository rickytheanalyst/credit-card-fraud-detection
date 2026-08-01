
------*----------*-----------*----------*------
------*--- EXPLORATORY DATA ANALYSIS ---*------
------*----------*-----------*----------*------

--============================
-- Part - 1 : Dataset Overview
--============================

-- 1. Total Transactions

SELECT 
    COUNT(*) AS total_transactions
FROM transactions;
-----------------------------------------------------------------------
-- 2. Fraud(1) Vs Legitimate(0)

SELECT 
    Class,
    COUNT(*) AS transaction_type
FROM transactions 
GROUP BY Class;
-----------------------------------------------------------------------
-- 3. Fraud Rate

SELECT
    COUNT(*) AS total_transactions,
    SUM(Class) AS fraud_transactions,
    COUNT(*) - SUM(Class) AS legitimate_transactions,
    ROUND(SUM(Class) * 100.0 / COUNT(*), 4) AS fraud_percentage
FROM transactions
-----------------------------------------------------------------------


--=======================================
-- PART - 2 : Transaction Amount Analysis
--=======================================

-- 1. Basic Statistics

SELECT 
    MIN(Amount) as min_amount,
    MAX(Amount) as max_amount,
    AVG(Amount) as avg_amount,
    SUM(Amount) as total_amount
FROM transactions

--=======================================================
-- PART - 3 : Comparing Fraud Vs Legitimate Transactions
--=======================================================

-- 1. Are fraud transactions generally larger than normal transactions?

SELECT
    Class,  -- # 0= Legitimate    # 1= Fraud
    COUNT(*) AS total_transactions,
    MIN(Amount) as min_amount,
    MAX(Amount) as max_amount,
    AVG(Amount) as avg_amount,
    SUM(Amount) as total_amount
FROM transactions
GROUP BY Class

--=======================================
-- PART - 4 : Time-Based Analysis
--=======================================

--"Do frauds happen more often at certain times?"

-- 1. Find the minimum and maximum Time.

SELECT 
    MIN([Time]) AS earliest_time,
    MAX([Time]) AS latest_time
FROM transactions
-----------------------------------------------------------
-- 2. Count total transactions by hour.

SELECT
    [Time]/3600 as hour_number,
    COUNT(*) AS total_transactions
FROM transactions
GROUP BY [Time]/3600
ORDER BY total_transactions DESC
-----------------------------------------------------------
-- 3. Count fraud transactions by hour.
SELECT
    FLOOR([Time]/3600) as hour_number,
    COUNT(*) AS total_transactions
FROM transactions
WHERE Class = 1
GROUP BY [Time]/3600
ORDER BY total_transactions DESC


--============================================
-- PART - 5 : Distribution & Outliers Analysis
--============================================

-- 1. Do fraud transactions usually involve small amounts, large amounts, or a mix of both?

SELECT 
    CASE WHEN Amount < 10 THEN 'Less than $10'
         WHEN Amount < 100 THEN '$10 - $100'
         WHEN Amount < 500 THEN '$100 - $500'
         ELSE 'More than $500'
    END AS amount_range,
    COUNT(*) AS total_transactions
FROM transactions
GROUP BY 
    CASE WHEN Amount < 10 THEN 'Less than $10'
         WHEN Amount < 100 THEN '$10 - $100'
         WHEN Amount < 500 THEN '$100 - $500'
         ELSE 'More than $500'
    END
ORDER BY total_transactions DESC



