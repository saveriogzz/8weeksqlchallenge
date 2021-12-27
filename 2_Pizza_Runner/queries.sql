---- A. Pizza Metrics ----
-- A1. How many pizzas were ordered?
select count(pizza_id) from customer_orders;

-- A2. How many unique customer orders were made?
select count(distinct order_id) from customer_orders;

-- A3. How many successful orders were delivered by each runner?

a