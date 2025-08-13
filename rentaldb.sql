/* =============================================
 COMPLETE DVD Rental Database Analysis Script
 Author: Khaja Hafeezuddin Shaik
 ============================================= */
-- =============================================
-- 1. DATABASE SCHEMA EXPLORATION
-- =============================================
-- List all tables in public schema
SELECT *
FROM information_schema.tables
WHERE table_schema = 'public';
-- List address table columns
SELECT column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'address'
  AND table_schema = 'public';
-- =============================================
-- 2. BASIC DATA INSPECTION
-- =============================================
/* Customer data Sample */
SELECT *
FROM customer c
ORDER BY customer_id
LIMIT 5;
/* Count of Total distinct customers, total films, total rentals */
--Main Query with subquery to display Distinct customers, rentals and films
SELECT (
    SELECT COUNT(DISTINCT customer_id)
    FROM customer
  ) AS total_customers,
  (
    SELECT COUNT(DISTINCT film_id)
    FROM film
  ) AS total_films,
  (
    SELECT COUNT(DISTINCT rental_date)
    FROM rental
  ) AS total_rentals;
--Using CTE & CROSS JOIN
WITH total_customers AS (
  SELECT COUNT(DISTINCT customer_id) AS total_customers
  FROM customer c
),
total_films AS (
  SELECT COUNT(DISTINCT f.film_id) AS total_films
  FROM film f
),
total_rentals AS (
  SELECT COUNT(DISTINCT r.rental_id) AS total_rentals
  FROM rental r
)
SELECT *
FROM total_customers
  CROSS JOIN total_films,
  total_rentals;
--Cross Join to join single value tables.
/* Distinct categories across stores */
SELECT DISTINCT c.name
FROM category c;
-- =============================================
-- 3. CUSTOMER ANALYSIS
-- =============================================
/* List of all customers with their full nmes */
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM customer;
/* Customers who are from London city */
SELECT CONCAT(first_name, ' ', last_name) AS customer_name
FROM customer c
  JOIN address a ON c.address_id = a.address_id
  JOIN city ci ON a.city_id = ci.city_id
WHERE ci.city = 'London';
/* List of active customers who rented atleast once */
SELECT DISTINCT r.customer_id AS customer_id,
  c.first_name,
  c.last_name
FROM rental r
  JOIN customer c ON r.customer_id = c.customer_id
ORDER BY r.customer_id;
/* List of customers who never rented a film */
SELECT c.customer_id
FROM customer c
  LEFT JOIN rental r ON c.customer_id = r.customer_id
WHERE r.customer_id IS NULL
LIMIT 5;
/* Customers renting from multiple stores */
SELECT c.customer_id,
  c.first_name,
  c.last_name
FROM customer c
  INNER JOIN rental r ON c.customer_id = r.customer_id
  INNER JOIN staff s ON r.staff_id = s.staff_id
WHERE s.store_id IN (1, 2)
GROUP BY 1,
  2,
  3
HAVING COUNT(DISTINCT s.store_id) = 2;
-- =============================================
-- 4. FILM ANALYSIS  
-- =============================================
/* Language of Each film */
SELECT f.title AS film_name,
  l.name AS language
FROM film f
  JOIN language l ON f.language_id = l.language_id;
/* No. of films in each language */
SELECT l.name AS film_language,
  COUNT(*) AS no_of_films
FROM language l
  INNER JOIN film f ON l.language_id = f.language_id
GROUP BY 1
ORDER BY no_of_films DESC;
/* List of films which are not in inventory */
SELECT f.film_id,
  f.title
FROM film f
  LEFT JOIN inventory i ON f.film_id = i.film_id
WHERE i.inventory_id IS NULL;
/* Films by rating (PG-13/NC-17/R/PG/G)*/
SELECT f.rating AS film_rating,
  COUNT(*) AS film_count
FROM film f
GROUP BY f.rating
ORDER BY film_count DESC;
/* No.of films in each category. Ordered by category having most no of films */
SELECT c.name AS category_name,
  COUNT(*) AS film_count
FROM category c
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY film_count DESC;
/* Categories with less than 5 films in them */
SELECT c.name AS category_name,
  COUNT(*) AS no_of_films
FROM category c
  INNER JOIN film_category fc ON c.category_id = fc.category_id
