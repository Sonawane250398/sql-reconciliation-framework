-- ============================================================
-- Financial Data Reconciliation Framework
-- Author: Yash Sonawane
-- Description: Multi-layer SQL reconciliation logic comparing
--              source transaction records vs. reported outputs.
--              Identifies mismatches, missing records, and
--              variance drivers across financial datasets.
-- ============================================================


-- ============================================================
-- STEP 1: Load & classify all transactions
-- Tag each record as MATCHED, MISMATCH, or MISSING
-- ============================================================

WITH classified_transactions AS (
    SELECT
        transaction_id,
        transaction_date,
        account_id,
        account_name,
        source_amount,
        reported_amount,
        transaction_type,
        region,
        status,
        CASE
            WHEN reported_amount IS NULL          THEN 'MISSING'
            WHEN source_amount != reported_amount THEN 'MISMATCH'
            ELSE                                       'MATCHED'
        END AS reconciliation_status,
        COALESCE(source_amount, 0) - COALESCE(reported_amount, 0) AS variance_amount
    FROM transactions
),


-- ============================================================
-- STEP 2: Aggregate summary by status
-- High-level view for finance leadership dashboards
-- ============================================================

reconciliation_summary AS (
    SELECT
        reconciliation_status,
        COUNT(*)                        AS record_count,
        SUM(source_amount)              AS total_source_amount,
        SUM(reported_amount)            AS total_reported_amount,
        SUM(ABS(variance_amount))       AS total_variance,
        ROUND(COUNT(*) * 100.0
            / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
    FROM classified_transactions
    GROUP BY reconciliation_status
),


-- ============================================================
-- STEP 3: Break investigation — isolate discrepancy records
-- Used for root cause analysis during release cycles
-- ============================================================

break_investigation AS (
    SELECT
        transaction_id,
        transaction_date,
        account_id,
        account_name,
        transaction_type,
        region,
        source_amount,
        reported_amount,
        variance_amount,
        reconciliation_status,
        -- Flag high-value breaks for priority review
        CASE
            WHEN ABS(variance_amount) > 1000 THEN 'HIGH'
            WHEN ABS(variance_amount) > 100  THEN 'MEDIUM'
            ELSE                                  'LOW'
        END AS break_severity
    FROM classified_transactions
    WHERE reconciliation_status IN ('MISMATCH', 'MISSING')
),


-- ============================================================
-- STEP 4: Account-level rollup
-- Identify accounts with recurring discrepancy patterns
-- ============================================================

account_level_rollup AS (
    SELECT
        account_id,
        account_name,
        COUNT(*)                                            AS total_transactions,
        SUM(CASE WHEN reconciliation_status = 'MATCHED'
                 THEN 1 ELSE 0 END)                        AS matched_count,
        SUM(CASE WHEN reconciliation_status != 'MATCHED'
                 THEN 1 ELSE 0 END)                        AS discrepancy_count,
        ROUND(
            SUM(CASE WHEN reconciliation_status != 'MATCHED'
                     THEN 1 ELSE 0 END) * 100.0
            / COUNT(*), 2
        )                                                   AS discrepancy_rate_pct,
        SUM(ABS(variance_amount))                           AS total_variance
    FROM classified_transactions
    GROUP BY account_id, account_name
),


-- ============================================================
-- STEP 5: Rolling 7-day discrepancy trend
-- Tracks whether discrepancy rate is improving over time
-- ============================================================

daily_trend AS (
    SELECT
        transaction_date,
        COUNT(*)                                             AS daily_records,
        SUM(CASE WHEN reconciliation_status != 'MATCHED'
                 THEN 1 ELSE 0 END)                         AS daily_discrepancies,
        ROUND(
            SUM(CASE WHEN reconciliation_status != 'MATCHED'
                     THEN 1 ELSE 0 END) * 100.0
            / COUNT(*), 2
        )                                                    AS daily_discrepancy_rate,
        AVG(
            SUM(CASE WHEN reconciliation_status != 'MATCHED'
                     THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        ) OVER (
            ORDER BY transaction_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )                                                    AS rolling_7day_discrepancy_rate
    FROM classified_transactions
    GROUP BY transaction_date
)


-- ============================================================
-- FINAL OUTPUT: Full break report for finance review
-- ============================================================

SELECT
    b.transaction_id,
    b.transaction_date,
    b.account_name,
    b.transaction_type,
    b.region,
    b.source_amount,
    b.reported_amount,
    b.variance_amount,
    b.reconciliation_status,
    b.break_severity,
    a.discrepancy_rate_pct   AS account_discrepancy_rate
FROM break_investigation b
JOIN account_level_rollup a USING (account_id)
ORDER BY b.break_severity DESC, ABS(b.variance_amount) DESC;


-- ============================================================
-- VALIDATION CHECKPOINT: Overall reconciliation health
-- ============================================================

SELECT
    reconciliation_status,
    record_count,
    pct_of_total,
    total_variance
FROM reconciliation_summary
ORDER BY record_count DESC;
