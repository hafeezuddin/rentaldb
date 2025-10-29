/* 002 - Customers spending more than average */
WITH customer_spending AS (
  SELECT 
    customer_id,
    SUM(amount) AS total_spent
  FROM payment
  GROUP BY customer_id
)
SELECT 
  customer_id,
  total_spent
FROM customer_spending
WHERE total_spent > (
    SELECT AVG(total_spent) FROM customer_spending
  )
ORDER BY total_spent;
