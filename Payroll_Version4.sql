/* *****************************************************************************
	FILE:		Group1_PayRoll.sql
	DATE:		2019-11-06
	AUTHOR:		Group 1:
					Mason Hamann
					Inez Gronewold
					Betty Mbuyi
					Haley Hepker
	VERSION: 	4.0
	DESCRIPTION:	Group assignment

	Project: Payroll
	Widukind Woodland Excursions (WWE) has a staff of eight salaried employees 
	and a varying number (twelve to thirty) hourly staff.  The hourly staff may 
	be full or part time.  They need a way to keep track of employees, hours worked 
	(for hourly staff), and calculate the payroll.
	
	WWE pays bi-weekly, and pays for all of the employee insurance, so there are no
	deductions for that.  Hourly employees are paid time-and-a-half for working more
	than forty hours in a single pay period.  Salaried employees are paid a 
	constant amount each pay period.  The amounts differ from one employee to the 
	next.

	WWE needs to know not just the gross pay, but must also calculate the appropriate
	withholdings for Federal Income Tax, Social Security, Medicare, Unemployment Tax,
	and State Income Tax.  Not only must these amounts be removed from the net pay
	for the employee, but records must be kept to know how much to send to the various
	government agencies.
	
	See http://www.wikihow.com/Calculate-Payroll-Taxes

***************************************************************************** */

DROP DATABASE IF EXISTS  payroll;
CREATE DATABASE payroll;
USE payroll;

/*
	Creating the Taxes table.
*/
DROP TABLE IF EXISTS Taxes;
CREATE TABLE Taxes(
	Tax_type VARCHAR(50) NOT NULL PRIMARY KEY COMMENT 'Description of tax type.'
	, Tax_bracket INT NULL COMMENT 'This is only used for the Federal Income Tax to determine which bracket percentage to apply.'
	, Tax_percent DECIMAL(4,2) NOT NULL COMMENT 'The percentage applied to gross pay to calculate the tax type.'
	, Max_pay DECIMAL(8,2) NULL COMMENT 'Maximum pay applicable to tax type. Can be NULL since it does not apply to all tax types.'
) COMMENT 'A table containing various tax types that can be applied to an employee wages. Examples: FICA_SS, FICA_Med, FIT'
;

INSERT INTO Taxes
	(Tax_type, Tax_bracket, Tax_percent,  Max_pay)
VALUES
	('Social Security', NULL, 6.2, 132900.00)
    , ('Medicare', NULL, 1.45, NULL)
    , ('FIT 1', 1, 10.0, NULL)
    , ('FIT 2', 2, 12.0, NULL)
    , ('FIT 3', 3, 22.0, NULL)
    , ('FIT 4', 4, 24.0, NULL)
    , ('FIT 5', 5, 32.0, NULL)
    , ('FIT 6', 6, 35.0, NULL)
	, ('FIT 7', 7, 37.0, NULL)
;

select * from taxes;

/*
	Creating the Zip Code table.
*/
DROP TABLE IF EXISTS Zipcode;
CREATE TABLE Zipcode(
	Zip CHAR(10) PRIMARY KEY NOT NULL COMMENT 'The ZIP code from the Postal Service.  ZIP plus four.'
    , City VARCHAR(100) NOT NULL COMMENT 'The name of the city.'
    , State CHAR(2) NOT NULL COMMENT 'The official two-letter state abreviation.'
) COMMENT 'A table listing zip codes and related data'
;

INSERT INTO Zipcode
	(Zip, City, State)
VALUES
	('52320', 'Olin', 'IA')
    , ('52406', 'Cedar Rapids', 'IA')
    , ('34477', 'Ocala', 'FL')
;

select * from Zipcode;

/*
	Creating the Employee table.
*/
DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee(
	Employee_Id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'A unique number to identify the employee'
    , Employee_firstName VARCHAR(50) NOT NULL COMMENT 'first name of an employee'
	, Employee_lastName VARCHAR(50) NOT NULL COMMENT 'The family name of an employee'
	, Employee_address VARCHAR(50) NOT NULL COMMENT 'The home address of an employee'
	, Employee_zip CHAR(10) NOT NULL COMMENT 'The zip code of an employee'
	, Employee_hourType CHAR(6) NOT NULL COMMENT 'An option whether the employee is a salary or hourly employee'
	, Employee_timeType CHAR(9) NULL COMMENT 'An option if the employee is hourly and if full or part time'
	, Employee_position VARCHAR(50) NOT NULL COMMENT 'The description of the employees postion'
    , CONSTRAINT fk_Employee_zip_Zipcode_Zip
 		FOREIGN KEY (Employee_zip) 
        REFERENCES Zipcode(Zip)
) COMMENT 'A table listing the employee information'
;

INSERT INTO Employee
	(Employee_Id, Employee_firstName, Employee_lastName, Employee_address, Employee_zip, Employee_hourType, Employee_timeType, Employee_position)
