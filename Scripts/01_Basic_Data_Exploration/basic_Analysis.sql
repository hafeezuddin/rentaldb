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
ORDER BY c.customer_id
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
SELECT DISTINCT c.name AS available_categories
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


/* Customers renting premium films */
--CTE to filter films which are most expensive using sub-query
WITH premium_films AS (
  SELECT film_id
  FROM film
  WHERE rental_rate = (
      SELECT MAX(rental_rate)
      FROM film
    )
) --Main query to display customer details who rented those expensive films
SELECT DISTINCT 
  c.customer_id, 
  CONCAT(c.first_name,' ',c.last_name),
  c.email
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
) 
--Main query to find top rented films in each category
SELECT fr.film_id,
  fr.title,
  fr.category,
  fr.rental_count
FROM film_rentals fr
--Conditional Joining category_max CTE AND Film_Rental CTE & Filtering with condition to extract most rented films in each category
  JOIN category_max cm ON fr.category = cm.category
  AND fr.rental_count = cm.max_rentals 
ORDER BY fr.category;

--Approach without using conditional join in main query.
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
) 
--Main query to find top rented films in each category
SELECT fr.film_id,
  fr.title,
  fr.category,
  fr.rental_count
FROM film_rentals fr
--without conmditional Join -  category_max CTE AND Film_Rental CTE & Filtering with condition to extract most rented films in each category
  JOIN category_max cm ON fr.category = cm.category
WHERE fr.rental_count = cm.max_rentals
ORDER BY fr.category;


/* Find customers who rented the most expensive movie (CTE)*/
--CTE to extract expensive movie rate from film table.
WITH expensive_movie AS (
  SELECT MAX(f.rental_rate) AS max_rate
  FROM film f
) --Main Query to find customers and who rented those films (Can be multiple)
SELECT 
  c.customer_id, 
  COUNT(c.customer_id) AS no_of_high_value_rentals,
  CONCAT(c.first_name,' ',c.last_name),
  c.email
FROM customer c
  INNER JOIN rental r ON c.customer_id = r.customer_id
  INNER JOIN inventory i ON r.inventory_id = i.inventory_id
  INNER JOIN film f ON i.film_id = f.film_id
  --INNER JOIN CTE filters data by only keeping data that is equal to expensive movie rate
  INNER JOIN expensive_movie em ON f.rental_rate = em.max_rate 
GROUP BY 1
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
--Cross join implementation to compare avgrate with rental rate of film. Unlike inner and left joins on condition is not required for cross join.
  CROSS JOIN avg_price ap 
WHERE rental_rate > ap.avg_rate --Filtering films whose rental rate > avgerage rate
ORDER BY f.film_id;


/* Films that have a rental rate higher than the average rental rate (Premium Films) using subquery.*/
SELECT f.film_id,
  f.title,
  f.rental_rate,
  ROUND((SELECT AVG(f.rental_rate) AS avg_rate FROM film f),2) AS avg_rental_rate --Calculation of AVG rental rate.
FROM film f
WHERE f.rental_rate > (SELECT AVG(f.rental_rate) FROM film f) --Comparing and filtering film rental rate with Avg rental rate using subquery
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
  GROUP BY 1,2,3
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

--Using window function
WITH film_count AS (
SELECT f.film_id,
    c.name,
    f.title,
    COUNT(*) AS total_rents,
    DENSE_RANK() OVER (PARTITION BY c.name ORDER BY COUNT(*) DESC) AS ranking
  FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
  GROUP BY 1,2,3
)
SELECT fc.film_id, fc.name, fc.title, fc.total_rents,fc.ranking
FROM film_count fc
WHERE ranking =1;


/* Find the top 5 films that: 
i.  Have been rented at least 10 times in total. 
ii. Have the highest average rental duration (in days).
iii.Show the film title, total number of rentals, and the average rental duration (rounded to 2 decimal places).
iv. Also display the category of each film.*/
--Main Query
SELECT f.film_id,
    f.title,
    c.name,
    COUNT(*) AS no_of_times_rented,
    EXTRACT(DAY FROM AVG(r.return_date - r.rental_date)) AS avg_rental_duration
FROM film f
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
HAVING count(*) >= 10
ORDER BY AVG(r.return_date - r.rental_date) DESC
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