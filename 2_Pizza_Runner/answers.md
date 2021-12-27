# A. Pizza metrics

### 4. How many of each type of pizza was delivered?
  '''
  select pizza_id, count(*) from customer_orders co
join runner_orders ro
on co.order_id = ro.order_id where pickup_time != 'null' group by pizza_id;
  '''
|pizza_id | count | 
|---------+-------|
|        2 |     3|
|        1 |     9|
