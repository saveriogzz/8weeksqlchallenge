------------------------------------
---- C. Ingredient Optimisation ----
------------------------------------

-- C1. What are the standard ingredients for each pizza?
WITH pizza_recipes_unnested AS 
(
  SELECT
    pizza_id,
    CAST( UNNEST( string_to_array(toppings, ', ') ) AS INT ) AS topping_id 
  FROM
    pizza_recipes 
)
SELECT
  pn.pizza_name,
  pr.topping_id,
  pt.topping_name 
FROM
  pizza_names pn 
  JOIN
    pizza_recipes_unnested pr 
    ON pn.pizza_id = pr.pizza_id 
  JOIN
    pizza_toppings pt 
    ON pr.topping_id = pt.topping_id
ORDER BY
  pizza_name;

-- C2. What was the most commonly added extra?
WITH extra_count AS 
(
  SELECT
    CAST (UNNEST( string_to_array(extras, ', ')) AS INT) AS extra_unnested,
    COUNT(*) 
  FROM
    customer_orders_cleaned 
  GROUP BY
    extra_unnested 
  ORDER BY
    COUNT DESC LIMIT 1
)
SELECT
  topping_name 
FROM
  extra_count ec 
  JOIN
    pizza_toppings pt 
    ON ec.extra_unnested = pt.topping_id;

-- C3. What was the most common exclusion?
WITH excl_count AS 
(
  SELECT
    CAST (UNNEST( string_to_array(exclusions, ', ')) AS INT) AS excl_unnested,
    COUNT(*) 
  FROM
    customer_orders_cleaned 
  GROUP BY
    excl_unnested 
  ORDER BY
    COUNT DESC LIMIT 1
)
SELECT
  topping_name 
FROM
  excl_count ec 
  JOIN
    pizza_toppings pt 
    ON ec.excl_unnested = pt.topping_id;

