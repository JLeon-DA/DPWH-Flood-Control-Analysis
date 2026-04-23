-- ===========================================
-- DPWH Flood Control Project
-- File: 05_Reports_and_Analytics.sql
-- Purpose: This file contains analytical SQL queries used to generate insights 
-- on flood control projects, including budget allocation, contractor performance, 
-- project duration, and yearly funding trends.
-- ===========================================

USE Flood_Control_DB;

-- ===========================================
-- Budget Allocation Overview (KPI)
-- ===========================================
SELECT 
	ROUND(SUM(Approved_Budget) / 1000000000 , 2) AS Total_Approved_Budget_Billions,
    ROUND(SUM(Contract_Cost) / 1000000000 , 2) AS Total_Contract_Cost_Billions
FROM Fact_Project f;

-- ===========================================
-- Regional Budget Distribution
-- ===========================================
WITH tb AS (SELECT	l.Region,
					SUM(f.Approved_Budget) AS Total_Budget
			FROM	fact_project f LEFT JOIN dim_location l
									ON f.location_key = l.location_key
			GROUP BY l.Region)
            
SELECT	ROW_NUMBER() OVER(ORDER BY Total_Budget DESC) AS Region_Rank,
		Region, 
		ROUND(Total_Budget / 1000000000 , 1) AS Total_Budget_Billions,
        ROUND(Total_Budget * 1.0 / SUM(Total_Budget) OVER() * 100, 1) AS Budget_Share_Pct
FROM	tb;

-- ===========================================
-- Budget Trends Over Time (YoY Analysis)
-- ===========================================

WITH yb AS (SELECT	 YEAR(d.Full_Date) AS Funding_Year, 
					 SUM(f.Approved_Budget) / 1000000000 AS Total_Budget_Billions
			FROM	 fact_project f LEFT JOIN dim_date d 
									ON f.Funding_Date_Key = d.date_Key
			WHERE	 f.Approved_Budget IS NOT NULL
            GROUP BY YEAR(d.Full_Date))
			
SELECT	Funding_Year,
		ROUND(Total_Budget_Billions, 2) AS Total_Budget_Billions,
		ROUND(LAG(Total_Budget_Billions) OVER(ORDER BY Funding_Year) , 2) AS Previous_Budget,
		ROUND(Total_Budget_Billions - LAG(Total_Budget_Billions) OVER(ORDER BY Funding_Year) , 2) AS Budget_Diff,
        ROUND((Total_Budget_Billions - LAG(Total_Budget_Billions) OVER(ORDER BY Funding_Year)) / 
			  LAG(Total_Budget_Billions) OVER(ORDER BY Funding_Year) * 100, 2) AS YoY_Growth
FROM 	yb;

-- ===========================================
-- Contractor Funding Analysis
-- ===========================================
WITH cb AS (SELECT	 c.Contractor,
						SUM(f.Approved_Budget) AS Total_Budget
			FROM	 Fact_Project f INNER JOIN Dim_Contractor c
										 ON f.Contractor_Key = c.Contractor_Key
			GROUP BY c.Contractor)

SELECT	DENSE_RANK() OVER(ORDER BY Total_Budget DESC) AS Contractor_Rank,
		Contractor, 
        ROUND(Total_Budget / 1000000000, 4) AS Total_Budget_Billions,
        ROUND(Total_Budget * 1.0 / SUM(Total_Budget) OVER() * 100 , 2) AS Budget_Share_Pct
FROM	cb;

-- ===========================================
-- Contractor Budget Distribution (Quartile Analysis)
-- ===========================================
WITH cb AS (SELECT	 c.Contractor,
						SUM(f.Approved_Budget) AS Total_Budget
			FROM	 Fact_Project f INNER JOIN Dim_Contractor c
									 ON f.Contractor_Key = c.Contractor_Key
			GROUP BY c.Contractor),

	 bq AS (SELECT	 NTILE(4) OVER(ORDER BY Total_Budget DESC) AS Budget_Quartile, Total_Budget,
					 Contractor, ROUND(Total_Budget / 1000000000, 4) AS Total_Budget_Billions
			FROM	 cb)

