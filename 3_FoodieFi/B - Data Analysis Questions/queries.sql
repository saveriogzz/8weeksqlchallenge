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

