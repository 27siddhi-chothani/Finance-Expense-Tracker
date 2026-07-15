create database finance;

use finance;

---- create users table ----
CREATE TABLE Users(
UserID INT PRIMARY KEY,
UserName VARCHAR(100),
City VARCHAR(50),
JoinDate DATE
);

INSERT INTO Users VALUES
(101,'Amit Sharma','Mumbai','2025-01-01'),
(102,'Priya Singh','Pune','2025-01-05'),
(103,'Rahul Verma','Delhi','2025-01-10'),
(104,'Sneha Patil','Bangalore','2025-01-12'),
(105,'Karan Mehta','Hyderabad','2025-01-15');

---- create categories table ----
CREATE TABLE Categories(
CategoryID INT PRIMARY KEY,
CategoryName VARCHAR(50)
);

INSERT INTO Categories VALUES
(1,'Food'),
(2,'Transport'),
(3,'Shopping'),
(4,'Bills'),
(5,'Entertainment'),
(6,'Healthcare'),
(7,'Education'),
(8,'Travel');

---- create income table ----
CREATE TABLE Income(
IncomeID INT PRIMARY KEY,
UserID INT,
IncomeDate DATE,
Source VARCHAR(50),
Amount DECIMAL(10,2)
);

INSERT INTO Income VALUES
(1,101,'2025-06-01','Salary',70000),
(2,102,'2025-06-01','Salary',60000),
(3,103,'2025-06-01','Salary',75000),
(4,104,'2025-06-01','Salary',65000),
(5,105,'2025-06-01','Salary',80000),
(6,101,'2025-06-20','Freelancing',10000),
(7,103,'2025-06-18','Bonus',15000),
(8,105,'2025-06-22','Investments',8000);

---- create budgets table ----
CREATE TABLE Budgets(
BudgetID INT PRIMARY KEY,
UserID INT,
CategoryID INT,
BudgetAmount DECIMAL(10,2),
MonthName VARCHAR(20)
);

INSERT INTO Budgets VALUES
(1,101,1,12000,'June'),
(2,101,2,4000,'June'),
(3,101,3,7000,'June'),
(4,102,1,10000,'June'),
(5,102,4,5000,'June'),
(6,103,5,6000,'June'),
(7,104,6,3000,'June'),
(8,105,8,15000,'June');

--- create expenses table ----
CREATE TABLE Expenses(
ExpenseID INT PRIMARY KEY,
UserID INT,
CategoryID INT,
ExpenseDate DATE,
Amount DECIMAL(10,2),
PaymentMethod VARCHAR(20)
);

INSERT INTO Expenses VALUES
(1,101,1,'2025-06-02',2500,'UPI'),
(2,101,2,'2025-06-03',1200,'Cash'),
(3,101,3,'2025-06-05',3500,'Card'),
(4,101,4,'2025-06-08',2800,'UPI'),
(5,102,1,'2025-06-04',2200,'UPI'),
(6,102,4,'2025-06-06',4200,'Card'),
(7,103,5,'2025-06-05',1800,'Cash'),
(8,103,1,'2025-06-07',2600,'UPI'),
(9,103,2,'2025-06-09',900,'Cash'),
(10,104,6,'2025-06-10',1800,'Card'),
(11,104,3,'2025-06-12',2700,'UPI'),
(12,105,8,'2025-06-14',9000,'Card'),
(13,105,1,'2025-06-15',3500,'UPI'),
(14,105,2,'2025-06-17',1400,'Cash'),
(15,101,5,'2025-06-18',1500,'UPI'),
(16,102,3,'2025-06-20',2800,'Card'),
(17,103,7,'2025-06-21',4000,'UPI'),
(18,104,1,'2025-06-22',2300,'Cash'),
(19,105,4,'2025-06-23',3200,'UPI'),
(20,101,8,'2025-06-25',5000,'Card');

---- create accounts table ----
CREATE TABLE Accounts(
AccountID INT PRIMARY KEY,
UserID INT,
AccountType VARCHAR(30),
Balance DECIMAL(10,2)
);

INSERT INTO Accounts VALUES
(1,101,'Savings',55000),
(2,102,'Savings',48000),
(3,103,'Savings',62000),
(4,104,'Savings',51000),
(5,105,'Savings',70000);

---- QUERIES ----

-- total monthly income
SELECT SUM(Amount) AS TotalIncome
FROM Income;

