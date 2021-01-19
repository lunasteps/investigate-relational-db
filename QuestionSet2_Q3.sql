 /*
Question Set #2, Question 3
Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly
payments during 2007. Please go ahead and write a query to compare the payment amounts in each successive month. 
Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the customer 
name who paid the most difference in terms of payments.
*/

/*
***************************ASSUMPTION***************************
This query generates a Pivot table and therefore I assume that:

tablefunc has been enabled in the database to create pivot table

as no human can read this I created it anyway d'oh
lalalalalalalala
*****************************************************************
*/
/*It never hurts to ensure temp tables do not exist*/
DROP TABLE IF EXISTS  temp_dif;
CREATE EXTENSION IF NOT EXISTS tablefunc;
/* CTEs to filter requested data*/

WITH t1 AS (SELECT c.customer_id,
				   CONCAT_WS(' ', c.first_name, c.last_name) AS fullname,                     
                   p.amount, 
                   p.payment_date
              FROM customer AS c
                   JOIN payment AS p
                    ON c.customer_id = p.customer_id
			  WHERE DATE_PART('year',p.payment_date) = 2007),

     t2 AS (SELECT t1.customer_id
              FROM t1
             GROUP BY 1
             ORDER BY SUM(t1.amount) DESC
             LIMIT 10),

	t3 AS (SELECT t1.fullname,
              DATE_PART('month', t1.payment_date) AS pay_month, 
              DATE_PART('year', t1.payment_date) AS pay_year,
              COUNT (*) AS count_tx,
              SUM(t1.amount) AS pay_amount,
              LEAD(SUM(t1.amount)) OVER(PARTITION BY t1.fullname ORDER BY DATE_PART('month', t1.payment_date)) AS lead_value,
              LEAD(SUM(t1.amount)) OVER(PARTITION BY t1.fullname ORDER BY DATE_PART('month', t1.payment_date)) - SUM(t1.amount) AS lead_dif
         FROM t1
              JOIN t2
               ON t1.customer_id = t2.customer_id
        GROUP BY fullname, pay_month, pay_year
        ORDER BY fullname, pay_year, pay_month)


/*Raw data can be extracted either by querying temp table or by using the following statement minus the INTO clause*/

SELECT fullname,
	   pay_month,
	   pay_year,
	   count_tx,
	   pay_amount,
	   lead_value,
	   lead_dif,
       CASE
           WHEN t3.lead_dif = (SELECT MAX(t3.lead_dif) FROM t3 ORDER BY 1 DESC LIMIT 1) THEN 'Cx with maximum difference'
           ELSE NULL
           END AS max_value				
  INTO TEMPORARY temp_dif
  FROM t3
  
 ORDER BY fullname;
 
 /*
 Pivot Table: results exported to Numbers to generate graph
*/

 SELECT * FROM crosstab(
  'SELECT fullname, pay_month, lead_dif FROM temp_dif ORDER BY 1',
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



 
