# SQL Reconciliation Framework

A SQL-based reconciliation and validation framework that compares source transaction records against downstream financial reporting outputs to detect mismatches, missing records, and variance drivers.

The framework simulates real-world financial reporting validation workflows used by finance and engineering teams to maintain reporting accuracy and audit readiness.

---

## Business Problem

In multi-layer financial reporting systems, data flows through several stages:

Source Systems → ETL Pipelines → Reporting Databases → BI Dashboards

At each stage values can diverge due to:

• transformation errors
• timing mismatches
• missing records
• aggregation inconsistencies

Without a systematic reconciliation process, these discrepancies accumulate silently and surface as reporting errors during audits or month-end reviews.

This framework detects discrepancies early and provides structured break analysis.

---

## What This Framework Does

| Step                 | Description                                                  |
| -------------------- | ------------------------------------------------------------ |
| Classification       | Tags each transaction as `MATCHED`, `MISMATCH`, or `MISSING` |
| Summary Aggregation  | Produces counts and variance totals by reconciliation status |
| Break Investigation  | Isolates discrepancy records and assigns severity            |
| Account-Level Rollup | Identifies accounts with recurring discrepancy patterns      |
| Rolling Trend        | Tracks discrepancy rate trends over time                     |

---

## Key SQL Techniques Used

• **Common Table Expressions (CTEs)** for modular multi-step logic
• **Window Functions** for percentage calculations and rolling trends
• **Conditional Aggregation** using `CASE WHEN` within `SUM()`
• **COALESCE** for safe NULL handling
• Multi-stage filtering pipelines for discrepancy analysis

---

## Example Results (Sample Dataset)

Using the included dataset:

• **3 MISSING** transactions detected
• **3 MISMATCH** transactions detected
• **30% discrepancy rate** across the sample dataset

Accounts flagged for recurring discrepancies:

• Gamma Inc
• Zeta Partners

These outputs help analysts quickly isolate break drivers.

---

## Repository Structure

```id="sql-repo-structure"
sql-reconciliation-framework
│
├── reconciliation.sql   ← Full reconciliation logic (5 CTEs + final output)
├── sample_data.csv      ← Sample transaction dataset
├── tableau_dashboard.md ← Dashboard design specification
├── BRD_SQL_Reconciliation_Framework.docx ← Business Requirements Document
└── README.md
```

---

## How to Run

1. Load `sample_data.csv` into a table named `transactions`
2. Run `reconciliation.sql` in your SQL environment
   (PostgreSQL, Snowflake, BigQuery, or DuckDB supported)
3. Review the break report and reconciliation summary outputs

Example quick test using DuckDB:

```sql
CREATE TABLE transactions AS
SELECT * FROM read_csv_auto('sample_data.csv');
```

---

## Business Impact

Reconciliation frameworks like this help organizations:

• detect reporting discrepancies earlier
• reduce investigation time for financial breaks
• improve reporting accuracy and audit readiness

In real-world reporting systems, similar validation processes have delivered:

• **~20% reduction in recurring reporting discrepancies**
• **~30% reduction in break investigation time**
• **Zero critical post-deployment reporting issues across multiple releases**

---

## Author

**Yash Sonawane**
Business Systems Analyst — Financial Data & Reporting

LinkedIn
https://linkedin.com/in/yash-sonawane25

Portfolio
https://yashsonawane.vercel.app
