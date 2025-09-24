DVD Rental Database Analysis – SQL Script
Overview
This SQL script performs a comprehensive analysis of the DVD Rental Sample Database, covering schema exploration, customer trends, inventory management, rental patterns, revenue insights, and staff performance.
It is structured into 12 sections, each focusing on a different analytical objective, with clear comments for easy navigation.

Requirements
Database: PostgreSQL
Sample DB: DVD Rental Database (can be restored from .tar file)
Tool: pgAdmin, psql CLI, or Visual Studio Code with PostgreSQL extension


| Section No. | Topic                       | Description                                                                                        |
| ----------- | --------------------------- | -------------------------------------------------------------------------------------------------- |
| **1**       | Database Schema Exploration | Lists tables, columns, and relationships in the database.                                          |
| **2**       | Film Information            | Retrieves detailed film data including categories and length.                                      |
| **3**       | Customer Data               | Analyzes customer profiles, active/inactive status, and regions.                                   |
| **4**       | Rental Information          | Tracks rentals, overdue returns, and rental frequency.                                             |
| **5**       | Financial Insights          | Calculates revenue per film, per store, and per customer.                                          |
| **6**       | Staff Performance           | Measures staff rental counts, revenue generated, and workload.                                     |
| **7**       | Geographic Analysis         | Shows customer and rental distribution by city and country.                                        |
| **8**       | Category Insights           | Compares film categories by rental count and revenue.                                              |
| **9**       | Time-based Trends           | Highlights seasonal and monthly rental patterns.                                                   |
| **10**      | Inventory Management        | Checks stock levels and availability for films.                                                    |
| **11**      | High & Low Performers       | Identifies best-selling and underperforming films.                                                 |
| **12**      | Advanced Queries            | Finds “Films at Risk of Being Overlooked” – high rental rate, low rentals, and currently in stock. |


Key Analytical Highlights
Revenue Hotspots – Pinpoints cities, stores, and categories driving the most revenue.
Customer Engagement – Identifies high-value customers and churn risks.
Inventory Gaps – Finds films that are in stock but rarely rented.
Seasonality – Detects peak and off-peak rental months.
Operational Insights – Evaluates staff contribution to rentals and revenue.

License
This project is licensed under the MIT License – you are free to use, modify, and distribute with attribution.

