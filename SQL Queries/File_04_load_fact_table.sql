-- ===========================================
-- DPWH Flood Control Project
-- File: 04_load_fact_table.sql
-- Purpose: Load Fact_Orders Table
-- ===========================================

USE Flood_Control_DB;

-- ===========================================
-- Load Fact_Project Table
-- ===========================================

INSERT INTO Fact_Project (
    Location_Key,
    Project_Key,
    Contractor_Key,
    Office_Key,
    Funding_Date_Key,
    Start_Date_Key,
    Completion_Date_Key,
    Project_Latitude,
    Project_Longitude,
    Approved_Budget,
    Contract_Cost
)
SELECT 
    l.Location_Key,
    p.Project_Key,
    c.Contractor_Key,
    o.Office_Key,
    (
		SELECT fd.Date_Key
        FROM Dim_Date fd
        WHERE YEAR(fd.Full_Date) = s.Funding_Year
        ORDER BY fd.Full_Date
        LIMIT 1
	) AS Funding_Date_Key,
    sd.Date_Key AS Start_Date_Key,
    cd.Date_Key AS Actual_Completion_Date_Key,
    s.Project_Latitude,
    s.Project_Longitude,
    s.Approved_Budget_for_Contract_Clean,
    s.Contract_Cost_Clean
FROM Staging_Flood_Control s

-- Location Lookup
JOIN Dim_Location l
	ON s.Main_Island = l.Main_Island
	AND s.Region = l.Region
    AND s.Province = l.Province
    AND s.Provincial_Capital = l.Provincial_Capital
    AND s.Legislative_District = l.Legislative_District
    AND s.Municipality = l.Municipality
    
-- Project Lookup
JOIN Dim_Project p
	ON s.Project_ID = p.Project_ID
    AND s.Project_Name = p.Project_Name
    AND s.Type_of_Work = p.Type_of_Work
    
-- Contractor Lookup
JOIN Dim_Contractor c
	ON s.Contract_ID = c.Contract_ID
    AND s.Contractor = c.Contractor
    
-- Office Lookup
JOIN Dim_Engineering_Office o
	ON s.District_Engineering_Office = o.District_Engineering_Office
    
-- Start Date Lookup
JOIN Dim_Date sd
	ON s.Start_Date_Clean = sd.Full_Date
    
-- Actual Completion Date Lookup
JOIN Dim_Date cd
	ON s.Actual_Completion_Date_Clean = cd.Full_Date;

-- ===========================================
-- Validation Checks
-- ===========================================

SELECT *
FROM Fact_Project;

SELECT COUNT(*)
FROM Fact_Project;

SELECT COUNT(*)
FROM Staging_Flood_Control;

SELECT *
FROM Fact_Project
WHERE Location_Key IS NULL
    OR Project_Key IS NULL
    OR Contractor_Key IS NULL
    OR Office_Key IS NULL
    OR Funding_Date_Key IS NULL
    OR Start_Date_Key IS NULL
    OR Completion_Date_Key IS NULL;
    