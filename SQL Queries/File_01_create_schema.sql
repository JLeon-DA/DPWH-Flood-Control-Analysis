-- ===========================================
-- DPWH Flood Control Projects
-- File: 01_create_schema.sql
-- Purpose: Create database and all tables
-- ===========================================

-- Create Database
DROP DATABASE IF EXISTS Flood_Control_DB;
CREATE DATABASE Flood_Control_DB;
USE Flood_Control_DB;

-- ===========================================
-- Dimension Tables
-- ===========================================

CREATE TABLE Dim_Location (
	Location_Key INT AUTO_INCREMENT PRIMARY KEY,
    Main_Island VARCHAR(20),
    Region VARCHAR(50),
    Province VARCHAR(50),
    Provincial_Capital VARCHAR(50),
    Legislative_District VARCHAR(100),
    Municipality VARCHAR(100)
);

CREATE TABLE Dim_Project (
	Project_Key INT AUTO_INCREMENT PRIMARY KEY,
    Project_ID VARCHAR(50),
    Project_Name VARCHAR(350),
    Type_of_Work VARCHAR(100)
);

CREATE TABLE Dim_Contractor (
	Contractor_Key INT AUTO_INCREMENT PRIMARY KEY,
    Contract_ID VARCHAR(150),
    Contractor VARCHAR(250)
);

CREATE TABLE Dim_Engineering_Office (
	Office_Key INT AUTO_INCREMENT PRIMARY KEY,
    District_Engineering_Office VARCHAR(150)
);

CREATE TABLE Dim_Date (
	Date_Key INT PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Quarter INT,
    Month INT,
    Month_Name VARCHAR(20),
    Day INT,
    Day_Name VARCHAR(20)
);

-- ===========================================
-- Fact Table
-- ===========================================

CREATE TABLE Fact_Project (
	Fact_Key INT AUTO_INCREMENT PRIMARY KEY,
    
    Location_Key INT,
    Project_Key INT,
    Contractor_Key INT,
    Office_Key INT,
    
    Funding_Date_Key INT,
    Start_Date_Key INT,
    Completion_Date_Key INT,
    
    Project_Latitude DECIMAL(10,8),
    Project_Longitude DECIMAL(11,8),
    
    Approved_Budget DECIMAL(15,2) NULL,
    Contract_Cost DECIMAL(15,2) NULL,
    
    FOREIGN KEY (Project_Key) REFERENCES Dim_Project(Project_Key),
    FOREIGN KEY (Location_Key) REFERENCES Dim_Location(Location_Key),
    FOREIGN KEY (Contractor_Key) REFERENCES Dim_Contractor(Contractor_Key),
    FOREIGN KEY (Office_Key) REFERENCES Dim_Engineering_Office(Office_Key),
    FOREIGN KEY (Funding_Date_Key) REFERENCES Dim_Date(Date_Key),
    FOREIGN KEY (Start_Date_Key) REFERENCES Dim_Date(Date_Key),
    FOREIGN KEY (Completion_Date_Key) REFERENCES Dim_Date(Date_Key)
);

-- ===========================================
-- Indexes
-- ===========================================

CREATE INDEX idx_Fact_Project ON Fact_Project(Project_Key);
CREATE INDEX idx_Fact_Location ON Fact_Project(Location_Key);
CREATE INDEX idx_Fact_Contractor ON Fact_Project(Contractor_Key);
CREATE INDEX idx_Fact_Office ON Fact_Project(Office_Key);

CREATE INDEX idx_Fact_Funding_Date ON Fact_Project(Funding_Date_Key);
CREATE INDEX idx_Fact_Start_Date ON Fact_Project(Start_Date_Key);
CREATE INDEX idx_Fact_Completion_Date_Key ON Fact_Project(Completion_Date_Key);

SELECT *
FROM Fact_Project;
    
	
