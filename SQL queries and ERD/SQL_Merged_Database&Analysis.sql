-- ==========================================================
-- PAYMENT CARD FRAUD ANALYTICS PROJECT
-- Full SQL Workflow
-- ==========================================================

-- Payment Fraud Analytics Project
-- Database Schema Creation
CREATE DATABASE IF NOT EXISTS fraud_analytics_project;

USE fraud_analytics_project;

-- Table 1: Account Profiles
-- Stores account-level customer/profile information
-- Primary key: account_id

CREATE TABLE account_profiles (
    account_id VARCHAR(50) PRIMARY KEY,
    account_age_days INT,
    credit_limit DECIMAL(12,2),
    home_country VARCHAR(10),
    risk_score DECIMAL(10,4),
    is_high_risk TINYINT,
    avg_txn_amount DECIMAL(12,2),
    avg_monthly_txns DECIMAL(10,2),
    has_2fa TINYINT,
    account_type VARCHAR(50),
    total_transactions DECIMAL(12,2),
    total_amount DECIMAL(15,2),
    avg_amount DECIMAL(12,2),
    max_amount DECIMAL(12,2),
    fraud_count DECIMAL(12,2),
    fraud_amount DECIMAL(15,2),
    pct_foreign DECIMAL(10,4),
    avg_velocity DECIMAL(10,4),
    unique_countries DECIMAL(10,2),
    unique_categories DECIMAL(10,2),
    avg_ip_risk DECIMAL(10,4),
    fraud_rate DECIMAL(10,4),
    is_fraudster DECIMAL(5,2)
);


-- Table 2: Fraud Patterns
-- Lookup table describing each fraud pattern/category
-- Primary key: fraud_pattern

CREATE TABLE fraud_patterns (
    fraud_pattern VARCHAR(100) PRIMARY KEY,
    description TEXT,
    transaction_count INT,
    fraud_share_pct DECIMAL(10,4),
    avg_amount DECIMAL(12,2),
    median_amount DECIMAL(12,2),
    pct_night_0_5 DECIMAL(10,4),
    pct_foreign DECIMAL(10,4),
    pct_card_not_present DECIMAL(10,4),
    avg_velocity_1h DECIMAL(10,4),
    avg_ip_risk DECIMAL(10,4),
    pct_no_2fa DECIMAL(10,4)
);

-- Table 3: Time Series Statistics
-- Stores hourly aggregated transaction/fraud statistics
-- Primary key: hour

CREATE TABLE time_series_stats (
    hour DATETIME PRIMARY KEY,
    transaction_count INT,
    fraud_count INT,
    total_amount DECIMAL(15,2),
    avg_amount DECIMAL(12,2),
    avg_ip_risk DECIMAL(10,4),
    fraud_rate DECIMAL(10,4),
    hour_of_day INT,
    day_of_week INT,
    is_weekend TINYINT
);

-- Table 4: Transactions
-- Main transaction-level fact table
-- Foreign keys:
-- account_id references account_profiles(account_id)
-- fraud_pattern references fraud_patterns(fraud_pattern)

CREATE TABLE transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50),
    timestamp DATETIME,
    hour_of_day INT,
    day_of_week INT,
    is_weekend TINYINT,
    amount DECIMAL(12,2),
    merchant_category VARCHAR(100),
    mcc_code INT,
    merchant_country VARCHAR(10),
    card_present TINYINT,
    device_type VARCHAR(50),
    device_known TINYINT,
    ip_risk_score DECIMAL(10,4),
    is_foreign_txn TINYINT,
    time_since_last_s INT,
    velocity_1h INT,
    amount_vs_avg_ratio DECIMAL(12,4),
    is_fraud TINYINT,
    fraud_pattern VARCHAR(100),

    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES account_profiles(account_id),

    CONSTRAINT fk_transactions_fraud_pattern
        FOREIGN KEY (fraud_pattern)
        REFERENCES fraud_patterns(fraud_pattern)
);

-- Table 5: Network Edges
-- Stores account-to-account links based on shared identifiers
-- Composite primary key: account_a, account_b, shared_type
-- Foreign keys reference account_profiles

CREATE TABLE network_edges (
    account_a VARCHAR(50),
    account_b VARCHAR(50),
    shared_type VARCHAR(100),
    connection_count INT,
    ring_id VARCHAR(100),
    both_fraud TINYINT,

    PRIMARY KEY (account_a, account_b, shared_type),

    CONSTRAINT fk_network_account_a
        FOREIGN KEY (account_a)
        REFERENCES account_profiles(account_id),

    CONSTRAINT fk_network_account_b
        FOREIGN KEY (account_b)
        REFERENCES account_profiles(account_id)
);