GROUP BY c.name
HAVING COUNT(*) < 5;
-- =============================================
-- 5. RENTAL ANALYSIS
-- =============================================
/* Rental count by customer */
SELECT r.customer_id,
  c.first_name,
  c.last_name,
  COUNT(*) AS rental_count
FROM rental r
  JOIN customer c ON r.customer_id = c.customer_id
GROUP BY r.customer_id,
  c.first_name,
  c.last_name
ORDER BY rental_count DESC;
/* Customers who rented the films the most */
SELECT c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  COUNT(r.rental_id) AS total_rentals
FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id,
  customer_name
ORDER BY total_rentals DESC
LIMIT 5;
/* How many times each film is rented out/ Top renting films */
SELECT i.film_id,
  COUNT(*) AS rental_count
FROM inventory i
  JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY i.film_id
ORDER BY rental_count DESC;
/* Calculating Average duration for each film */
SELECT f.film_id,
  f.title,
  EXTRACT(
    DAY
    FROM AVG(r.return_date - r.rental_date)
  ) AS avg_rental_days
FROM film f
  JOIN inventory i ON f.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.return_date IS NOT NULL
GROUP BY f.film_id,
  f.title
ORDER BY avg_rental_days DESC;
/* Hours which are busiest/Most rentals */
SELECT EXTRACT(
    HOUR
    FROM rental_date
  ) AS hour_of_day,
  COUNT(*) AS rental_count
FROM rental
GROUP BY hour_of_day
ORDER BY rental_count DESC
LIMIT 10;
-- =============================================
-- 6. FINANCIAL ANALYSIS
-- =============================================
/* Top Spending customers for loyalty rewards */
SELECT c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  SUM(p.amount) AS total_spend
FROM customer c
  JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id,
  customer_name
ORDER BY total_spend DESC
LIMIT 5;
/* Total amount spent by a customer across all transactions (Life time value) */
SELECT p.customer_id,
  SUM(p.amount) AS lifetime_value
FROM payment p
GROUP BY p.customer_id
ORDER BY lifetime_value DESC;
/* Average revenue per customer */
-- Option 1: Subquery
SELECT CONCAT(ROUND(AVG(total_revenue), 2), '$') AS avg_revenue_per_customer --Main query to calculate avg revenue per customer
FROM (
    SELECT customer_id,
      SUM(amount) AS total_revenue --Subquery to calculate total anount spent by each customer.
    FROM payment
    GROUP BY customer_id
  ) AS customer_revenue;
-- Option 2: CTE
--CTE to calculate amount total spent by customer
WITH customer_revenue AS (
  SELECT customer_id,
    SUM(amount) AS total_revenue
  FROM payment
  GROUP BY customer_id
)
SELECT CONCAT(ROUND(AVG(total_revenue), 2), '$') AS avg_revenue_per_customer
FROM customer_revenue;
/* Customers spending more than average spend */
--CTE to calculate amount spend by each customer across multiple rental transactions.
WITH customer_spending AS (
  SELECT customer_id,
    SUM(amount) AS total_spent
  FROM payment
  GROUP BY customer_id
)
SELECT customer_id,
  total_spent
FROM customer_spending --Comparing total amount spend by a customer with average for filtering
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM customer_spending
  )
ORDER BY customer_id;
-- Alternative with CROSS JOIN
--CTE to calculate total amount spent by each customer across all transactions.
WITH customer_spending AS (
  SELECT customer_id,
    SUM(amount) AS total_spent
  FROM payment
  GROUP BY customer_id
),
--CTE to calculate avg amount spent by all customers
avg_spending AS (
  SELECT AVG(total_spent) AS avg_spent
  FROM customer_spending
) --Main query to display customers and filter them
SELECT cs.customer_id,
  cs.total_spent
FROM customer_spending cs
  CROSS JOIN avg_spending --Ideal when comparing one value to many rows
WHERE cs.total_spent > avg_spending.avg_spent -- Filtering
ORDER BY cs.customer_id;
/* Total revenue generated till date */
SELECT CONCAT(SUM(amount), '$') AS total_revenue
FROM payment;
/* Yearly revenue generated by all stores acorss all geographies */
SELECT EXTRACT(
    YEAR
    FROM payment_date
  ) AS year,
  CONCAT(SUM(amount), '$') AS revenue