VALUES
	(DEFAULT, 'Inez', 'Gronewold', '111 Red Deer', '52320', 'Salary', NULL, 'Ranger')
    , (DEFAULT, 'Haley', 'Hepker', '222 Avenue', '52406', 'Salary', NULL, 'CEO')
	, (DEFAULT, 'Betty', 'Mbuyi', '3 Maple Drive', '34477', 'Salary', NULL, 'CFO')
	, (DEFAULT, 'Mason', 'Hamann', '53 Violet Road', '52406', 'Hourly', 'Full', 'Grounds Keeper')    
;

select * from Employee;

/*
	Creating the W4 table.
*/
DROP TABLE IF EXISTS W4;
CREATE TABLE W4(
	Employee_Id INT NOT NULL PRIMARY KEY COMMENT 'A unique number to identify the employee'
	, Filing_status CHAR(2) NULL COMMENT 'The filing status of an employee. Choices are Single, Married, Married but withholding at the higher Single Rate, or Head of Household.'
	, Tax_bracket INT NULL COMMENT 'The bracket an employee is in based on their filing status and yearly income.'
	, Additional_amount DECIMAL(6,2) NULL COMMENT 'The additional amount (if any) an employee wants withhold.'
	, Exemption CHAR(1) NOT NULL COMMENT 'An option whether an employee is claiming an exemption from Federal Income Tax.'
    , CONSTRAINT fk_W4_Employee_Id_Employee_Employee_Id
 		FOREIGN KEY (Employee_Id)
        REFERENCES Employee(Employee_Id)
) COMMENT 'A table that contains information from the Federal W4 form used to calculate the Federal Income Tax.'
;

INSERT INTO W4
	(Employee_Id, Filing_status, Tax_bracket, Additional_amount, Exemption)
VALUES
	(1, 'S', 4, NULL, 'N')
    , (2, 'M', 3, NULL, 'Y')
    , (3, 'S', 2, NULL, 'N')
	, (4, 'M', 1, NULL, 'N')
;

select * from W4;

/*
	Creating the Wages table.
*/
DROP TABLE IF EXISTS Wages;
CREATE TABLE Wages(
-- 	Wage_Id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identify one type of wage'
	Check_number VARCHAR(20) PRIMARY KEY NOT NULL COMMENT 'The number of the check given to the employee'
	, Pay_rate DECIMAL(6,2) NOT NULL COMMENT 'The rate of pay for the employee, by hourly.'
	, Hours_worked DECIMAL(4,2) NULL COMMENT 'The number of hours worked for the hourly employees'
	, Pay_amount DECIMAL(5,2) NOT NULL COMMENT 'The pay amount in the pay period given to the employee'
-- 	, YTD_amount DECIMAL(6,2) NOT NULL COMMENT 'The total amount of pay the employee has made from the beginning of the year'
	, Overtime_pay DECIMAL(5,2) NULL COMMENT 'An overtime earned by an hourly employee'
-- 	, CONSTRAINT fk_Wages_Check_number_Paystub_Check_number
-- 		FOREIGN KEY (Check_number)
--        REFERENCES Paystub(Check_number)
) COMMENT 'A table listing the employees pay and hours.'
;

INSERT INTO Wages
	(Check_number, Pay_rate, Hours_worked, Pay_amount, Overtime_pay)
VALUES
	('WW01', 15.25, 40.0
    , (15.25 * 40)
    , 0)
	, ('WW02', 5.25, 20.0
    , (5.25 * 20)
    , 0)
;

select * from Wages;

/*
	Creating the Withholdings table.
*/
DROP TABLE IF EXISTS Withholdings;
CREATE TABLE Withholdings(
	Check_number VARCHAR(20)  PRIMARY KEY NOT NULL COMMENT 'The number of the check given to the employee'
--  , Withholdings_Id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'An identifier for the total withholdings in a single pay period'
	, FICA_SS_amount DECIMAL(5,2) NOT NULL COMMENT 'The amount withheld from a paycheck for social security'
-- , FICA_SS_YTD DECIMAL(6,2)  NOT NULL COMMENT 'The year to date amount withheld for social security'
	, FICA_Med_amount DECIMAL(5,2)  NOT NULL COMMENT 'The amount withheld from a paycheck for medicare'
-- 	, FICA_Med_YTD DECIMAL(6,2) NOT NULL COMMENT 'The year to date amount wihheld for medicare'
	, FIT_amount DECIMAL(5,2)  NOT NULL COMMENT 'The amount withheld from a paycheck for federal income tax'
-- 	, FIT_YTD DECIMAL(6,2)  NOT NULL COMMENT 'The year to date amount withheld for federal income tax'
-- , IOWA_SIT_amount DECIMAL(3,2)  NOT NULL COMMENT 'The amount withheld from a paycheckfor state income tax'
-- , IOWA_SIT_YTD DECIMAL(6,2)  NOT NULL COMMENT 'The year to date amount withheld for state income tax'
-- , Deductions_amount DECIMAL(3,2) NULL COMMENT 'Any other deductions wanted withheld from ma paycheck'
-- , Deductions_YTD DECIMAL(6,2) NULL COMMENT 'The year amount of the extra deductions wanted withheld '
	, CONSTRAINT fk_Withholdings_Check_number_Wages_Check_number
		FOREIGN KEY (Check_number)
        REFERENCES Wages(Check_number)
) COMMENT 'A table with the listed government withholdings.'
;

