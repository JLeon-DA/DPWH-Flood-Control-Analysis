# DPWH-Flood-Control-Analysis

## Overview
This project analyzes flood control infrastructure data to evaluate how government budgets are allocated across regions and contractors. It focuses on identifying funding concentration, regional distribution patterns, and the relationship between project cost and execution efficiency.

The project demonstrates end-to-end data analytics skills, including SQL-based data cleaning, star schema data modeling, analytical querying, and interactive dashboard development in Power BI.

## Dashboard Preview

## Objectives
This analysis aims to answer the following key questions:
- How is the total approved budget distributed across regions in the Philippines?
- Which regions received the highest share of flood control funding?
- Which contractors received the largest portion of the government infrastructure budget?
- Is funding concentrated among a small group of contractors or evenly distributed?
- How has the flood control funding changed over time (year-over-year trends)
  
## Tools Used
- SQL – Data cleaning, transformation, and analysis  
- Power BI – Data visualization and dashboard development  
- GitHub – Version control and project documentation

## Data Model
The data set follows a **Star Schema** design:

**Fact Table:**
- Fact_Project

**Dimension Tables:**
- Dim_Contractor
- Dim_Date
- Dim_Engineering_Office
- Dim_Location
- Dim_Project

This structure supports efficient analytics and reporting.

## SQL Analysis

SQL was used to perform infrastructure-focused analysis on the dataset, combining business logic with advanced SQL techniques to extract insights on budget allocation, contractor performance, and project efficiency.

The analysis includes:

- Budget allocation vs contract cost analysis to measure funding efficiency and cost variance  
- Regional budget distribution and ranking using aggregation and conditional grouping  
- Contractor funding concentration analysis using CTEs and window functions  
- Contractor segmentation and inequality analysis using NTILE (quartile-based grouping)  
- Project budget vs duration relationship analysis using window-based comparisons  
- Year-over-year funding trends using LAG to measure growth and changes over time

**Key SQL techniques used:** Joins, CTEs, Window Functions (LAG, NTILE), Aggregate Functions, Conditional Aggregation

## Power BI Dashboard Features

The dashboard is structured into two pages:

## Page 1: Executive Overview
Focuses on high-level KPIs and trends:
- Total Approved Budget  
- Total Contract Cost  
- Budget Deviation  
- Total Projects  
- Average Project Duration  
- Funding trends over time  
- Budget vs cost comparison

## Page 2: Deep Dive Analysis
Focuses on distribution and breakdowns:
- Regional funding concentration  
- Contractor funding concentration  
- Project distribution by geography  
- Project distribution by contractor  
- Hierarchical drill-down by location 
