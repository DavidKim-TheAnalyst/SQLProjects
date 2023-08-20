USE study;


SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'study'
AND TABLE_NAME = 'chipotle';

ALTER TABLE chipotle
CHANGE COLUMN `癤퓇rder_id` order_id int;


SELECT * FROM chipotle limit 10;
SELECT COUNT(*) FROM chipotle;

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'study'
AND TABLE_NAME = 'chipotle';

# How many items are in the dataset?
SELECT
	COUNT(distinct(item_name)) as total_menu
FROM chipotle;

# Top 10 the most sold items
SELECT
	distinct(item_name),
    count(item_name) as total_sold
FROM chipotle
GROUP BY item_name
ORDER BY total_sold desc
limit 10;