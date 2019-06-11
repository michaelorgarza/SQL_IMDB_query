USE sakila;

-- 1a. Display the first and last names of all the actors from the table 'actor'

SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters named "Actor Name"

SELECT CONCAT(first_name," ", last_name) AS Actor_Name FROM actor;
UPDATE Actor_Name SET Actor_Name = UPPER(Actor_Name);

-- 2a. Find the ID #, first and last name of an actor, of whom you know only the first name, "Joe." What is one query used to obtain this information.

SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "JOE";
-- One query to obtain this information is the use of a WHERE clause which allows you to choose which rows are returned from a SELECT statement based on a condition. 

-- 2b. Find all the actors who last name contain the letters "GEN:"

SELECT actor_id, first_name, last_name from actor WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. Order the rows by last and first name, in that order.

SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE "%LI%" ORDER BY first_name, last_name;

-- 2d. Using IN, display the country_id and country columns of the following: Afghanistan, Bangladesh, China

SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name

ALTER TABLE `sakila`.`actor` 
ADD COLUMN `middle_name` VARCHAR(45) NOT NULL AFTER `first_name`;
SELECT * FROM actor;

-- 3b. Some actors have very long names. Change the data type of middle_name column to blobs

ALTER TABLE `sakila`.`actor` 
CHANGE COLUMN `middle_name` `middle_name` BLOB NOT NULL ;
SELECT * FROM actor;

-- 3c. Delete the middle_name column

ALTER TABLE `sakila`.`actor` 
DROP COLUMN `middle_name`;
SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have the last name. 
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name;

-- 4b. List the last names of actos and the # of actors who have the last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as Occurences from actor group by last_name HAVING COUNT(last_name) > 1;

-- 4c. Actor Harop W. was entered in the actor table as Groucho W., write a query to fix the record. 
UPDATE `sakila`.`actor` SET `first_name`='HARPO' WHERE `first_name` = "GROUCHO" AND `last_name`='Williams';
SELECT * FROM actor;

-- 4d. In a single query, if the first name of the actor is currently Harpo, change it to Groucho. Otherwise change the name to Mucho Groucho. 
UPDATE actor SET first_name = CASE 
WHEN first_name = 'HARPO' THEN 'GROUCHO' ELSE 'MUCHO GROUCHO' END
WHERE actor_id = 172;

-- 5a. You cannot locate the local schema of the address tab. Which query would you use to recreate it?
SHOW COLUMNS FROM sakila.address;

SHOW CREATE TABLE address;
-- I would recreate the table if I could not locate the schema. 
 /* CREATE TABLE `address` (
  `address_id` tinyint(5)  NOT NULL AUTO_INCREMENT,
  `address` varchar(45) NOT NULL,
  `address2` varchar(45) DEFAULT NULL,
  `district` varchar(45) NOT NULL,
  `city_id` tinyint(5) unsigned NOT NULL,
  `postal_code` varchar(45) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=latin1 */

-- 6a. Use join to display the first and last names, as well as the addresses, of each staff member. Use tables staff and address. 
SELECT first_name, last_name, address FROM staff s INNER JOIN address a ON s.address_id = a.address_id;

-- 6b. Use join to display the total amount rung up by each staff member in Aug., 2005. Use staff/payment tables. 
SELECT s.staff_id, first_name, last_name, SUM(amount) AS 'Total Amount/Staff Member'
FROM staff s INNER JOIN payment p ON s.staff_id = p.staff_id GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use film_actor/film and inner join.
SELECT f.title, COUNT(fa.actor_id) AS '# of Actors' FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory. 
SELECT f.title, COUNT(i.inventory_id) AS '# of Copies' FROM film f  INNER JOIN inventory i 
ON f.film_id = i.film_id  GROUP BY f.film_id HAVING title = 'Hunchback Impossible'; 

-- 6e. Using the payment and customer tables and the join command, list the total paid by each customer alphabetically. 
SELECT c.last_name, c.first_name, SUM(p.amount) AS 'Total Paid' FROM customer c
INNER JOIN payment p ON c.customer_id = p.customer_id GROUP BY p.customer_id
ORDER BY last_name, first_name; 

-- 7a. The music of Queen and Kris have seen a resurgence. Films starting with the letters k and q have also soared in popularity 
-- Use subqueries to display the titles of the movies starting with the lettes and k and q who langauge is English
SELECT title FROM film WHERE language_id  IN (
SELECT language_id FROM language WHERE name = 'English') 
AND(title LIKE "K%") OR(title LIKE "Q%");

-- 7b. Use subqueriesto display all the actors who appear in the film Alone Trip
SELECT first_name, last_name FROM actor WHERE actor_id IN 
(
SELECT actor_id
FROM film_actor 
WHERE film_id IN 
(
SELECT film_id 
FROM film 
WHERE title = "Alone Trip" 
)); 

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and emails of Mounty customers. Use joins.
SELECT c.first_name, c.last_name, c.email, cn.country FROM customer c LEFT JOIN address a 
ON c.address_id = a.address_id LEFT JOIN city cy 
ON cy.city_id = a.city_id LEFT JOIN country cn
ON cn.country_id = cy.country_id
WHERE country = 'Canada'; 

-- 7d. Sales have been lagging among your young families and you wish to target all family movies for a promo. Identify all young movie category 
SELECT * FROM film WHERE film_id IN 
(
SELECT film_id
FROM film_category
WHERE category_id IN 
(
SELECT category_id
FROM category
WHERE name = 'Family'
)); 

-- 7e. Display the most frequently rented movies in descending order. 
SELECT f.title, COUNT(r.rental_id ) AS '# of Rentals'
FROM film f 
RIGHT JOIN inventory i ON f.film_id=i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.title ORDER BY COUNT(r.rental_id) DESC; 

-- 7f. Write a query to display how much a business, in dollars, each store bought. 
SELECT s.store_id, SUM(amount) FROM store s
RIGHT JOIN staff sf ON s.store_id = sf.store_id
LEFT JOIN payment p ON sf.staff_id = p.staff_id
GROUP BY s.store_id; 

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, cy.city, cn.country FROM store s 
JOIN address a ON s.address_id = a.address_id
JOIN city cy ON a.city_id = cy.city_id
JOIN country cn ON cy.country_id = cn.country_id; 

-- 7h.  List the top five genres in gross revenue in descending order.
SELECT c.name, SUM(p.amount) AS 'Gross Revenue/Category' FROM category c 
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i  ON fc.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY name; 

-- 8a. You would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
CREATE VIEW Top_Five_Genres AS

SELECT c.name, SUM(p.amount) AS 'Gross Revenue/Category' FROM category c 
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i  ON fc.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY name ORDER BY SUM(p.amount) DESC LIMIT 5; 

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;






































