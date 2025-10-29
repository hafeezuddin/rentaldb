/* Busiest hours by rental count */
SELECT EXTRACT(
    HOUR
    FROM rental_date
  ) AS hour_of_day,
  COUNT(*) AS rental_count
FROM rental
GROUP BY hour_of_day
ORDER BY rental_count DESC
LIMIT 10;
