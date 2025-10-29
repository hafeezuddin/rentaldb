/* Top 5 films that meet rental-count and average duration criteria */
SELECT f.film_id,
    f.title,
    c.name,
    COUNT(*) AS no_of_times_rented,
    EXTRACT(DAY FROM AVG(r.return_date - r.rental_date)) AS avg_rental_duration
FROM film f
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
HAVING count(*) >= 10
ORDER BY AVG(r.return_date - r.rental_date) DESC
LIMIT 5;
