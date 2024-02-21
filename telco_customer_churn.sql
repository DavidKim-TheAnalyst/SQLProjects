USE telco_customer_churn;
-- Data Pulling check
SELECT * FROM telco_customer_churn LIMIT 5;
-- Checking all column and its type.
DESCRIBE telco_customer_churn;

-- How many customer are there and how many churn their service?
CREATE TABLE churn_int AS
SELECT *,
    CASE WHEN Churn = 'No' THEN 0
         ELSE 1
    END AS churn_flag
FROM telco_customer_churn;

SELECT
    COUNT(customerID) AS total_customer,
    SUM(churn_flag) AS churn_customer,
    ROUND(SUM(churn_flag)/COUNT(customerID)*100,1) AS churn_rate
FROM
    churn_int;
/*
There are 7032 customers who use either phone or internet service with Telco company.
About 26.6% of customer  or 1869 customers had churned the service and switch to competitor's service.
*/

SELECT
	PhoneService,
	InternetService,
	Contract,
	PaperlessBilling,
	SUM(churn_flag) AS churned_customers,
    ROUND(SUM(churn_flag)/COUNT(*)*100,1) AS churn_rate,
    ROUND(SUM(churn_flag)/(SELECT COUNT(*) FROM telco_customer_churn)*100,1) AS churn_rate_total
FROM
	churn_int
GROUP BY
	PhoneService,
	InternetService,
	Contract,
	PaperlessBilling
ORDER BY
	churned_customers DESC;

SELECT
	PhoneService,
	InternetService,
	Contract,
	SUM(churn_flag) AS churned_customers,
    ROUND(SUM(churn_flag)/COUNT(*)*100,1) AS churn_rate,
    ROUND(SUM(churn_flag)/(SELECT COUNT(*) FROM telco_customer_churn)*100,1) AS churn_rate_total
FROM
	churn_int
GROUP BY
	PhoneService,
	InternetService,
	Contract
ORDER BY
	churned_customers DESC;
/*

The overall churn rate for the company averages at 26.6%, but attention is drawn to 10 specific groups surpassing this average.
Notably, the group choosing a month-to-month contract with paperless billing for phone service and Fiber optic internet exhibits the highest churn rate at 57%.
Interestingly, this group constitutes 13.7% of the total customer base, exerting a considerable impact on the overall churn rate.

The second-largest group, sharing the same characteristics but without opting for paperless billing, experiences a churn rate of 45.6%.
This sheds light on the significance of investigating this customer segment, emphasizing the need to understand the reasons behind the elevated churn rate, which stands at about 54.6%, involving 1162 customers.
Devoting attention to this group is essential for identifying and addressing the factors contributing to their churn.
*/

CREATE TEMPORARY TABLE churn_spec_group AS 
SELECT *
FROM churn_int
WHERE
	PhoneService ="Yes"
    AND InternetService = "Fiber optic"
    AND Contract = "Month-to-month";

select * from churn_spec_group WHERE churn_flag =1;
/*
There are multiple factors that can affect the decision to churn, including gender, seniority, partnership status, dependents, tenure, multiple lines, and monthly charges.
We will analyze how these factors are grouped within the dataset.
*/
-- Gender
SELECT
    ROUND((SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) / COUNT(*)) * 100,1) AS churn_rate_female,
    100-ROUND((SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) / COUNT(*)) * 100,1) AS churn_rate_male
FROM churn_spec_group;
-- Seniority
SELECT
    ROUND((SUM(SeniorCitizen) / COUNT(customerID)) * 100,1) AS churn_rate_Senior,
    100-ROUND((SUM(SeniorCitizen) / COUNT(customerID)) * 100,1) AS churn_rate_non
FROM churn_spec_group;

-- Partner
SELECT
    ROUND((SUM(CASE WHEN Partner = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100,1) AS churn_rate_partner,
    100-ROUND((SUM(CASE WHEN Partner = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100,1) AS churn_rate_no
FROM churn_spec_group;
-- Dependant
SELECT
    ROUND((SUM(CASE WHEN Dependents = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100,1) AS churn_rate_dependent,
    100-ROUND((SUM(CASE WHEN Dependents = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100,1) AS churn_rate_no
FROM churn_spec_group;
-- tenure
SELECT
    tenure,
    SUM(churn_flag) AS total_churn,
    ROUND(SUM(churn_flag) / 
          (SELECT SUM(churn_flag) FROM churn_int
           WHERE PhoneService = "Yes"
                 AND InternetService = "Fiber optic"
                 AND Contract = "Month-to-month"
          ) * 100, 1) AS churn_rate,
    ROUND(SUM(SUM(churn_flag)) OVER (ORDER BY tenure) / 
          (SELECT SUM(churn_flag) FROM churn_int
           WHERE PhoneService = "Yes"
                 AND InternetService = "Fiber optic"
                 AND Contract = "Month-to-month"
          ) * 100, 1) AS running_churn_rate
FROM churn_spec_group
GROUP BY tenure
ORDER BY tenure;

-- multiple line
SELECT
    ROUND((SUM(CASE WHEN MultipleLines = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100,1) AS churn_rate_multiple,
    100-ROUND((SUM(CASE WHEN MultipleLines = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100,1) AS churn_rate_no
FROM churn_spec_group;
-- Monthly Charge
SELECT
    CASE WHEN MonthlyCharges <=60 THEN '$0-60'
		 WHEN MonthlyCharges <=70 THEN '$60-70'
         WHEN MonthlyCharges <=80 THEN '$70-80'
         WHEN MonthlyCharges <=90 THEN '$80-90'
         WHEN MonthlyCharges <=100 THEN '$90-100'
         WHEN MonthlyCharges <=110 THEN '$100-110'
         ELSE '$110 +'
         END AS monthly_group,
    SUM(churn_flag) AS total_churn,
    (SELECT ROUND(AVG(MonthlyCharges),1) FROM churn_int) AS avg_monthly_charge,
	(SELECT ROUND(AVG(MonthlyCharges),1)
     FROM churn_int
     WHERE
		PhoneService ="Yes"
		AND InternetService = "Fiber optic"
		AND Contract = "Month-to-month") AS avg_monthly_charge_churned
FROM churn_spec_group
GROUP BY monthly_group
ORDER BY total_churn DESC;

SELECT 
    AVG(MonthlyCharges)
FROM
    churn_int;
/*
Gender:
In the group of individuals who opted to discontinue the service, 50.1% were female, and 49.9% were male.
The marginal difference suggests that, in this preliminary analysis, it is too minimal to draw a conclusive inference regarding whether gender has a significant impact on churn.
Senior Citizens:
29.9% of customers who discontinued the service were senior citizens.
Partner:
Only 39.5% of churned customers had a partner who shared the service.
Dependents:
Only 16.3% of churned customers had dependents.
Tenure:
28.7% of customers who discontinued the service had a tenure of less than 4 years.
Additionally, 17.5% of customers retained the service for only a year, significantly impacting the overall retention rate.
Multiple Lines:
57.2% of churned customers had more than one service.
Monthly Payment:
The average monthly payment made by all customers is approximately $64.8.
Interestingly, among customers who chose to discontinue the service, the average monthly payment was higher at $87, representing a $23 difference from the company average.
In this preliminary analysis, we can formulate a hypothesis that suggests a potential correlation between a higher monthly payment and the decision to churn. 
*/