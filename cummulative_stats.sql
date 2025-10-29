/* Find the cumulative monthly revenue growth over time.
For each month, show: Year-Month, Number of rentals, Monthly revenue
Cumulative revenue up to that month
Percentage growth compared to the previous month */
-- CTE to calculate monthly revenue and rental counts
WITH revenue AS (
  SELECT 
    TO_CHAR(DATE_TRUNC('MONTH', r.rental_date), 'YYYY-MM') AS Month_Year, -- Format rental_date as Year-Month
    SUM(p.amount) AS revenue,                                             -- Total revenue for the month
    COUNT(r.rental_id) AS rentals                                         -- Number of rentals for the month
  FROM rental r
    INNER JOIN payment p ON r.rental_id = p.rental_id
  GROUP BY 1
)
SELECT 
  r.Month_Year, 
  r.revenue,
  LAG(r.revenue) OVER (ORDER BY r.Month_Year) AS lag, -- Previous month's revenue
  r.revenue - LAG(r.revenue) OVER (ORDER BY r.Month_Year) AS diff_in_rev, -- Revenue difference from previous month
  SUM(r.revenue) OVER (ORDER BY r.Month_Year) AS cumm_rev, -- Cumulative revenue up to this month
  -- Percentage growth compared to previous month
  ROUND((r.revenue - LAG(r.revenue) OVER(ORDER BY r.Month_Year)) / NULLIF(LAG(r.revenue) OVER(ORDER BY r.Month_Year), 0) * 100, 2) AS percentage_change,
  r.rentals -- Number of rentals in the month
FROM revenue r;