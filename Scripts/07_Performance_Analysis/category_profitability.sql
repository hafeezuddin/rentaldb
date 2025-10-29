/* Finding categories which are more profitable */
SELECT 
  c.name,
  COUNT(r.rental_id) AS total_rentals,
  SUM(p.amount) AS total_revenue,
  ROUND(SUM(p.amount) / COUNT(r.rental_id), 2) AS avg_revenue_per_rental
FROM category c
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN inventory i ON fc.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
  JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY avg_revenue_per_rental DESC;
