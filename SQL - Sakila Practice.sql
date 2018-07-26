-- Instructions
use sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name
from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, ' ', last_name) as 'Actor Name'
from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor.actor_id, actor.first_name, actor.last_name
from actor
where first_name = "Joe"
-- 2b. Find all actors whose last name contain the letters `GEN`:
select actor.actor_id, actor.first_name, actor.last_name
from actor
where last_name like "%gen%";
-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select actor.actor_id, actor.last_name, actor.first_name
from actor
where last_name like "%Li%";
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country.country_id, country.country
from country
where country.country in("Afghanistan", "Bangladesh", "China");
-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
-- Hint: you will need to specify the data type.
alter table actor
add middle_name varchar(15) after first_name;
-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the `middle_name` column to `blobs`.
alter table actor
modify column middle_name blob;
-- 3c. Now delete the `middle_name` column.
alter table actor
drop column middle_name;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select actor.last_name, count(last_name)
from actor
group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select actor.last_name, count(last_name) as LastNameCount
from actor
group by last_name
having LastNameCount > 1
-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
select actor.actor_id, actor.first_name, actor.last_name
from actor
where last_name = "Williams";
	-- actor_id=172 - "Groucho Williams"
update actor set first_name="HARPO"
where actor_id=172;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
-- Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error.
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 
-- (Hint: update the record using a unique identifier.)
select actor.actor_id, actor.first_name, actor.last_name
from actor
where last_name= "Williams";
update actor set first_name="GROUCHO"
where actor_id=172 and first_name = "HARPO"
else "MUCHO GROUCHO";
-- COULDN'T FIGURE THIS ONE OUT?

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
Show create table address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:
select s.first_name, s.last_name, a.address, c.city, ctry.country
from staff s
left join address a
on s.address_id=a.address_id
left join city c
on a.city_id=c.city_id
left join country ctry
on c.country_id=ctry.country_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
 select s. first_name, s.last_name, sum(p.amount) as "Total Rung Up"
 from payment p 
 join staff s on p.staff_id=s.staff_id
 group by s.staff_id;
 
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title, count(a.actor_id)
from film_actor a
inner join film f on a.film_id=f.film_id
group by a.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(i.film_id)
from inventory i
where film_id = (select film_id from film where title = "Hunchback Impossible");

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) as "Total Paid"
from payment p
join customer c on p.customer_id=c.customer_id
group by p.customer_id
order by c.last_name asc;
 
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title, language_id from film
where (title like "k%" or title like "q%") and language_id = (
		select language_id
        from `language`
        where `name` = "english");

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select actor.first_name, actor.last_name from actor
where actor_id in
	(select actor_id from film_actor
    where film_id=
		(select film_id from film where title = "Alone Trip")
        );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
-- and email addresses of all Canadian customers. Use joins to retrieve this information.
select s.first_name, s.last_name, s.email, c.city, ctry.country
from customer s
left join address a 
on s.address_id=a.address_id
left join city c
on a.city_id=c.city_id
left join country ctry
on c.country_id=ctry.country_id
where ctry.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select f.title
from film_category fc inner join film f on f.film_id=fc.film_id
where fc.category_id = 
	(select category_id 
    from category 
    where `name` = "Family");

-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id)
from rental r
inner join inventory i on r.inventory_id=i.inventory_id
inner join film f on i.film_id=f.film_id
group by f.title
order by count(r.rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as "business_in_$"
from payment p
join customer c on p.customer_id=c.customer_id
join store s on c.store_id=s.store_id
group by c.store_id
order by s.store_id, c.customer_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, ctry.country
from store s
left join address a
on s.address_id=a.address_id
left join city c
on a.city_id=c.city_id
left join country ctry
on c.country_id=ctry.country_id;
-- 7h. List the top five genres in gross revenue in descending order. (----Hint----: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount)
from payment p 
inner join rental r 
on p.rental_id=r.rental_id
inner join inventory i 
on r.inventory_id=i.inventory_id
inner join film_category fc 
on i.film_id=fc.film_id
inner join category c on fc.category_id=c.category_id
group by c.`name`
order by sum(p.amount) desc;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
-- 8b. How would you display the view that you created in 8a? - See line "select * from Top5Genres"
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it. - See line "drop view if exists Top5Genres"

drop view if exists Top5Genres;

create view Top5Genres as (

	select c.name, sum(p.amount)
	from payment p 
	inner join rental r 
	on p.rental_id=r.rental_id
	inner join inventory i 
	on r.inventory_id=i.inventory_id
	inner join film_category fc 
	on i.film_id=fc.film_id
	inner join category c on fc.category_id=c.category_id
	group by c.`name`
	order by sum(p.amount) desc
    
limit 5);

select * from Top5Genres




