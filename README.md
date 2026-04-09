# Fintech Fraud Detection — SQL Analysis

## Project Overview
This project analyzes 10,000 synthetic fintech transactions 
using PostgreSQL to identify fraudulent activity patterns 
relevant to South African payment platforms like Ozow and Yoco.

## Business Problem
How can a fintech company detect fraudulent transactions 
before significant financial damage occurs?

## Fraud Signals Analyzed
- Odd-hour transactions (midnight to 5am)
- High-value transaction spikes (above R3,000)
- Transaction velocity (users with 20+ transactions)
- Merchant category risk breakdown
- Composite risk profiling per user

## Key Findings
- 519 out of 10,000 transactions flagged as suspicious (5.19%)
- ATM category has the highest fraud count (109 flagged)
- User 499 identified as highest risk — 5 fraud flags, 
  5 odd-hour transactions, R72,962 total spent
- Only 4% of late-night high-value transactions are flagged, 
  meaning time of day alone is insufficient as a fraud signal

## Tools Used
- PostgreSQL 17
- pgAdmin 4

## Author
Matt Davids — Aspiring Data Analyst | Cape Town, SA
GitHub: matthewdavids7785-creator
