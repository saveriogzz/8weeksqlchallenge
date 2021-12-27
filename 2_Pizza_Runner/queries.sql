---- A. Pizza Metrics ----
-- A1. How many pizzas were ordered?
select count(pizza_id) from customer_orders;

-- A2. How many unique customer orders were made?
select count(distinct order_id) from customer_orders;

-- A3. How many successful orders were delivered by each runner?
select runner_id, count(distinct order_id) from runner_orders where pickup_time != 'null' group by runner_id;

-- A4. How many of each type of pizza was delivered?
select pizza_id, count(*) from customer_orders co
join runner_orders ro
on co.order_id = ro.order_id where pickup_time != 'null' group by pizza_id;

-- A5. How many Vegetarian and Meatlovers were ordered by each customer?
select pizza_name, count(*) from customer_orders co
join pizza_names pn
on co.pizza_id = pn.pizza_id group by pn.pizza_name;

-- A6. What was the maximum number of pizzas delivered in a single order?
with count_table as (
    select co.order_id, count(pizza_id)
    from customer_orders co join runner_orders ro on co.order_id = ro.order_id 
    where pickup_time != 'null'
    group by co.order_id order by co.order_id
) select max(count) from count_table;

-- A7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
