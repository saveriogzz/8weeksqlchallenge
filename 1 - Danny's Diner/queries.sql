-- 1. What is the total amount each customer spent at the restaurant?
select sales.customer_id, sum(menu.price) as total
from sales join menu
on sales.product_id = menu.product_id
group by customer_id;


-- 2. How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as count_visit from sales group by customer_id;


-- 3. What was the first item from the menu purchased by each customer?
select distinct on (customer_id) customer_id, product_id from sales order by customer_id, order_date;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_id, count(product_id) from sales group by product_id limit 1;


-- 5. Which item was the most popular for each customer?
select distinct customer_id, product_id, count(product_id) from sales group by (customer_id, product_id) order by customer_id;