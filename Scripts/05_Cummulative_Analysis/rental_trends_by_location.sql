/* Rental trends by location (City, Country), Year and Month */
SELECT 
  co.country,
  c.city,
  EXTRACT(YEAR FROM r.rental_date) AS year,
  EXTRACT(MONTH FROM r.rental_date) AS month,
  COUNT(*) AS rental_count
FROM city c
  JOIN country co ON c.country_id = co.country_id
  JOIN address a ON c.city_id = a.city_id
  JOIN customer cu ON a.address_id = cu.address_id
  JOIN rental r ON cu.customer_id = r.customer_id
GROUP BY co.country, c.city, year, month
ORDER BY rental_count DESC;
