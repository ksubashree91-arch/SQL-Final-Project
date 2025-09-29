CREATE DATABASE HR_Analytics_db;
USE HR_Analytics_db;

-- STEP:1.CREATE TABLES --
-- Employees table --
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DepartmentID INT,
    JoinDate DATE
);

-- Departments table --
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100)
);

-- Salaries table --
CREATE TABLE Salaries (
    SalaryID INT PRIMARY KEY,
    EmployeeID INT,
    Salary DECIMAL(10,2),
    EffectiveDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Attendance table --
CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY,
    EmployeeID INT,
    AttendanceDate DATE,
    Status VARCHAR(20), -- Present, Absent, Leave
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Performance table --
CREATE TABLE Performance (
    PerfID INT PRIMARY KEY,
    EmployeeID INT,
    PerformanceScore INT,
    ReviewDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- STEP:2- Query-Employees earning above average salary --
SELECT e.EmployeeID, e.FirstName, e.LastName, s.Salary
FROM Employees e
JOIN Salaries s ON e.EmployeeID = s.EmployeeID
WHERE s.Salary > (SELECT AVG(Salary) FROM Salaries);

-- STEP:3-Query-Highest-paid employee in each department --
SELECT d.DepartmentName, e.FirstName, e.LastName, s.Salary
FROM Employees e
JOIN Salaries s ON e.EmployeeID = s.EmployeeID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE s.Salary = (
    SELECT MAX(s2.Salary)
    FROM Salaries s2
    JOIN Employees e2 ON s2.EmployeeID = e2.EmployeeID
    WHERE e2.DepartmentID = e.DepartmentID
);
-- STEP:4-Ranking Employees by Performance (Window Functions) --
SELECT e.EmployeeID, e.FirstName, e.LastName, p.PerformanceScore,
       RANK() OVER (ORDER BY p.PerformanceScore DESC) AS Rank_Pos,
       DENSE_RANK() OVER (ORDER BY p.PerformanceScore DESC) AS Dense_Rank_Pos
FROM Employees e
JOIN Performance p ON e.EmployeeID = p.EmployeeID;

-- STEP:5-Stored Procedure-Employees Joined in Last 6 Months---
DELIMITER $$

CREATE PROCEDURE GetRecentEmployees()
BEGIN
    SELECT EmployeeID, FirstName, LastName, JoinDate
    FROM Employees
    WHERE JoinDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
END $$

DELIMITER ;
SHOW TABLES;