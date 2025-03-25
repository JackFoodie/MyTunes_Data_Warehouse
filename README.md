# MyTunes Data Warehouse

## Overview
This project implements a star schema data warehouse for MyTunes, an online music platform operating in 24 countries. The data warehouse enables analysis of music sales across multiple dimensions.

## Business Context
MyTunes needs to analyze their sales data to make better business decisions. This data warehouse provides a structured way to analyze sales by artist, album, customer, and time periods.

## Star Schema Design
![Star Schema](visualizations/ER_diagram.png)
The data warehouse follows a star schema with:
- Fact table: fact_sales (contains sales transactions)
- Dimension tables:
  - dim_customer (customer information)
  - dim_track (track details with links to albums and artists)
  - dim_time (time hierarchy for date-based analysis)

## ETL Process
The project includes two main SQL scripts:
- `create_DWH.sql`: Creates the data warehouse structure and performs initial data load
- `update_DWH.sql`: Updates the data warehouse when the source system changes

## Sample Queries
The `sample_queries.sql` file contains example analytical queries that demonstrate how to analyze:
- Sales by artist per year
- Sales by country per quarter
- Top-selling tracks
- Monthly sales trends
- Customer purchase patterns

## Project Structure
- `data/`: Source database files
- `scripts/`: SQL scripts for creating and updating the data warehouse
- `docs/`: Documentation and diagrams
- `visualizations/`: Sample data visualizations
