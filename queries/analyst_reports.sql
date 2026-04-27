-- Query 1: Monthly Billing Trend
SELECT 
    DATE_FORMAT(service_date, '%Y-%m') AS month,
    COUNT(claim_id) AS total_claims,
    SUM(billed_amount) AS total_billed,
    SUM(paid_amount) AS total_collected,
    ROUND(SUM(paid_amount) / SUM(billed_amount) * 100, 2) AS collection_rate_pct
FROM claims
GROUP BY DATE_FORMAT(service_date, '%Y-%m')
ORDER BY month;

-- Query 2: Denial Rate by Provider
SELECT 
    p.provider_name,
    p.department,
    COUNT(c.claim_id) AS total_claims,
    SUM(CASE WHEN c.status = 'Denied' THEN 1 ELSE 0 END) AS denied_claims,
    ROUND(SUM(CASE WHEN c.status = 'Denied' THEN 1 ELSE 0 END) 
          / COUNT(c.claim_id) * 100, 2) AS denial_rate_pct
FROM claims c
JOIN providers p ON c.provider_id = p.provider_id
GROUP BY p.provider_name, p.department
ORDER BY denial_rate_pct DESC;

-- Query 3: Collection Efficiency by Payer
SELECT 
    py.payer_name,
    py.payer_type,
    COUNT(c.claim_id) AS total_claims,
    SUM(c.billed_amount) AS total_billed,
    SUM(c.paid_amount) AS total_collected,
    ROUND(SUM(c.paid_amount) / SUM(c.billed_amount) * 100, 2) AS collection_efficiency_pct
FROM claims c
JOIN payers py ON c.payer_id = py.payer_id
GROUP BY py.payer_name, py.payer_type
ORDER BY collection_efficiency_pct DESC;

-- Query 4: AR Aging Buckets
SELECT 
    claim_id,
    patient_id,
    billed_amount,
    status,
    service_date,
    DATEDIFF(CURDATE(), service_date) AS days_outstanding,
    CASE
        WHEN DATEDIFF(CURDATE(), service_date) <= 30  THEN '0-30 Days'
        WHEN DATEDIFF(CURDATE(), service_date) <= 60  THEN '31-60 Days'
        WHEN DATEDIFF(CURDATE(), service_date) <= 90  THEN '61-90 Days'
        WHEN DATEDIFF(CURDATE(), service_date) <= 120 THEN '91-120 Days'
        ELSE '120+ Days'
    END AS aging_bucket
FROM claims
WHERE status IN ('Pending', 'Denied')
ORDER BY days_outstanding DESC;

-- Query 5: AR Aging Summary
SELECT 
    CASE
        WHEN DATEDIFF(CURDATE(), service_date) <= 30  THEN '0-30 Days'
        WHEN DATEDIFF(CURDATE(), service_date) <= 60  THEN '31-60 Days'
        WHEN DATEDIFF(CURDATE(), service_date) <= 90  THEN '61-90 Days'
        WHEN DATEDIFF(CURDATE(), service_date) <= 120 THEN '91-120 Days'
        ELSE '120+ Days'
    END AS aging_bucket,
    COUNT(claim_id) AS total_claims,
    SUM(billed_amount) AS total_outstanding
FROM claims
WHERE status IN ('Pending', 'Denied')
GROUP BY aging_bucket
ORDER BY MIN(DATEDIFF(CURDATE(), service_date));

-- Query 6: Top Denial Reasons
SELECT 
    denial_reason,
    COUNT(claim_id) AS total_denials,
    SUM(billed_amount) AS revenue_at_risk,
    ROUND(COUNT(claim_id) / (SELECT COUNT(*) FROM claims 
          WHERE status = 'Denied') * 100, 2) AS pct_of_total_denials
FROM claims
WHERE status = 'Denied'
GROUP BY denial_reason
ORDER BY total_denials DESC;

-- Query 7: Provider Performance Ranking (Window Function)
SELECT 
    p.provider_name,
    p.department,
    SUM(c.billed_amount) AS total_billed,
    SUM(c.paid_amount) AS total_collected,
    ROUND(SUM(c.paid_amount) / SUM(c.billed_amount) * 100, 2) AS collection_rate_pct,
    RANK() OVER (
        PARTITION BY p.department 
        ORDER BY SUM(c.paid_amount) DESC
    ) AS dept_rank
FROM claims c
JOIN providers p ON c.provider_id = p.provider_id
GROUP BY p.provider_name, p.department
ORDER BY p.department, dept_rank;

-- Query 8: Month-over-Month Revenue Change (Window Function)
SELECT 
    month,
    total_collected,
    LAG(total_collected) OVER (ORDER BY month) AS prev_month_collected,
    ROUND(total_collected - LAG(total_collected) OVER (ORDER BY month), 2) AS mom_change,
    ROUND((total_collected - LAG(total_collected) OVER (ORDER BY month)) 
          / LAG(total_collected) OVER (ORDER BY month) * 100, 2) AS mom_change_pct
FROM (
    SELECT 
        DATE_FORMAT(service_date, '%Y-%m') AS month,
        SUM(paid_amount) AS total_collected
    FROM claims
    GROUP BY DATE_FORMAT(service_date, '%Y-%m')
) monthly_totals
ORDER BY month;
