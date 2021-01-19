/*
Question Set #2, Question 1:
Query that returns the store ID for the store, the year and month and the number of rental orders each store has 
fulfilled for that month. 
*/

/*
--Raw data 
SELECT  DATE_PART('month', rental_date) AS rental_month, DATE_PART('year', rental_date) AS rental_year,
		s.store_id, COUNT (r.rental_id) AS count_rentals
FROM rental r
	JOIN staff s 
	ON s.staff_id = r.staff_id
GROUP BY rental_month, rental_year, s.store_id
ORDER BY count_rentals DESC 
*/

/*
Pivot table to create visualisation
Results exported to Numbers to generate graph
*/

CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab(
$$ SELECT  CONCAT_WS('-', DATE_PART('year', rental_date), DATE_PART('month', rental_date)) AS year_month,
		s.store_id, COUNT (r.rental_id) AS count_rentals
FROM rental r
	JOIN staff s 
	ON s.staff_id = r.staff_id
GROUP BY year_month, s.store_id
ORDER BY count_rentals DESC 
$$
) AS ("Year_Month" text,
	  "StoreID_1" bigint,
	  "StoreID_2" bigint);