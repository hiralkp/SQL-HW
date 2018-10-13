Use sakila;


-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name,  last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, '  '  , last_name)  as Actor_Name from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name="Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
select first_name,last_name from actor where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select last_name,first_name from actor where last_name like "%LI%";

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ("Afghanistan","Bangladesh", "China");

/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` 
named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).*/
alter table actor add column description BLOB;
select description from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor drop column description;
select description from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
use sakila;
select count(last_name), last_name as Last_Name from actor group by last_name;

-- 4b.4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'name_count' FROM actor GROUP BY last_name HAVING name_count >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

SELECT first_name,last_name,actor_id FROM actor where last_name = "Williams";
update actor set first_name="HARPO " where actor_id=172;
SELECT first_name,last_name,actor_id FROM actor where last_name = "Williams";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor set first_name="GROUCHO " where actor_id=172;
SELECT first_name,last_name,actor_id FROM actor where last_name = "Williams";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

DESCRIBE ADDRESS;

-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT s.first_name, s.last_name, a.address, c.city, c_1.country 
FROM staff AS s INNER JOIN address as a ON s.address_id = a.address_id
INNER JOIN city as c ON a.city_id = c.city_id INNER JOIN country as c_1 ON c.country_id = c_1.country_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT s.first_name, s.last_name, SUM(p.amount) AS revenue_received FROM staff as s
INNER JOIN payment as p ON s.staff_id = p.staff_id WHERE p.payment_date LIKE '2005-08%' GROUP BY p.staff_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, COUNT(actor_id) AS number_of_actors FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id GROUP BY title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT title, COUNT(inventory_id) AS number_of_copies FROM film as f
INNER JOIN inventory as i ON f.film_id = i.film_id WHERE title = 'Hunchback Impossible';


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with
-- the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title from film where language_id in (select language_id from language where name="English") and title like "K%" or title like "Q%";
select * from language;

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select * from film where title="Alone Trip";
select * from film_actor;
select first_name, last_name from actor where actor_id in(select actor_id from film_actor where film_id in (select film_id from film where title="Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select * from customer;
select * from country;
select * from address;
select * from city;


select c.first_name, c.last_name, c.email from customer as c
left join address as a 
on (address_id);




-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title FROM film WHERE film_id IN (SELECT film_id FROM film_category WHERE category_id IN (SELECT category_id FROM category WHERE name = 'Family'));


-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT() AS 'rent_count' FROM film, inventory, rental WHERE film.film_id = inventory.film_id AND rental.inventory_id = inventory.inventory_id
 GROUP BY inventory.film_id ORDER BY COUNT() DESC, film.title ASC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount) AS revenue FROM store INNER JOIN staff ON store.store_id = staff.store_id INNER JOIN payment ON payment.staff_id = staff.staff_id GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country FROM store INNER JOIN address ON store.address_id = address.address_id INNER JOIN city ON address.city_id = city.city_id INNER JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT store.store_id, city.city, country.country FROM store INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS top_five_genres;
CREATE VIEW top_five_genres AS

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;