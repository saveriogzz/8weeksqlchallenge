# C - Ingredient Optmisation

### 1. What are the standard ingredients for each pizza?
TODO: finish this
```sql
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
```

### 3. What was the most commonly added extra?
