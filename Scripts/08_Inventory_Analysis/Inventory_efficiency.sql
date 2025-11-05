/* Analyze film performance across rental metrics and inventory efficiency to identify optimization opportunities.

Specific Requirements:
For each film, calculate: Total rentals and total revenue generated
Average rental duration vs. actual rental period

Rental frequency (rentals per day available)
Inventory utilization rate (% of inventory copies rented at least once in last 90 days)

Categorize films into:
"Blockbusters": Top 20% by revenue AND rental frequency
"Underperformers": Bottom 30% by revenue AND rental frequency
"Efficient Classics": High utilization rate (>80%) AND above average rental duration
"Slow Movers": Low utilization rate (<30%) AND below average rentals
"Balanced Performers": All other films

Include store-level analysis:
Compare performance between store locations
Identify films that perform well in one store but poorly in another


Expected Output Columns:
film_id, title, category_name, total_rentals, total_revenue, avg_rental_duration, rental_frequency, inventory_utilization_rate
performance_category, store_1_rentals, store_2_rentals, performance_disparity */

--CTE to calculate core business metrics
WITH film_metrics AS (
    SELECT f.film_id, COUNT(DISTINCT r.rental_id) AS total_rentals, SUM(p.amount) AS total_revenue
    FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
    WHERE r.return_date IS NOT NULL
    GROUP BY 1
),
--CTE to calculate average_rental_duration per film and pull  actual allowed duration
filmwise_avg_rental_duration AS (
        SELECT f.film_id, 
        f.rental_duration AS allowed_rental_duration,
        ROUND(AVG(r.return_date::date - r.rental_date::date),2) AS actual_average_duration
        FROM film f
        INNER JOIN inventory i ON f.film_id = i.film_id
        INNER JOIN rental r ON i.inventory_id = r.inventory_id
        GROUP BY 1
)
SELECT * FROM filmwise_avg_rental_duration;
