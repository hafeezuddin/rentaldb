/* List tables in public information schema */
SELECT *
FROM information_schema.tables;

/* List of all columns in the table address */
SELECT column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'address'
    AND table_schema = 'public';

/* Select 5 records from a table */
SELECT *
FROM customer c
ORDER BY customer_id
LIMIT 5;

/* SELECT DISTINCT customers, films and rentals from db */
SELECT (SELECT COUNT(DISTINCT c.customer_id) FROM customer c) AS total_customers,
    (SELECT COUNT(DISTINCT f.film_id) FROM film f) AS total_films,
    (SELECT COUNT(DISTINCT r.rental_date) FROM rental r) AS total_rentals;


/* List all distinct names from the category table */
SELECT DISTINCT name
FROM category;


/*Retrieve Full name from customer table*/
SELECT CONCAT(first_name,' ',last_name) AS full_name FROM customer;


/* List customers who have rented films atleast once */
SELECT DISTINCT r.customer_id, c.first_name, c.last_name
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
ORDER BY customer_id;


/* No of times each customer has rented */
SELECT r.customer_id,
    c.first_name,
    c.last_name,
    COUNT(r.customer_id) AS no_of_times_rented
FROM rental r
    INNER JOIN customer c ON r.customer_id = c.customer_id
GROUP BY r.customer_id,
    c.first_name,
    c.last_name
ORDER BY no_of_times_rented DESC;



/* No of times a film is rented */
SELECT i.film_id, COUNT(i.film_id) AS no_of_times_rented
FROM inventory i
    INNER JOIN rental r
        ON i.inventory_id = r.inventory_id
GROUP BY i.film_id
ORDER BY no_of_times_rented DESC;


/* Rentals per movie category */
SELECT c.category_id,
    c.name,
    COUNT(r.rental_id) AS rental_count
FROM category c
    INNER JOIN film_category fc ON c.category_id = fc.category_id
    INNER JOIN inventory i ON fc.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c.category_id,
    c.name
ORDER BY rental_count DESC;


/* Busiest Months using rental table */
SELECT EXTRACT(
        MONTH
        from rental_date
    ) AS Month,
    CASE
        WHEN EXTRACT(Month FROM rental_date) = 1 THEN 'JAN'
        WHEN EXTRACT(Month FROM rental_date) = 2 THEN 'FEB'
        WHEN EXTRACT(Month FROM rental_date) = 3 THEN 'MAR'
        WHEN EXTRACT(Month FROM rental_date) = 4 THEN 'APR'
        WHEN EXTRACT(Month FROM rental_date) = 5 THEN 'MAY'
        WHEN EXTRACT(Month FROM rental_date) = 6 THEN 'JUN'
        WHEN EXTRACT(Month FROM rental_date) = 7 THEN 'JUL'
        WHEN EXTRACT(Month FROM rental_date) = 8 THEN 'AUG'
        WHEN EXTRACT(Month FROM rental_date) = 9 THEN 'SEP'
        WHEN EXTRACT(Month FROM rental_date) = 10 THEN 'OCT'
        WHEN EXTRACT(Month FROM rental_date) = 11 THEN 'NOV'
        WHEN EXTRACT(Month FROM rental_date) = 12 THEN 'DEC'
        ELSE NULL
        END AS Month_desc,
    COUNT(*)
FROM rental
GROUP BY Month
ORDER BY Month DESC;