FROM payment
GROUP BY year
ORDER BY year;
/* Total Revenue calculation by Year, Month and total revenue generated */
SELECT EXTRACT(
    YEAR
    FROM payment_date
  ) AS year,
  TO_CHAR(payment_date, 'month') AS month,
  SUM(amount) AS revenue
FROM payment
GROUP BY year,
  month
ORDER BY year,
  month;
-- =============================================
-- 7. GEOGRAPHIC ANALYSIS
-- =============================================
/* Store information */
SELECT s.store_id,
  c.city,
  co.country
FROM store s
  JOIN address a ON s.address_id = a.address_id
  JOIN city c ON a.city_id = c.city_id
  JOIN country co ON c.country_id = co.country_id;
/* Rental trends by location (City, Country), Year and Month */
SELECT co.country,
  c.city,
  EXTRACT(
    YEAR
    FROM r.rental_date
  ) AS year,
  EXTRACT(
    MONTH
    FROM r.rental_date
  ) AS month,
  COUNT(*) AS rental_count
FROM city c
  JOIN country co ON c.country_id = co.country_id
  JOIN address a ON c.city_id = a.city_id
  JOIN customer cu ON a.address_id = cu.address_id
  JOIN rental r ON cu.customer_id = r.customer_id
GROUP BY co.country,
  c.city,
  year,
  month
ORDER BY rental_count DESC;
/* Top revenue generating cities */
SELECT c.city,
  EXTRACT(
    YEAR
    FROM p.payment_date
  ) AS year,
  SUM(p.amount) AS total_revenue
FROM city c
  JOIN address a ON c.city_id = a.city_id
  JOIN customer ct ON a.address_id = ct.address_id
  JOIN payment p ON ct.customer_id = p.customer_id
GROUP BY c.city,
  year
ORDER BY total_revenue DESC
LIMIT 10;
--Limiting by top 10 cities
-- =============================================
-- 8. CATEGORY ANALYSIS
-- =============================================
/* Films rented out in each category */
SELECT c.category_id,
  c.name,
  COUNT(r.rental_id) AS rental_count
FROM category c
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN inventory i ON fc.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c.category_id,
  c.name
ORDER BY rental_count DESC;
/* Finding categories which are more profitable */
/* Main query to calculate rentals in each movie category, 
 revenue generated by them and 
 average revenue per rental in that category
 Ordered by Avg revenue */
SELECT c.name,
  COUNT(r.rental_id) AS total_rentals,
  SUM(p.amount) AS total_revenue,
  ROUND(SUM(p.amount) / COUNT(r.rental_id), 2) AS avg_revenue_per_rental
FROM category c
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN inventory i ON fc.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
  JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY avg_revenue_per_rental DESC;
--Key Insights Derived
--Sports generates highest revenue despite being in 3rd Position by avg_revenue
-- Comedy Category Commands the highest premium.
-- Family and Classics have below avg revenue.
--Sports + Comedy + Sci-Fi deliver 28% of total revenue
-- =============================================
-- 9. STAFF PERFORMANCE
-- =============================================
/* No.of.films rented out by each staff member/Metric to evaluate performance */
SELECT r.staff_id,
  s.email,
  COUNT(*) AS rental_count
FROM rental r
  JOIN staff s ON r.staff_id = s.staff_id --Joing Staff table to retrive identifiable staff data
GROUP BY r.staff_id,
  s.email
ORDER BY rental_count DESC;
-- =============================================
-- 10. OPERATIONAL ISSUES
-- =============================================
/* Query to extract customers who return the rented films late using the date operations */
SELECT r.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.email,
  COUNT(*) AS late_returns
FROM rental r
  JOIN inventory i ON r.inventory_id = i.inventory_id
  JOIN film f ON i.film_id = f.film_id
  JOIN customer c ON r.customer_id = c.customer_id
WHERE r.return_date IS NOT NULL
  AND (r.return_date::date - r.rental_date::date) > f.rental_duration --Converting renturn date, rental date into date and comparing that with rental duration to filter late returns
GROUP BY 1,
  2,
  3
