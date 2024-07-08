use project;
create database project;
select * from bank_data;


/*1. What is the distribution of account balances across different regions?*/
SELECT 
    Country, ROUND(SUM(Balance), 4) AS Total_amount
FROM
    bank_data
GROUP BY Country;

/*2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)*/
SELECT 
    Surname, Balance
FROM
    bank_data
ORDER BY Balance DESC
LIMIT 5;
/*3. Calculate the average number of products used by customers who have a credit card. (SQL)*/
SELECT 
    round(AVG(NumOfProducts),2) as AverageNumOfProducts
FROM
    bank_data
WHERE
    creditcard = 1;
/****************************************************************************************************************************************************************/
/*converted the date doj to standard SQl Format Run this code before Q 4*/
SELECT 
    CustomerID, Surname, Gender, Country, Age, Age_group,EstimatedSalary, Balance, Creditcard,CreditScore, CreditScorecatgry, ActiveMember, 
    Tenure, NumOfProducts, Churn, 
    STR_TO_DATE(bank_doj, '%d-%m-%Y %H:%i:%s') AS bank_doj
FROM 
    bank_data;
/*Add New Column*/
ALTER TABLE bank_data ADD COLUMN bank_doj_converted DATE;

UPDATE bank_data 
SET bank_doj_converted = STR_TO_DATE(bank_doj, '%d-%m-%Y %H:%i:%s');
/*Update the existing column*/
UPDATE bank_data 
SET bank_doj = STR_TO_DATE(bank_doj, '%d-%m-%Y %H:%i:%s');
/****************************************************************************************************************************************************************************************************
    
/*4. Determine the churn rate by gender for the most recent year in the dataset.*/
 WITH LatestYearData AS (
    SELECT 
        Gender, 
        Churn
    FROM 
        bank_data
    WHERE 
        YEAR(Bank_doj_converted) = (SELECT MAX(YEAR(Bank_doj_converted)) FROM bank_data)
        AND Churn = 1
),
TotalChurn AS (
    SELECT 
        COUNT(*) AS TotalChurnCount
    FROM 
        LatestYearData
)
SELECT 
    Gender,
    (COUNT(*) * 100.0 / (SELECT TotalChurnCount FROM TotalChurn)) AS ChurnPercentage
FROM 
    LatestYearData
GROUP BY 
    Gender;
  

/*5. Compare the average credit score of customers who have exited and those who remain. (SQL)*/

SELECT 
    Churn, ROUND(AVG(CreditScore)) AS AverageCreditScore
FROM
    bank_data
GROUP BY Churn;

/*6. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)*/

SELECT 
    Gender,
    AVG(EstimatedSalary) AS AverageSalary,
    SUM(CASE WHEN ActiveMember = 1 THEN 1 ELSE 0 END) / COUNT(*) AS AverageActiveAccounts
FROM
    bank_data
GROUP BY Gender;
    
  /*7. Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)*/
 SELECT 
    CreditScorecatgry,
    COUNT(*) AS Churn_rate
FROM
    bank_data
WHERE
    Churn = 1
GROUP BY 
    CreditScorecatgry
ORDER BY 
    Churn_rate DESC
limit 1;
/* 8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)*/  
select Country,count(ActiveMember) as Active_accounts
from bank_data
where Tenure>5 and ActiveMember=1
group by Country
order by Active_accounts Desc
Limit 1;
/*9. What is the impact of having a credit card on customer churn, based on the available data?*/

SELECT 
    Creditcard, COUNT(Churn) AS Churncount
FROM
    bank_data
WHERE
    Churn = 1
GROUP BY Creditcard;

/*10. For customers who have exited, what is the most common number of products they have used?*/

SELECT 
    NumOfProducts, COUNT(*) AS ChurnFrequency
FROM
    bank_data
WHERE
    Churn = 1
GROUP BY NumOfProducts
ORDER BY ChurnFrequency DESC;

/*11. Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL 
and then visualize it.*/

