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
