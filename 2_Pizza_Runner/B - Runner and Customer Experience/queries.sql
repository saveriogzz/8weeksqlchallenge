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
