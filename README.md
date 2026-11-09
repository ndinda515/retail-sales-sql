##Project Overview##

This project analyses retail sales and customer data for Duka Smart Electronics, a Kenyan electronics retailer operating across ten towns.
The aim is to use SQL to examine sales performance, customer behaviour, product profitability, and revenue trends to support better business decisions.

##Project Objectives##

Analyse sales and revenue performance.
Identify the most profitable product categories.
Compare sales performance across towns.
Understand customer purchasing behaviour.
Identify inactive and high-value customers.
Provide business insights and recommendations.

##Datase##

-150 customers
-800 orders
-Period covered: January 2025 to September 2026

##Project Files##

retail-sales-sql/
│
├── 01_create_database.sql
├── 02_create_tables.sql
├── 03_insert_customers.sql
├── 04_insert_orders.sql
├── 05_verify_data.sql
├── schema.sql
├── queries.sql
├── insights.md
├── README.md
│
└── screenshots/

##How to Run the Project##

1.Install PostgreSQL and open pgAdmin or another SQL editor.

2.Run 01_create_database.sql to create the database.

3.Connect to retail_analytics.

4.Run the remaining setup scripts in order, from 02_create_tables.sql to 05_verify_data.sql.

5.Run schema.sql to review the database structure.

6.Run queries.sql to explore the 46 SQL questions and analyses.

7.Review insights.md for the findings and business recommendations.

##Business Insights##

The analysis highlights product revenue and profitability, sales performance by city, customer segments, inactive customers, monthly revenue trends, and customer value categories.

Detailed findings and recommendations are documented in insights.md.

##Conclusion##

This project demonstrates how PostgreSQL can be used to transform retail data into meaningful business insights. The findings can help Duka Smart Electronics improve sales performance, understand its customers, and make informed business decisions.

