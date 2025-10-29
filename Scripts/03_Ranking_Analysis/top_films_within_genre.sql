
/*Find films that are among the top 3 most-rented movies within their category.
For each such film, display: Category name, Film title, Number of rentals, Its rank within the category*/
SELECT * FROM
(
SELECT f.film_id,
f.title,
c.name,
f.release_year,
COUNT(r.rental_id),
RANK() OVER (PARTITION BY c.name ORDER BY COUNT(r.rental_id) DESC, f.release_year ASC, f.title ASC) as rank
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3,4
) AS ranked_films
WHERE rank <=3;
--CTE Version
WITH film_data AS (
  SELECT f.film_id,
f.title,
c.name,
COUNT(DISTINCT r.rental_id) AS total_rentals,
RANK() OVER (PARTITION BY c.name ORDER BY COUNT(DISTINCT r.rental_id) DESC) as rank
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
)
SELECT fd.film_id,
fd.title,
fd.name,
fd.total_rentals,
fd.rank
FROM film_data fd
WHERE rank<=3;