/* Films not in inventory */
SELECT 
  f.film_id,
  f.title
FROM film f
  LEFT JOIN inventory i ON f.film_id = i.film_id
WHERE i.inventory_id IS NULL;
