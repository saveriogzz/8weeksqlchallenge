# B - Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?
```sql
SELECT
  COUNT(DISTINCT customer_id) 
FROM
  subscriptions;
```
| count |
|-------|
|  1000 |

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
```sql
WITH trial_plans AS 
(
  SELECT
    * 
  FROM
    subscriptions 
  WHERE
    plan_id = 1
)
SELECT
  date_part('month', start_date) AS month,
  COUNT(*) 
FROM
  trial_plans 
GROUP BY
  month 
ORDER BY
  month;
```
|month | count |
|-------|-------|
|     1 |    39|
|     2 |    37|
|     3 |    49|
|     4 |    43|
|     5 |    53|
|     6 |    51|
|     7 |    44|
|     8 |    54|
|     9 |    38|
|    10 |    46|
|    11 |    49|
|    12 |    43|