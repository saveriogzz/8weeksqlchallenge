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
    s.customer_id, order_date, product_id, join_date, 
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
    s.customer_id, order_date, product_id, join_date, 
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


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
    s.customer_id, count(s.product_id) AS item_count, sum(price) AS total_spent 
  FROM 
    sales s 
    JOIN members m ON s.customer_id = m.customer_id 
    JOIN menu ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date GROUP BY s.customer_id ORDER BY s.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
    customer_id, sum(CASE WHEN product_name = 'sushi' THEN price * 20 ELSE price * 10 END) AS total_points  
  FROM 
    sales s  
    JOIN menu m ON s.product_id = m.product_id
WHERE s.product_id = m.product_id group by customer_id order by customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
--     how many points do customer A and B have at the end of January?
SELECT sales.customer_id
	,SUM(CASE 
			WHEN sales.order_date BETWEEN members.join_date::DATE
					AND (members.join_date::DATE + 6)
				THEN 2 * 10 * menu.price
			WHEN menu.product_name = 'sushi'
				THEN 2 * 10 * menu.price
			ELSE 10 * menu.price
			END) AS points
FROM sales
INNER JOIN menu ON sales.product_id = menu.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE sales.order_date <= '2021-01-31'::DATE
GROUP BY sales.customer_id;