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


### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
DROP TABLE IF EXISTS total_count;
CREATE TEMP TABLE total_count AS (
    SELECT COUNT(DISTINCT customer_id) AS num
    FROM foodie_fi.subscriptions
);

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
              AND plan_rank = 2
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

a much cleaner solution makes use of `LEAD()`

```sql
DROP TABLE IF EXISTS total_count;
CREATE TEMP TABLE total_count AS (
    SELECT COUNT(DISTINCT customer_id) AS num
    FROM foodie_fi.subscriptions
);

WITH churn_count AS 
(
  SELECT
    COUNT(*) AS total_churned 
  FROM
    (
      SELECT
        s.*,
        LEAD(plan_id, 1) OVER (PARTITION BY customer_id 
      ORDER BY
        start_date) AS next_plan 
      FROM
        subscriptions AS s
    )
    w 
  WHERE
    w.plan_id = 0 
    AND w.next_plan = 4
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
|            92 |    9 |

### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
DROP TABLE IF EXISTS total_count;
CREATE TEMP TABLE total_count AS (
    SELECT COUNT(DISTINCT customer_id) AS num
    FROM foodie_fi.subscriptions
);

WITH abb_count AS 
(
  SELECT
    COUNT(*) AS total_abb 
  FROM
    (
      SELECT
        s.*,
        LEAD(plan_id, 1) OVER (PARTITION BY customer_id 
      ORDER BY
        start_date) AS next_plan 
      FROM
        subscriptions AS s
    )
    w 
  WHERE
    w.plan_id = 0 
    AND w.next_plan IN (1,2,3)
)
SELECT
  abb_count.total_abb,
  round((abb_count.total_abb::FLOAT / total_count.num::FLOAT)*100) AS perc 
FROM
  abb_count,
  total_count;
```

| total_abb | perc |
|----------|-------|
|      908 |   91  |


### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
WITH last_plan AS 
(
  SELECT
    s.customer_id,
    p.plan_name,
    s.start_date,
    ROW_NUMBER() OVER(PARTITION BY customer_id 
  ORDER BY
    start_date DESC) 
  FROM
    subscriptions s 
    JOIN
      plans p 
      ON s.plan_id = p.plan_id 
  WHERE
    start_date <= '2020-12-31'
)
,
total_count AS 
(
  SELECT
    COUNT(DISTINCT customer_id) AS num 
  FROM
    foodie_fi.subscriptions
)
,
count_groups AS
(
  SELECT
    plan_name,
    COUNT(plan_name) 
  FROM
    last_plan 
  WHERE
    last_plan.ROW_NUMBER = 1 
  GROUP BY
    last_plan.plan_name
)
SELECT
  count_groups.*,
  round((count_groups.COUNT::NUMERIC / total_count.num::NUMERIC)*100, 2) AS perc 
FROM
  count_groups,
  total_count;
```

   plan_name   | count | perc  
---------------|-------|-------
 basic monthly |   224 | 22.40
 churn         |   236 | 23.60
 pro annual    |   195 | 19.50
 pro monthly   |   326 | 32.60
 trial         |    19 |  1.90


### 8. How many customers have upgraded to an annual plan in 2020?

```sql
WITH cte AS 
(
  SELECT
    s.*,
    LEAD(plan_id, 1) OVER (PARTITION BY customer_id 
  ORDER BY
    start_date) AS next_plan 
  FROM
    subscriptions AS s
)
SELECT
  COUNT(*) as total_ann_abb
FROM
  cte 
WHERE
  next_plan = 3 
  AND date_part('year', start_date) = 2020;
```

| total_ann_abb |
|---------------|
|       253     |


### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
WITH ann_plan_dates AS 
(
  SELECT
    s1.*
  FROM
    subscriptions AS s1
  WHERE plan_id = 3
), join_dates AS (
  SELECT
    s2.*,
    ROW_NUMBER() OVER (PARTITION BY s2.customer_id 
  ORDER BY
    s2.start_date) AS row_number
    FROM subscriptions as s2
)
SELECT
 ROUND(AVG(t1.start_date - t2.start_date), 2) as avg_days_before_year_abb
FROM
  ann_plan_dates t1 LEFT JOIN join_dates t2 ON t1.customer_id = t2.customer_id WHERE t2.row_number=1;
```

|avg_days_before_year_abb |
|-------------------------|
|                   104.62|


### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
SELECT cases as buckets, ROUND(AVG(days),2) AS avg_days FROM (SELECT days, CASE WHEN d.days<31 THEN 'lessThan30days' WHEN d.days<61 THEN 'lessThan60days' WHEN d.days<90 THEN 'lessThan90days' WHEN d.days<181 THEN 'lessThan6month' WHEN d.days<365 THEN 'lessThan1year' ELSE 'moreThanOneYear' END as cases FROM (WITH ann_plan_dates AS 
(
  SELECT
    s1.*
  FROM
    subscriptions AS s1
  WHERE plan_id = 3
), join_dates AS (
  SELECT
    s2.*,
    ROW_NUMBER() OVER (PARTITION BY s2.customer_id 
  ORDER BY
    s2.start_date) AS row_number
    FROM subscriptions as s2
)
SELECT
 t1.start_date - t2.start_date as days
FROM
  ann_plan_dates t1 LEFT JOIN join_dates t2 ON t1.customer_id = t2.customer_id WHERE t2.row_number=1) d) c GROUP BY buckets;
```

|    buckets     | avg_days|
|----------------|---------|
| lessThan1year  |   213.16|
| lessThan30days |     9.96|
| lessThan60days |    42.33|
| lessThan6month |   132.01|
| lessThan90days |    70.88|


### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
