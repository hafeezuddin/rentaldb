/* =============================================
 COMPLETE DVD Rental Database Analysis Script
 Author: Khaja Hafeezuddin Shaik
 ============================================= */

-- List all tables and address columns
SELECT * FROM information_schema.tables WHERE table_schema = 'public';

-- Retrieve column names and data types for the 'address' table
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'address' AND table_schema = 'public';


/* Customer data Sample */
SELECT *
FROM customer c
ORDER BY customer_id
LIMIT 5;



/* Count of Total distinct customers, total films, total rentals */
-- Using subqueries in the SELECT list to get aggregate counts.
-- Each subquery calculates a single value.
SELECT 
  -- Subquery to count the total number of unique customers.
  (SELECT COUNT(DISTINCT customer_id) FROM customer) AS total_customers,
  -- Subquery to count the total number of unique films.
  (SELECT COUNT(DISTINCT film_id) FROM film) AS total_films,
  -- Subquery to count the total number of unique rental transactions.
  (SELECT COUNT(DISTINCT rental_id) FROM rental) AS total_rentals;

--Using CTE & CROSS JOIN
-- This query calculates the total number of distinct customers, films, and rentals
-- using Common Table Expressions (CTEs) as an alternative to subqueries in the SELECT list.
WITH 
  -- CTE to count the total number of unique customers.
  total_customers AS (
  SELECT COUNT(DISTINCT customer_id) AS total_customers
  FROM customer c
),
  -- CTE to count the total number of unique films.
  total_films AS (
  SELECT COUNT(DISTINCT f.film_id) AS total_films
  FROM film f
),
  -- CTE to count the total number of unique rental transactions.
  total_rentals AS (
  SELECT COUNT(DISTINCT r.rental_id) AS total_rentals
  FROM rental r
)
-- The main query uses CROSS JOIN to combine the single-row results from each CTE
-- into a single output row with all the counts.
SELECT *
FROM total_customers
  CROSS JOIN total_films
  CROSS JOIN total_rentals;
--Cross Join to join single value tables.





/* Distinct categories across stores */
SELECT DISTINCT c.name
FROM category c;



/* List of all customers with their full nmes */
SELECT 
  CONCAT(c.first_name,' ',c.last_name) AS full_name,
  c.email
FROM customer c
ORDER BY c.first_name;


/* Customers who are from London city */
SELECT 
  CONCAT(c.first_name,' ',c.last_name) AS customer_name,
  ci.city
FROM customer c
  JOIN address a ON c.address_id = a.address_id
  JOIN city ci ON a.city_id = ci.city_id
WHERE ci.city = 'London';


/* List of active customers who rented atleast once */
SELECT DISTINCT 
  r.customer_id AS customer_id,
  c.first_name,
  c.last_name
FROM rental r
  JOIN customer c ON r.customer_id = c.customer_id
ORDER BY r.customer_id;


/* List of customers who never rented a film */
SELECT 
  c.customer_id
FROM customer c
  LEFT JOIN rental r ON c.customer_id = r.customer_id
WHERE r.customer_id IS NULL
LIMIT 5;


/* Customers renting from multiple stores */
SELECT 
  c.customer_id,
  c.first_name,
  c.last_name
FROM customer c
  INNER JOIN rental r ON c.customer_id = r.customer_id
  INNER JOIN staff s ON r.staff_id = s.staff_id
WHERE s.store_id IN (1, 2)
GROUP BY 1,2,3
HAVING COUNT(DISTINCT s.store_id) = 2;



-- Film language distribution
SELECT 
  f.title AS film_name,
  l.name AS language
FROM film f
  JOIN language l ON f.language_id = l.language_id;



/* No. of films in each language */
SELECT 
  l.name AS film_language,
  COUNT(*) AS no_of_films
FROM language l
  INNER JOIN film f ON l.language_id = f.language_id
GROUP BY 1
ORDER BY no_of_films DESC;



/* List of films which are not in inventory */
SELECT 
  f.film_id,
  f.title
FROM film f
  LEFT JOIN inventory i ON f.film_id = i.film_id
WHERE i.inventory_id IS NULL;


/* Films by rating (PG-13/NC-17/R/PG/G)*/
SELECT 
  f.rating AS film_rating,
  COUNT(*) AS film_count
FROM film f
GROUP BY f.rating
ORDER BY film_count DESC;


/* No.of films in each category. Ordered by category having most no of films */
SELECT 
  c.name AS category_name,
  COUNT(*) AS film_count
FROM category c
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY film_count DESC;

/* Categories with less than 5 films in them */
SELECT 
  c.name AS category_name,
  COUNT(*) AS no_of_films
FROM category c
  INNER JOIN film_category fc ON c.category_id = fc.category_id
GROUP BY c.name
HAVING COUNT(*) < 5;


/* Rental counts by customer */
SELECT 
  r.customer_id,
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
SELECT 
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  COUNT(r.rental_id) AS total_rentals
FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id,
  customer_name
ORDER BY total_rentals DESC
LIMIT 5;


/* How many times each film is rented out/ Top renting films */
SELECT 
  i.film_id,
  f.title,
  COUNT(*) AS rental_count
FROM inventory i
  JOIN rental r ON i.inventory_id = r.inventory_id
  INNER JOIN film f ON i.film_id = f.film_id
GROUP BY i.film_id, f.title
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


-- Top spending customers
SELECT c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  SUM(p.amount) AS total_spend
FROM customer c
  JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id,
  customer_name
ORDER BY total_spend DESC
LIMIT 5;



/* Total amount spent by a customer across all transactions (Life time value -LTV) */
SELECT 
  DISTINCT p.customer_id,
  SUM(p.amount) AS lifetime_value
FROM payment p
GROUP BY p.customer_id
ORDER BY lifetime_value DESC;



