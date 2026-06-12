/*
SQL Customer Insights Project
Dataset: customer_support
Purpose: Analyse customer support demand, channel usage, key issue drivers, and response-time performance.
Tools: PostgreSQL + DBeaver
*/


-- =========================================================
-- Query 1: Category Demand Analysis
-- Business Question:
-- Which customer support categories generate the highest contact volume?
-- =========================================================

SELECT
    category,
    COUNT(*) AS total_contacts,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_contacts
FROM customer_support
GROUP BY category
ORDER BY total_contacts DESC;


-- =========================================================
-- Query 2: Channel Usage Analysis
-- Business Question:
-- Which support channels are most frequently used by customers?
-- =========================================================

SELECT
    channel_name,
    COUNT(*) AS total_contacts,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_contacts
FROM customer_support
GROUP BY channel_name
ORDER BY total_contacts DESC;


-- =========================================================
-- Query 3: Top Support Issues
-- Business Question:
-- Which specific issues generate the highest contact volume?
-- =========================================================

SELECT
    sub_category,
    COUNT(*) AS contacts,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_total_contacts
FROM customer_support
GROUP BY sub_category
ORDER BY contacts DESC
LIMIT 10;


-- =========================================================
-- Query 4: Category and Subcategory Drilldown
-- Business Question:
-- Which categories contain the highest-volume support issues?
-- =========================================================

SELECT
    category,
    sub_category,
    COUNT(*) AS contacts
FROM customer_support
GROUP BY category, sub_category
ORDER BY contacts DESC
LIMIT 20;


-- =========================================================
-- Query 5: Average Response Time After Data Cleaning
-- Business Question:
-- What is the average customer support response time?
--
-- Data Quality Note:
-- Some records contained response timestamps earlier than the issue reported timestamp.
-- These were excluded from response-time calculations because they produced invalid negative response times.
-- =========================================================

SELECT
    AVG(
        TO_TIMESTAMP(issue_responded, 'DD-MM-YYYY HH24:MI')
        -
        TO_TIMESTAMP(issue_reported_at, 'DD-MM-YYYY HH24:MI')
    ) AS avg_response_time
FROM customer_support
WHERE
    TO_TIMESTAMP(issue_responded, 'DD-MM-YYYY HH24:MI')
    >= TO_TIMESTAMP(issue_reported_at, 'DD-MM-YYYY HH24:MI');


-- =========================================================
-- Query 6: Response Time by High-Volume Issue
-- Business Question:
-- Which high-volume issues take longest to respond to?
-- =========================================================

SELECT
    category,
    sub_category,
    COUNT(*) AS contacts,
    AVG(
        TO_TIMESTAMP(issue_responded, 'DD-MM-YYYY HH24:MI')
        -
        TO_TIMESTAMP(issue_reported_at, 'DD-MM-YYYY HH24:MI')
    ) AS avg_response_time
FROM customer_support
WHERE
    TO_TIMESTAMP(issue_responded, 'DD-MM-YYYY HH24:MI')
    >= TO_TIMESTAMP(issue_reported_at, 'DD-MM-YYYY HH24:MI')
GROUP BY category, sub_category
ORDER BY contacts DESC
LIMIT 20;


-- =========================================================
-- Optional Query 7: Day of Week Contact Volume
-- Business Question:
-- Are customer contacts concentrated on particular days of the week?
-- =========================================================

SELECT
    TO_CHAR(
        TO_TIMESTAMP(issue_reported_at, 'DD-MM-YYYY HH24:MI'),
        'Day'
    ) AS day_of_week,
    COUNT(*) AS contacts
FROM customer_support
GROUP BY day_of_week
ORDER BY contacts DESC;


-- =========================================================
-- Optional Query 8: Data Quality Check - Negative Response Times
-- Business Question:
-- Are there invalid response-time records that should be excluded from response-time analysis?
-- =========================================================

SELECT
    issue_reported_at,
    issue_responded,
    (
        TO_TIMESTAMP(issue_responded, 'DD-MM-YYYY HH24:MI')
        -
        TO_TIMESTAMP(issue_reported_at, 'DD-MM-YYYY HH24:MI')
    ) AS response_time
FROM customer_support
WHERE
    TO_TIMESTAMP(issue_responded, 'DD-MM-YYYY HH24:MI')
    < TO_TIMESTAMP(issue_reported_at, 'DD-MM-YYYY HH24:MI')
LIMIT 20;