SELECT 
    EXTRACT(YEAR FROM bank_doj_converted) AS YearJoined,
    EXTRACT(MONTH FROM bank_doj_converted) AS MonthJoined,
    COUNT(*) AS TotalCustomers
FROM
    bank_data
GROUP BY 
    YearJoined, MonthJoined
ORDER BY 
    YearJoined, MonthJoined;


/*12. Analyze the relationship between the number of products and the account balance for customers who have exited.*/

SELECT 
    NumOfProducts,
    AVG(Balance) AS AverageBalance
FROM
    bank_data
WHERE
    Churn = 1
GROUP BY 
    NumOfProducts
ORDER BY 
    2; 


/*13. Identify any potential outliers in terms of balance among customers who have remained with the bank.*/
SELECT 
    CustomerID,
    Balance,
    CASE
        WHEN ABS(Balance - (SELECT AVG(Balance) FROM bank_data WHERE Churn = 0)) / (SELECT STDDEV(Balance) FROM bank_data WHERE Churn = 0) > 3 THEN 'Potential Outlier'
        ELSE 'Normal'
    END AS Outlier_Status
FROM 
    bank_data
WHERE 
    Churn = 0;

 /*15. Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to
 the average value. (SQL)*/

SELECT 
    country,
    Gender,
    AVG(EstimatedSalary) AS AverageIncome,
    RANK() OVER (PARTITION BY country ORDER BY AVG(EstimatedSalary) DESC) AS GenderRank
FROM 
    bank_data
GROUP BY 
    country, Gender;

    
    /*16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).*/

SELECT 
    age_group, AVG(Tenure) AS Churn
FROM
    bank_data
WHERE
    Churn = 1
GROUP BY age_group;    
/*17.	Is there any direct correlation between salary and the balance of the customers? And is it different for people who have exited or not?*/

SELECT 
    Churn,
    (COUNT(*) * SUM(Balance * EstimatedSalary) - SUM(Balance) * SUM(EstimatedSalary)) /
    (SQRT((COUNT(*) * SUM(POWER(Balance, 2)) - POWER(SUM(Balance), 2)) * 
          (COUNT(*) * SUM(POWER(EstimatedSalary, 2)) - POWER(SUM(EstimatedSalary), 2))))
AS CorrelationCoefficient
FROM 
    bank_data
GROUP BY 
    Churn;

/*18. Is there any correlation between the salary and the Credit score of customers?*/

SELECT 
    CreditScorecatgry,
    (COUNT(*) * SUM(CreditScore * EstimatedSalary) - SUM(CreditScore) * SUM(EstimatedSalary)) /
    (SQRT(
        (COUNT(*) * SUM(CreditScore * CreditScore) - SUM(CreditScore) * SUM(CreditScore)) * 
        (COUNT(*) * SUM(EstimatedSalary * EstimatedSalary) - SUM(EstimatedSalary) * SUM(EstimatedSalary))
    )) AS CorrelationCoefficient
FROM 
    bank_data
GROUP BY 
    CreditScorecatgry;


/*19. Rank each bucket of credit score as per the number of customers who have churned the bank.*/

SELECT 
    CreditScorecatgry,
    COUNT(*) AS ChurnCount,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS CreditRank
FROM 
    bank_data
WHERE 
    Churn = 1
GROUP BY 
    CreditScorecatgry;


  /*20.	According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average 
number of credit cards per bucket.*/

WITH AgeGroupCounts AS (
    SELECT 
        age_group, 
        COUNT(*) AS No_of_cust
    FROM
        bank_data
    WHERE
        Creditcard = 1
    GROUP BY 
        age_group
),
AverageCount AS (
    SELECT 
        AVG(No_of_cust) AS AvgNoOfCust
    FROM 
        AgeGroupCounts
)
SELECT 
    age_group, 
    No_of_cust
FROM 
    AgeGroupCounts
WHERE 
    No_of_cust < (SELECT AvgNoOfCust FROM AverageCount);  
        
