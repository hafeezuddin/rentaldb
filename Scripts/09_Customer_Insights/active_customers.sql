/* Active customers who rented at least once */
SELECT DISTINCT 
  r.customer_id AS customer_id,
  c.first_name,
  c.last_name
FROM rental r
  JOIN customer c ON r.customer_id = c.customer_id
ORDER BY r.customer_id;