INSERT INTO Withholdings
	(Check_number, FICA_SS_amount, FICA_Med_amount, FIT_amount)
VALUES
    ('WW01'
    , (SELECT Wages.Pay_amount * 0.062
    FROM Wages
    WHERE Wages.Check_number = 'WW01')
    , (SELECT Wages.Pay_amount * 0.0145
    FROM Wages
    WHERE Wages.Check_number = 'WW01')
	, (SELECT Wages.Pay_amount * 0.12
    FROM Wages
	WHERE Wages.Check_number = 'WW01'))
    
    , ('WW02'
    , (SELECT Wages.Pay_amount * 0.062
    FROM Wages
    WHERE Wages.Check_number = 'WW02')
    , (SELECT Wages.Pay_amount * 0.0145
    FROM Wages
    WHERE Wages.Check_number = 'WW02')
	, (SELECT Wages.Pay_amount * 0.12
    FROM Wages
	WHERE Wages.Check_number = 'WW02'))
;

select * from Withholdings;

/*
	Creating the Paystub table.
*/
DROP TABLE IF EXISTS Paystub;
CREATE TABLE Paystub(
	Check_number VARCHAR(20) PRIMARY KEY NOT NULL PRIMARY KEY COMMENT 'The number of the check given to the employee'
	, Pay_period_begins	DATE NOT NULL COMMENT 'The date and time for the beginning of the pay period'
	, Pay_period_ends DATE NOT NULL COMMENT 'The date and time for the end of the pay period'
	, Check_date DATE NOT NULL COMMENT 'The date and time the check was printed out'
	, Net_check_amount DECIMAL(5,2) NOT NULL COMMENT 'The amount for the check after all deductions are taken out'
-- 	, Net_check_YTD DECIMAL(6,2) NOT NULL COMMENT 'The year to date amount of the net of money made'
	, Employee_Id INT NOT NULL COMMENT 'A unique number to identify the employee'
 	, CONSTRAINT fk_Paystub_Employee_Id_Employee_Employee_Id
 		FOREIGN KEY (Employee_Id)
        REFERENCES Employee(Employee_Id)
	, CONSTRAINT fk_Paystub_Check_number_Wages_Check_number
		FOREIGN KEY (Check_number)
        REFERENCES Wages(Check_number)
) COMMENT 'A table with pay period and check dates and amounts.'
;

INSERT INTO Paystub
	(Check_number, Pay_period_begins, Pay_period_ends, Check_date, Net_check_amount, Employee_Id)
VALUES
	('WW01'
    , '2019-11-03'
    , '2019-11-16'
    , '2019-11-17'
    , (SELECT  Wages.Pay_amount - Withholdings.FICA_SS_amount - Withholdings.FICA_Med_amount - Withholdings.FIT_amount
	  FROM Withholdings
	  INNER JOIN Wages
	  ON Withholdings.Check_number = Wages.Check_number
      WHERE Withholdings.Check_number = 'WW01')
    , 1)
    , ('WW02'
    , '2019-11-03'
    , '2019-11-16'
    , '2019-11-17'
    , (SELECT  Wages.Pay_amount - Withholdings.FICA_SS_amount - Withholdings.FICA_Med_amount - Withholdings.FIT_amount
	  FROM Withholdings
	  INNER JOIN Wages
	  ON Withholdings.Check_number = Wages.Check_number
	  WHERE Withholdings.Check_number = 'WW02')
    , 2)
;

select * from Paystub;

SELECT 
	Paystub.Check_Number
    , Paystub.Pay_period_begins AS 'start_date'
    , Paystub.Pay_period_ends AS 'end_date'
    , Wages.Pay_amount AS 'gross_pay'
    , (Withholdings.FICA_SS_amount + Withholdings.FICA_Med_amount + Withholdings.FIT_amount) AS 'deductions'
    , Paystub.Net_check_amount AS 'net_pay'
    , Employee.Employee_firstName AS 'first'
    , Employee.Employee_lastName AS 'last'   
    , Employee.Employee_address AS 'street'
    , Zipcode.City AS 'city'
    , Zipcode.State AS 'state'
    , Zipcode.Zip AS 'zip'
FROM Paystub
INNER JOIN Employee
ON Paystub.Employee_Id = Employee.Employee_Id
INNER JOIN Zipcode
ON Employee.Employee_zip = Zipcode.Zip
INNER JOIN Wages
ON Paystub.Check_Number = Wages.Check_Number
INNER JOIN Withholdings
ON Paystub.Check_Number = Withholdings.Check_Number
;


-- The following SELECT statement totals the employee checks deductions per tax type
SELECT 
    SUM(FICA_SS_amount) AS 'ttl_SSI'
    , SUM(FICA_Med_amount) AS 'ttl_Medicare'
    , SUM(FIT_amount) AS 'ttl_Fed Inc Tax'
FROM Withholdings
;

/* ********************************************************************************
          							END OF FILE
********************************************************************************  */
