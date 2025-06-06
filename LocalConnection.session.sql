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


/* List all distinct names from the category table */
SELECT DISTINCT name
FROM category;