/*
Objective:
Conducted a comprehensive analysis of sales data from January 10th, 2003, to September 9th, 2004, utilizing SQL queries on the "sample_sales_data_1" database.

Key Actions:
Cleaned data by addressing null values and transforming the 'ORDERDATE' column from text to datetime.
Explored the date range, revealing 252 orders during the specified period.

Customer Insights:
Analyzed 92 unique customers placing 2,823 orders, with an average of 35.09 units per order, contributing to an average sales volume of $3,553.89.
Investigated the top 5 customers, highlighting the Euro Shopping Channel's significant transactions.

Temporal Analysis:
Explored yearly and monthly order trends, dispelling the misconception that 2005 was a weak year by considering the data only until May.
Identified November as the highest sales month, advising increased production in Q2 to meet second-half demand.

Global Market Overview:
Examined orders from 19 countries, with the USA, Spain, France, Australia, and the UK contributing 70% of total orders.
Analyzed the market share trends, noting declining USA market share but positive growth in Spain, France, and Australia.

Product Performance:
Evaluated the top 10 products, emphasizing Classic cars' exceptional performance with a 34.3% share and $3,919,616 in total sales.

Deal Size Classification:
Classified orders into 'Small,' 'Medium,' and 'Large' based on sales volume.

Conclusion:
Provided actionable insights into customer behaviors, temporal trends, global market dynamics, product performance, and deal size classification, aiding strategic decision-making for business enhancement.
*/
/*
Data Source:
	https://www.kaggle.com/kyanyoga/sample-sales-data
*/
USE sample_sales_data_1;
-- Check if nba table is successfully imported
SELECT * FROM sales_data_sample LIMIT 10;

-- Check the data column types
SELECT
	column_name
  , DATA_TYPE
FROM INFORMATION_SCHEMA.columns
WHERE table_schema = 'sample_sales_data_1' AND table_name = 'sales_data_sample';

-- Alter 'ORDERDATE' type from text to a datetime by replacing its col with a new column
ALTER TABLE sales_data_sample
ADD COLUMN NEW_ORDERDATE DATE;
UPDATE sales_data_sample
SET NEW_ORDERDATE = STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i');
ALTER TABLE sales_data_sample
DROP COLUMN ORDERDATE,
CHANGE COLUMN NEW_ORDERDATE ORDERDATE DATE;


-- What is the date range for orders in this dataset?
SELECT
	MIN(ORDERDATE) AS first_order_date
  , MAX(ORDERDATE) AS last_order_date
FROM sales_data_sample;

SELECT
   COUNT(DISTINCT(ORDERDATE)) AS total_order_num
FROM sales_data_sample;
/*
This dataset encompasses a total of 252 orders, spanning from the initial order on January 10th, 2003,to the concluding order on September 9th, 2004.
*/

-- How many customers were present, how frequently did they place orders, and what are the average quantities and sales amounts per order?
SELECT
	COUNT(DISTINCT(CUSTOMERNAME)) AS customer_total
  , COUNT(ORDERNUMBER) AS total_order
  , AVG(QUANTITYORDERED) AS avg_quantity
  , AVG(SALES) AS avg_sales_vol
  , COUNT(DISTINCT(PRODUCTCODE)) AS product_num
  , COUNT(DISTINCT(COUNTRY)) AS country
FROM sales_data_sample;
/*
92 customers made an purchase from 19 countries all over the world.
The dataset comprises 92 unique customers who placed a total of 2823 orders between January 10th, 2003, and September 9th, 2004.
On average, each order consists of approximately 35.09 units of products, contributing to an average sales volume of $3553.89 per order.
The dataset encompasses a diverse range of 109 unique products.
*/

-- Top 5 most purchased customer
SELECT
	CUSTOMERNAME
  , COUNT(ORDERNUMBER) AS total_order_freq
  , SUM(QUANTITYORDERED) AS total_quantity
  , ROUND(SUM(SALES),1) AS total_sales_vol
  , AVG(QUANTITYORDERED) AS avg_quantity
  , ROUND(AVG(SALES),1) AS avg_sales_vol
  , MIN(ORDERDATE) AS first_order
  , MAX(ORDERDATE) AS lASt_order
  , COUNT(DISTINCT(PRODUCTCODE)) AS product_num
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY
	total_sales_vol DESC
  , total_quantity DESC
LIMIT 10;
/*
The Euro Shopping Channel has made 259 transactions, acquiring a total of 9327 items from a range of 106 distinct products.
The cumulative revenue recorded from these transactions amounts to $912,294, covering the period from January 2003 to May 2005.
Among the top 10 customers, their average sales volume and average item counts did not show significant deviations from the overall market averages.
*/

-- Which year did customers order the most?
SELECT
	YEAR(ORDERDATE) AS year
  , COUNT(DISTINCT(MONTH(ORDERDATE))) AS months_in_year
  , COUNT(ORDERNUMBER) AS total_order_freq
  , SUM(QUANTITYORDERED) AS total_quantity
  , ROUND(SUM(SALES),1) AS total_sales_vol
FROM sales_data_sample
GROUP BY year
ORDER BY year;
SELECT
	YEAR(ORDERDATE) AS year
  , ROUND(COUNT(ORDERNUMBER)/COUNT(DISTINCT(MONTH(ORDERDATE))),1) AS total_order_freq_per_month
  , ROUND(SUM(QUANTITYORDERED)/COUNT(DISTINCT(MONTH(ORDERDATE))),1) AS total_quantity_per_month
  , ROUND(SUM(SALES)/COUNT(DISTINCT(MONTH(ORDERDATE))),1) AS total_sales_vol_per_month
