-- ===========================================
-- DPWH Flood Control Project
-- File: 02_load_staging.sql
-- Purpose: Load raw CSV into staging table
-- ===========================================

USE Flood_Control_DB;

-- ===========================================
-- Create Raw Table
-- ===========================================

CREATE TABLE Raw_Flood_Control (
	RowId INT,
	MainIsland TEXT,
    Region TEXT,
    Province TEXT,
    LegislativeDistrict TEXT,
    Municipality TEXT,
    DistrictEngineeringOffice TEXT,
    ProjectId TEXT,
    ProjectName TEXT,
    TypeOfWork TEXT,
    FundingYear TEXT,
    ContractId TEXT,
    ApprovedBudgetForContract TEXT,
    ContractCost TEXT,
    ActualCompletionDate TEXT,
    Contractor TEXT,
    ContractorCount TEXT,
    StartDate TEXT,
    ProjectLatitude TEXT,
    ProjectLongitude TEXT,
    ProvincialCapital TEXT,
    ProvincialCapitalLatitude TEXT,
    ProvincialCapitalLongitude TEXT
);

-- ===========================================
-- CSV Import Notes
-- ===========================================

-- CSV was imported using Data Wizard Import

-- ===========================================
-- Verify Import
-- ===========================================

SELECT COUNT(*) AS Total_Rows
FROM Raw_Flood_Control;

-- ===========================================
-- Create Staging Table
-- ===========================================

CREATE TABLE Staging_Flood_Control (
	Row_ID INT PRIMARY KEY,
	Main_Island TEXT NULL,
    Region TEXT NULL,
    Province TEXT NULL,
    Legislative_District TEXT NULL,
    Municipality TEXT NULL,
    District_Engineering_Office TEXT NULL,
    Project_ID TEXT NULL,
    Project_Name TEXT NULL,
    Type_of_Work TEXT NULL,
    Funding_Year INT NULL,
    Contract_ID TEXT NULL,
    Approved_Budget_for_Contract TEXT NULL,
    Contract_Cost TEXT NULL,
    Actual_Completion_Date TEXT NULL,
    Actual_Completion_Date_Clean DATE NULL,
    Contractor TEXT NULL,
    Contractor_Count INT NULL,
    Start_Date TEXT NULL,
    Start_Date_Clean DATE NULL,
    Project_Latitude DECIMAL(10,8) NULL,
    Project_Longitude DECIMAL(11,8) NULL,
    Provincial_Capital TEXT NULL,
    Provincial_Capital_Latitude DECIMAL(6,4) NULL,
    Provincial_Capital_Longitude DECIMAL(7,4) NULL,
    Approved_Budget_for_Contract_Clean DECIMAL(15,2) NULL,
    Contract_Cost_Clean DECIMAL(15,2) NULL
);

-- ===========================================
-- Load Staging Table
-- ===========================================