/* Average revenue per customer */
-- Subquery Version
SELECT 
  CONCAT(ROUND(AVG(total_revenue), 2), '$') AS avg_revenue_per_customer --Main query to calculate avg revenue per customer
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
-- CTE to calculate the total amount spent by each customer.
WITH customer_spending AS (
  SELECT 
    customer_id,
    SUM(amount) AS total_spent
  FROM payment
  GROUP BY customer_id
)
-- Select customers whose total spending is greater than the overall average.
SELECT 
  customer_id,
  total_spent
FROM customer_spending
WHERE total_spent > (
    -- Subquery to calculate the average spending across all customers from the CTE.
    SELECT AVG(total_spent)
    FROM customer_spending
  )
ORDER BY total_spent;


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
SELECT 
  CONCAT(SUM(p.amount), '$') AS total_revenue
FROM payment p;

/* Yearly revenue generated by all stores acorss all geographies */
SELECT 
  EXTRACT(YEAR FROM p.payment_date) AS year,
  CONCAT(SUM(p.amount), '$') AS revenue
FROM payment p
GROUP BY year
ORDER BY year;
/* Total Revenue calculation by Year, Month and total revenue generated */
SELECT 
    TO_CHAR(DATE_TRUNC('Year', p.payment_date), 'YYYY') AS Year,
    TO_CHAR(DATE_TRUNC('Month', p.payment_date), 'MM') AS Month,
    SUM(p.amount)
FROM payment p
GROUP BY 1,2
ORDER BY Year,
    Month;



/* Store information */
SELECT s.store_id,
  c.city,
  co.country
FROM store s
  JOIN address a ON s.address_id = a.address_id
  JOIN city c ON a.city_id = c.city_id
  JOIN country co ON c.country_id = co.country_id;



/* Rental trends by location (City, Country), Year and Month */
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


/* Top revenue generating cities */
SELECT
  co.country,
  c.city,
  EXTRACT(YEAR FROM p.payment_date) AS year,
  SUM(p.amount) AS total_revenue
FROM city c
  JOIN address a ON c.city_id = a.city_id
  JOIN customer ct ON a.address_id = ct.address_id
  JOIN payment p ON ct.customer_id = p.customer_id
  INNER JOIN country co ON c.country_id = co.country_id
GROUP BY c.city,year, co.country
ORDER BY total_revenue DESC
LIMIT 10;
--Limiting by top 10 cities


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
/* Main query to calculate rentals in each movie category, revenue generated by them and average revenue per rental in that category, Ordered by Avg revenue */
SELECT 
  c.name,
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
--Key Business Insights Derived
--Sports generates highest revenue despite being in 3rd Position by avg_revenue
-- Comedy Category Commands the highest premium.
-- Family and Classics have below avg revenue.
--Sports + Comedy + Sci-Fi deliver 28% of total revenue


/* No.of.films rented out by each staff member/Metric to evaluate performance */
SELECT 
  r.staff_id,
  s.email,
  COUNT(*) AS rental_count
FROM rental r
  JOIN staff s ON r.staff_id = s.staff_id --Joing Staff table to retrive identifiable staff data
GROUP BY r.staff_id,
  s.email
ORDER BY rental_count DESC;


/* Query to extract customers who return the rented films late using the date operations */
SELECT 
  r.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.email,
  COUNT(*) AS late_returns
FROM rental r
  JOIN inventory i ON r.inventory_id = i.inventory_id
  JOIN film f ON i.film_id = f.film_id
  JOIN customer c ON r.customer_id = c.customer_id
WHERE r.return_date IS NOT NULL --Handling null values
  AND (r.return_date::date - r.rental_date::date) > f.rental_duration --Converting renturn date, rental date into date and comparing that with rental duration to filter late returns
GROUP BY 1,2,3
ORDER BY late_returns DESC
LIMIT 10;


/* Unreturned films*/
SELECT 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name, --Concating firstname and lastname into customername
  c.email,
  r.rental_date,
  r.return_date,
  EXTRACT(DAYS FROM (CURRENT_DATE - r.rental_date)) AS days_rented --No.of days since film was rented out
FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
WHERE r.return_date IS NULL;
--Filtering customers whose returned date is Null - Unreturned films.




/* Monthly rental patterns */
SELECT 
  TO_CHAR(rental_date, 'MM') AS month,
  EXTRACT(YEAR FROM rental_date) AS year,
  COUNT(r.rental_id) AS rental_count
FROM rental r
GROUP BY 1,2
ORDER BY rental_count DESC;


/* Category popularity by year/month */
--Main query to calculate no.of.rentals in each category, month and year wise.
WITH pop_cat_rank AS (
SELECT
  TO_CHAR(r.rental_date, 'YYYY') AS year,
  TO_CHAR(r.rental_date, 'MM') AS month,
  c.name AS category,
  COUNT(*) AS rental_count,
  DENSE_RANK() OVER (PARTITION BY TO_CHAR(r.rental_date, 'YYYY'), TO_CHAR(r.rental_date, 'MM') ORDER BY COUNT(*) DESC) as ranked_metric
FROM category c
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN inventory i ON fc.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
ORDER BY Year, month
)
SELECT * FROM pop_cat_rank pcr
WHERE pcr.ranked_metric =1;