ORDER BY late_returns DESC
LIMIT 10;
/* Unreturned films*/
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  --Concating firstname and lastname into customername
  c.email,
  r.rental_date,
  r.return_date,
  EXTRACT(
    DAYS
    FROM (CURRENT_DATE - r.rental_date)
  ) AS days_rented --No.of days since film was rented out
FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
WHERE r.return_date IS NULL;
--Filtering customers whose returned date is Null - Unreturned films.
-- =============================================
-- 11. TEMPORAL TRENDS
-- =============================================
/* Monthly rental trends */
--Rental data month and year wise.
SELECT TO_CHAR(rental_date, 'MM') AS month,
  EXTRACT(
    YEAR
    FROM rental_date
  ) AS year,
  COUNT(*) AS rental_count
FROM rental
GROUP BY 1,
  2
ORDER BY rental_count DESC;
/* Category popularity by year/month */
--Main query to calculate no.of.rentals in each category, month and year wise.
SELECT TO_CHAR(r.rental_date, 'YYYY') AS year,
  TO_CHAR(r.rental_date, 'MM') AS month,
  c.name AS category,
  COUNT(*) AS rental_count
FROM category c
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN inventory i ON fc.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,
  2,
  3
ORDER BY rental_count DESC;


/* Categorize Films by Rental Performance
 Objective:
 Classify films into performance tiers based on rental frequency and compare their revenue contribution.
 
 Requirements:
 Use a CASE statement to categorize films as:
 "High Demand": Rented 30+ times | "Medium Demand": Rented 15-29 times | "Low Demand": Rented <15 times
 For each category, calculate: Number of films, Total revenue generated, Average rental rate
 Sort results by revenue contribution (highest to lowest). */
--CTE to categorize films based on no.of.times film was rented
WITH demandcat AS (
  SELECT f.film_id,
    f.rental_rate,
    f.title,
    COUNT(*) AS no_of_times_rented,
    CASE
      WHEN COUNT(*) >= 30 THEN 'High Demand'
      WHEN COUNT(*) BETWEEN 15 AND 29 THEN 'Medium Demand'
      ELSE 'Low Demand'
    END AS Demand
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY 1,
    2,
    3
  ORDER BY no_of_times_rented DESC
),
--CTE to calculate revenue per category, Average rental rate and no.of.films in each category.
catrevenue AS (
  SELECT d.demand,
    SUM(d.rental_rate * d.no_of_times_rented) AS revenue_per_cat,
    --Calculation of revenue in each category
    ROUND(AVG(d.rental_rate), 2) avg_rental_rate,
    --Average rental rate calculation for the data in each category.
    COUNT(d.demand)
  FROM demandcat d
  GROUP BY 1
)
SELECT *
FROM catrevenue
ORDER BY revenue_per_cat DESC;
-- =============================================
-- 12. PREMIUM CONTENT ANALYSIS
-- =============================================
/* Customers renting premium films */
--CTE to filter films which are most expensive
WITH premium_films AS (
  SELECT film_id
  FROM film
  WHERE rental_rate = (
      SELECT MAX(rental_rate)
      FROM film
    )
) --Main query to display customer details who rented those expensive films
SELECT DISTINCT c.customer_id
FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
  JOIN inventory i ON r.inventory_id = i.inventory_id
  JOIN premium_films pf ON i.film_id = pf.film_id --Joining CTE table to filter records using premium_films CTE
ORDER BY c.customer_id;
--Without subquery
WITH maxrate AS (
  SELECT MAX(rental_rate) AS max_rate
  FROM film f
)
SELECT DISTINCT c.first_name,
  c.last_name,
  c.email
FROM customer c
  INNER JOIN rental r ON c.customer_id = r.customer_id
  INNER JOIN inventory i ON r.inventory_id = i.inventory_id
  INNER JOIN film f ON i.film_id = f.film_id --INNER JOIN maxrate mr ON f.rental_rate = mr.max_rate (Alternative)
  CROSS JOIN maxrate mr
WHERE f.rental_rate = mr.max_rate
ORDER BY c.first_name,
  c.last_name;
WITH maxrate AS (
  SELECT MAX(rental_rate) AS max_rate
  FROM film f
)
SELECT DISTINCT c.first_name,
  c.last_name,
  c.email
