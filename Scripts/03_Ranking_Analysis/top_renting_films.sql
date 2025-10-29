/* How many times each film is rented out / Top renting films */
SELECT 
  i.film_id,
  f.title,
  COUNT(*) AS rental_count
FROM inventory i
  JOIN rental r ON i.inventory_id = r.inventory_id
  INNER JOIN film f ON i.film_id = f.film_id
GROUP BY i.film_id, f.title
ORDER BY rental_count DESC;
