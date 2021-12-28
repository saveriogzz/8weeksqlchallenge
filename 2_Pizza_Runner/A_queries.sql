---- A. Pizza Metrics ----
-- A1. How many pizzas were ordered?
select 
  count(pizza_id) 
from 
  customer_orders;
-- A2. How many unique customer orders were made?
select 
  count(distinct order_id) 
from 
  customer_orders;
-- A3. How many successful orders were delivered by each runner?
select 
  runner_id, 
  count(distinct order_id) 
from 
  runner_orders 
where 
  pickup_time != 'null' 
group by 
  runner_id;
-- A4. How many of each type of pizza was delivered?
select 
  pizza_id, 
  count(*) 
from 
  customer_orders co 
  join runner_orders ro on co.order_id = ro.order_id 
where 
  pickup_time != 'null' 
group by 
  pizza_id;
-- A5. How many Vegetarian and Meatlovers were ordered by each customer?
select 
  pizza_name, 
  count(*) 
from 
  customer_orders co 
  join pizza_names pn on co.pizza_id = pn.pizza_id 
group by 
  pn.pizza_name;

-- A6. What was the maximum number of pizzas delivered in a single order?
with count_table as (
  select 
    co.order_id, 
    count(pizza_id) 
  from 
    customer_orders co 
    join runner_orders ro on co.order_id = ro.order_id 
  where 
    pickup_time != 'null' 
  group by 
    co.order_id 
  order by 
    co.order_id
) 
select 
  max(count) 
from 
  count_table;

-- A7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH change_table AS (
  SELECT 
    co.customer_id, 
    co.pizza_id, 
    exclusions, 
    extras, 
    CASE WHEN exclusions = '' OR exclusions = 'null' 
    AND extras = '' OR extras = 'null' THEN 'N' ELSE 'Y' END AS change 
  FROM 
    customer_orders co 
    JOIN runner_orders ro ON co.order_id = ro.order_id 
  WHERE 
    pickup_time != 'null'
) 
SELECT 
  customer_id, 
  COUNT(CASE WHEN change = 'Y' THEN 1 END) AS atLeastOneChange, 
  COUNT(CASE WHEN change = 'N' THEN 1 END) AS NoChanges 
FROM 
  change_table 
GROUP BY 
  customer_id 
ORDER BY 
  customer_id;

-- A8. How many pizzas were delivered that had both exclusions and extras?
WITH change_table AS (
  SELECT 
    co.customer_id, 
    co.pizza_id, 
    exclusions, 
    extras, 
    CASE WHEN exclusions is not null 
    AND exclusions != '' 
    AND exclusions != 'null' THEN 1 END AS exc, 
    CASE WHEN extras is not null 
    AND extras != '' 
    AND extras != 'null' THEN 1 END AS ext 
  FROM 
    customer_orders co 
    JOIN runner_orders ro ON co.order_id = ro.order_id 
  WHERE 
    pickup_time != 'null'
) 
SELECT 
  SUM(
    CASE WHEN exc = 1 
    AND ext = 1 THEN 1 ELSE 0 END
  ) as pizzas_both_excl_and_extr 
from 
  change_table;

--- A9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
  extract(
    hour 
    FROM 
      order_time
  ) AS order_hour, 
  count(*) 
FROM 
  customer_orders 
GROUP BY 
  order_hour 
ORDER BY 
  order_hour;

--- A10. What was the volume of orders for each day of the week?
SELECT 
  extract(
    isodow 
    from 
      order_time
  ) as order_day, 
  count(*) 
FROM 
  customer_orders 
group by 
  order_day 
order by 
  order_day;