FROM customer c
  INNER JOIN rental r ON c.customer_id = r.customer_id
  INNER JOIN inventory i ON r.inventory_id = i.inventory_id
  INNER JOIN film f ON i.film_id = f.film_id --INNER JOIN maxrate mr ON f.rental_rate = mr.max_rate (Alternative)
  CROSS JOIN maxrate mr
WHERE f.rental_rate = mr.max_rate
ORDER BY c.first_name,
  c.last_name;
/*Top rented films per category*/
--CTE to calculate how many times each film is rented along with its category
WITH film_rentals AS (
  SELECT f.film_id,
    f.title,
    c.name AS category,
    COUNT(*) AS rental_count
  FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY f.film_id,
    f.title,
    c.name
),
--CTE to extract Category max values from the film_rental CTE for each category
category_max AS (
  SELECT category,
    MAX(rental_count) AS max_rentals
  FROM film_rentals
  GROUP BY category
) --Main query to find top rented films in each category
SELECT fr.film_id,
  fr.title,
  fr.category,
  fr.rental_count
FROM film_rentals fr
  JOIN category_max cm ON fr.category = cm.category
  AND fr.rental_count = cm.max_rentals --Joining category_max CTE AND Film_Rental CTE & Filtering to extract most rented films in each category
ORDER BY fr.category;
/* Find customers who rented the most expensive movie (CTE)*/
--CTE to extract expensive movie rate from film table.
WITH expensive_movie AS (
  SELECT MAX(f.rental_rate) AS max_rate
  FROM film f
) --Main Query to find customers and who rented those films (Can be multiple)
SELECT DISTINCT c.customer_id,
  c.first_name,
  c.last_name
FROM customer c
  INNER JOIN rental r ON c.customer_id = r.customer_id
  INNER JOIN inventory i ON r.inventory_id = i.inventory_id
  INNER JOIN film f ON i.film_id = f.film_id
  INNER JOIN expensive_movie em ON f.rental_rate = em.max_rate --INNER JOIN CTE filters data by only keeping data that is equal to expensive movie rate
ORDER BY c.customer_id;
/*Films that have a rental rate higher than the average rental rate (Premium Films) using CTE.*/
--CTE to calculate average rental rate of films from film table
WITH avg_price AS (
  SELECT AVG(f.rental_rate) AS avg_rate
  FROM film f
)
SELECT f.film_id,
  f.title,
  f.rental_rate,
  ROUND(ap.avg_rate, 2) AS avgrate
FROM film f
  CROSS JOIN avg_price ap --Cross join implementation to compare avgrate with rental rate of film.
WHERE rental_rate > ap.avg_rate --Filtering films whose rental rate > avgerage rate
ORDER BY f.film_id;
/* Films that have a rental rate higher than the average rental rate (Premium Films) using subquery.*/
SELECT f.film_id,
  f.title,
  f.rental_rate,
  ROUND(
    (
      SELECT AVG(f.rental_rate) AS avg_rate
      FROM film f
    ),
    2
  ) AS avg_rental_rate --Calculation of AVG rental rate.
FROM film f
WHERE f.rental_rate > (
    SELECT AVG(f.rental_rate)
    FROM film f
  ) --Comparing and filtering film rental rate with Avg rental rate using subquery
ORDER BY film_id;
/* Customers who have spent more than the average total rental amount across all customers (Premium Customers)*/
--CTE to calculate total amount spent by each customer. Data retreived from Payments table
WITH total_spend AS (
  SELECT p.customer_id,
    SUM(p.amount) AS totspend
  FROM payment p
  GROUP BY 1
  ORDER BY p.customer_id
),
--CTE to calculate Average amount spent by each customer. Calculated from totspend metric from total_spend_cte 
avg_spend AS (
  SELECT AVG(totspend) AS avg_spend
  FROM total_spend
) --Main Query with cross join to compare, and filter the required data to display customers who spent more than average
SELECT ts.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS full_name,
  ts.totspend,
  ROUND(avgspendamnt.avg_spend, 2) AS per_customer_avg
FROM total_spend ts
  CROSS JOIN avg_spend AS avgspendamnt --Ideal when one value is being compared against all rows.
  INNER JOIN customer c ON ts.customer_id = c.customer_id