/* Categorize Films by Rental Performance
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


-- Premium film rentals
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
-- CTE to calculate revenue metrics for each film including total revenue, 
-- average revenue per rental and inventory count
WITH film_metrics AS (
  SELECT f.film_id,
    f.title,
    SUM(p.amount) AS total_revenue_per_film, -- Total revenue generated by each film
    SUM(p.amount) / COUNT(r.rental_id) AS avg_revenue_per_rental, -- Average revenue per rental for each film 
    COUNT(i.inventory_id) AS inventory_count -- Number of copies in inventory for each film
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY 1,2
),
-- CTE to calculate overall averages across all films
avg_metrics AS (
  SELECT AVG(avg_revenue_per_rental) AS rental_average_revenue, -- Average revenue per rental across all films
    AVG(inventory_count) AS avg_inventory_count -- Average inventory count across all films
  FROM film_metrics
)
-- Main query to identify films with high revenue but limited availability
SELECT fm.film_id,
  fm.title,
  fm.total_revenue_per_film,
  fm.avg_revenue_per_rental,
  fm.inventory_count,
  a.rental_average_revenue,
  a.avg_inventory_count
FROM film_metrics fm
  CROSS JOIN avg_metrics a -- Cross join to compare each film against overall averages
WHERE fm.total_revenue_per_film > a.rental_average_revenue -- Filter for films with above average revenue
  AND inventory_count < a.avg_inventory_count -- Filter for films with below average inventory
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
          FROM payment
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
  FROM film f --Replace with * for detailed idea
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
total spend is below the average total spend across all customers. */s
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




/* Weekend Rental Lovers
Find the top 10 customers who rented the most movies on weekends (Saturday and Sunday).*/
--CTE to find top 10 customers who rented most on weekends, corresponding metric (count)
WITH wknd_rental AS 
(
  SELECT
r.customer_id, c.first_name, COUNT(*) AS wk_rental_count
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
WHERE EXTRACT(DOW FROM rental_date) IN (0,6) --DOW: Extracting day of week from date 0-6
GROUP BY 1,2
ORDER BY count(*) DESC
LIMIT 10
),
--CTE to find total_rentals by the above filtered customers (Top 10 weekend renters) to calculate weekend rental%
rentals_by_customer_id AS
(
  SELECT r2.customer_id, count(*) AS total_rentals
  FROM rental r2
  INNER JOIN wknd_rental ON r2.customer_id = wknd_rental.customer_id --INNER JOIN CTE wknd_rentals
  GROUP BY r2.customer_id
)
--Main query to display customer_id, weekend_rentals, total_rentals, percentage of weekend rentals out of total rentals
SELECT wknd_rental.customer_id,
wknd_rental.first_name,
wknd_rental.wk_rental_count, --bigint
rbci.total_rentals, --bigint
ROUND((wknd_rental.wk_rental_count::numeric/rbci.total_rentals::numeric)*100,2) AS percentgae_of_rentals_on_weekends
--Percetage calculation/dt conversion into numeric for percentage calculation
FROM wknd_rental
INNER JOIN rentals_by_customer_id rbci ON wknd_rental.customer_id = rbci.customer_id;


/* Find the top 5 films that: Have been rented at least 10 times in total. Have the highest average rental duration (in days).
Show the film title, total number of rentals, and the average rental duration (rounded to 2 decimal places).
Also display the category of each film.*/
--Main Query
SELECT f.film_id,
    f.title,
    c.name,
    COUNT(*) AS no_of_times_rented,
    EXTRACT(
        DAY
        FROM AVG(r.return_date - r.rental_date)
    ) AS avg_rental_duration
FROM film f
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
HAVING count(*) >= 10
ORDER BY AVG(r.return_date - r.rental_date) DESC
LIMIT 5;



/* Find the top 5 customers who:
Have spent the most total rental fees (based on payment.amount).
Also have rented films from at least 5 different categories.
Display for each customer: customer_id,first_name & last_name,total_spent, number_of_categories_rented
Order the result by total_spent (highest first). */
--Main Query to retrive customer details, total spend, no.of unique categories they rented from
SELECT c.customer_id,
    c.first_name, 
    c.last_name,
    count(DISTINCT ct.name) AS number_of_categories_rented,
    SUM(p.amount) AS total_spent
FROM customer c
    INNER JOIN rental r ON c.customer_id = r.customer_id
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film_category fc ON i.film_id = fc.film_id
    INNER JOIN category ct ON fc.category_id = ct.category_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1,2,3
HAVING COUNT(DISTINCT ct.name) >= 5
ORDER BY SUM(p.amount) DESC
LIMIT 5;


--By Applying CTE
--CTE to calculate no.of.times each customer rented from categories
WITH customer_data AS (
  SELECT c.customer_id,
    c.first_name,c.last_name,
    count(DISTINCT ct.name) AS number_of_categories_rented
FROM customer c
    INNER JOIN rental r ON c.customer_id = r.customer_id
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film_category fc ON i.film_id = fc.film_id
    INNER JOIN category ct ON fc.category_id = ct.category_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1,2,3
HAVING count(DISTINCT ct.NAME) >=5
),
spend_criteria AS (
  SELECT c.customer_id, SUM(p.amount) AS total_spent
  FROM customer c
  INNER JOIN rental r ON c.customer_id = r.customer_id --Incase customer has 2 rentals and 1 payment (x Joined using c.customer_id).
  INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY 1
)
SELECT cs.first_name, cs.last_name, cs.number_of_categories_rented, sc.total_spent
FROM customer_data cs
INNER JOIN spend_criteria sc ON cs.customer_id = sc.customer_id
ORDER BY sc.total_spent DESC
LIMIT 5;


/*Task:
Find the top 5 actors who:
Have acted in films from at least 7 different categories.
Have an average rental rate (across all their films) above the overall average rental rate of all films in the database.
Output columns: actor_id, first_name, last_name, num_categories (distinct film categories), avg_rental_rate*/

