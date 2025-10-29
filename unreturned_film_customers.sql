/* Unreturned films*/
SELECT 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name, --Concating firstname and lastname into customername
  c.email,
  r.rental_date,
  r.return_date,
  EXTRACT(DAYS FROM (CURRENT_DATE - r.rental_date)) AS days_rented --No.of days since film was rented out
FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
WHERE r.return_date IS NULL;
--Filtering customers whose returned date is Null - Unreturned films.