-- total monthly income
SELECT SUM(Amount) AS TotalExpenses
FROM Expenses;

-- monthly savings 
SELECT
(SELECT SUM(Amount) FROM Income) -
(SELECT SUM(Amount) FROM Expenses)
AS TotalSavings;

-- categories wise spending
SELECT
C.CategoryName,
SUM(E.Amount) AS TotalSpent
FROM Expenses E
JOIN Categories C
ON E.CategoryID=C.CategoryID
GROUP BY C.CategoryName
ORDER BY TotalSpent DESC;

-- budget vs actual spending
SELECT
U.UserName,
C.CategoryName,
B.BudgetAmount,
COALESCE(SUM(E.Amount),0) AS ActualSpent
FROM Budgets B
JOIN Users U ON B.UserID=U.UserID
JOIN Categories C ON B.CategoryID=C.CategoryID
LEFT JOIN Expenses E
ON B.UserID=E.UserID
AND B.CategoryID=E.CategoryID
GROUP BY
U.UserName,
C.CategoryName,
B.BudgetAmount;

-- users exceeding budget
SELECT
U.UserName,
C.CategoryName,
SUM(E.Amount) AS Spent,
B.BudgetAmount
FROM Expenses E
JOIN Budgets B
ON E.UserID=B.UserID
AND E.CategoryID=B.CategoryID
JOIN Users U ON E.UserID=U.UserID
JOIN Categories C ON E.CategoryID=C.CategoryID
GROUP BY
U.UserName,
C.CategoryName,
B.BudgetAmount
HAVING SUM(E.Amount)>B.BudgetAmount;

-- highest spendin users
SELECT top 1
U.UserName,
SUM(E.Amount) AS TotalSpent
FROM Users U
JOIN Expenses E
ON U.UserID=E.UserID
GROUP BY U.UserName
ORDER BY TotalSpent DESC;

-- payment method analysis
SELECT
PaymentMethod,
COUNT(*) TotalTransactions,
SUM(Amount) TotalAmount
FROM Expenses
GROUP BY PaymentMethod;

-- cash flow trends
SELECT
ExpenseDate,
SUM(Amount) AS DailyExpense
FROM Expenses
GROUP BY ExpenseDate
ORDER BY ExpenseDate;

-- income vs expenses
SELECT
U.UserName,
COALESCE(I.TotalIncome,0) Income,
COALESCE(E.TotalExpense,0) Expense,
COALESCE(I.TotalIncome,0)-COALESCE(E.TotalExpense,0) Savings
FROM Users U
LEFT JOIN
(
SELECT UserID,SUM(Amount) TotalIncome
FROM Income
GROUP BY UserID
) I
ON U.UserID=I.UserID
LEFT JOIN
(
SELECT UserID,SUM(Amount) TotalExpense
FROM Expenses
GROUP BY UserID
) E
ON U.UserID=E.UserID;

-- top 5 highest expenses
SELECT top 5 *
FROM Expenses
ORDER BY Amount DESC;

-- running expense total
SELECT
ExpenseDate,
Amount,
SUM(Amount) OVER(ORDER BY ExpenseDate)
AS RunningExpense
FROM Expenses;

-- rank users by savings
SELECT
U.UserName,
(COALESCE(I.TotalIncome,0)-COALESCE(E.TotalExpense,0)) Savings,
RANK() OVER(
ORDER BY
(COALESCE(I.TotalIncome,0)-COALESCE(E.TotalExpense,0)) DESC
) AS SavingsRank
FROM Users U
LEFT JOIN
(
SELECT UserID,SUM(Amount) TotalIncome
FROM Income
GROUP BY UserID
) I ON U.UserID=I.UserID
LEFT JOIN
(
SELECT UserID,SUM(Amount) TotalExpense
FROM Expenses
GROUP BY UserID
) E ON U.UserID=E.UserID;

-- avg expense per user
SELECT
U.UserName,
AVG(E.Amount) AvgExpense
FROM Users U
JOIN Expenses E
ON U.UserID=E.UserID
GROUP BY U.UserName;

-- highest spending categoru
SELECT top 1
C.CategoryName,
SUM(E.Amount) TotalSpent
FROM Categories C
JOIN Expenses E
ON C.CategoryID=E.CategoryID
GROUP BY C.CategoryName
ORDER BY TotalSpent DESC;

