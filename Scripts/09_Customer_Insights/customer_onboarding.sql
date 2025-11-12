/*Task: 2005 Customer Onboarding & Premium Film Strategy

Background: Using only 2005 data, we need to determine if customers who started with premium films within the year became more valuable during that same year.
Your Mission: Analyze the relationship between a customer's first rental quality and their 2005 spending patterns.

Metric 1: 2005 Customer Value by Starting Tier
Objective: Compare the 2005 spending of customers based on their first rental's film quality.
Business Question: "Within their first year, do customers who start with premium films spend more than those who start with standard films?"
Calculation:

    First Rental Quality: Categorize by the replacement cost of their first 2005 rental:
        'Premium Start' (replacement_cost >= $20)
        'Standard Start' (replacement_cost < $20)
         2005 Customer Value: Total 2005 payments from their first rental to Dec 31, 2005
Required Analysis: Compare average 2005 spending between Premium-start vs Standard-start customers.


Metric 2: 2005 Engagement & Quality Progression
Objective: Analyze if starting with premium films leads to different rental behaviors within 2005.
Business Question: "Do premium-start customers rent more frequently and continue choosing premium films?"

Calculation:
    90-Day Retention: % of customers who rented again within 90 days of their first 2005 rental
    2005 Rental Frequency: Total 2005 rentals per customer
    Premium Mix: % of each customer's 2005 rentals that are premium films

Strategic Deliverable (2005 Analysis):
A focused analysis answering:
    Short-term ROI: Do premium-start customers generate enough additional 2005 revenue to justify the higher inventory cost?
    Engagement Pattern: Do they rent more frequently within their first year?
    Quality Preference: Do they develop a taste for premium content?
Data Scope: January 1 - December 31, 2005 only */

--CTE to filter who started rentals with with premium films (1st ever rental)
WITH customer_first_rental_analysis AS (
SELECT sq1.customer_id, sq1.rental_date, 
CASE
    WHEN sq1.replacement_cost >= 20
        THEN 'Premium Start'
    ELSE
        'Standard start'
    END AS first_rental_quality
FROM (
SELECT c.customer_id, r.rental_date, f.title, f.replacement_cost,
    row_number() OVER (PARTITION BY c.customer_id ORDER BY c.customer_id, r.rental_date ASC) AS first_rental
    FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
WHERE r.return_date IS NOT NULL AND (r.rental_date BETWEEN '01-01-2005' AND '12-31-2005')
) sq1
WHERE sq1.first_rental =1
),
total_spent AS (
    SELECT c.customer_id, SUM(p.amount) AS total_spent
    FROM customer c
    INNER JOIN rental r ON c.customer_id = r.customer_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
    WHERE r.return_date IS NOT NULL AND (r.rental_date BETWEEN '01-01-2005' AND '12-31-2005')
    GROUP BY 1
),
category_avg AS (
    SELECT  DISTINCT cfra.first_rental_quality,
    ROUND(AVG(ts.total_spent) OVER (PARTITION BY cfra.first_rental_quality),2) AS cat_avg
    FROM customer_first_rental_analysis cfra
    INNER JOIN total_spent ts ON cfra.customer_id = ts.customer_id
),
rentention_cte AS (
  SELECT sq2.customer_id, sq2.rental_date
FROM (
SELECT c.customer_id, r.rental_date, f.title, f.replacement_cost,
    row_number() OVER (PARTITION BY c.customer_id ORDER BY c.customer_id, r.rental_date ASC) AS first_rental
    FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
WHERE r.return_date IS NOT NULL AND (r.rental_date BETWEEN '01-01-2005' AND '12-31-2005')
) sq2
)
SELECT * FROM rentention_cte
ORDER BY 1 ASC;