FROM sales_data_sample
GROUP BY year
ORDER BY year;

/*
Comparing sales at the yearly level might suggest that 2005 was a weaker year with only 478 orders, in contrast to 1000 and 1345 orders in 2003 and 2004, respectively. However, this could be misleading, AS the data for 2005 only includes information until May.
A more accurate analysis at the monthly level reveals that 2003 had the lowest sales, while 2004 exhibited the highest performance.
*/

-- Which month did customers order the most?
SELECT
	MONTH(ORDERDATE) AS month
  , ROUND(COUNT(ORDERNUMBER)/COUNT(DISTINCT(YEAR(ORDERDATE))),1) AS total_order_freq_per_month
  , ROUND(SUM(QUANTITYORDERED)/COUNT(DISTINCT(YEAR(ORDERDATE))),1) AS total_quantity_per_month
  , ROUND(SUM(SALES)/COUNT(DISTINCT(YEAR(ORDERDATE))),1) AS total_sales_vol_per_month
FROM sales_data_sample
GROUP BY month
ORDER BY total_order_freq_per_month DESC;
/*
Taking into account the limited data for 2005, the average sales figures reveal that November had the highest sales volume, followed by October and August.
The top 5 months are all in the second half of the year, indicating a trend where customers tend to accumulate orders after July.
Consequently, it's advisable for the company to anticipate significant orders in the latter part of the year by boosting production in Q2.
*/

-- TOP country in orders
SELECT
	COUNTRY
  , COUNT(COUNTRY) AS total_order
  , ROUND(COUNT(COUNTRY)/(SELECT COUNT(*) FROM sales_data_sample)*100,1) AS country_share
  , SUM(ROUND(COUNT(COUNTRY)/(SELECT COUNT(*) FROM sales_data_sample)*100,1)) OVER (ORDER BY COUNT(COUNTRY) DESC) AS running_sum_share
  , ROUND(SUM(SALES),2) AS total_dollar
  , ROUND(SUM(SALES)/(SELECT SUM(SALES) FROM sales_data_sample)*100,1) AS dollar_share
  , SUM(QUANTITYORDERED) AS total_quantity
  , ROUND(SUM(QUANTITYORDERED)/(SELECT SUM(QUANTITYORDERED) FROM sales_data_sample)*100,1) AS quantity_share
FROM sales_data_sample
GROUP BY COUNTRY
ORDER BY total_order DESC
;
	-- Evaluating top 10 countries' market share trend over the span of 18 months.
SELECT
	COUNTRY
  , YEAR(ORDERDATE) AS year
  , COUNT(COUNTRY) AS total_order
  , ROUND(COUNT(COUNTRY) / (SELECT COUNT(*) FROM sales_data_sample WHERE YEAR(ORDERDATE) = year) * 100, 1) AS country_share
FROM sales_data_sample t1
JOIN 
(
	SELECT
		COUNTRY as coun
	  , COUNT(COUNTRY) AS total_order
	  , ROUND(COUNT(COUNTRY)/(SELECT COUNT(*) FROM sales_data_sample)*100,1) AS country_share
	FROM sales_data_sample
	GROUP BY COUNTRY
	ORDER BY total_order DESC
	LIMIT 10
) t2
ON t1.COUNTRY = t2.coun
GROUP BY year, COUNTRY
ORDER BY COUNTRY, year,country_share DESC
;
/*
The analysis reveals that orders originated from 19 countries globally,
with the United States, Spain, France, Australia, and the UK emerging as the top five contributors in terms of order numbers over the span of 18 months.
These countries collectively accounted for a significant 70% of the total order share, with the USA, Spain, and France individually contributing 35.6%, 12.1%, and 11.1%, respectively.
While it remains crucial to maintain focus on these top three countries, a nuanced examination of their sales trends unveils noteworthy insights.
Notably, the USA, despite being the primary contributor, displays a declining trend since 2003, experiencing an annual loss of more than 1% in market share.
Conversely, Spain, France, and Australia exhibit positive growth in market share, emphasizing the importance of understanding and adapting to evolving market dynamics.
*/

-- Top 10 products in sales
SELECT
    PRODUCTLINE
  , AVG(MSRP) AS price
  , ROUND(SUM(QUANTITYORDERED) / (SELECT SUM(QUANTITYORDERED) FROM sales_data_sample) * 100, 2) AS product_share_percent
  , SUM(QUANTITYORDERED) AS total_quantity
  , ROUND(SUM(SALES),1) AS total_sales_vol
  , AVG(QUANTITYORDERED) AS avg_quantity
  , ROUND(AVG(SALES),1) AS avg_sales_vol
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY total_quantity DESC;
/*
Classic cars demonstrated exceptional performance by selling 33,992 units over 29 months, securing a noteworthy product share of 34.3%.
With a higher price point, Classic cars contributed significantly to the total sales, reaching $3,919,616.
Following Classic cars, Vintage cars, Motorcycles, and Trucks and buses claimed the second to fourth positions in terms of sales performance.
*/

-- What is deal size?
SELECT
	DEALSIZE
  , MIN(SALES) AS min_sales
  , MAX(SALES) AS max_sales
  , AVG(SALES) AS avg_sales
  , MIN(QUANTITYORDERED) AS min_quantity
  , MAX(QUANTITYORDERED) AS max_quantity
  , AVG(QUANTITYORDERED) AS avg_quantity
FROM sales_data_sample
GROUP BY DEALSIZE;
/*
The "DEALSIZE" column classifies orders based on their sales volume.
Orders with a sales volume below $3,000 are categorized as 'Small,' those exceeding $7,000 fall into the 'Large' category, while those within this range are designated as 'Medium.'
*/