SELECT	 Budget_Quartile,
		 COUNT(*) AS Contractor_Count,
         ROUND(SUM(Total_Budget) * 1.0 / SUM(SUM(Total_Budget)) OVER() * 100 ,2) AS Budget_Share_Pct
FROM	 bq
GROUP BY Budget_Quartile
ORDER BY Budget_Quartile;

-- ===========================================
-- Project Budget vs Project Duration Matrix
-- ===========================================
WITH qt AS (SELECT	p.Project_ID, f.Approved_Budget,
				    DATEDIFF(cd.Full_Date, sd.Full_Date) AS Project_Duration,

				    NTILE(4) OVER (ORDER BY f.Approved_Budget DESC) AS Budget_Quartile,
				    NTILE(4) OVER (ORDER BY DATEDIFF(cd.Full_Date, sd.Full_Date) DESC) AS Duration_Quartile
				
			 FROM Fact_Project f LEFT JOIN Dim_Project p ON f.Project_Key = p.Project_Key
								 LEFT JOIN Dim_Date sd ON f.Start_Date_Key = sd.Date_Key
								 LEFT JOIN Dim_Date cd ON f.Completion_Date_Key = cd.Date_Key
									 
			 WHERE f.Approved_Budget IS NOT NULL),

	 pc AS (SELECT	 Budget_Quartile, Duration_Quartile,
					 COUNT(*) AS Project_Count
			FROM	 qt
			GROUP BY Budget_Quartile, Duration_Quartile),
            
	 pr AS (SELECT	Budget_Quartile, Duration_Quartile, Project_Count,
					SUM(Project_Count) OVER(PARTITION BY Budget_Quartile) AS Total_Project_Per_Row
			FROM	pc)
	 
SELECT	 Budget_Quartile,

		 ROUND(SUM(CASE WHEN Duration_Quartile = 1 THEN Project_Count * 1.0 / Total_Project_Per_Row END) * 100, 2) AS Q1_Duration_Pct,
		 ROUND(SUM(CASE WHEN Duration_Quartile = 2 THEN Project_Count * 1.0 / Total_Project_Per_Row END) * 100, 2) AS Q2_Duration_Pct,
         ROUND(SUM(CASE WHEN Duration_Quartile = 3 THEN Project_Count * 1.0 / Total_Project_Per_Row END) * 100, 2) AS Q3_Duration_Pct,
         ROUND(SUM(CASE WHEN Duration_Quartile = 4 THEN Project_Count * 1.0 / Total_Project_Per_Row END) * 100, 2) AS Q4_Duration_Pct

FROM	 pr
GROUP BY Budget_Quartile
ORDER BY Budget_Quartile;
 
-- ===========================================
-- Regional Budget Distribution (Yearly Matrix)
-- ===========================================
SELECT 
	COALESCE(l.Region, 'Grand_Total') AS Region,

	SUM(CASE WHEN d.Year = 2018 THEN f.Approved_Budget ELSE 0 END) AS `2018`,
	SUM(CASE WHEN d.Year = 2019 THEN f.Approved_Budget ELSE 0 END) AS `2019`,
	SUM(CASE WHEN d.Year = 2020 THEN f.Approved_Budget ELSE 0 END) AS `2020`,
	SUM(CASE WHEN d.Year = 2021 THEN f.Approved_Budget ELSE 0 END) AS `2021`,
	SUM(CASE WHEN d.Year = 2022 THEN f.Approved_Budget ELSE 0 END) AS `2022`,
	SUM(CASE WHEN d.Year = 2023 THEN f.Approved_Budget ELSE 0 END) AS `2023`,
	SUM(CASE WHEN d.Year = 2024 THEN f.Approved_Budget ELSE 0 END) AS `2024`,
	SUM(CASE WHEN d.Year = 2025 THEN f.Approved_Budget ELSE 0 END) AS `2025`,

	SUM(f.Approved_Budget) AS Grand_Total

FROM Fact_Project f
JOIN Dim_Location l
	ON f.Location_Key = l.Location_Key
JOIN Dim_Date d
	ON f.Funding_Date_Key = d.Date_Key
WHERE f.Approved_Budget IS NOT NULL
GROUP BY l.Region WITH ROLLUP
ORDER BY 
	CASE WHEN l.Region IS NULL THEN 1 ELSE 0 END,
    Grand_Total DESC;