WHERE ts.totspend > avgspendamnt.avg_spend
ORDER BY ts.totspend DESC;
/* Top Rented films in each category and Number of times they were rented.*/
--CTE to find No.of.Times each film is rented/to calculate rental counts per film.
WITH filmcount AS (
  SELECT f.film_id,
    c.name,
    f.title,
    COUNT(*) AS total_rents
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
  GROUP BY 1,
    2,
    3
),
-- CTE to find the maximum rental count for each category
Catmax AS (
  SELECT name,
    MAX(total_rents) AS max_rent
  FROM filmcount
  GROUP BY name
) --Main query to JOIN the results and display most rented films in each category.
SELECT cm.name AS category,
  flc.film_id,
  flc.title AS film_name,
  flc.total_rents AS no_of_times_rented
FROM filmcount flc
  INNER JOIN catmax cm ON flc.name = cm.name
WHERE flc.total_rents = cm.max_rent
ORDER BY cm.name;



/*Identify Films with High Revenue but Low Rental Frequency 
 Find films that generate above-average revenue per rental 
 but have below-average rental frequency, 
 indicating potentially undervalued content in your catalog.*/
--CTE to calculate film_metrics - 
-- total_revenue, total rentals, avg_revenue (total_revenue_per_filmnue/no_of_times_rented) GROUPED BY film title & ID.
WITH film_metrics AS (
  SELECT f.film_id,
    f.title,
    c.name,
    SUM(p.amount) AS total_revenue_per_film,
    -- calculates total revenue generated by that film.
    COUNT(r.rental_id) AS no_of_times_film_rented,
    --calculates Total no of times film was rented.
    ROUND(SUM(p.amount) / COUNT(r.rental_id), 2) AS avg_revenue_per_rental -- Calculate Average revenue for that film (revenue/times_Rented)
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
  GROUP BY 1,
    2,
    3
),
--CTE to calculate avg_rental_amount & Rental frequency using film_metrics CTE
avg_metrics AS (
  SELECT AVG(avg_revenue_per_rental) AS avg_rental_amount,
    --FROM film_metrics CTE calculates Avg_rental_amount (avg_revenue_per_film/no_of_films)
    AVG(no_of_times_film_rented) AS avg_no_of_times_film_rented --FROM film_metrics CTE calculates avg_no_of_times_film_rented - Rental frequency (no_of_times_film_rented/no.of.rental_id)
  FROM film_metrics
) --Main query to display film data that have above average revenue and below average rental frequency using cross join.
SELECT fm.film_id,
  fm.title,
  fm.name,
  ROUND(fm.avg_revenue_per_rental, 2) AS avg_revenue_per_rental,
  ROUND(a.avg_rental_amount, 2) AS avg_rental_amount_across_all_rentals,
  ROUND(fm.no_of_times_film_rented, 2) AS no_of_times_film_rented,
  ROUND(a.avg_no_of_times_film_rented, 2) AS rental_frequency
FROM film_metrics fm
  CROSS JOIN avg_metrics a
WHERE fm.avg_revenue_per_rental > a.avg_rental_amount
  AND fm.no_of_times_film_rented < a.avg_no_of_times_film_rented
ORDER BY avg_revenue_per_rental DESC;




/*Identify Films with High Revenue but Low Availability. 
 (Find films that generate strong revenue per rental but have limited inventory copies, 
 potentially indicating missed business opportunities)*/
WITH film_metrics AS (
  SELECT f.film_id,
    f.title,
    SUM(p.amount) AS total_revenue_per_film,
    SUM(p.amount) / COUNT(r.rental_id) AS avg_revenue_per_rental,
    COUNT(i.inventory_id) AS inventory_count
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY 1,
    2
),
avg_metrics AS (
  SELECT AVG(avg_revenue_per_rental) AS rental_average_revenue,
    AVG(inventory_count) AS avg_inventory_count
  FROM film_metrics
)
SELECT fm.film_id,
  fm.title
FROM film_metrics fm
  CROSS JOIN avg_metrics a --CROSS for comparision
WHERE fm.total_revenue_per_film > a.rental_average_revenue --Filtering data
  AND inventory_count < a.avg_inventory_count
  ORDER BY fm.film_id;



