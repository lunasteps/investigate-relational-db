
/*THE QUERY FOR EACH SLIDE IS IN THE PDF PRESENTATION AS REQUESTED
WITH THE POOR SERVICE I HAVE HAD THIS TIME I DO WONDER WHAT IS THE POINT*/


/* 
Question Set #1, Question 1
We want to understand more about the movies that families are watching. The following categories are considered
family movies: Animation, Children, Classics, Comedy, Family and Music.

Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.

*/

/*
CTE to filter data requested by question
*/

WITH t1 AS (SELECT f.title film_title, 
				   c.name category_name, 
				   r.rental_id
			FROM film f 
				JOIN film_category fc
				ON f.film_id = fc.film_id
				JOIN category c
				ON c.category_id = fc.category_id
				JOIN inventory i
				ON i.film_id = f.film_id
				JOIN rental r
				ON i.inventory_id = r.inventory_id
			WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
),

/*
Extra CTE to help visualisation, to output raw data requested by the question use the query within CTE
SELECT DISTINCT film_title, category_name, 
	   count(rental_id) OVER (PARTITION BY film_title) AS rental_count
FROM t1
ORDER BY category_name, film_title
--Removing leading comma
*/

t2 AS (SELECT DISTINCT film_title, 
	   		  category_name, 
	   		  count(rental_id) OVER (PARTITION BY film_title) AS rental_count
	   FROM t1
	   ORDER BY category_name, film_title)

/*
Output from the following query as exported to Numbers to generate graph
*/

SELECT category_name, SUM(rental_count)
FROM t2
GROUP BY category_name;
