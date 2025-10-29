/* Customers who rented the most (top 5) */
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
