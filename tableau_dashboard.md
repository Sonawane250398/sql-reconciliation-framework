# Tableau Dashboard Design — Financial Reconciliation Monitor

## Dashboard Title
**Financial Reconciliation Health Monitor**

---

## Purpose
Provide finance and engineering leadership with a real-time view of reconciliation status across transaction datasets — surfacing discrepancy trends, high-risk accounts, and break severity distributions without requiring SQL access.

---

## Dashboard Layout (3 Sections)

### Section 1 — Executive Summary (Top Row)
Four KPI tiles side by side:

| Tile | Metric | Colour Logic |
|------|--------|--------------|
| Total Transactions | Count of all records | Neutral (blue) |
| Match Rate % | % with MATCHED status | Green if >95%, amber if 90–95%, red if <90% |
| Total Variance ($) | Sum of ABS(variance_amount) | Red if >$10,000 |
| Open Breaks | Count of MISMATCH + MISSING | Red if >0 |

---

### Section 2 — Trend & Distribution (Middle Row)

**Left: Daily Discrepancy Rate — Line Chart**
- X-axis: transaction_date
- Y-axis: daily_discrepancy_rate (%)
- Secondary line: rolling_7day_discrepancy_rate
- Purpose: Shows whether the team is improving week over week

**Right: Break Severity Distribution — Donut Chart**
- Segments: HIGH / MEDIUM / LOW
- Colour: Red / Amber / Green
- Purpose: Quick visual of how serious the open breaks are

---

### Section 3 — Account Drill-Down (Bottom Row)

**Left: Account Discrepancy Leaderboard — Bar Chart**
- Sorted by discrepancy_rate_pct descending
- Colour gradient: darker = higher discrepancy rate
- Purpose: Identify which accounts need remediation attention

**Right: Break Detail Table**
- Columns: transaction_id, account_name, transaction_type, region, source_amount, reported_amount, variance_amount, break_severity
- Filterable by: region, transaction_type, break_severity, date range
- Purpose: Drill-down for analysts investigating specific breaks

---

## Filters (Applied Globally)
- Date Range picker
- Region dropdown (West / East / Central)
- Transaction Type (WIRE / ACH)
- Break Severity (HIGH / MEDIUM / LOW)

---

## Data Source
Connect Tableau to the `transactions` table or import `sample_data.csv` directly via Tableau's text file connector.

**Calculated Fields needed in Tableau:**

```
// Reconciliation Status
IF ISNULL([Reported Amount]) THEN "MISSING"
ELSEIF [Source Amount] != [Reported Amount] THEN "MISMATCH"
ELSE "MATCHED"
END

// Variance Amount
[Source Amount] - IFNULL([Reported Amount], 0)

// Break Severity
IF ABS([Variance Amount]) > 1000 THEN "HIGH"
ELSEIF ABS([Variance Amount]) > 100 THEN "MEDIUM"
ELSE "LOW"
END

// Match Rate %
SUM(IF [Reconciliation Status] = "MATCHED" THEN 1 ELSE 0 END) / COUNT([Transaction Id])
```
