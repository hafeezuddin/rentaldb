/*Find the top 2 cities in each country by number of rentals.
For each city, show: Country name, City name, Number of rentals in that city, Rank of the city within its country
If multiple cities tie for the same rank, they should all be included. */

--CTE to consolidate and rank city,country wise data based on rentals
WITH ranking_cities AS (
SELECT ci.city, 
co.country, 
COUNT(r.rental_id) AS total_rentals,
--Ranking by partioning by country and rentals in Desc
RANK() OVER (PARTITION BY co.country ORDER BY COUNT(r.rental_id) DESC) AS ranking,
--Calculating no.of.rentals of each country using partioning 
SUM(COUNT(r.rental_id)) OVER (PARTITION BY co.country) AS country_total_rentals
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id
GROUP BY 1,2
)
--Main query to filter top 2 cities in each country.
SELECT rc.city,
rc.country,
rc.total_rentals,
rc.ranking,
rc.country_total_rentals,
--city Percentage/share calculation
ROUND((rc.total_rentals::numeric/country_total_rentals)*100,2) AS city_share_
FROM ranking_cities rc
WHERE rc.ranking <=2;