/* Identify Customers with High Potential for Loyalty Programs */
--1.Frequent Renters: Above-average rental frequency, 
--2.High-Value: Above-average total spending 
--3.Recent Activity: Rented at least once in the last 30 days)
--CTE to find customers who rent more often than average
WITH above_avg_rental_frequency AS (
  SELECT r.customer_id,
    COUNT(r.rental_id) AS no_of_times_film_rented
  FROM rental r
  GROUP BY 1
  HAVING COUNT(r.rental_id) > --Filtering customers based on average frequency
    (
      SELECT AVG(times_rented)
      FROM (
          SELECT r.customer_id,
            COUNT(r.rental_id) AS times_rented
          FROM rental r
          GROUP BY 1
        )
    )
),
--CTE to find customers who spend more than the average amount
above_avg_spend AS (
  SELECT p.customer_id,
    SUM(p.amount) AS total_amount_spent
  FROM payment p
  GROUP BY 1
  HAVING SUM(p.amount) > --Filtering customers based on avg amount spent criteria
    (
      SELECT AVG(tot_spend)
      FROM (
          SELECT SUM(amount) AS tot_spend
          FROM payment p
          GROUP BY customer_id
        )
    )
),
--CTE to find customers who rented out movies in last 30 days
recent_activity AS (
  SELECT DISTINCT r.customer_id
  FROM rental r
  WHERE (CURRENT_DATE - r.rental_date::date) < 31
) --Main query to find customers who spend more than average, rent more than average and has recent activity.
SELECT cte1.customer_id
FROM above_avg_rental_frequency AS cte1
  INNER JOIN above_avg_spend cte2 ON cte1.customer_id = cte2.customer_id
  INNER JOIN recent_activity cte3 ON cte2.customer_id = cte3.customer_id;




/* Task: Identify Films at Risk of Being Overlooked */
/* Objective:
 Find films that meet all of these criteria:
 High Quality: Above-average rental rate
 Low Engagement: Below-average rental frequency
 Available Inventory: Currently in stock (at least 1 copy) */
-- CTE to Display films whose price is above the avg.rental rate of all films.
WITH ab_avg_rental_rate AS (
  SELECT f.film_id,
    f.title,
    f.rental_rate
  FROM film f
  WHERE rental_rate > (
      SELECT AVG(rental_price)
      FROM (
          SELECT f.film_id,
            f.rental_rate AS rental_price
          FROM film f
        )
    )
  ORDER BY f.film_id
),
--CTE to display films with below average rental frequency
rental_frequency AS (
  SELECT f.film_id,
    COUNT(f.film_id) AS no_of_times_film_rented
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY f.film_id
  HAVING COUNT(f.film_id) < (
      SELECT AVG(rental_count)
      FROM (
          SELECT f2.film_id,
            COUNT(f2.film_id) AS rental_count
          FROM film f2
            INNER JOIN inventory i2 ON f2.film_id = i2.film_id
            INNER JOIN rental r2 ON i2.inventory_id = r2.inventory_id
          GROUP BY f2.film_id
        )
    )
),
--CTE to get available inventory
available_inventory AS (
  SELECT DISTINCT f.film_id
  FROM film f --Replace with * from detailed idea
    INNER JOIN inventory i ON f.film_id = i.film_id
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id
    AND return_date IS NULL
    /* --You join to the rental table only if the inventory item is currently rented and NOT returned (return_date IS NULL).
     Because it’s a LEFT JOIN, even if there’s no active rental, the row will still appear — but with r.rental_id as NULL. */
  WHERE r.rental_id IS NULL
  ORDER BY f.film_id
) --Main Query
SELECT avrr.film_id,
  avrr.title
FROM ab_avg_rental_rate AS avrr
  INNER JOIN rental_frequency rf ON avrr.film_id = rf.film_id
  INNER JOIN available_inventory ai ON rf.film_id = ai.film_id
ORDER BY avrr.film_id;



/* Task: "Identify Underpriced Films"
 Find films where:
 High Rental Demand: Above-average rental frequency
 Low Rental Rate: Priced below the average rental rate for their category
 Available to Rent: Currently in stock */
