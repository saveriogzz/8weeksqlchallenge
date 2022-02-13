-- B1
SELECT
  COUNT(DISTINCT customer_id) 
FROM
  subscriptions;

-- B2
WITH trial_plans AS 
(
  SELECT
    * 
  FROM
    subscriptions 
  WHERE
    plan_id = 1
)
SELECT
  date_part('month', start_date) AS month,
  COUNT(*) 
FROM
  trial_plans 
GROUP BY
  month 
ORDER BY
  month;

-- B3
WITH x AS 
(
  SELECT
    plan_name,
    start_date 
  FROM
    subscriptions s 
    JOIN
      plans p 
      ON s.plan_id = p.plan_id 
)
SELECT
  plan_name,
  COUNT(*) 
FROM
  x 
WHERE
  start_date >= '2021-01-01' 
GROUP BY
  plan_name;

-- B4
DROP TABLE IF EXISTS total_count;
CREATE TEMP TABLE total_count AS (
    SELECT COUNT(DISTINCT customer_id) AS num
    FROM foodie_fi.subscriptions
);

WITH churn_count AS (
    SELECT COUNT(DISTINCT customer_id) AS num
    FROM foodie_fi.subscriptions
    WHERE plan_id = 4
)
SELECT churn_count.num AS num_churned,
       churn_count.num::FLOAT  / total_count.num::FLOAT *100 AS percent_churned
FROM churn_count, total_count;

