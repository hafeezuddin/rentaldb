/* Category popularity by year/month (top category per period) */
WITH pop_cat_rank AS (
SELECT
  TO_CHAR(r.rental_date, 'YYYY') AS year,
  TO_CHAR(r.rental_date, 'MM') AS month,
  c.name AS category,
  COUNT(*) AS rental_count,
  DENSE_RANK() OVER (PARTITION BY TO_CHAR(r.rental_date, 'YYYY'), TO_CHAR(r.rental_date, 'MM') ORDER BY COUNT(*) DESC) as ranked_metric
FROM category c
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN inventory i ON fc.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
ORDER BY Year, month
)
SELECT * FROM pop_cat_rank pcr
WHERE pcr.ranked_metric =1;