/* Busiest Months with Year */
SELECT EXTRACT(
        YEAR
        FROM rental_date
    ) AS YEAR,
    EXTRACT(
        MONTH
        FROM rental_date
    ) AS MONTH,
    CASE
        WHEN EXTRACT(Month FROM rental_date) = 1 THEN 'JAN'
        WHEN EXTRACT(Month FROM rental_date) = 2 THEN 'FEB'
        WHEN EXTRACT(Month FROM rental_date) = 3 THEN 'MAR'
        WHEN EXTRACT(Month FROM rental_date) = 4 THEN 'APR'
        WHEN EXTRACT(Month FROM rental_date) = 5 THEN 'MAY'
        WHEN EXTRACT(Month FROM rental_date) = 6 THEN 'JUN'
        WHEN EXTRACT(Month FROM rental_date) = 7 THEN 'JUL'
        WHEN EXTRACT(Month FROM rental_date) = 8 THEN 'AUG'
        WHEN EXTRACT(Month FROM rental_date) = 9 THEN 'SEP'
        WHEN EXTRACT(Month FROM rental_date) = 10 THEN 'OCT'
        WHEN EXTRACT(Month FROM rental_date) = 11 THEN 'NOV'
        WHEN EXTRACT(Month FROM rental_date) = 12 THEN 'DEC'
        ELSE NULL
        END AS Month_desc,
    COUNT(rental_id) AS no_of_rentals
FROM rental
GROUP BY 1,
    2
ORDER BY no_of_rentals DESC;


/* Total Revenue from Rentals */
SELECT SUM(p.amount) AS total_revenue
FROM payment p;


/* Total revenue year wise */
SELECT EXTRACT(YEAR FROM p.payment_date), 
SUM(p.amount)
FROM payment p
GROUP BY 1;


/* Total revenue segregated by year and month */
SELECT EXTRACT(YEAR from p.payment_date) AS year,
    EXTRACT(MONTH FROM p.payment_date) AS month,
    CASE
        WHEN EXTRACT(Month FROM payment_date) = 1 THEN 'JAN'
        WHEN EXTRACT(Month FROM payment_date) = 2 THEN 'FEB'
        WHEN EXTRACT(Month FROM payment_date) = 3 THEN 'MAR'
        WHEN EXTRACT(Month FROM payment_date) = 4 THEN 'APR'
        WHEN EXTRACT(Month FROM payment_date) = 5 THEN 'MAY'
        WHEN EXTRACT(Month FROM payment_date) = 6 THEN 'JUN'
        WHEN EXTRACT(Month FROM payment_date) = 7 THEN 'JUL'
        WHEN EXTRACT(Month FROM payment_date) = 8 THEN 'AUG'
        WHEN EXTRACT(Month FROM payment_date) = 9 THEN 'SEP'
        WHEN EXTRACT(Month FROM payment_date) = 10 THEN 'OCT'
        WHEN EXTRACT(Month FROM payment_date) = 11 THEN 'NOV'
        WHEN EXTRACT(Month FROM payment_date) = 12 THEN 'DEC'
        ELSE NULL
        END AS Month_desc,
    SUM(p.amount) AS revenue
FROM payment p
GROUP BY 1,2
ORDER BY 4 DESC;


/* Top 5 Customers who spent the most money */
SELECT c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name),
    SUM(p.amount) AS total_spend
FROM customer c
    INNER JOIN payment p ON c.customer_id = p.customer_id
GROUP BY 1,
    2
ORDER BY 3 DESC
LIMIT 5;


/* Top customers who rented the most */
SELECT c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name),
    COUNT(r.rental_id) total_rentals
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;


/* Customers who have never rented a movie from store */
SELECT c.customer_id
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
WHERE r.customer_id IS NULL
LIMIT 5;


/* Average rental duration per movie */
SELECT f.film_id, 
    f.title,
    AVG(r.return_date - r.rental_date) AS average_rental
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.return_date IS NOT NULL
GROUP BY f.film_id, f.title
ORDER BY 3 DESC;


/* Top salesperson */
SELECT r.staff_id, 
    s.email,
    COUNT(rental_id) no_of_rentals
FROM rental r
INNER JOIN staff s ON r.staff_id = s.staff_id
GROUP BY 1,2
ORDER BY 2 DESC;


/* Top 10 customers who return movies late the most */
SELECT r.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name),
    c.email,
    COUNT(*) AS no_of_late_returns
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN customer c ON r.customer_id = c.customer_id
WHERE (r.return_date::date - r.rental_date::date) > f.rental_duration
AND r.return_date IS NOT NULL
GROUP BY 1,2,3
ORDER BY 4 DESC
LIMIT 10;