INSERT INTO Staging_Flood_Control (
	Row_ID,
    Main_Island,
    Region,
    Province,
    Legislative_District,
    Municipality,
    District_Engineering_Office,
    Project_ID,
    Project_Name,
    Type_of_Work,
    Funding_Year,
    Contract_ID,
    Approved_Budget_for_Contract,
    Contract_Cost,
    Actual_Completion_Date,
    Actual_Completion_Date_Clean,
    Contractor,
    Contractor_Count,
    Start_Date,
    Start_Date_Clean,
    Project_Latitude,
    Project_Longitude,
    Provincial_Capital,
    Provincial_Capital_Latitude,
    Provincial_Capital_Longitude,
    Approved_Budget_for_Contract_Clean,
    Contract_Cost_Clean
)
SELECT
	RowId,
    UPPER(TRIM(MainIsland)),
    UPPER(TRIM(Region)),
    UPPER(TRIM(Province)),
    TRIM(LegislativeDistrict),
    COALESCE(NULLIF(TRIM(Municipality), ''), 'NOT PROVIDED'),
    TRIM(DistrictEngineeringOffice),
    TRIM(ProjectId),
    TRIM(ProjectName),
    TRIM(TypeOfWork),
    CAST(LEFT(TRIM(FundingYear),4) AS UNSIGNED),
    TRIM(ContractId),
    TRIM(ApprovedBudgetForContract),
    TRIM(ContractCost),
    TRIM(ActualCompletionDate),
    STR_TO_DATE(TRIM(ActualCompletionDate), '%m/%d/%Y'),
    TRIM(Contractor),
    CAST(TRIM(ContractorCount) AS UNSIGNED),
    TRIM(StartDate),
    STR_TO_DATE(TRIM(StartDate), '%m/%d/%Y'),
    CAST(TRIM(ProjectLatitude) AS DECIMAL(10,8)),
    CAST(TRIM(ProjectLongitude) AS DECIMAL(11,8)),
    TRIM(ProvincialCapital),
    CAST(TRIM(ProvincialCapitalLatitude) AS DECIMAL(6,4)),
    CAST(TRIM(ProvincialCapitalLongitude) AS DECIMAL(7,4)),
    
    CASE
		WHEN TRIM(ApprovedBudgetForContract) REGEXP '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(TRIM(ApprovedBudgetForContract) AS DECIMAL(15,2))
        ELSE NULL
	END,
    
    CASE
		WHEN TRIM(ContractCost) REGEXP '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(TRIM(ContractCost) AS DECIMAL(15,2))
        ELSE NULL
	END

FROM Raw_Flood_Control;

-- ===========================================
-- Clean wrong character encoding - mojibake
-- ===========================================

UPDATE Staging_Flood_Control
SET
    Province = REPLACE(REPLACE(Province,'Ã‘','Ñ'),'Ã±','ñ'),
    Municipality = REPLACE(REPLACE(Municipality,'Ã‘','Ñ'),'Ã±','ñ'),
    Legislative_District = REPLACE(REPLACE(Legislative_District,'Ã‘','Ñ'),'Ã±','ñ'),
    Project_Name = REPLACE(REPLACE(Project_Name,'Ã‘','Ñ'),'Ã±','ñ'),
    Contractor = REPLACE(REPLACE(Contractor,'Ã‘','Ñ'),'Ã±','ñ'),
    Provincial_Capital = REPLACE(REPLACE(Provincial_Capital,'Ã‘','Ñ'),'Ã±','ñ');

-- ===========================================
-- Verify data validity and integrity
-- ===========================================

-- Check Row Count
SELECT COUNT(*) FROM Raw_Flood_Control;
SELECT COUNT(*) FROM Staging_Flood_Control;

-- Verify Municipality Replacement
SELECT Municipality, COUNT(*)
FROM Staging_Flood_Control
GROUP BY Municipality
ORDER BY COUNT(*) DESC;

-- Validate Date Conversion
SELECT *
FROM Staging_Flood_Control
WHERE Actual_Completion_Date IS NOT NULL
AND Actual_Completion_Date_Clean IS NULL;

SELECT *
FROM Staging_Flood_Control
WHERE Start_Date IS NOT NULL
AND Start_Date_Clean IS NULL;

-- Inspect Funding Year
SELECT Funding_Year, COUNT(*)
FROM Staging_Flood_Control
GROUP BY Funding_Year
ORDER BY Funding_Year DESC;

-- Verify Budget and Contract Cost
SELECT MAX(Approved_Budget_for_Contract_Clean), MIN(Approved_Budget_for_Contract_Clean)
FROM Staging_Flood_Control;

SELECT COUNT(*)
FROM Staging_Flood_Control
WHERE Approved_Budget_for_Contract_Clean IS NULL;

SELECT COUNT(*)
FROM Raw_Flood_Control
WHERE ApprovedBudgetForContract NOT REGEXP '^[0-9]+(\.[0-9]+)?$';

SELECT MAX(Contract_Cost_Clean), MIN(Contract_Cost_Clean)
FROM Staging_Flood_Control;

SELECT COUNT(*)
FROM Staging_Flood_Control
WHERE Contract_Cost_Clean IS NULL;

SELECT COUNT(*)
FROM Raw_Flood_Control
WHERE ContractCost NOT REGEXP '^[0-9]+(\.[0-9]+)?$';