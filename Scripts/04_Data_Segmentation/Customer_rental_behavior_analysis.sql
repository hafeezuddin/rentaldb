/* Business Requirement: Customer Rental Behavior Analysis
Objective: Analyze customer rental patterns to identify different behavioral segments

Specific Requirements:
Find each customer's total rentals and total spending
Calculate their average days between rentals (engagement frequency)
Identify their most rented film category

Flag if they've rented in the last 30 days (active status)

Segment customers into:
"Frequent High Spenders" (top 25% by rentals AND spending)
"Loyal Regulars" (above average rentals, medium spending)
"Occasional Viewers" (below average rentals)
"Inactive" (no rentals in last 90 days) */

--CTE to calculate basic metrics
WITH customer_metrics AS (
SELECT c.customer_id, 
    COUNT(DISTINCT r.rental_id) AS total_rentals
    ,SUM(p.amount) AS total_spent
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1
),
derived_metrics AS (
    SELECT DISTINCT cm.customer_id,
        DATE_TRUNC('Day', r2.rental_date)::date AS date_of_rental
    FROM customer_metrics cm
    INNER JOIN rental r2 ON cm.customer_id = r2.customer_id
    ORDER BY cm.customer_id ASC, DATE_TRUNC('Day', r2.rental_date)::date DESC
),
rental_days_diff AS (
    SELECT dm.customer_id,
        dm.date_of_rental,
        LAG(dm.date_of_rental) OVER (PARTITION BY dm.customer_id ORDER BY dm.date_of_rental DESC),
        CASE 
            WHEN LAG(dm.date_of_rental) OVER (PARTITION BY dm.customer_id ORDER BY dm.date_of_rental DESC) IS NULL
                THEN 0
            ELSE     
                LAG(dm.date_of_rental) OVER (PARTITION BY dm.customer_id ORDER BY dm.date_of_rental DESC) - dm.date_of_rental
            END AS diff
        FROM derived_metrics dm
),
avg_engagement_frequency AS (
    SELECT rdd.customer_id, ROUND(AVG(rdd.diff),2) AS engagement_frequency
    FROM rental_days_diff rdd
    GROUP BY 1
),
most_rented_category AS (
  SELECT x.customer_id, 
    x.name FROM (  
            SELECT cm.customer_id, 
            cat.name, COUNT(*) AS rented_times,
            ROW_NUMBER() OVER (PARTITION BY cm.customer_id ORDER BY count(*) DESC, cat.name ASC) AS ranking
        FROM customer_metrics cm
        INNER JOIN rental r3 ON cm.customer_id = r3.customer_id
        INNER JOIN inventory i ON r3.inventory_id = i.inventory_id
        INNER JOIN film_category fc ON i.film_id = fc.film_id
        INNER JOIN category cat ON fc.category_id = cat.category_id
        GROUP BY 1,2
        ORDER BY 1 ASC, rented_times DESC
  ) x
  WHERE ranking =1
),
active_status AS (
    
);