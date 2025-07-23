/* =============================================
   COMPLETE DVD Rental Database Analysis Script
   Includes ALL original queries with optimization
   Organized by business function
   ============================================= */

-- =============================================
-- 1. DATABASE SCHEMA EXPLORATION
-- =============================================

-- List all tables in public schema
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public';

-- List address table columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'address' AND table_schema = 'public';

-- =============================================
-- 2. BASIC DATA INSPECTION
-- =============================================

-- Sample customer records
SELECT * FROM customer ORDER BY customer_id LIMIT 5;

-- Entity counts
SELECT 
  (SELECT COUNT(DISTINCT customer_id) FROM customer) AS total_customers,
  (SELECT COUNT(DISTINCT film_id) FROM film) AS total_films,
  (SELECT COUNT(DISTINCT rental_date) FROM rental) AS total_rentals;

-- Distinct categories
SELECT DISTINCT name FROM category;

-- =============================================
-- 3. CUSTOMER ANALYSIS
-- =============================================

-- Customer full names
SELECT CONCAT(first_name,' ',last_name) AS full_name FROM customer;

-- Customers from London
SELECT CONCAT(first_name,' ', last_name) AS customer_name
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
WHERE ci.city = 'London';

-- Active customers (rented at least once)
SELECT DISTINCT r.customer_id, c.first_name, c.last_name
FROM rental r JOIN customer c ON r.customer_id = c.customer_id
ORDER BY r.customer_id;

-- Inactive customers (never rented)
SELECT c.customer_id
FROM customer c LEFT JOIN rental r ON c.customer_id = r.customer_id
WHERE r.customer_id IS NULL 
LIMIT 5;

-- Customers renting from multiple stores
SELECT r.customer_id, c.first_name
FROM rental r JOIN customer c ON r.customer_id = c.customer_id
WHERE r.staff_id IN (1,2)
GROUP BY r.customer_id, c.first_name
HAVING COUNT(DISTINCT r.staff_id) = 2;

-- =============================================
-- 4. FILM ANALYSIS  
-- =============================================

-- Films with language
SELECT f.title, l.name AS language
FROM film f JOIN language l ON f.language_id = l.language_id;

-- Films not in inventory
SELECT f.film_id 
FROM film f LEFT JOIN inventory i ON f.film_id = i.film_id
WHERE i.inventory_id IS NULL;

-- Films by rating
SELECT f.rating, COUNT(*) AS film_count
FROM film f
GROUP BY f.rating
ORDER BY film_count DESC;

-- Category film counts
SELECT c.name, COUNT(*) AS film_count
FROM category c 
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name 
ORDER BY film_count DESC;

-- Small categories (<5 films)
SELECT c.name, COUNT(*) AS film_count
FROM category c JOIN film_category fc ON c.category_id = fc.category_id
GROUP BY c.name 
HAVING COUNT(*) < 5;

-- =============================================
-- 5. RENTAL ANALYSIS
-- =============================================

-- Rental frequency by customer
SELECT 
  r.customer_id, 
  c.first_name, 
  c.last_name, 
  COUNT(*) AS rental_count
FROM rental r JOIN customer c ON r.customer_id = c.customer_id
GROUP BY r.customer_id, c.first_name, c.last_name 
ORDER BY rental_count DESC;

-- Top 5 renters
SELECT 
  c.customer_id, 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  COUNT(r.rental_id) AS total_rentals
FROM customer c JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_rentals DESC
LIMIT 5;

-- Rentals per film
SELECT i.film_id, COUNT(*) AS rental_count
FROM inventory i JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY i.film_id
ORDER BY rental_count DESC;

-- Average rental duration per film
SELECT 
  f.film_id, 
  f.title,
  EXTRACT(DAY FROM AVG(r.return_date - r.rental_date)) AS avg_rental_days
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.return_date IS NOT NULL
GROUP BY f.film_id, f.title
ORDER BY avg_rental_days DESC;

