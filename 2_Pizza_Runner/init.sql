CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


-- To help ourselves, we will create a few VIEWS
CREATE VIEW customer_orders_cleaned AS WITH first_layer AS (
    SELECT order_id,
        customer_id,
        pizza_id,
        CASE
            WHEN exclusions = '' THEN NULL
            WHEN exclusions = 'null' THEN NULL
            ELSE exclusions
        END as exclusions,
        CASE              
            WHEN extras = '' THEN NULL
            WHEN extras = 'null' THEN NULL
            ELSE extras
        END as extras,
        order_time
    FROM customer_orders
)
SELECT ROW_NUMBER() OVER (
        -- We are adding a row_number rank to deal with orders having multiple times the same pizza in it
        ORDER BY order_id,                                                                               
            pizza_id
    ) AS row_number_order,
    order_id,
    customer_id,
    pizza_id,
    exclusions,
    extras,
    order_time
  FROM first_layer;


CREATE VIEW extras_exclusions AS SELECT customers_info.order_id,
    customers_info.pizza_id,
    pizza_names.pizza_name,
    customers_info.exclusion_col1,
    top1.topping_name AS topping_name1,
        CASE
            WHEN (customers_info.exclusion_col2 = ''::text) THEN NULL::integer
            ELSE (TRIM(BOTH FROM customers_info.exclusion_col2))::integer
        END AS exclusion_col2,
    customers_info.extras_col1,
    top2.topping_name AS topping_name3,
        CASE
            WHEN (customers_info.extras_col2 = ''::text) THEN NULL::integer
            ELSE (TRIM(BOTH FROM customers_info.extras_col2))::integer
        END AS extras_col2
   FROM (((( SELECT customer_orders_cleaned.order_id,
            customer_orders_cleaned.pizza_id,
            split_part((customer_orders_cleaned.exclusions)::text, ','::text, 1) AS exclusion_col1,
            split_part((customer_orders_cleaned.exclusions)::text, ','::text, 2) AS exclusion_col2,
            split_part((customer_orders_cleaned.extras)::text, ','::text, 1) AS extras_col1,
            split_part((customer_orders_cleaned.extras)::text, ','::text, 2) AS extras_col2
           FROM customer_orders_cleaned
          ORDER BY customer_orders_cleaned.order_id) customers_info
     JOIN pizza_names ON ((customers_info.pizza_id = pizza_names.pizza_id)))
     LEFT JOIN pizza_toppings top1 ON (((customers_info.exclusion_col1)::integer = top1.topping_id)))
     LEFT JOIN pizza_toppings top2 ON (((customers_info.extras_col1)::integer = top2.topping_id)));