# A. Pizza metrics

### 4. How many of each type of pizza was delivered?
```sql
select pizza_id, count(*) from customer_orders co
join runner_orders ro
on co.order_id = ro.order_id where pickup_time != 'null' group by pizza_id;
```
|pizza_id  | count  | 
|---------:|-------:|
|        2 |       3|
|        1 |       9|

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
```sql
select pizza_name, count(*) from customer_orders co
join pizza_names pn
on co.pizza_id = pn.pizza_id group by pn.pizza_name;
```
| pizza_name | count |
|------------|-------|
| Meatlovers |    10 |
| Vegetarian |     4 |

### 6. What was the maximum number of pizzas delivered in a single order?
If delivered != ordered:
```sql
with count_table as (
    select co.order_id, count(pizza_id)
    from customer_orders co join runner_orders ro on co.order_id = ro.order_id 
    where pickup_time != 'null'
    group by co.order_id order by co.order_id
) select max(count) from count_table;
```
| max |
|-----|
|  3  |

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
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
  ```
| customer_id | atleastonechange | nochanges|
|-----------:|-----------------:|----------:|
|        101 |                0 |         2 |
|        102 |                0 |         3 |
|        103 |                3 |         0 |
|        104 |                2 |         1 |
|        105 |                1 |         0 |

### 8. How many pizzas were delivered that had both exclusions and extras?
```sql
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
```
|pizzas_both_excl_and_extr |
|-------------------------:|
|                        1 |

### 9. What was the total volume of pizzas ordered for each hour of the day?
```sql
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
```
| order_hour | count |
|------------:|-------:|
|        18 |     3 |
|        11 |     1 | 
|        13 |     3 |
|        19 |     1 |
|        21 |     3 |
|        23 |     3 |

### 10. 
```sql
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
```
| order_day | count |
|---------:|-------:|
|        3 |     5 |
|        4 |     3 |
|        5 |     1 |
|        6 |     5 |