-- Busiest rental hours
SELECT 
  EXTRACT(HOUR FROM rental_date) AS hour_of_day,
  COUNT(*) AS rental_count
FROM rental
GROUP BY hour_of_day
ORDER BY rental_count DESC
LIMIT 10;

-- =============================================
-- 6. FINANCIAL ANALYSIS
-- =============================================

-- Top spending customers
SELECT 
  c.customer_id, 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  SUM(p.amount) AS total_spend
FROM customer c JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spend DESC
LIMIT 5;

-- Customer lifetime value
SELECT 
  p.customer_id, 
  SUM(p.amount) AS lifetime_value
FROM payment p
GROUP BY p.customer_id
ORDER BY lifetime_value DESC;

-- Average revenue per customer (two methods)
-- Method 1: Subquery
SELECT CONCAT(ROUND(AVG(total_revenue),2),'$') AS avg_revenue_per_customer
FROM (
  SELECT customer_id, SUM(amount) AS total_revenue
  FROM payment
  GROUP BY customer_id
) AS customer_revenue;

-- Method 2: CTE
WITH customer_revenue AS (
  SELECT customer_id, SUM(amount) AS total_revenue
  FROM payment
  GROUP BY customer_id
)
SELECT CONCAT(ROUND(AVG(total_revenue),2),'$') AS avg_revenue_per_customer
FROM customer_revenue;

-- Customers spending above average
WITH customer_spending AS (
  SELECT 
    customer_id, 
    SUM(amount) AS total_spent
  FROM payment
  GROUP BY customer_id
)
SELECT 
  customer_id, 
  total_spent
FROM customer_spending
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spending)
ORDER BY customer_id;

-- Alternative with CROSS JOIN
WITH customer_spending AS (
  SELECT 
    customer_id, 
    SUM(amount) AS total_spent
  FROM payment
  GROUP BY customer_id
),
avg_spending AS (
  SELECT AVG(total_spent) AS avg_spent
  FROM customer_spending
)
SELECT 
  cs.customer_id, 
  cs.total_spent
FROM customer_spending cs
CROSS JOIN avg_spending
WHERE cs.total_spent > avg_spending.avg_spent
ORDER BY cs.customer_id;

-- Total revenue
SELECT CONCAT(SUM(amount),'$') AS total_revenue FROM payment;

-- Yearly revenue
SELECT 
  EXTRACT(YEAR FROM payment_date) AS year, 
  CONCAT(SUM(amount),'$') AS revenue
FROM payment
GROUP BY year
ORDER BY year;

-- Monthly revenue
SELECT 
  EXTRACT(YEAR FROM payment_date) AS year,
  TO_CHAR(payment_date, 'month') AS month,
  SUM(amount) AS revenue
FROM payment
GROUP BY year, month
ORDER BY year, month;

-- =============================================
-- 7. GEOGRAPHIC ANALYSIS
-- =============================================

-- Store locations
SELECT 
  s.store_id, 
  c.city, 
  co.country
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id;

-- Rental trends by location
SELECT 
  co.country, 
  c.city,
  EXTRACT(YEAR FROM r.rental_date) AS year,
  EXTRACT(MONTH FROM r.rental_date) AS month,
  COUNT(*) AS rental_count
FROM city c
JOIN country co ON c.country_id = co.country_id
JOIN address a ON c.city_id = a.city_id
JOIN customer cu ON a.address_id = cu.address_id
JOIN rental r ON cu.customer_id = r.customer_id
GROUP BY co.country, c.city, year, month
ORDER BY rental_count DESC;

-- Top revenue cities
SELECT 
  c.city, 
  EXTRACT(YEAR FROM p.payment_date) AS year,
  SUM(p.amount) AS total_revenue
FROM city c
JOIN address a ON c.city_id = a.city_id
JOIN customer ct ON a.address_id = ct.address_id
JOIN payment p ON ct.customer_id = p.customer_id
GROUP BY c.city, year
ORDER BY total_revenue DESC
LIMIT 10;