-- ==========================================================
-- CSV IMPORT STEP
-- ==========================================================
-- Import the cleaned CSV files from the cleaned_data folder into the tables above.
-- Recommended import order because of foreign key relationships:
-- 1. account_profiles_clean.csv        -> account_profiles
-- 2. fraud_patterns_clean.csv          -> fraud_patterns
-- 3. time_series_stats_clean.csv       -> time_series_stats
-- 4. transactions_clean.csv            -> transactions
-- 5. network_edges_clean.csv           -> network_edges
-- ==========================================================

SHOW TABLES;

SELECT COUNT(*) AS account_count
FROM account_profiles;

SELECT COUNT(*) AS fraud_patterns_count
FROM fraud_patterns;

SELECT COUNT(*) AS time_series_count
FROM time_series_stats;

SELECT COUNT(*) AS transaction_count
FROM transactions;

SELECT COUNT(*) AS network_count
FROM network_edges;

-- Preview sample rows after import

SELECT *
FROM account_profiles
LIMIT 5;

SELECT *
FROM fraud_patterns
LIMIT 5;

SELECT *
FROM time_series_stats
LIMIT 5;

SELECT *
FROM transactions
LIMIT 5;

SELECT *
FROM network_edges
LIMIT 5;

-- ==========================================================
-- Research Question 1: Fraud Pattern Financial Loss Analysis
-- Business Question:
-- Which fraud patterns generate the highest financial losses and should be prioritized for fraud prevention?
-- ==========================================================

USE fraud_analytics_project;

-- Analysis 1
-- Fraud loss by fraud pattern
-- NOTE: This query includes a subquery.
-- The subquery calculates the total fraud loss across all fraud transactions.
-- The outer query uses it to calculate each fraud pattern's share of total fraud loss.

SELECT
    transactions.fraud_pattern,
    COUNT(transactions.transaction_id) AS fraud_transactions,
    ROUND(SUM(transactions.amount), 2) AS total_fraud_loss,
    ROUND(AVG(transactions.amount), 2) AS avg_fraud_amount,
    ROUND(
        SUM(transactions.amount) * 100 /
        (SELECT SUM(amount) FROM transactions WHERE is_fraud = 1),
        2
    ) AS share_of_total_fraud_loss_pct
FROM transactions
WHERE transactions.is_fraud = 1
GROUP BY transactions.fraud_pattern
ORDER BY total_fraud_loss DESC;

-- Analysis 2
-- Fraud pattern performance using the fraud_patterns lookup table

SELECT
    fraud_patterns.fraud_pattern,
    fraud_patterns.description,
    fraud_patterns.transaction_count,
    fraud_patterns.fraud_share_pct,
    fraud_patterns.avg_amount,
    fraud_patterns.median_amount,
    fraud_patterns.pct_foreign,
    fraud_patterns.pct_card_not_present,
    fraud_patterns.avg_velocity_1h,
    fraud_patterns.avg_ip_risk,
    fraud_patterns.pct_no_2fa
FROM fraud_patterns
WHERE fraud_patterns.fraud_pattern <> 'No Fraud'
ORDER BY fraud_patterns.fraud_share_pct DESC;

-- Analysis 3
-- Compare fraud patterns by both frequency and financial impact

SELECT
    transactions.fraud_pattern,
    COUNT(transactions.transaction_id) AS fraud_transactions,
    ROUND(SUM(transactions.amount), 2) AS total_fraud_loss,
    ROUND(AVG(transactions.amount), 2) AS avg_fraud_amount,
    ROUND(AVG(transactions.ip_risk_score), 2) AS avg_ip_risk_score,
    ROUND(AVG(transactions.velocity_1h), 2) AS avg_velocity_1h
FROM transactions
WHERE transactions.is_fraud = 1
GROUP BY transactions.fraud_pattern
ORDER BY total_fraud_loss DESC, fraud_transactions DESC;


-- ==========================================================
-- Research Question 2: Customer Risk Analysis
-- Analysis 1
-- Business Question:
-- Which account types are associated with higher fraud risk?
-- ==========================================================

USE fraud_analytics_project;

-- Fraud rate by account type

SELECT
    account_profiles.account_type,
    COUNT(account_profiles.account_id) AS total_accounts,
    SUM(account_profiles.is_fraudster) AS fraud_accounts,
    ROUND(
        SUM(account_profiles.is_fraudster) * 100 /
        COUNT(account_profiles.account_id),
        2
    ) AS fraud_rate_pct

FROM account_profiles
GROUP BY account_profiles.account_type
ORDER BY fraud_rate_pct DESC;

-- ==========================================================
-- Research Question 2: Customer Risk Analysis
-- Analysis 2
-- Business Question:
-- Are accounts with Two-Factor Authentication (2FA) less likely to experience fraud?
-- ==========================================================