/*21. Rank the Locations as per the number of people who have churned the bank and average balance of the customers.*/

SELECT 
    country,
    COUNT(*) AS ChurnedCustomers,
    AVG(Balance) AS AverageBalance,
    RANK() OVER (ORDER BY COUNT(*) DESC, AVG(Balance) DESC) AS LocationRank
FROM 
    bank_data
WHERE 
    Churn = 1
GROUP BY 
    country;


/*22. As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where 
the format is “CustomerID_Surname”.*/

SELECT CONCAT_WS('', CustomerID, Surname) AS CustomerID_Surname
FROM bank_data;


/*23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.*/
SELECT Churn
FROM 
    bank_data
WHERE 
    Churn = 1;
/*25. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.*/

SELECT 
    CustomerID,
    Surname,
    CASE ActiveMember
        WHEN 1 THEN 'Active'
        ELSE 'Not Active'
    END AS MembershipStatus
FROM 
    bank_data
WHERE 
    Surname LIKE '%on'
ORDER BY 
    Surname;

/*SUBJECTIVE QUESTIONS************************************************************************************************************************/
/*1. Customer Behavior Analysis: What patterns can be observed in the spending habits of long-term customers compared to 
new customers, and what might these patterns suggest about customer loyalty?*/

SELECT 
    CASE
        WHEN Tenure >= 6 THEN 'Long-term'
        ELSE 'New'
    END AS CustomerTenure,
    AVG(EstimatedSalary) AS AverageEstimatedSalary,
    AVG(Balance) AS AverageBalance,
    AVG(NumOfProducts) AS AverageNumOfProducts,
    COUNT(*) AS NumberOfCustomers,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers
FROM 
    bank_data
GROUP BY 
    CASE
        WHEN Tenure >= 6 THEN 'Long-term'
        ELSE 'New'
    END;
    
 /*2. Product Affinity Study: Which bank products or services are most commonly used together, and how might this 
influence cross-selling strategies?*/


SELECT 
    NumOfProducts,
    COUNT(1) AS Count
FROM 
    bank_data
GROUP BY 
    NumOfProducts;
  
/*3. Geographic Market Trends: How do economic indicators in different geographic regions correlate with 
the number of active accounts and customer churn rates?*/

SELECT 
    Country,
    AVG(ActiveMember) AS AvgActiveMembers,
    SUM(Churn) AS TotalChurned,
    COUNT(*) AS TotalCustomers
FROM 
    bank_data
GROUP BY 
    Country;

/*4.Risk Management Assessment: Based on customer profiles,
 which demographic segments appear to pose the highest financial risk to the bank, and why?*/

SELECT 
Churn, ROUND(AVG(CreditScore)) AS AverageCreditScore
FROM  bank_data
GROUP BY  Churn;
/*************************************************************************************************************/
SELECT
 CreditScorecatgry, COUNT(CreditScorecatgry) AS Churned_Count
FROM bank_data
WHERE Churn = 1
GROUP BY CreditScorecatgry
ORDER BY  Churned_Count DESC
LIMIT 1;


/*9.Utilize SQL queries to segment customers based on demographics and account details.*/

 SELECT
Gender,
Country,
COUNT(CustomerId) AS CustomerCount
FROM
bank_data
GROUP BY
Gender, Country;

/*Segment customers based on age group and credit*/

SELECT
age_group,
Creditcard,
COUNT(CustomerId) AS CustomerCount
FROM
bank_data
GROUP BY
age_group, Creditcard;
/*Segment customers based on credit score category and active membership status*/
SELECT
CreditScorecatgry,ActiveMember,
COUNT(CustomerId) AS CustomerCount
FROM
bank_data
GROUP BY
CreditScorecatgry,ActiveMember;


/*14.	In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?*/

ALTER TABLE bank_data
RENAME COLUMN Creditcard TO Has_creditcard;
SELECT * FROM bank_data