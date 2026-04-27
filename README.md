# RCM Claims SQL Analysis

**Tech Stack:** SQL · MySQL  
**Domain:** Healthcare Revenue Cycle Management (RCM)

## Overview
Designed a simulated healthcare RCM database and wrote 8 business-grade 
analyst reports directly mirroring real-world revenue cycle workflows 
used by healthcare billing teams.

## Database Schema
- `providers` — Physician details and departments
- `payers` — Insurance companies and payer types  
- `claims` — Core billing table (50 records across 8 months)

## The 8 Analyst Reports

| # | Report | Business Question |
|---|--------|-------------------|
| 1 | Monthly Billing Trend | How much did we bill and collect each month? |
| 2 | Denial Rate by Provider | Which providers have the most denied claims? |
| 3 | Collection Efficiency by Payer | Which insurance pays us the best? |
| 4 | AR Aging Detail | How old are our unpaid claims? |
| 5 | AR Aging Summary | How much revenue sits in each aging bucket? |
| 6 | Top Denial Reasons | Why are claims being denied? |
| 7 | Provider Performance Ranking | Who are the top performers per department? |
| 8 | Month-over-Month Revenue Change | Is our revenue growing or shrinking? |

## Key SQL Concepts Used
- JOINS (INNER JOIN across 3 tables)
- Aggregate functions (SUM, COUNT, ROUND)
- CASE WHEN (aging buckets, denial flags)
- Window functions (RANK, LAG with PARTITION BY)
- Subqueries
- DATE_FORMAT, DATEDIFF, CURDATE()

## Sample Output

### Query 5: AR Aging Summary
![AR Aging](output\Screenshots\Screenshot_q5_ans.jpg)

### Query 7: Provider Performance Ranking
![Provider Ranking](output\Screenshots\Screenshot_q7_ans.jpg)

## How to Run
1. Open MySQL Workbench
2. Run `schema/create_tables.sql` to create database and tables
3. Run `schema/insert_data.sql` to populate mock data
4. Run `queries/analyst_reports.sql` to execute all 8 reports

## Business Context
Ventra Health and similar RCM companies use exactly these reports 
to track billing performance, identify denial patterns, and 
optimize revenue collection across physician practices.