--CTE to filter actors who have acted in atleast 7 different categories
WITH actor_filter AS (
    SELECT a.actor_id,
        a.first_name,
        a.last_name,
        count(DISTINCT c.name) AS num_categories
    FROM actor a
        INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
        INNER JOIN film_category fc ON fa.film_id = fc.film_id
        INNER JOIN category c ON fc.category_id = c.category_id
    GROUP BY 1,2,3
    HAVING COUNT(DISTINCT c.name) >= 7
),
rental_rate_cte AS (
    SELECT a.actor_id,
        AVG(f.rental_rate) AS actor_avg_rental_rate
    FROM actor a
        INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
        INNER JOIN film f ON fa.film_id = f.film_id
    GROUP BY 1
    HAVING AVG(f.rental_rate) > (
            SELECT AVG(f2.rental_rate)
            FROM film f2
        )
)
SELECT af.actor_id,
    af.first_name,
    af.last_name,
    af.num_categories,
    ROUND(rrc.actor_avg_rental_rate,2)
FROM actor_filter af
    INNER JOIN rental_rate_cte rrc ON af.actor_id = rrc.actor_id
ORDER BY rrc.actor_avg_rental_rate DESC
LIMIT 5;



/*Find the top 10 customers who meet both of these conditions:
They have rented at least 20 films in total.
Their total amount spent (from the payment table) is above the overall average spending of all customers.
For each such customer, display: customer_id, first_name, last_name, total_rentals, total_spent, avg_spent_per_rental (rounded to 2 decimals)
Order the results by total_spent descending.*/

SELECT c.customer_id, 
c.first_name, 
c.last_name, 
COUNT(r.rental_id), 
SUM(p.amount) AS total_spent,
ROUND(SUM(p.amount)/COUNT(r.rental_id),2) AS avg_spent_per_rental
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1,2,3
HAVING COUNT(r.rental_id) >= 20 AND 
SUM(p.amount) > (SELECT AVG(total) 
                FROM (SELECT p2.customer_id, SUM(p2.amount) AS total 
                FROM payment p2 
                GROUP BY p2.customer_id) 
                t )
ORDER BY total_spent DESC
LIMIT 10;


/*Find the customers who spent the most on rentals from only “Action” and “Comedy” categories.
Requirements:
Show customer_id, first_name, last_name, category_name, and total_spent.
Only include customers whose total spending in that category is above the average spending in that category (across all customers).
Order by category_name and then total_spent DESC.
Limit to the top 10 results overall.*/

--CTE to find customers who rented from action or comedy or both along with their total spent in each cat
WITH customer_info AS (
SELECT c.customer_id, c.first_name, c.last_name, ct.name, SUM(p.amount) AS total_spent FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc ON i.film_id = fc.film_id
INNER JOIN category ct ON fc.category_id = ct.category_id
INNER JOIN payment p on r.rental_id = p.rental_id
WHERE ct.name IN ('Comedy','Action')
GROUP BY 1,2,3,4
ORDER BY c.customer_id
),
cat_avg AS (
  SELECT ci.name, AVG(ci.total_spent) AS avg_category
  FROM customer_info ci
  GROUP BY 1
)
SELECT ci.customer_id, ci.first_name, ci.last_name, ci.name, ci.total_spent
FROM customer_info ci
INNER JOIN cat_avg ca ON ci.name = ca.name
WHERE ci.total_spent > ca.avg_category
ORDER BY ci.name, ci.total_spent DESC
LIMIT 10;


/*Find the top 10 cities where customers have spent the highest total amount on rentals.
For each city, also show: Total number of rentals made, Total amount spent, Average spend per rental 
Only include cities where at least 20 rentals were made.
Compare each city’s total spend against the overall average city spend.
Compare each city’s total spend against the overall average city spend (and only keep those above average)*/
SELECT c.city, 
  a.city_id, 
  SUM(p.amount) AS city_total, 
  COUNT(r.rental_id) AS total_rentals, 
  ROUND(SUM(p.amount)/COUNT(r.rental_id),2) AS avg_spent_per_rental
  FROM city c
INNER JOIN address a ON c.city_id = a.city_id
INNER JOIN customer cus ON a.address_id = cus.address_id
INNER JOIN rental r ON cus.customer_id = r.customer_id
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1,2
HAVING COUNT(r.rental_id) > 20 AND
  SUM(p.amount) > (SELECT AVG(city_sum) AS city_average FROM 
                    (SELECT SUM(p2.amount) AS city_sum 
                    FROM city c2
                    INNER JOIN address a2 ON c2.city_id = a2.city_id
                    INNER JOIN customer cus2 ON a2.address_id = cus2.address_id
                    INNER JOIN rental r2 ON cus2.customer_id = r2.customer_id
                    INNER JOIN payment p2 ON r2.rental_id = p2.rental_id
                    GROUP BY c2.city_id
  ) t
)
ORDER BY city_total DESC
LIMIT 10;

--CTE Version
--CTE to calculate city_wise data
WITH city_wise_rental AS (
SELECT c.city, 
  a.city_id, 
  SUM(p.amount) AS city_total, 
  COUNT(r.rental_id) AS total_rentals, 
  ROUND(SUM(p.amount)/COUNT(r.rental_id),2) AS avg_spent_per_rental
  FROM city c
INNER JOIN address a ON c.city_id = a.city_id
INNER JOIN customer cus ON a.address_id = cus.address_id
INNER JOIN rental r ON cus.customer_id = r.customer_id
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1,2
),
--CTE to calculate city average by implementing sub-query
avg_income_per_city AS (
SELECT AVG(city_avg) AS city_average FROM 
                    (SELECT SUM(p2.amount) AS city_avg
                    FROM city c2
                    INNER JOIN address a2 ON c2.city_id = a2.city_id
                    INNER JOIN customer cus2 ON a2.address_id = cus2.address_id
                    INNER JOIN rental r2 ON cus2.customer_id = r2.customer_id
                    INNER JOIN payment p2 ON r2.rental_id = p2.rental_id
                    GROUP BY c2.city_id
                    )t
)
--Main query to display cities whose total rentals are greater than 20 
--And city total revenue is greater than average city revenue using cross join