SELECT
    account_profiles.has_2fa,
    COUNT(account_profiles.account_id) AS total_accounts,
    SUM(account_profiles.is_fraudster) AS fraud_accounts,
    ROUND(
        SUM(account_profiles.is_fraudster) * 100 /
        COUNT(account_profiles.account_id),
        2
    ) AS fraud_rate_pct
FROM account_profiles
GROUP BY account_profiles.has_2fa
ORDER BY fraud_rate_pct DESC;

-- ==========================================================
-- Research Question 2: Customer Risk Analysis
-- Analysis 3
-- Business Question:
-- Are newer customer accounts more likely to be associated with fraudulent activity?
-- ==========================================================

SELECT

    CASE
        WHEN account_profiles.account_age_days < 30 THEN 'Less than 30 days'
        WHEN account_profiles.account_age_days BETWEEN 30 AND 180 THEN '30 - 180 days'
        WHEN account_profiles.account_age_days BETWEEN 181 AND 365 THEN '181 - 365 days'
        ELSE 'More than 365 days'
    END AS account_age_group,
    COUNT(account_profiles.account_id) AS total_accounts,
    SUM(account_profiles.is_fraudster) AS fraud_accounts,
    ROUND(
        SUM(account_profiles.is_fraudster) * 100 /
        COUNT(account_profiles.account_id),
        2
    ) AS fraud_rate_pct
FROM account_profiles
GROUP BY account_age_group
ORDER BY fraud_rate_pct DESC;

-- ==========================================================
-- Research Question 2: Customer Risk Analysis
-- Analysis 4
-- Business Question:
-- Do accounts marked as high-risk have a higher fraud rate?
-- ==========================================================

SELECT
    account_profiles.is_high_risk,
    COUNT(account_profiles.account_id) AS total_accounts,
    SUM(account_profiles.is_fraudster) AS fraud_accounts,
    ROUND(
        SUM(account_profiles.is_fraudster) * 100 /
        COUNT(account_profiles.account_id),
        2
    ) AS fraud_rate_pct
FROM account_profiles
GROUP BY account_profiles.is_high_risk
ORDER BY fraud_rate_pct DESC;

-- ==========================================================
-- Research Question 2: Customer Risk Analysis
-- Analysis 5
-- Business Question:
-- Are customers with higher risk scores more likely to be involved in fraudulent transactions?
-- ==========================================================

SELECT
    CASE
        WHEN account_profiles.risk_score < 30 THEN 'Low Risk (0-29)'
        WHEN account_profiles.risk_score BETWEEN 30 AND 60 THEN 'Medium Risk (30-60)'
        ELSE 'High Risk (61-100)'
    END AS risk_score_group,
    COUNT(transactions.transaction_id) AS total_transactions,
    SUM(transactions.is_fraud) AS fraud_transactions,
    ROUND(
        SUM(transactions.is_fraud) * 100 /
        COUNT(transactions.transaction_id),
        2
    ) AS fraud_rate_pct
FROM account_profiles
INNER JOIN transactions
ON account_profiles.account_id = transactions.account_id
GROUP BY risk_score_group
ORDER BY fraud_rate_pct DESC;

-- ==========================================================
-- Research Question 3: Transaction Behaviour Analysis
-- Analysis 1
-- Business Question:
-- Which merchant categories have the highest fraud rate?
-- ==========================================================

SELECT
    transactions.merchant_category,
    COUNT(transactions.transaction_id) AS total_transactions,
    SUM(transactions.is_fraud) AS fraud_transactions,
    ROUND(
        SUM(transactions.is_fraud) * 100 /
        COUNT(transactions.transaction_id),
        2
    ) AS fraud_rate_pct
FROM transactions
GROUP BY transactions.merchant_category
ORDER BY fraud_rate_pct DESC;

-- Analysis 1B
-- Merchant categories with fraud rate above 3%
-- NOTE: This query uses HAVING because we are filtering after GROUP BY.

SELECT
    transactions.merchant_category,
    COUNT(transactions.transaction_id) AS total_transactions,
    SUM(transactions.is_fraud) AS fraud_transactions,
    ROUND(
        SUM(transactions.is_fraud) * 100 /
        COUNT(transactions.transaction_id),
        2
    ) AS fraud_rate_pct
FROM transactions
GROUP BY transactions.merchant_category
HAVING fraud_rate_pct > 3
ORDER BY fraud_rate_pct DESC;


-- ==========================================================
-- Research Question 3: Transaction Behaviour Analysis
-- Analysis 2
-- Business Question:
-- Are higher-value transactions more likely to be fraudulent?
-- ==========================================================

SELECT
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount,
    ROUND(AVG(amount),2) AS average_amount
FROM transactions;

