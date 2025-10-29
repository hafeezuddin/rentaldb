
/* Identify Customers with High Potential for Loyalty Programs */
--1.Frequent Renters: Above-average rental frequency, 
--2.High-Value: Above-average total spending 
--3.Recent Activity: Rented at least once in the last 30 days)
--CTE to find customers who rent more often than average
WITH above_avg_rental_frequency AS (
  SELECT r.customer_id,
    COUNT(r.rental_id) AS no_of_times_film_rented
  FROM rental r
  GROUP BY 1
  HAVING COUNT(r.rental_id) > --Filtering customers based on average frequency
    (
      SELECT AVG(times_rented)
      FROM (
          SELECT r.customer_id,
            COUNT(r.rental_id) AS times_rented
          FROM rental r
          GROUP BY 1
        )
    )
),
--CTE to find customers who spend more than the average amount
above_avg_spend AS (
  SELECT p.customer_id,
    SUM(p.amount) AS total_amount_spent
  FROM payment p
  GROUP BY 1
  HAVING SUM(p.amount) > --Filtering customers based on avg amount spent criteria
    (
      SELECT AVG(tot_spend)
      FROM (
          SELECT SUM(amount) AS tot_spend
          FROM payment
          GROUP BY customer_id
        )
    )
),
--CTE to find customers who rented out movies in last 30 days
recent_activity AS (
  SELECT DISTINCT r.customer_id
  FROM rental r
  WHERE (CURRENT_DATE - r.rental_date::date) < 100000
) 
--Main query to find customers who spend more than average, rent more than average and has recent activity.
SELECT cte1.customer_id
FROM above_avg_rental_frequency AS cte1
  INNER JOIN above_avg_spend cte2 ON cte1.customer_id = cte2.customer_id
  INNER JOIN recent_activity cte3 ON cte2.customer_id = cte3.customer_id;