/* Total amount spent by customer (Lifetime Value) */
SELECT 
  p.customer_id,
  SUM(p.amount) AS lifetime_value
FROM payment p
GROUP BY p.customer_id
ORDER BY lifetime_value DESC;
