/* Customers from London */
SELECT 
  CONCAT(c.first_name,' ',c.last_name) AS customer_name,
  ci.city
FROM customer c
  JOIN address a ON c.address_id = a.address_id
  JOIN city ci ON a.city_id = ci.city_id
WHERE ci.city = 'London';
