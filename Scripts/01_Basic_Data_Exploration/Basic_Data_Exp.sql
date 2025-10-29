/*
  Combined Basic Data Exploration queries
  This file concatenates the small scripts from:
    - 001_list_tables_and_address_columns.sql
    - 002_customer_sample.sql
    - 003_total_counts.sql
    - 004_customer_full_names.sql

  License: MIT (see /LICENSE)
*/

-- ===== 001_list_tables_and_address_columns.sql =====
/* 001 - List tables and address columns */
-- List all tables in public schema
SELECT * FROM information_schema.tables WHERE table_schema = 'public';

-- Retrieve column names and data types for the 'address' table
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'address' AND table_schema = 'public';

-- ===== 002_customer_sample.sql =====
/* 002 - Customer sample */
SELECT *
FROM customer c
ORDER BY c.customer_id
LIMIT 5;

-- ===== 003_total_counts.sql =====
/* 003 - Total distinct customers, films, rentals (subquery + CTE versions) */
-- Subquery version
SELECT 
  (SELECT COUNT(DISTINCT customer_id) FROM customer) AS total_customers,
  (SELECT COUNT(DISTINCT film_id) FROM film) AS total_films,
  (SELECT COUNT(DISTINCT rental_id) FROM rental) AS total_rentals;

-- CTE + CROSS JOIN version
WITH 
  total_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers FROM customer
  ),
  total_films AS (
    SELECT COUNT(DISTINCT f.film_id) AS total_films FROM film f
  ),
  total_rentals AS (
    SELECT COUNT(DISTINCT r.rental_id) AS total_rentals FROM rental r
  )
SELECT * FROM total_customers CROSS JOIN total_films CROSS JOIN total_rentals;

-- ===== 004_customer_full_names.sql =====
/* 004 - Customer full names and emails */
SELECT 
  CONCAT(c.first_name,' ',c.last_name) AS full_name,
  c.email
FROM customer c
ORDER BY c.first_name;
