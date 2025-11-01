/* You're analyzing the DVD rental business to optimize inventory purchasing and identify underperforming films. 
Management wants to make data-driven decisions about which films to keep, restock, or remove from inventory.

Specific Requirements:
Calculate for each film:
    Total number of rentals
    Total revenue generated
    Average rental duration (days between rental and return)
    Number of copies in inventory
Utilization rate (% of time the film was rented vs. available)
    

Categorize films into performance tiers:
"Blockbuster": Top 15% by revenue AND rental count
"Underperforming": Bottom 25% by revenue AND replacement_cost > $20
"Efficient": Above average revenue per copy AND utilization rate > 60%
"Standard": All other films
Additional Requirements:

Only include films with at least 5 rentals
Exclude films with missing return dates
Include film category and replacement cost
Calculate ROI: (total_revenue / replacement_cost) * 100
*/

WITH film_metrics AS (
SELECT f.film_id AS fid, 
    f.title AS title,
    COUNT(r.rental_id) AS no_of_rentals,
    SUM(p.amount) AS total_revenue_generated,
    EXTRACT(DAY FROM AVG(r.return_date - r.rental_date)) AS avg_rental_duration
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN payment p ON r.rental_id = p.rental_id
WHERE r.return_date IS NOT NULL
GROUP BY 1,2
ORDER BY 1 ASC
),
available_inventory AS (
    SELECT f.film_id,
    COUNT(*)
    FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id AND r.return_date IS NULL
    WHERE r.rental_id IS NULL
    GROUP BY 1
)
SELECT * FROM available_inventory;
