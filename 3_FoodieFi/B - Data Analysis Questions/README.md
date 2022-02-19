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

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
```sql
WITH x AS 
(
  SELECT
    plan_name,
    start_date 
  FROM
    subscriptions s 
    JOIN
      plans p 
      ON s.plan_id = p.plan_id 
)
SELECT
  plan_name,
  COUNT(*) 
FROM
  x 
WHERE
  start_date >= '2021-01-01' 
GROUP BY
  plan_name;
```
or

```sql
WITH x AS 
(
  SELECT
    plan_name,
    start_date 
  FROM
    subscriptions s 
    JOIN
      plans p 
      ON s.plan_id = p.plan_id 
)
SELECT DISTINCT
  plan_name,
  COUNT(*) OVER(PARTITION BY plan_name) 
FROM
  x 
WHERE
  start_date >= '2021-01-01';
```

|  plan_name   | count|
|--------------|------|
|pro annual    |    63|
|churn         |    71|
|pro monthly   |    60|
|basic monthly |     8|

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```sql
DROP TABLE IF EXISTS total_count;
CREATE TEMP TABLE total_count AS (
    SELECT COUNT(DISTINCT customer_id) AS num
    FROM foodie_fi.subscriptions
);

WITH churn_count AS (
    SELECT COUNT(DISTINCT customer_id) AS num
    FROM foodie_fi.subscriptions
    WHERE plan_id = 4
)
SELECT churn_count.num AS num_churned,
       churn_count.num::FLOAT  / total_count.num::FLOAT *100 AS percent_churned
FROM churn_count, total_count;
```
|num_churned | percentage|
|------------|-----------|
|        307 |       30.7|


```sql
WITH churn_count AS 
(
  SELECT
    COUNT(t.*) AS total_churned 
  FROM
    (
      WITH ranking AS 
      (
        SELECT
          s.*,
          RANK() OVER (PARTITION BY customer_id 
        ORDER BY
          start_date) AS plan_rank 
        FROM
          subscriptions AS s
      )
,
      conditions AS 
      (
        SELECT
          r.*,
          CASE
            WHEN
              plan_id = 0 
              AND plan_rank = 1 
            THEN
              1 
            WHEN
              plan_id = 4 
              AND plan_rank = 4 
            THEN
              1 
            ELSE
              0 
          END
          AS conditions 
        FROM
          ranking AS r
      )
      SELECT
        customer_id,
        SUM(conditions) AS s 
      FROM
        conditions 
      GROUP BY
        customer_id
    )
    t 
  WHERE
    s = 2
)
SELECT
  churn_count.total_churned,
  round((churn_count.total_churned::FLOAT / total_count.num::FLOAT)*100) AS perc 
FROM
  churn_count,
  total_count;
```

| total_churned | perc |
|---------------|------|
|            45 |    4 |