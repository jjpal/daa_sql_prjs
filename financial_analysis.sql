-- Return all of the table to review data
-- Note this is not recommended on a production system
SELECT *
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv"


-- How many total transactions were there during this period? 
-- Only the first 5 rows
SELECT COUNT(*)
FROM "IDA_Statement_Of_Credits_and_Grants_-_Historical_Data.csv"
LIMIT 5


-- How many total transactions were there per country
SELECT country, COUNT(*) AS t_transactions
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv"
GROUP BY "country"
LIMIT 20;


-- How much is owed (in total) to the IDA?
SELECT SUM("Due to IDA") 
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv";


-- How much was owed to the IDA across the different regions.
SELECT region, "Due to IDA" AS due 
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv"
LIMIT 20;


-- Review in more detail how much is owed to IDA by adding
-- borrower, country to know where the borrower is from, 
-- filter where borrower owes more than $0 has paid off loan
SELECT borrower, country, "Due to IDA"
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv"
WHERE  "Due to IDA" > 0
ORDER BY "Due to IDA" DESC
LIMIT 5;


-- What is the average service charge rate for a loan? 
SELECT AVG("Service Charge Rate") AS Avg_srv_charge
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv"


-- Check the service charges for Cote d'Ivoire that are greater than $1
SELECT *
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv"
WHERE country = 'Cote d''Ivoire' AND "Service Charge Rate" > 1
ORDER BY "Service Charge Rate" DESC 
LIMIT 20;


-- Who has the most loans? 
SELECT Borrower, country, "Project Name", 
       COUNT("Due to IDA") AS count_ida, SUM("Due to IDA") AS ida_due, 
       SUM("Repaid to IDA") AS ida_paid
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv"
GROUP BY Borrower, country, "Project Name"
HAVING SUM("Due to IDA") > 0
ORDER BY count_ida DESC, ida_due DESC
LIMIT 20



-- Which was the most recent to pay?
-- For this question - there are not too many details, so 
-- after some investigating resulting query
SELECT Borrower, country, "End of Period", "Last Disbursement Date"
FROM "IDA_Statement_Of_Credits_and_Grants__Historical_Data.csv"
WHERE "First Repayment Date" IS NOT null 
     AND "Last Disbursement Date" IS NOT null
GROUP BY 1, 2, 3, 4
ORDER BY "End of Period" DESC, "Last Disbursement Date" DESC
LIMIT 20