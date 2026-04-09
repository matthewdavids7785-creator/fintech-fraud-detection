-- =============================================
-- FINTECH FRAUD DETECTION - SQL ANALYSIS
-- Author: Matt Davids
-- Database: PostgreSQL
-- Description: Fraud detection queries analyzing
-- 10,000 synthetic fintech transactions
-- =============================================


-- STEP 1: CREATE TRANSACTIONS TABLE
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    merchant_category VARCHAR(50) NOT NULL,
    transaction_time TIMESTAMP NOT NULL,
    is_flagged BOOLEAN DEFAULT FALSE
);


-- STEP 2: VIEW SAMPLE DATA
SELECT *
FROM transactions
LIMIT 10;


-- STEP 3: FILTER FLAGGED TRANSACTIONS
-- Result: 519 flagged transactions out of 10,000 (5.19%)
SELECT *
FROM transactions
WHERE is_flagged = true;


-- STEP 4: DETECT ODD-HOUR TRANSACTIONS (midnight to 5am)
-- High value transactions at unusual hours = fraud signal 1
SELECT *
FROM transactions
WHERE EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 5
ORDER BY amount DESC;


-- STEP 5: COMBINE SIGNALS - ODD HOURS + HIGH AMOUNT
-- Transactions over R3000 between midnight and 5am
SELECT *
FROM transactions
WHERE EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 5
AND amount > 3000
ORDER BY amount DESC;


-- STEP 6: CALCULATE FRAUD PERCENTAGE BY FLAG STATUS
-- Only 4% of late-night high-value transactions are flagged
SELECT
    is_flagged,
    COUNT(*) AS total_transactions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM transactions
WHERE EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 5
AND amount > 3000
GROUP BY is_flagged;


-- STEP 7: TRANSACTION VELOCITY - HIGH FREQUENCY USERS
-- Users with more than 20 transactions = potential stolen card
SELECT
    user_id,
    COUNT(*) AS transaction_count,
    MIN(transaction_time) AS first_transaction,
    MAX(transaction_time) AS last_transaction,
    ROUND(SUM(amount)::NUMERIC, 2) AS total_spent
FROM transactions
GROUP BY user_id
HAVING COUNT(*) > 20
ORDER BY transaction_count DESC;


-- STEP 8: MERCHANT CATEGORY RISK BREAKDOWN
-- ATM highest fraud count (109), Grocery lowest (49)
SELECT
    merchant_category,
    is_flagged,
    COUNT(*) AS total
FROM transactions
GROUP BY merchant_category, is_flagged
ORDER BY merchant_category, is_flagged;


-- STEP 9: MASTER FRAUD QUERY - COMPOSITE RISK PROFILE
-- Combines velocity + odd hours + fraud flags per user
-- User 499 identified as highest risk
SELECT
    user_id,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount)::NUMERIC, 2) AS total_spent,
    ROUND(AVG(amount)::NUMERIC, 2) AS avg_transaction,
    SUM(CASE WHEN is_flagged = true THEN 1 ELSE 0 END) AS flagged_count,
    SUM(CASE WHEN EXTRACT(HOUR FROM transaction_time)
        BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS odd_hour_count
FROM transactions
GROUP BY user_id
HAVING COUNT(*) > 15
    AND SUM(CASE WHEN is_flagged = true THEN 1 ELSE 0 END) > 0
ORDER BY flagged_count DESC, odd_hour_count DESC;
