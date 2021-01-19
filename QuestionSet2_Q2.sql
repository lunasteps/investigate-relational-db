/* 
Question Set #2, Question 2
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, 
and what was the amount of the monthly payments. Can you write a query to capture the customer name,
month and year of payment, and total payment amount for each month by these top 10 paying customers?
*/

/*
***************************ASSUMPTION***************************
This query generates a Pivot table and therefore I assume that:

tablefunc has been enabled in the database to create pivot table
*****************************************************************
*/

/*It never hurts to ensure temp tables do not exist*/

DROP TABLE IF EXISTS  temp_topcust;
CREATE EXTENSION IF NOT EXISTS tablefunc;


/* CTE to filter requested data */

WITH t1 AS (SELECT  c.customer_id, 
                    CONCAT_WS(' ', c.first_name, c.last_name) AS fullname, 
                    SUM(p.amount) as pay_amount
			FROM customer c 
				JOIN payment p
				ON p.customer_id = c.customer_id
			WHERE DATE_PART('year',p.payment_date) = 2007
			GROUP BY c.customer_id, fullname
			ORDER BY  pay_amount DESC

			LIMIT 10)
/*
The following was added to be abe to visualise the data in Numbers, as seemed better handling categories than excel,
to rerieve the data requested in the queston use the following query along with the above CTE

SELECT DATE_TRUNC('month', p.payment_date) AS pay_mon, 
        t.fullname, 
        COUNT(*) AS count_tx, 
        SUM(p.amount) as pay_amount
FROM payment p
	JOIN t1 t 
	ON p.customer_id = t.customer_id
GROUP BY pay_mon, t.fullname
ORDER BY t.fullname, pay_mon
*/

/* Creating temporary table to create pivot table */

SELECT DATE_TRUNC('month', p.payment_date) AS pay_mon,
        	 t.fullname, 
             COUNT(*) AS count_tx, 
             SUM(p.amount) as pay_amount
	 INTO  TEMPORARY  temp_topcust
	 FROM payment p
 	 	JOIN t1 t 
		ON p.customer_id = t.customer_id
	 GROUP BY pay_mon, t.fullname
	 ORDER BY t.fullname, pay_mon;



/* Pivot table, results were exported to Numbers to generate graph*/

SELECT * FROM crosstab(
  'SELECT fullname, DATE_PART(''month'', pay_mon), pay_amount FROM temp_topcust ORDER BY 1',
  'SELECT m FROM generate_series(2,5) m'
) AS (
  fullname text,
  /*only data for the following mnths exist in the database, however it is simple to modify above series to include all months
	filtering to help whoever is reviewing visualisations*/
  "Feb" numeric,
  "Mar" numeric,
  "Apr" numeric,
  "May" numeric
  
);


	   