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
