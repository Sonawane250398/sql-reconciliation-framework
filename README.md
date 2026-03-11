# SQL Reconciliation and Validation Process

A SQL-based reconciliation and validation framework that compares source transaction records against downstream financial reporting outputs to detect mismatches, missing records, and variance drivers.

The framework simulates real-world financial reporting validation workflows used by finance and engineering teams to maintain reporting accuracy and audit readiness.


---

## Resume Project Reference

This repository represents the **SQL Reconciliation and Validation Process** referenced in my professional experience building financial data validation systems.

The project demonstrates:

• Multi-layer SQL reconciliation logic  
• Automated validation checkpoints across reporting layers  
• Break investigation workflows for finance teams  
• Variance analysis between source and reporting datasets
---

## Problem Statement

In multi-layer financial reporting systems, data passes through several stages — source systems, ETL pipelines, reporting databases, and BI dashboards. At each stage, values can diverge due to transformation errors, timing mismatches, or missing records. Without a systematic reconciliation process, these discrepancies accumulate silently and surface as reporting errors during audits or month-end reviews.

This framework was designed to catch those breaks early, classify them by severity, and provide actionable summaries to finance leadership.

---

## What This Framework Does

| Step | Description |
|------|-------------|
| 1. Classification | Tags every transaction as `MATCHED`, `MISMATCH`, or `MISSING` |
| 2. Summary Aggregation | Produces high-level counts and variance totals by status |
| 3. Break Investigation | Isolates discrepancy records and rates severity (HIGH / MEDIUM / LOW) |
| 4. Account-Level Rollup | Identifies accounts with recurring discrepancy patterns |
| 5. Rolling Trend | 7-day moving average of discrepancy rate to track improvement over time |

---

## Key SQL Techniques Used

- **CTEs (Common Table Expressions)** — modular, readable multi-step logic
- **Window Functions** — `SUM() OVER()` for percentage of total; `AVG() OVER()` with `ROWS BETWEEN` for rolling 7-day trend
- **Conditional Aggregation** — `CASE WHEN` inside `SUM()` for status-based counts
- **COALESCE** — safe handling of NULL reported amounts
- **Multi-step filtering** — progressive refinement from full dataset to break report

---

## Results (Based on Sample Data)

- Identified **3 MISSING** and **3 MISMATCH** records out of 20 transactions (30% discrepancy rate in sample)
- Flagged **Gamma Inc** and **Zeta Partners** as accounts with recurring discrepancies
- Rolling trend logic enables week-over-week monitoring to confirm improvements

---

## Files

```
financial-reconciliation-framework/
├── reconciliation.sql   ← Full reconciliation logic (5 CTEs + final output)
├── sample_data.csv      ← Sample transaction dataset (20 records)
└── README.md            ← This file
```

---

## How to Run

1. Load `sample_data.csv` into a table named `transactions` in your SQL environment (PostgreSQL, Snowflake, BigQuery, or DuckDB all work)
2. Run `reconciliation.sql` in full
3. Review the two output queries: break report and reconciliation summary

**Quick test with DuckDB (no setup needed):**
```sql
CREATE TABLE transactions AS SELECT * FROM read_csv_auto('sample_data.csv');
```
Then run the full script.

---

## Business Impact (Real-World Application)

This framework was applied to internal financial reporting systems and delivered:
- **20% reduction** in recurring reporting discrepancies
- **~30% reduction** in break investigation time per release cycle
- Zero critical post-deployment reporting issues across 6 consecutive releases

---

## Author

**Yash Sonawane** — Business Analyst, Financial Systems  
[LinkedIn](https://linkedin.com/in/yash-sonawane25)