SELECT cwr.city, cwr.city_id, cwr.city_total, cwr.total_rentals, cwr.avg_spent_per_rental
FROM city_wise_rental cwr
CROSS JOIN avg_income_per_city aipc
WHERE cwr.total_rentals > 20 AND cwr.city_total > aipc.city_average
ORDER BY cwr.city_total DESC
LIMIT 10;                                        



/* Find the top 5 customers (by total spend) in each film category.
For each category, show:
Category name, Customer name (first and last)
Total amount they’ve spent on rentals in that category
Number of rentals they made in that category
Only include customers who have rented more than 3 films in that category.
Order the results by category name, then total spent (descending). */

--CTE to Dsiplay each customer total_spend in each category
WITH total_cat_spend AS (
  Select c.first_name, 
  c.last_name, 
  cat.name, 
  SUM(p.amount) AS total_spent,
  COUNT(r.rental_id) AS no_of_rentals
  FROM customer c
  INNER JOIN rental r ON c.customer_id = r.customer_id
  INNER JOIN payment p ON r.rental_id = p.rental_id
  INNER JOIN inventory i ON r.inventory_id = i.inventory_id
  INNER JOIN film_category fc ON i.film_id = fc.film_id
  INNER JOIN category cat ON fc.category_id = cat.category_id
  GROUP BY 1,2,3
  HAVING COUNT(r.rental_id) > 3 --Filtering customers who rented less than/Equals to 3 films.
),
--CTE to rank customers using window function. Partionioning by category and ranking by total_spend in descending order.
ranked_customers AS (
SELECT tcs.first_name, 
tcs.last_name, 
tcs.name, 
tcs.total_spent, 
tcs.no_of_rentals,
RANK() OVER (PARTITION BY tcs.name ORDER BY tcs.total_spent DESC) AS spend_rank
FROM total_cat_spend tcs
)
--Main query to display top 5 customers in each category.
SELECT rc.first_name, 
rc.last_name, 
rc.name, 
rc.total_spent, 
rc.no_of_rentals,
rc.spend_rank
FROM ranked_customers rc
WHERE spend_rank <= 5
ORDER BY rc.name, rc.total_spent DESC;

/*Find the top 3 most-rented films in each category.
For each film, show: Category name,Film title, Number of times it was rented, Its rank within the category */
WITH films_data AS (
SELECT f.film_id, 
f.title, c.name, 
COUNT(f.film_id) AS times_rented, 
SUM(f.rental_rate), 
f.release_year,
ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY COUNT(f.film_id) DESC, SUM(f.rental_rate) DESC, f.title ASC) AS ranks
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY f.film_id, f.title, c.name, f.release_year
)
SELECT fd.film_id, 
fd.title, 
fd.name,
fd.times_rented,
fd.ranks FROM films_data fd
WHERE ranks <=3;


/*Find each customer’s favorite film category based on rental count.
For each customer, show: Customer ID, First Name, Last Name
The film category they rented most frequently
The total number of rentals in that category
Their rank of that category among all categories they’ve rented
If a customer has ties for their most rented category, include all tied categories.*/

--CTE to calculate rental counts per customer per category
WITH rental_data AS (
SELECT c.customer_id, 
c.first_name, 
c.last_name, 
cat.name, 
COUNT(r.rental_id) rental_count
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc ON i.film_id = fc.film_id
INNER JOIN category cat ON fc.category_id = cat.category_id
GROUP BY 1,2,3,4
),
--Rank cte
ranking_rentals AS (
SELECT rd.*, 
rank() OVER (PARTITION BY rd.customer_id ORDER BY rd.rental_count DESC) AS rank
FROM rental_data rd
)
SELECT * FROM ranking_rentals
WHERE rank <=3;



/*Find the top 2 cities in each country by number of rentals.
For each city, show: Country name, City name, Number of rentals in that city, Rank of the city within its country
If multiple cities tie for the same rank, they should all be included. */

--CTE to consolidate and rank city,country wise data based on rentals
WITH ranking_cities AS (
SELECT ci.city, 
co.country, 
COUNT(r.rental_id) AS total_rentals,
--Ranking by partioning by country and rentals in Desc
RANK() OVER (PARTITION BY co.country ORDER BY COUNT(r.rental_id) DESC) AS ranking,
--Calculating no.of.rentals of each country using partioning 
SUM(COUNT(r.rental_id)) OVER (PARTITION BY co.country) AS country_total_rentals
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id
GROUP BY 1,2
)
--Main query to filter top 2 cities in each country.
SELECT rc.city,
rc.country,
rc.total_rentals,
rc.ranking,
rc.country_total_rentals,
--city Percentage/share calculation
ROUND((rc.total_rentals::numeric/country_total_rentals)*100,2) AS city_share_
FROM ranking_cities rc
WHERE rc.ranking <=2;


/* Find the top 5 customers in each country by total rental amount.
For each customer, show: Country name, Customer ID and name
Total amount spent
Their rank within the country, 
Their percentage share of that country’s rental revenue */