-- =============================================
-- 8. CATEGORY ANALYSIS
-- =============================================

-- Rentals per category
SELECT 
  c.category_id, 
  c.name, 
  COUNT(r.rental_id) AS rental_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c.category_id, c.name
ORDER BY rental_count DESC;

-- Profitable categories
SELECT 
  c.name, 
  COUNT(r.rental_id) AS total_rentals,
  SUM(p.amount) AS total_revenue,
  ROUND(SUM(p.amount)/COUNT(r.rental_id),2) AS avg_revenue_per_rental
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY avg_revenue_per_rental DESC;

-- =============================================
-- 9. STAFF PERFORMANCE
-- =============================================

-- Staff rental counts
SELECT 
  r.staff_id, 
  s.email, 
  COUNT(*) AS rental_count
FROM rental r JOIN staff s ON r.staff_id = s.staff_id
GROUP BY r.staff_id, s.email
ORDER BY rental_count DESC;

-- =============================================
-- 10. OPERATIONAL ISSUES
-- =============================================

-- Late returns
SELECT 
  r.customer_id, 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.email, 
  COUNT(*) AS late_returns
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE r.return_date IS NOT NULL 
  AND (r.return_date::date - r.rental_date::date) > f.rental_duration
GROUP BY r.customer_id, customer_name, c.email
ORDER BY late_returns DESC
LIMIT 10;

-- Unreturned films
SELECT 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
  c.email, 
  r.rental_date,
  EXTRACT(DAYS FROM (CURRENT_DATE - r.rental_date)) AS days_rented
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE r.return_date IS NULL;

-- =============================================
-- 11. TEMPORAL TRENDS
-- =============================================

-- Monthly rental trends
SELECT 
  TO_CHAR(rental_date, 'MON') AS month,
  EXTRACT(YEAR FROM rental_date) AS year,
  COUNT(*) AS rental_count
FROM rental
GROUP BY month, year
ORDER BY rental_count DESC;

-- Category popularity by year/month
SELECT 
  TO_CHAR(r.rental_date, 'YYYY') AS year,
  TO_CHAR(r.rental_date, 'MM') AS month,
  c.name AS category,
  COUNT(*) AS rental_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY year, month, category
ORDER BY rental_count DESC;

-- =============================================
-- 12. PREMIUM CONTENT ANALYSIS
-- =============================================

-- Customers renting premium films
WITH premium_films AS (
  SELECT film_id 
  FROM film 
  WHERE rental_rate = (SELECT MAX(rental_rate) FROM film)
)
SELECT DISTINCT c.customer_id
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN premium_films pf ON i.film_id = pf.film_id
ORDER BY c.customer_id;

-- Top rented films per category
WITH film_rentals AS (
  SELECT 
    f.film_id,
    f.title,
    c.name AS category,
    COUNT(*) AS rental_count
  FROM film f
  JOIN film_category fc ON f.film_id = fc.film_id
  JOIN category c ON fc.category_id = c.category_id
  JOIN inventory i ON f.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY f.film_id, f.title, c.name
),
category_max AS (
  SELECT 
    category,
    MAX(rental_count) AS max_rentals
  FROM film_rentals
  GROUP BY category
)
SELECT 
  fr.film_id,
  fr.title,
  fr.category,
  fr.rental_count
FROM film_rentals fr
JOIN category_max cm ON fr.category = cm.category AND fr.rental_count = cm.max_rentals
ORDER BY fr.category;

--Find customers who rented the most expensive movie (CTE)
WITH expensive_movie AS (
  SELECT MAX(f.rental_rate) AS max_rate
  FROM film f
)
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN expensive_movie em ON f.rental_rate =  em.max_rate
ORDER BY c.customer_id;

--Subquery Version of Find customers who rented the most expensive movie (CTE)



--Films that have a rental rate higher than the average rental rate (Premium Films).

 