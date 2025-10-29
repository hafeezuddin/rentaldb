/* Customers who return rented films late */
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
GROUP BY 1,2,3
ORDER BY late_returns DESC
LIMIT 10;
