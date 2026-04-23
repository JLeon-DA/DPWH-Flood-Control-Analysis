-- ===========================================
-- DPWH Flood Control Project
-- File: 03_load_dimensions.sql
-- Purpose: Populate all dimension tables from staging
-- ===========================================

USE Flood_Control_DB;

-- ===========================================
-- Load Dim_Location
-- ===========================================

INSERT INTO Dim_Location (
	Main_Island,
    Region,
    Province,
    Provincial_Capital,
    Legislative_District,
    Municipality
)
SELECT DISTINCT
	Main_Island,
    Region,
    Province,
    Provincial_Capital,
    Legislative_District,
    Municipality
FROM Staging_Flood_Control;

-- Verify 
SELECT COUNT(*) AS Distinct_Count
FROM Dim_Location;

SELECT COUNT(DISTINCT Main_Island, Region, Province, Provincial_Capital, Legislative_District, Municipality) AS Distinct_Count
FROM Staging_Flood_Control;

-- ===========================================
-- Load Dim_Engineering_Office
-- ===========================================

INSERT INTO Dim_Engineering_Office (
	District_Engineering_Office
)
SELECT DISTINCT
	District_Engineering_Office
FROM Staging_Flood_Control;

-- Verify
SELECT COUNT(*) AS DEO_Count
FROM Dim_Engineering_Office;

SELECT COUNT(DISTINCT District_Engineering_Office) AS DEO_Count
FROM Staging_Flood_Control;

-- ===========================================
-- Load Dim_Contractor
-- ===========================================

INSERT INTO Dim_Contractor (
	Contract_ID,
    Contractor
)
SELECT DISTINCT
	Contract_ID,
    Contractor
FROM Staging_Flood_Control;

-- Verify
SELECT COUNT(*) AS Total_Contractor
FROM Dim_Contractor;

SELECT COUNT(DISTINCT Contract_ID, Contractor) AS Total_Contractor
FROM Staging_Flood_Control;

-- ===========================================
-- Load Dim_Project
-- ===========================================

INSERT INTO Dim_Project (
	Project_ID,
    Project_Name,
    Type_of_Work
)
SELECT DISTINCT
	Project_ID,
    Project_Name,
    Type_of_Work
FROM Staging_Flood_Control;

-- Verify
SELECT COUNT(*) AS Total_Project
FROM Dim_Project;

SELECT COUNT(DISTINCT Project_ID, Project_Name, Type_of_Work)
FROM Staging_Flood_Control;

-- ===========================================
-- Load Dim_Date
-- ===========================================

INSERT IGNORE INTO Dim_Date (
    Date_Key,
    Full_Date,
    Year,
    Quarter,
    Month,
    Month_Name,
    Day,
    Day_Name
)
SELECT DISTINCT
    CAST(DATE_FORMAT(d.Full_Date, '%Y%m%d') AS UNSIGNED) AS Date_Key,
    d.Full_Date,
    YEAR(d.Full_Date) AS Year,
    QUARTER(d.Full_Date) AS Quarter,
    MONTH(d.Full_Date) AS Month,
    MONTHNAME(d.Full_Date) AS Month_Name,
    DAY(d.Full_Date) AS Day,
    DAYNAME(d.Full_Date) AS Day_Name
FROM (
    SELECT Start_Date_Clean AS Full_Date
    FROM Staging_Flood_Control
    WHERE Start_Date_Clean IS NOT NULL

    UNION

    SELECT Actual_Completion_Date_Clean
    FROM Staging_Flood_Control
    WHERE Actual_Completion_Date_Clean IS NOT NULL
) d;

-- Verify
SELECT *
FROM Dim_Date;

SELECT MIN(Year), MAX(Year)
FROM Dim_Date;

	