-------------------------------------------
---- B. Runner and Customer Experience ----
-------------------------------------------

-- B1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
  DATE_PART('week', registration_date) AS registration_week, 
  count(*) 
FROM 
  runners 
group by 
  registration_Week;

--- B2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
  AVG(
    split_part(duration, 'm', 1):: INT
  ):: FLOAT as avg_duration 
from 
  runner_orders 
where 
  duration != 'null';

-- B3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH _stats AS (
  SELECT 
    co.order_id, 
    AGE(
      pickup_time :: TIMESTAMP, order_time :: TIMESTAMP
    ) AS difference, 
    COUNT(pizza_id) AS pizza_count 
  FROM 
    customer_orders co 
    JOIN runner_orders ro ON co.order_id = ro.order_id 
  WHERE 
    ro.pickup_time != 'null' 
  GROUP BY 
    co.order_id, 
    difference 
  ORDER BY 
    order_id
) 
SELECT 
  order_id, 
  difference / pizza_count AS time_per_pizza 
FROM 
  _stats;

-- B4. What was the average distance travelled for each customer?
SELECT                       
  AVG(
    SPLIT_PART(distance, 'km', 1):: FLOAT
  ):: FLOAT AS avg_distance 
FROM 
  runner_orders 
WHERE 
  duration != 'null';

-- B5. What was the difference between the longest and shortest delivery times for all orders?
WITH durations AS (
  SELECT 
    SPLIT_PART(duration, 'm', 1):: INT AS duration 
  FROM 
    runner_orders 
  WHERE 
    duration != 'null'
) 
SELECT 
  (
    MAX(duration) - MIN(duration)
  ) as difference 
FROM 
  durations;

-- B6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
  runner_id, 
  AVG(
    SPLIT_PART(distance, 'km', 1):: FLOAT / SPLIT_PART(duration, 'm', 1):: FLOAT
  ) * 16.666666667 as meters_per_seconds 
FROM 
  runner_orders 
where 
  duration != 'null' 
GROUP BY 
  runner_id 
ORDER BY 
  runner_id;

-- B7. What is the successful delivery percentage for each runner?
SELECT
  runner_id,
  100*SUM(
  CASE
    WHEN
      distance != 'null' 
    THEN
      1 
    ELSE
      0 
  END
) / COUNT(*) AS percentage 
FROM
  runner_orders 
GROUP BY
  runner_id 
ORDER BY
  runner_id;