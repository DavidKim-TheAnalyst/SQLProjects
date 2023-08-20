USE study;
#________________________________________________________________________________________________________________________________________________#
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'study'
AND TABLE_NAME = 'chipotle';
#________________________________________________________________________________________________________________________________________________#
ALTER TABLE chipotle
CHANGE COLUMN `癤퓇rder_id` order_id int;
#________________________________________________________________________________________________________________________________________________#
# Data Check
SELECT * 
FROM chipotle
limit 10;

SELECT
   COUNT(*) as total_row
FROM chipotle;
/*
The Chipotle dataset has been effectively loaded into an SQL database, encompassing a total of 4622 entries.
*/
#________________________________________________________________________________________________________________________________________________#
SELECT
   COLUMN_NAME
 , DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'study'
AND TABLE_NAME = 'chipotle';
/*
The dataset is comprised of five columns, namely order ID, quantity, item name, choice description, and item price.
Notably, the item price column has an erroneous data type due to the presence of dollar signs. 
*/
# Removing $ sign in item_price column
UPDATE chipotle
SET item_price = CAST(SUBSTRING(item_price, 2) AS DECIMAL(10, 2));

ALTER TABLE chipotle
MODIFY item_price DECIMAL(10, 2);
#________________________________________________________________________________________________________________________________________________#
# How many items are in the dataset?
SELECT
	COUNT(distinct(item_name)) as total_menu
FROM chipotle;
/*
Within this dataset, there exist 50 unique item names.
*/
#________________________________________________________________________________________________________________________________________________#
# Top 10 the most sold items
SELECT
   distinct(item_name)
 , sum(quantity) as total_sold
FROM chipotle
GROUP BY item_name
ORDER BY total_sold desc
limit 10;

# Best selling protein
WITH protein AS (
    SELECT
        CASE WHEN item_name LIKE '%Chicken%' THEN 'chicken'
            WHEN item_name LIKE '%Steak%' THEN 'steak'
            WHEN item_name LIKE '%Veggie%' THEN 'veggie'
            WHEN item_name LIKE '%Carnitas%' THEN 'carnitas'
        END AS protein_category
    FROM chipotle
)
SELECT
   protein_category
 , COUNT(*) AS total_sold
 , ROUND(COUNT(*)/(SELECT COUNT(*) FROM protein WHERE protein_category IS NOT NULL)*100,2) as percentage
FROM protein
WHERE protein_category IS NOT NULL
GROUP BY protein_category
ORDER BY total_sold DESC;

/*
The top five best-selling items at Chipotle, in descending order, are Chicken Bowl, Chicken Burrito,
Chips and Guacamole, Steak Burrito, and Canned Soft Drink.
Chicken items are the most popular, accounting for the highest percentage of sales at 58.76%.
This indicates that customers prefer chicken-based options over other protein choices.
Steak items are the second-highest in sales, making up 26.44% of the total.
While not as popular as chicken, steak still contributes significantly to Chipotle's sales.
The data indicates that customers tend to lean more towards traditional protein options like chicken and steak. 
*/

#________________________________________________________________________________________________________________________________________________#
# Menu price for Main entree
SELECT
  item_name,
   MIN(item_price) AS min_price
FROM chipotle
WHERE item_name LIKE '%Bowl%' OR item_name LIKE '%Burrito%' OR item_name LIKE '%Tacos%'
GROUP BY item_name
ORDER BY item_name;

/*
Sample result:
item_name				min_price
Barbacoa Bowl			8.69
Barbacoa Burrito		8.69
Barbacoa Crispy Tacos	8.99
Barbacoa Salad Bowl		9.39
Barbacoa Soft Tacos		8.99
Bowl					7.40
*/
#________________________________________________________________________________________________________________________________________________#
# What is the average dollar spent per order? What is the most expensive order and how many items were sold in that order?
SELECT
   ROUND(AVG(total_cost),2) as avg_cost_per_order
 , ROUND(MAX(total_cost),2) as max_cost_per_order
 , ROUND(MIN(total_cost),2) as min_cost_per_order
FROM(
	SELECT
	   SUM(item_price) AS total_cost
	FROM chipotle
	GROUP BY order_id
    ) a
;

SELECT
   order_id
 , SUM(item_price) AS total_cost
 , sum(quantity)
FROM chipotle
GROUP BY order_id
order by total_cost desc
LIMIT 1;
/*
The average cost per order is calculated to be $18.81.
This value represents the average amount spent on an order, considering all orders in the dataset.
The average cost per order can be an important metric for businesses to understand the typical spending behavior of their customers.
Moreover, there exists an exceptional case within the dataset, characterized by a maximum cost order.
This specific order encompasses a total of 23 items, culminating in an expenditure of $205.25.
*/
#________________________________________________________________________________________________________________________________________________#