SELECT
    CASE
        WHEN transactions.amount < 50 THEN 'Less than $50'
        WHEN transactions.amount BETWEEN 50 AND 200 THEN '$50 - $200'
        WHEN transactions.amount BETWEEN 201 AND 500 THEN '$201 - $500'
        ELSE 'More than $500'
    END AS transaction_amount_group,
    COUNT(transactions.transaction_id) AS total_transactions,
    SUM(transactions.is_fraud) AS fraud_transactions,
    ROUND(
        SUM(transactions.is_fraud) * 100 /
        COUNT(transactions.transaction_id),
        2
    ) AS fraud_rate_pct
FROM transactions
GROUP BY transaction_amount_group
ORDER BY fraud_rate_pct DESC;

-- ==========================================================
-- Research Question 3: Transaction Behaviour Analysis
-- Analysis 3
-- Business Question:
-- Are foreign transactions more likely to be fraudulent?
-- ==========================================================

SELECT
    transactions.is_foreign_txn,
    COUNT(transactions.transaction_id) AS total_transactions,
    SUM(transactions.is_fraud) AS fraud_transactions,
    ROUND(
        SUM(transactions.is_fraud) * 100 /
        COUNT(transactions.transaction_id),
        2
    ) AS fraud_rate_pct
FROM transactions
GROUP BY transactions.is_foreign_txn
ORDER BY fraud_rate_pct DESC;


-- ==========================================================
-- Research Question 3: Transaction Behaviour Analysis
-- Analysis 4
-- Business Question:
-- Does transaction velocity influence fraud risk?
-- ==========================================================

SELECT
    CASE
        WHEN transactions.velocity_1h = 0 THEN 'No Previous Transactions'
        WHEN transactions.velocity_1h BETWEEN 1 AND 2 THEN 'Low Velocity (1–2)'
        WHEN transactions.velocity_1h BETWEEN 3 AND 5 THEN 'Moderate Velocity (3–5)'
        ELSE 'High Velocity (6+)'
    END AS velocity_group,
    COUNT(transactions.transaction_id) AS total_transactions,
    SUM(transactions.is_fraud) AS fraud_transactions,
    ROUND(
        SUM(transactions.is_fraud) * 100 /
        COUNT(transactions.transaction_id),
        2
    ) AS fraud_rate_pct
FROM transactions
GROUP BY velocity_group
ORDER BY fraud_rate_pct DESC;

-- ==========================================================
-- Research Question 3: Transaction Behaviour Analysis
-- Analysis 5
-- Business Question:
-- Does IP Risk Score influence fraudulent transactions?
-- ==========================================================

SELECT
    MIN(ip_risk_score) AS minimum_score,
    MAX(ip_risk_score) AS maximum_score,
    ROUND(AVG(ip_risk_score), 2) AS average_score
FROM transactions;

SELECT
    CASE
        WHEN transactions.ip_risk_score <= 20 THEN 'Low IP Risk (0–20)'
        WHEN transactions.ip_risk_score BETWEEN 21 AND 50 THEN 'Medium IP Risk (21–50)'
        ELSE 'High IP Risk (51–100)'
    END AS ip_risk_group,
    COUNT(transactions.transaction_id) AS total_transactions,
    SUM(transactions.is_fraud) AS fraud_transactions,
    ROUND(
        SUM(transactions.is_fraud) * 100 /
        COUNT(transactions.transaction_id),
        2
    ) AS fraud_rate_pct
FROM transactions
GROUP BY ip_risk_group
ORDER BY fraud_rate_pct DESC;

-- ==========================================================
-- RESEARCH QUESTION 4
-- Can network analysis identify coordinated fraud rings and high-risk account clusters?
-- ==========================================================


-- ----------------------------------------------------------
-- 4.1 Network Analysis Summary
-- Measures the scale of coordinated fraud activity across identified fraud rings.
-- ----------------------------------------------------------

SELECT
    COUNT(DISTINCT ring_id) AS identified_fraud_rings,
    COUNT(*) AS fraud_ring_connections,
    SUM(connection_count) AS total_shared_connections,
    ROUND(AVG(connection_count), 2) AS avg_shared_connections
FROM network_edges
WHERE ring_id IS NOT NULL
  AND TRIM(ring_id) <> '';


-- ----------------------------------------------------------
-- 4.2 Top Fraud Rings by Network Activity
-- Identifies the most highly connected fraud rings based on the volume of shared network connections.
-- ----------------------------------------------------------

SELECT
    ring_id,
    COUNT(*) AS network_connections,
    SUM(connection_count) AS total_shared_connections,
    ROUND(AVG(connection_count), 2) AS avg_shared_connections,
    MAX(connection_count) AS max_shared_connections
FROM network_edges
WHERE ring_id IS NOT NULL
  AND TRIM(ring_id) <> ''
GROUP BY ring_id
ORDER BY total_shared_connections DESC
LIMIT 10;