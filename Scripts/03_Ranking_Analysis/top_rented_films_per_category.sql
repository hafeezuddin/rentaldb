/* Top rented films per category (using CTEs) */
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
category_max AS (
  SELECT category,
    MAX(rental_count) AS max_rentals
  FROM film_rentals
  GROUP BY category
)
SELECT fr.film_id,
  fr.title,
  fr.category,
  fr.rental_count
FROM film_rentals fr
  JOIN category_max cm ON fr.category = cm.category
  AND fr.rental_count = cm.max_rentals 
ORDER BY fr.category;
