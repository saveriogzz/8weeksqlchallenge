-- 1. What is the total amount each customer spent at the restaurant?
select 
  sales.customer_id, 
  sum(menu.price) as total 
from 
  sales 
  join menu on sales.product_id = menu.product_id 
group by 
  customer_id;


-- 2. How many days has each customer visited the restaurant?
select 
  customer_id, 
  count(distinct order_date) as count_visit 
from 
  sales 
group by 
  customer_id;


-- 3. What was the first item from the menu purchased by each customer?
select 
  distinct on (customer_id) customer_id, 
  product_id 
from 
  sales 
order by 
  customer_id, 
  order_date;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select 
  product_id, 
  count(product_id) 
from 
  sales 
group by 
  product_id 
limit 
  1;


-- 5. Which item was the most popular for each customer?
select 
  distinct customer_id, 
  product_id, 
  count(product_id) 
from 
  sales 
group by 
  (customer_id, product_id) 
order by 
  customer_id;


-- 6. Which item was purchased first by the customer after they became a member?
WITH added_row_number as (
  SELECT 
    s.customer_id, 
    order_date, 
    product_id, 
    join_date, 
    ROW_NUMBER() OVER(PARTITION BY s.customer_id) AS row_number 
  FROM 
    sales s 
    JOIN members m ON s.customer_id = m.customer_id 
  WHERE 
    order_date >= join_date
) 
SELECT 
  * 
FROM 
  added_row_number 
WHERE 
  row_number = 1;


-- 7. Which item was purchased just before the customer became a member?
WITH added_row_number as (
  SELECT                                             
    s.customer_id,                                             
    order_date,                                                                              
    product_id,                                   
    join_date, 
    ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS row_number 
  FROM 
    sales s 
    JOIN members m ON s.customer_id = m.customer_id 
  WHERE 
    order_date < join_date
) 
SELECT 
  * 
FROM 
  added_row_number 
WHERE 
  row_number = 1;
