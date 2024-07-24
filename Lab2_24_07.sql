-- Active: 1721290975934@@127.0.0.1@3306@sakila
--Write SQL queries to perform the following tasks using the Sakila database:

--Determine the number of copies of the film "Hunchback Impossible"
--that exist in the inventory system.

SELECT f.title, COUNT (i.inventory_id)
FROM film as f
JOIN inventory as i
ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible"

--List all films whose length is longer than the average length
--of all the films in the Sakila database.

SELECT f.title, AVG (f.length) AS "Average"
FROM film as f
GROUP BY f.title
HAVING Average > (SELECT ROUND(AVG (f.length)) AS "Average"
FROM film AS f);

--Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT f.title, CONCAT(a.first_name, ' ', a.last_name) AS actors_name
FROM actor as a
JOIN film_actor as fa
ON a.actor_id = fa.actor_id
JOIN film as f
ON fa.film_id = f.film_id
WHERE f.title = "Alone Trip";

SELECT "Alone Trip" AS title, CONCAT(a.first_name, ' ', a.last_name) AS actors_name
FROM actor AS a
JOIN film_actor AS fa
ON a.actor_id = fa.actor_id
WHERE fa.film_id = (SELECT film_id FROM film WHERE title = "Alone Trip");


--Bonus:
--Sales have been lagging among young families, and you want to 
--target family movies for a promotion. Identify all movies categorized 
--as family films.

SELECT f.title, c.name AS "Category"
FROM film as f
JOIN film_category as fc
ON f.film_id = fc.film_id
JOIN category as c
ON fc.category_id = c.category_id
WHERE c.name = "Family";


--Retrieve the name and email of customers from Canada using both 
--subqueries and joins. To use joins, you will need to identify the 
--relevant tables and their primary and foreign keys.

SELECT CONCAT(c.first_name, ' ', c.last_name) AS customers_name, c.email, co.country
FROM customer AS c
JOIN address As a 
ON c.address_id = a.address_id
JOIN city AS ci
ON a.city_id = ci.city_id
JOIN country AS co
ON ci.country_id = co.country_id
WHERE co.country = "Canada";

SELECT CONCAT(c.first_name, ' ', c.last_name) AS customers_name, c.email, 
       (SELECT co.country 
        FROM country AS co
        WHERE co.country_id = 
              (SELECT ci.country_id 
               FROM city AS ci 
               WHERE ci.city_id = a.city_id)
       ) AS country
FROM customer AS c
JOIN address AS a 
ON c.address_id = a.address_id
WHERE a.city_id IN (
    SELECT ci.city_id
    FROM city AS ci
    WHERE ci.country_id = (
        SELECT co.country_id
        FROM country AS co
        WHERE co.country = "Canada"
    )
);


--Determine which films were starred by the most prolific 
--actor in the Sakila database. A prolific actor is defined as 
--the actor who has acted in the most number of films. First, 
--you will need to find the most prolific actor and then use that 
--actor_id to find the different films that he or she starred in.

SELECT f.title, fa.actor_id
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1);

--Find the films rented by the most profitable customer
--in the Sakila database. You can use the customer and payment tables
--to find the most profitable customer, i.e., the customer who has made 
--the largest sum of payments.

SELECT customer_id, SUM (amount) FROM payment
GROUP BY customer_id
ORDER BY SUM (amount) DESC

SELECT customer_id FROM payment
GROUP BY customer_id
ORDER BY SUM (amount) DESC LIMIT 1

SELECT f.title FROM rental AS r
JOIN inventory AS i
ON i.inventory_id = r.inventory_id
JOIN film AS f
ON f.film_id = i.film_id
WHERE r.customer_id = (SELECT customer_id FROM payment
GROUP BY customer_id
ORDER BY SUM (amount) DESC LIMIT 1)

--Retrieve the client_id and the total_amount_spent 
--of those clients who spent more than the average of the total_amount 
--spent by each client. You can use subqueries to accomplish this.

SELECT customer_id, total_amount_spent
FROM (
    SELECT p.customer_id, SUM(p.amount) AS total_amount_spent
    FROM payment AS p
    GROUP BY p.customer_id
) AS customer_totals
WHERE total_amount_spent > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT SUM(p.amount) AS total_amount_spent
        FROM payment AS p
        GROUP BY p.customer_id
    ) AS subquery
);