--CTE to find films with above average rental frequency
WITH abv_avg_rental_f AS (
  SELECT f.film_id,
    f.title,
    f.rental_rate,
    COUNT(r.rental_id)
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY f.film_id
  HAVING COUNT(r.rental_id) > (
      SELECT AVG(avg_rental_freq)
      FROM (
          SELECT f2.film_id,
            COUNT(r2.rental_id) AS avg_rental_freq
          FROM film f2
            INNER JOIN inventory i2 ON f2.film_id = i2.film_id
            INNER JOIN rental r2 ON i2.inventory_id = r2.inventory_id
          GROUP BY f2.film_id
        )
    )
  ORDER BY f.film_id
),
--CTE to get films which are priced below average
low_priced_films AS (
  SELECT f.film_id,
    f.rental_rate
  FROM film f
  WHERE f.rental_rate < (
      SELECT AVG(f.rental_rate)
      FROM film f
    )
  ORDER BY f.film_id
),
--CTE to retrieve available inventory
available_in_inventory AS (
  SELECT DISTINCT f.film_id
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id
    AND r.return_date IS NULL
  WHERE r.rental_id IS NULL
) -- Main query to display underpriced films
SELECT aarf.film_id,
  aarf.title,
  aarf.rental_rate
FROM abv_avg_rental_f aarf
  INNER JOIN low_priced_films lpf ON aarf.film_id = lpf.film_id
  INNER JOIN available_in_inventory aii ON lpf.film_id = aii.film_id
ORDER BY aarf.film_id;




/* Task: Identify Never-Rented Films with High Revenue Potential. 
 Find films that meet all of these criteria: 

 Zero Rentals: Never been rented
 High Value: Rental rate above the average for their category 
 In Stock: Currently available in inventory. */

--CTE to find films that have never been rented
WITH film_with_no_rentals AS (
  SELECT f.film_id, i.inventory_id, f.title
  FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL
ORDER BY f.film_id
),
--CTE to find high value rentals
abv_avg_rental_rate AS (
  SELECT f.film_id,
    f.title,
    f.rental_rate
  FROM film f
  WHERE rental_rate > (
      SELECT AVG(rental_price)
      FROM (
          SELECT f.film_id,
            f.rental_rate AS rental_price
          FROM film f
        )
    )
  ORDER BY f.film_id
),
--CTE to get Current Inventory
available_in_inventory AS (
SELECT DISTINCT f.film_id
  FROM film f --Replace with * for detailed idea
    INNER JOIN inventory i ON f.film_id = i.film_id
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id AND return_date IS NULL
    /* --You join to the rental table only if the inventory item is currently rented and NOT returned (return_date IS NULL).
     Because it’s a LEFT JOIN, even if there’s no active rental, the row will still appear — but with r.rental_id as NULL. */
  WHERE r.rental_id IS NULL
  ORDER BY f.film_id
)
--Main query
SELECT fwnr.film_id, 
  fwnr.title
FROM film_with_no_rentals fwnr
INNER JOIN abv_avg_rental_rate aarr ON fwnr.film_id = aarr.film_id
INNER JOIN available_in_inventory aii ON aarr.film_id = aii.film_id;




/*- Find customers who have rented films more than the average number of times but whose 
total spend is below the average total spend across all customers. */

--CTE to find customers who rented more than average number of times
WITH above_avg_rentals AS (
SELECT c.customer_id,
    c.first_name,
    COUNT(*) AS abv_avg_rentals_count
FROM customer c
    INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY 1,
    2
HAVING COUNT(*) > (
        SELECT AVG(count2)
        FROM (
                SELECT r2.customer_id,
                    COUNT(*) AS count2
                FROM rental r2
                GROUP BY r2.customer_id
            )
    )
ORDER BY abv_avg_rentals_count DESC
),
--CTE to calculate average spend and Filter customers whose spend is below average
below_avg_payment AS (
    SELECT c.customer_id,
        c.first_name,
        SUM(p.amount) AS total_spent
    FROM customer c
        INNER JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    HAVING SUM(p.amount) < (
            SELECT AVG(total_spent2)
            FROM (
                    SELECT p2.customer_id,
                        SUM(p2.amount) AS total_spent2
                    FROM payment p2
                    GROUP BY p2.customer_id
                )
        )
)
--Main query to filter customers who rent above average times but spent below average.
--Picky spenders
SELECT aar.customer_id, aar.first_name
FROM above_avg_rentals AS aar
INNER JOIN below_avg_payment bap ON aar.customer_id = bap.customer_id
ORDER BY 1;
