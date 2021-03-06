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
 pizza_name | topping_id | topping_name 
------------|------------|--------------
 Meatlovers |          2 | BBQ Sauce
 Meatlovers |          8 | Pepperoni
 Meatlovers |          4 | Cheese
 Meatlovers |         10 | Salami
 Meatlovers |          5 | Chicken
 Meatlovers |          1 | Bacon
 Meatlovers |          6 | Mushrooms
 Meatlovers |          3 | Beef
 Vegetarian |         12 | Tomato Sauce
 Vegetarian |          4 | Cheese
 Vegetarian |          6 | Mushrooms
 Vegetarian |          7 | Onions
 Vegetarian |          9 | Peppers
 Vegetarian |         11 | Tomatoes

### 2. What was the most commonly added extra?
```sql
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
```
|topping_name |
|-------------|
|       Bacon |

### 3. What was the most common exclusion?
```sql
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
```
|topping_name |
|-------------|
|       Cheese|

### 3. Generate an order item for each record in the `customers_orders` table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