-- CTE to retrieve customer details and rank them by amount spent within each country
WITH customer_ranks AS (
  SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ci.city,
    co.country,
    co.country_id,
    SUM(p.amount) AS total_spent,
    RANK() OVER (PARTITION BY co.country ORDER BY SUM(p.amount) DESC) AS rank_within_country
  FROM customer c
    INNER JOIN address a ON c.address_id = a.address_id
    INNER JOIN city ci ON a.city_id = ci.city_id
    INNER JOIN country co ON ci.country_id = co.country_id
    INNER JOIN rental r ON c.customer_id = r.customer_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY 1,2,3,4,5
),
-- CTE to calculate total rental revenue for each country
country_totals AS (
  SELECT 
    co2.country, 
    co2.country_id,
    SUM(p2.amount) AS country_total
  FROM country co2
    INNER JOIN city ci2 ON co2.country_id = ci2.country_id
    INNER JOIN address a2 ON ci2.city_id = a2.city_id
    INNER JOIN customer c2 ON a2.address_id = c2.address_id
    INNER JOIN rental r2 ON c2.customer_id = r2.customer_id
    INNER JOIN payment p2 ON r2.rental_id = p2.rental_id
  GROUP BY 1,2
)
-- Main query: Top 5 customers per country, their spend, rank, and percentage share of country revenue
SELECT 
  cr.customer_id,
  cr.customer_name,
  cr.city,
  cr.country,
  cr.total_spent,
  cr.rank_within_country,
  ct.country_total,
  ROUND((cr.total_spent / ct.country_total) * 100, 2) AS percentage_share
FROM customer_ranks cr
  INNER JOIN country_totals ct ON cr.country_id = ct.country_id
WHERE cr.rank_within_country <= 5;

--Method/Solution 2: 
-- =============================================
-- Top 5 Customers in Each Country by Total Rental Amount
-- For each customer: Country name, Customer ID, City, Total amount spent,
-- Their rank within the country, Their percentage share of that country’s rental revenue
-- =============================================

-- CTE to aggregate customer spend, country totals, rank, and share within each country
WITH customer_data AS (
  SELECT 
    c.customer_id, 
    ci.city, 
    co.country, 
    SUM(p.amount) AS total_spent, -- Total amount spent by the customer
    SUM(SUM(p.amount)) OVER (PARTITION BY co.country) AS country_sum, -- Total amount spent in the country
    RANK() OVER (PARTITION BY co.country ORDER BY SUM(p.amount) DESC) AS rank, -- Customer's rank within the country by total spent
    ROUND((SUM(p.amount) / SUM(SUM(p.amount)) OVER (PARTITION BY co.country)) * 100, 2) AS share -- Percentage share of country revenue
  FROM payment p
    INNER JOIN rental r ON p.rental_id = r.rental_id
    INNER JOIN customer c ON r.customer_id = c.customer_id
    INNER JOIN address a ON c.address_id = a.address_id
    INNER JOIN city ci ON a.city_id = ci.city_id
    INNER JOIN country co ON ci.country_id = co.country_id
  GROUP BY c.customer_id, ci.city, co.country
)
-- Main query: Filter top 5 customers per country and show their spend, rank, and share
SELECT 
  cd.customer_id, 
  cd.city, 
  cd.country, 
  cd.total_spent, 
  cd.country_sum, 
  cd.rank, 
  cd.share
FROM customer_data cd
WHERE cd.rank <= 5
ORDER BY cd.country, cd.rank;


/*Find films that are among the top 3 most-rented movies within their category.
For each such film, display: Category name, Film title, Number of rentals, Its rank within the category*/
SELECT * FROM
(
SELECT f.film_id,
f.title,
c.name,
COUNT(r.rental_id),
RANK() OVER (PARTITION BY c.name ORDER BY COUNT(r.rental_id) DESC) as rank
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
) AS ranked_films
WHERE rank <=3;

--CTE Version
WITH film_data AS (
  SELECT f.film_id,
f.title,
c.name,
COUNT(r.rental_id) AS total_rentals,
RANK() OVER (PARTITION BY c.name ORDER BY COUNT(r.rental_id) DESC) as rank
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
)
SELECT fd.film_id,
fd.title,
fd.name,
fd.total_rentals,
fd.rank
FROM film_data fd
WHERE rank<=3;


/*Find the top 5 months (across all years) with the highest rental activity.
For each of these months, show: Year and Month (e.g., 2021-05), Total number of rentals, Total revenue collected (from payment.amount)
The percentage share of revenue compared to the overall revenue.*/

-- CTE to calculate total rentals and revenue per month
WITH revenue_cal AS (
  SELECT
    DATE_TRUNC('Month', r.rental_date) AS rental_month, -- Truncate rental_date to month
    COUNT(r.rental_id) AS no_of_rentals,                -- Number of rentals in the month
    SUM(p.amount) AS total_revenue                      -- Total revenue in the month
  FROM rental r
    INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY 1
),
-- CTE to calculate overall total revenue
total_rev_cal AS (
  SELECT SUM(p.amount) AS tot_rev
  FROM payment p
)
-- Main query: Top 5 months by revenue, with percentage of total revenue
SELECT 
  TO_CHAR(rc.rental_month, 'YYYY-MM') AS YEAR_Month,         -- Year-Month format
  TO_CHAR(rc.rental_month, 'MON-YYYY') AS Mon_Desc,          -- Month-Year description
  rc.no_of_rentals,                                          -- Number of rentals in the month
  rc.total_revenue,                                          -- Total revenue in the month
  ROUND((rc.total_revenue/rvc.tot_rev)*100,2) AS percentage  -- Percentage of total revenue
FROM revenue_cal rc
  CROSS JOIN total_rev_cal rvc
ORDER BY rc.total_revenue DESC
LIMIT 5;

