/* Top 10 customers with >=20 rentals and above-average spend */
SELECT c.customer_id, 
c.first_name, 
c.last_name, 
COUNT(r.rental_id) AS total_rentals, 
SUM(p.amount) AS total_spent,
ROUND(SUM(p.amount)/COUNT(r.rental_id),2) AS avg_spent_per_rental
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1,2,3
HAVING COUNT(r.rental_id) >= 20 AND 
SUM(p.amount) > (SELECT AVG(total) 
                FROM (SELECT p2.customer_id, SUM(p2.amount) AS total 
                FROM payment p2 
                GROUP BY p2.customer_id) 
                t )
ORDER BY total_spent DESC
LIMIT 10;
