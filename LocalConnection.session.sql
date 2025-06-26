-- =====================================
-- SECTION 1: Schema Exploration
-- =====================================

-- List all tables in the public schema
SELECT *
FROM information_schema.tables
WHERE table_schema = 'public';

-- List all columns in the address table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'address' AND table_schema = 'public';

-- =====================================
-- SECTION 2: Customer Insights
-- =====================================

-- Sample 5 customer records
SELECT * FROM customer ORDER BY customer_id LIMIT 5;

-- Total customers, films, and rental dates
SELECT 
  (SELECT COUNT(DISTINCT customer_id) FROM customer) AS total_customers,
  (SELECT COUNT(DISTINCT film_id) FROM film) AS total_films,
  (SELECT COUNT(DISTINCT rental_date) FROM rental) AS total_rentals;

-- Distinct category names
SELECT DISTINCT name FROM category;

-- Retrieve full names of customers
SELECT CONCAT(first_name,' ',last_name) AS full_name FROM customer;

-- Customers who have rented at least once
SELECT DISTINCT r.customer_id, c.first_name, c.last_name
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
ORDER BY customer_id;

-- Rental count per customer
SELECT r.customer_id, c.first_name, c.last_name, COUNT(*) AS no_of_times_rented
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
GROUP BY r.customer_id, c.first_name, c.last_name
ORDER BY no_of_times_rented DESC;

-- Top 5 customers by spend
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name,
       SUM(p.amount) AS total_spend
FROM customer c
INNER JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, full_name
ORDER BY total_spend DESC
LIMIT 5;

-- Top 5 customers by rentals
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name,
       COUNT(r.rental_id) AS total_rentals
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, full_name
ORDER BY total_rentals DESC
LIMIT 5;

-- Customers who have never rented
SELECT c.customer_id
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
WHERE r.customer_id IS NULL
LIMIT 5;

-- LTV per customer
SELECT p.customer_id, SUM(p.amount) AS total_ltv
FROM payment p
GROUP BY p.customer_id
ORDER BY total_ltv DESC;

-- Average revenue per customer
SELECT AVG(total_revenue_per_customer) AS average_revenue_from_customer
FROM (
    SELECT p.customer_id, SUM(p.amount) AS total_revenue_per_customer
    FROM payment p
    GROUP BY p.customer_id
) AS customer_revenue;

-- =====================================
-- SECTION 3: Film & Rental Analytics
-- =====================================

-- Rentals per film
SELECT i.film_id, COUNT(*) AS no_of_times_rented
FROM inventory i
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY i.film_id
ORDER BY no_of_times_rented DESC;

-- Rentals per category
SELECT c.category_id, c.name, COUNT(r.rental_id) AS rental_count
FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN inventory i ON fc.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c.category_id, c.name
ORDER BY rental_count DESC;

-- Rental duration per film
SELECT f.film_id, f.title,
       AVG(r.return_date - r.rental_date) AS average_rental
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.return_date IS NOT NULL
GROUP BY f.film_id, f.title
ORDER BY average_rental DESC;

-- Top salesperson by rentals
SELECT r.staff_id, s.email, COUNT(*) AS no_of_rentals
FROM rental r
INNER JOIN staff s ON r.staff_id = s.staff_id
GROUP BY r.staff_id, s.email
ORDER BY no_of_rentals DESC;

-- Top 10 late returns
SELECT r.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name,
       c.email, COUNT(*) AS no_of_late_returns
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN customer c ON r.customer_id = c.customer_id
WHERE r.return_date IS NOT NULL AND (r.return_date::date - r.rental_date::date) > f.rental_duration
GROUP BY r.customer_id, full_name, c.email
ORDER BY no_of_late_returns DESC
LIMIT 10;

-- Movies rented but not returned
SELECT CONCAT(c.first_name, ' ', c.last_name) AS full_name, c.email, r.rental_date,
       EXTRACT(DAYS FROM (CURRENT_DATE - r.rental_date)) AS rented_out_days
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
WHERE r.return_date IS NULL;

-- Busiest hour of the day
SELECT EXTRACT(HOUR FROM rental_date) AS hour_of_day,
       COUNT(*) AS No_of_times_rented
FROM rental
GROUP BY hour_of_day
ORDER BY No_of_times_rented DESC
LIMIT 10;

-- =====================================
-- SECTION 4: Revenue & Trends
-- =====================================

-- Total revenue from rentals
SELECT SUM(p.amount) AS total_revenue FROM payment p;

-- Yearly revenue
SELECT EXTRACT(YEAR FROM p.payment_date) AS year, SUM(p.amount) AS revenue
FROM payment p
GROUP BY year
ORDER BY year;

-- Monthly revenue with labels
SELECT EXTRACT(YEAR FROM p.payment_date) AS year,
       TO_CHAR(p.payment_date, 'Mon') AS month,
       SUM(p.amount) AS revenue
FROM payment p
GROUP BY year, month
ORDER BY year, month;

-- Rental trends by month
SELECT TO_CHAR(rental_date, 'Mon') AS month,
       COUNT(*) AS no_of_rentals
FROM rental
GROUP BY month
ORDER BY no_of_rentals DESC;

-- Rental trends by year & month
SELECT EXTRACT(YEAR FROM rental_date) AS year,
       TO_CHAR(rental_date, 'Mon') AS month,
       COUNT(*) AS no_of_rentals
FROM rental
GROUP BY year, month
ORDER BY no_of_rentals DESC;

-- Rental trends by country/city
SELECT co.country, c.city,
       EXTRACT(YEAR FROM r.rental_date) AS rental_year,
       EXTRACT(MONTH FROM r.rental_date) AS rental_month,
       COUNT(*) AS total_rentals
FROM city c
INNER JOIN country co ON c.country_id = co.country_id
INNER JOIN address a ON c.city_id = a.city_id
INNER JOIN customer cus ON a.address_id = cus.address_id
INNER JOIN rental r ON cus.customer_id = r.customer_id
GROUP BY co.country, c.city, rental_year, rental_month
ORDER BY total_rentals DESC;

-- Profitable categories
SELECT c.name, COUNT(r.rental_id) AS total_rentals,
       SUM(p.amount) AS total_revenue
FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN inventory i ON fc.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY total_revenue DESC;
