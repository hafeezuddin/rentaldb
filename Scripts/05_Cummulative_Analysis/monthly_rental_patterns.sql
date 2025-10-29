/* Monthly rental patterns */
SELECT 
  TO_CHAR(rental_date, 'MM') AS month,
  EXTRACT(YEAR FROM rental_date) AS year,
  COUNT(r.rental_id) AS rental_count
FROM rental r
GROUP BY 1,2
ORDER BY rental_count DESC;