--Window_function_version
WITH revenue_cal AS (
  SELECT DATE_TRUNC('Month', r.rental_date) AS year_month, --Truncate rental_date to month
  COUNT(r.rental_id) AS no_of_rentals,                     --Counting no.of.rentals in a given month
  SUM(p.amount) AS revenue,                                --Counting revenue in each given month
  SUM(SUM(p.amount)) OVER() AS total_revenue               --Counting total global revenue generated till date (May not work in all db's)
  FROM rental r
  INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY 1
)
SELECT 
TO_CHAR(rc.year_month, 'YYYY-MM') AS ym,          --Year Month format
TO_CHAR(rc.year_month, 'MON-YYYY') my_des,        --Month Year format description
ROUND((rc.revenue/rc.total_revenue)*100,2) AS percentage,  --Percentage/Share in total revenue
rc.no_of_rentals, rc.revenue, rc.total_revenue
FROM revenue_cal rc
ORDER BY rc.revenue DESC
LIMIT 5;


/* Find the cumulative monthly revenue growth over time.
For each month, show: Year-Month, Number of rentals, Monthly revenue
Cumulative revenue up to that month
Percentage growth compared to the previous month */
-- CTE to calculate monthly revenue and rental counts
WITH revenue AS (
  SELECT 
    TO_CHAR(DATE_TRUNC('MONTH', r.rental_date), 'YYYY-MM') AS Month_Year, -- Format rental_date as Year-Month
    SUM(p.amount) AS revenue,                                             -- Total revenue for the month
    COUNT(r.rental_id) AS rentals                                         -- Number of rentals for the month
  FROM rental r
    INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY 1
)
SELECT 
  r.Month_Year, 
  r.revenue,
  LAG(r.revenue) OVER (ORDER BY r.Month_Year) AS lag, -- Previous month's revenue
  r.revenue - LAG(r.revenue) OVER (ORDER BY r.Month_Year) AS diff_in_rev, -- Revenue difference from previous month
  SUM(r.revenue) OVER (ORDER BY r.Month_Year) AS cumm_rev, -- Cumulative revenue up to this month
  ROUND(
    (r.revenue - LAG(r.revenue) OVER(ORDER BY r.Month_Year)) 
    / NULLIF(LAG(r.revenue) OVER(ORDER BY r.Month_Year), 0) * 100, 2
  ) AS percentage_change, -- Percentage growth compared to previous month
  r.rentals -- Number of rentals in the month
FROM revenue r;



/* Find the top 3 highest revenue-generating days in each month.
For each month, show: Year-Month, Day (date), Daily revenue, Rank of the day within that month by revenue */
SELECT * FROM (
SELECT TO_CHAR(DATE_TRUNC('DAY', r.rental_date), 'YYYY-MM-DD') AS date_of_month,
TO_CHAR(DATE_TRUNC('MONTH', r.rental_date), 'YYYY-MM') AS mon_year,
SUM(p.amount) AS total_rev_by_date,
RANK() OVER (PARTITION BY TO_CHAR(DATE_TRUNC('MONTH', r.rental_date), 'YYYY-MM') ORDER BY sum(p.amount) DESC) AS rank_within_month
FROM rental r
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY date_of_month, mon_year
) r
WHERE rank_within_month <=3;



/*Find the 3 months where revenue grew the fastest compared to the previous month.
For each month, you need: Total revenue in that month, Cumulative revenue (running total up to that month).
Growth % compared to the previous month.
Then pick only the top 3 growth months. */

--CTE to find monthly total_revenue
WITH mon_rev AS (
SELECT DATE_TRUNC('Month', r.rental_date) AS datemonth, --Truncates Date upto monthlevel for aggregation task
SUM(p.amount) AS total_revenue                          -- Calculate total revenue generated and aggregated with date
FROM rental r
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1
ORDER BY datemonth
),
--CTE to calculate cummulative revenue, lag for percentage change in revenue calculations
cumm_rev AS (
  SELECT m.datemonth AS datemonth2,
  LAG(total_revenue) OVER (ORDER BY m.datemonth) AS pmr,        --LAG() window function for calculating percentage change in revenue
  SUM(total_revenue) OVER (ORDER BY m.datemonth) AS cummu_rev   --Cummulative revenue month-over-month
  FROM mon_rev m
)
SELECT
  m.datemonth, 
  m.total_revenue, 
  cr.pmr, 
  cr.cummu_rev,
CASE                                                   --CASE statement to handle null values.
  WHEN cr.pmr IS NULL THEN 0
ELSE
  ROUND((m.total_revenue - cr.pmr)/cr.pmr*100,2)     --Change in percentage calculation. total_revenue - previous_month_revenue/previous_month revenue
END AS percentage_change

FROM mon_rev m
INNER JOIN cumm_rev cr ON m.datemonth = cr.datemonth2
ORDER BY percentage_change DESC
LIMIT 3;



/* A “churn risk” customer is one who hasn’t rented in the last 60 days but had rented at least 5 films before that.*
For each such customer, show: Customer ID & Name, Last rental date, Total amount spent
Total rentals before their last rental */
--CTE to calculate last rental date
WITH last_rental_date AS (
SELECT c.customer_id, CONCAT(c.first_name,'', c.last_name) AS full_name, MAX(r.rental_date) AS last_rental_date
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY 1,2
),
--CTE to filter inactive customers
inactive_customers AS (
  SELECT lrd.customer_id,
  CURRENT_DATE -last_rental_date::date AS days_since_last_rented
  FROM last_rental_date lrd
  WHERE CURRENT_DATE -last_rental_date::date >60
),
--CTE to find customer_Activity
customer_activity AS (
SELECT 
    r.customer_id,
    COUNT(r.rental_id) AS total_rentals,
    SUM(p.amount) AS total_spent
  FROM rental r
  INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY r.customer_id
)
SELECT lrd.customer_id, lrd.full_name, lrd.last_rental_date, ca.total_rentals, ca.total_spent
FROM last_rental_date lrd
INNER JOIN inactive_customers ic ON lrd.customer_id = ic.customer_id
INNER JOIN customer_activity ca ON ic.customer_id = ca.customer_id
WHERE ca.total_rentals > 5;




/* Create a basic system that suggests films to customers based on their rental history and preferences.
[FOR Customer_id =1] 
Customer's Favorite Categories:find which film categories they rent most often
Top Films in Those Categories: Show the most popular films in the customer's favorite categories
Check which of these recommended films are actually in stock
Combine all this into a clean list of 10 film recommendations for customer_id = 1 */

-- CTE to find the top 3 most rented film categories for a specific customer (customer_id = 1)
WITH pop_cat AS (
  SELECT 
    c.customer_id, 
    cat.name, 
    cat.category_id, 
    COUNT(r.rental_id) AS rental_count
  FROM customer c
    INNER JOIN rental r ON c.customer_id = r.customer_id
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film_category fc ON i.film_id = fc.film_id
    INNER JOIN category cat ON fc.category_id = cat.category_id
  GROUP BY 1,2,3
  HAVING c.customer_id = 1 -- Filter for a specific customer
  ORDER BY COUNT(r.rental_id) DESC
  LIMIT 3 -- Limit to their top 3 favorite categories
),
-- CTE to find the most popular films (by rental count) within the customer's favorite categories
top_films_cat AS (
  SELECT 
    f.film_id, 
    f.title, 
    i2.inventory_id, 
    fc2.category_id, 
    COUNT(r2.rental_id) AS total_rentals
  FROM film f
    INNER JOIN inventory i2 ON f.film_id = i2.film_id
    INNER JOIN rental r2 ON i2.inventory_id = r2.inventory_id
    INNER JOIN film_category fc2 ON f.film_id = fc2.film_id
  WHERE fc2.category_id IN (SELECT pop_cat.category_id FROM pop_cat) -- Filter for films in the favorite categories
  GROUP BY 1,2,3,4
  ORDER BY total_rentals DESC
),
-- CTE to identify all inventory items that are currently in stock (not rented out)
available_inventory AS (
  SELECT 
    i3.film_id, 
    i3.inventory_id
  FROM inventory i3
  WHERE i3.inventory_id NOT IN (SELECT r3.inventory_id FROM rental r3 WHERE r3.return_date IS NULL) -- Exclude items currently rented
)
-- Main query: Recommend the top 10 available films from the customer's favorite categories
SELECT 
  tfc.film_id, 
  tfc.title, 
  COUNT(*) AS tot_av_inven -- Count how many copies are available in inventory
FROM top_films_cat tfc
  INNER JOIN available_inventory ai ON tfc.inventory_id = ai.inventory_id -- Join with available inventory
GROUP BY 1,2
ORDER BY tot_av_inven DESC -- Order by the number of available copies
LIMIT 10; -- Limit to the top 10 recommendations


/*Identify which film categories (like Action, Comedy, etc.) are growing the fastest month-over-month based on total rental revenue.*/
WITH cat_stats AS (
SELECT 
  cat.category_id, 
  cat.name,
  TO_CHAR(DATE_TRUNC('Month',r.rental_date),'YYYY-MM') AS month,
  SUM(p.amount) AS total_revenue
FROM category cat
INNER JOIN film_category fc ON cat.category_id = fc.category_id
INNER JOIN inventory i ON fc.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1,2,3
ORDER BY cat.category_id
),
pmr_cal AS (
SELECT 
  cs.category_id, 
  cs.name, 
  cs.month, 
  cs.total_revenue,

  LAG(cs.total_revenue) OVER (PARTITION BY cs.category_id ORDER BY cs.month) AS pmr
  FROM cat_stats cs
),
per_change_cal AS (
  SELECT 
    pmr_cal.category_id, 
    pmr_cal.name, 
    pmr_cal.month, 
    pmr_cal.total_revenue, 
    pmr_cal.pmr,
    CASE
      WHEN pmr_cal.pmr IS NULL
        THEN 0
      ELSE
        (pmr_cal.total_revenue - pmr_cal.pmr)/pmr_cal.pmr * 100
      END AS percentage_change
  FROM pmr_cal
),
ranking_months AS (
  Select
  pcl.category_id, 
  pcl.name, 
  pcl.month, 
  pcl.total_revenue, 
  pcl.pmr,
  ROUND(pcl.percentage_change,2) AS percentage_change,
  RANK() OVER (PARTITION BY pcl.month ORDER BY ROUND(pcl.percentage_change,2) DESC) AS ranking
FROM per_change_cal pcl
)
SELECT * FROM ranking_months rm
WHERE rm.percentage_change !=0 AND rm.ranking=1;


/* Task: Film Inventory & Availability Analysis
Business Question: "Help store managers understand which films are frequently out of stock and which categories need more inventory investment. */

/*Part-1: Count total films vs available films per store */
WITH total_inventory AS (
SELECT s.store_id, count(*) AS total_inventory
FROM store s
INNER JOIN inventory i ON
s.store_id = i.store_id
GROUP BY 1
),
rented_inventory AS (
  SELECT s.store_id, COUNT(*) AS rent_iv
    FROM store s
    INNER JOIN inventory i ON s.store_id = i.store_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    WHERE r.return_date IS NULL
    GROUP BY 1
),
available_inventory AS (
  SELECT ri.store_id, ti.total_inventory, ri.rent_iv,
  ti.total_inventory - ri.rent_iv AS av_inv
  FROM rented_inventory ri
  INNER JOIN total_inventory ti ON ti.store_id = ri.store_id
)
SELECT *,
ROUND(av.rent_iv::decimal/av.total_inventory::decimal*100,3) AS rented_percentage
 FROM available_inventory av;

 /* Part 2: Which specific films are hardest to keep in stock across our stores? 
Film titles and IDs
Store locations
Total copies per film per store
Currently rented copies
Availability percentage
Rank films by worst availability
  */

