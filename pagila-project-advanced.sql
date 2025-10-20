-- Question 1: Find the total number of rentals per customer.

SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name  AS full_name,
	COUNT(r.rental_id) AS total_rental
FROM customer AS c
JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY full_name, total_rental DESC;


-- Question 2: Find the total payment per customer.
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name  AS full_name,
	COUNT(p.payment_id) AS total_payment
FROM customer AS c
JOIN payment AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY full_name, total_payment DESC;

-- Question 3: Find the number of films in each category.
SELECT 
	ca.category_id,
	ca.name,
	COUNT(f.film_id) AS total_film
FROM category AS ca
JOIN film_category AS fc ON fc.category_id = ca.category_id
JOIN film AS f ON fc.film_id = f.film_id
GROUP BY ca.category_id, ca.name
ORDER BY total_film DESC;

-- Question 4: Find the average length of films per category.
SELECT
	c.category_id,
	c.name,
	ROUND(AVG(f.length), 2) AS avg_length
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN film AS f ON fc.film_id = f.film_id
GROUP BY c.category_id, c.name
ORDER BY avg_length

-- Question 5: Find the top 5 actors who have acted in the most films.
SELECT 
    a.actor_id,
    a.first_name || ' ' || a.last_name AS full_name,
    COUNT(fa.film_id) AS total_films
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, full_name
ORDER BY total_films DESC
LIMIT 5;

-- Question 6: Find the top 3 customers in each city by total payment
WITH customer_payments AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS full_name,
        ci.city,
        SUM(p.amount) AS total_payment
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    GROUP BY c.customer_id, full_name, ci.city
)
SELECT *
FROM (
    SELECT *,
        RANK() OVER(PARTITION BY city ORDER BY total_payment DESC) AS city_rank
    FROM customer_payments
) ranked_customers
WHERE city_rank <= 3
ORDER BY city, total_payment DESC;



-- Question 7: Find actors who acted in above-average number of films
WITH avg_total_film AS (
SELECT
	a.actor_id,
	a.first_name || ' ' || last_name AS full_name,
	COUNT(fa.film_id) AS total_film
FROM actor AS a
JOIN film_actor AS fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, full_name
)
SELECT *
FROM (
	SELECT *,
	ROUND(AVG(total_film) OVER(), 2) AS avg_film
FROM avg_total_film
) 
WHERE total_film > avg_film
ORDER BY total_film DESC;

-- Question 8: Find monthly revenue trend per category
SELECT
	c.name AS category_name,
	DATE_TRUNC('hour', rental_date) AS month,
	SUM(p.amount) AS monthly_revenue
FROM rental AS r
JOIN payment AS p ON r.rental_id = p.rental_id
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film_category AS fc ON i.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
GROUP BY category_name, month
ORDER BY category_name, month;

-- Question 9: Recursive CTE – Find all films in same categories as customer rented films
WITH RECURSIVE customer_films AS (
    SELECT r.customer_id, i.film_id
    FROM rental AS r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    WHERE r.customer_id = 1  -- örnek müşteri
),
related_films AS (
    SELECT cf.film_id, fc.category_id
    FROM customer_films AS cf
    JOIN film_category fc ON cf.film_id = fc.film_id
    UNION
    SELECT f.film_id, fc.category_id
    FROM related_films AS rf
    JOIN film_category fc ON rf.category_id = fc.category_id
    JOIN film AS f ON fc.film_id = f.film_id
)
SELECT DISTINCT film_id FROM related_films;

-- Question 10: Compare staff performance by total payments processed
WITH total_payments AS(
SELECT
	s.staff_id,
	s.first_name || ' ' || last_name AS full_name,
	SUM(p.amount) AS total_payment
FROM staff AS s
JOIN payment AS p ON s.staff_id = p.staff_id
GROUP BY s.staff_id
)
SELECT
	*,
	RANK() OVER(PARTITION BY staff_id ORDER BY total_payment)
FROM total_payments

-- Question 11: Customers inactive for last 6 months
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name
FROM customer AS c
LEFT JOIN rental AS r ON r.customer_id = c.customer_id AND r.rental_date >= CURRENT_DATE - INTERVAL '6 month'
WHERE r.rental_id IS NULL
GROUP BY c.customer_id
ORDER BY full_name;

-- Question 12: Question 13: Find top 5 movies by rental count in last 3 months
SELECT
	f.film_id,
	f.title,
	COUNT(r.rental_id) AS total_rental
FROM film AS f
JOIN inventory AS i ON f.film_id = i.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
WHERE r.rental_date >= CURRENT_DATE - INTERVAL '3 month'
GROUP BY f.film_id
ORDER BY total_rental DESC
LIMIT 5;

-- Question 13: Average payment per customer per store
WITH customer_avg AS (
    SELECT
        c.customer_id,
        s.store_id,
        c.first_name || ' ' || c.last_name AS full_name,
        SUM(p.amount) AS total_payment
    FROM customer AS c
    JOIN payment AS p ON c.customer_id = p.customer_id
    JOIN staff AS s ON p.staff_id = s.staff_id
    JOIN store AS st ON s.store_id = st.store_id
    GROUP BY c.customer_id, s.store_id, full_name
)
SELECT
    *,
    ROUND(AVG(total_payment) OVER (PARTITION BY store_id), 2) AS avg_payment_per_store
FROM customer_avg
ORDER BY store_id, total_payment DESC;

-- Question 14: Find longest movie per category
WITH category_length AS (
SELECT
	f.film_id,
	f.title,
	f.length,
	c.name AS category_name
FROM film AS f
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
GROUP BY f.film_id, f.title, f.length, c.name 
)
SELECT film_id, title, length, category_name
FROM (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY category_name ORDER BY length DESC) AS rn
	FROM category_length
) sub
WHERE rn = 1
ORDER BY category_name

-- Question 15: Top 1 movie by rental count per category (show title, category, rental_count)
WITH film_rentals AS (
    SELECT
        f.film_id,
        f.title,
        c.name AS category_name,
        COUNT(r.rental_id) AS rental_count
    FROM film AS f
    JOIN film_category AS fc ON f.film_id = fc.film_id
    JOIN category AS c ON fc.category_id = c.category_id
    JOIN inventory AS i ON f.film_id = i.film_id
    JOIN rental AS r ON i.inventory_id = r.inventory_id
    GROUP BY f.film_id, f.title, c.name
)
SELECT film_id, title, category_name, rental_count
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category_name ORDER BY rental_count DESC) AS rn
    FROM film_rentals
) ranked
WHERE rn = 1
ORDER BY rental_count DESC;

-- Question 16: Top 3 customers by total_payment for each store (show customer, store, total_payment, rank)
WITH total_payments AS (
SELECT 
	c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name,
	s.store_id,
	SUM(p.amount) AS total_payment
FROM customer AS c
JOIN payment AS p ON c.customer_id = p.customer_id
JOIN staff AS s ON p.staff_id = s.staff_id
JOIN store AS st ON s.store_id = st.store_id
GROUP BY c.customer_id, full_name, s.store_id
)
SELECT customer_id, full_name, store_id, total_payment
FROM (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY total_payment DESC) AS rn
FROM total_payments
)
WHERE rn < 3
ORDER BY total_payment DESC;
 
-- Question 17: Find actors whose film count is above the overall average (show actor, total_films, avg_films)
WITH actor_films AS (
SELECT
	a.actor_id,
	a.first_name || ' ' || a.last_name AS full_name,
	COUNT(f.film_id) AS total_films
	
FROM actor AS a
JOIN film_actor AS fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, full_name
)
SELECT
	actor_id,
	full_name,
	total_films,
	ROUND(AVG(total_films) OVER(), 2) AS avg_films
FROM actor_films
WHERE total_films > (SELECT AVG(total_films) FROM actor_films)
ORDER BY total_films DESC;

-- Question 18: List customers renting within the average rent range
WITH avg_customer_rent AS (
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name,
	COUNT(r.rental_id) AS total_rental
FROM customer AS c
JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, full_name
)
SELECT customer_id, full_name, total_rental
FROM (
	SELECT *,
	AVG(total_rental) OVER() AS avg_rental
FROM avg_customer_rent
)
WHERE total_rental > avg_rental
ORDER BY total_rental

-- Question 19: List movies longer than average movie length
WITH avg_longer_films AS (
SELECT
	f.film_id,
	f.title,
	f.length,
	ROUND(AVG(f.length), 2) AS avg_length
FROM film AS f
GROUP BY f.film_id, f.title, f.length
)
SELECT film_id, title, length
FROM avg_longer_films
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;

-- Question 20: Stores with more than average stock of films. Calculate how many movies are in inventory in each store.
WITH store_film AS (
SELECT
	i.store_id,
	COUNT(i.inventory_id) AS total_inventory,
	ROUND(AVG(i.inventory_id), 2) AS avg_inventory
FROM inventory AS i
GROUP BY i.store_id
)
SELECT store_id, total_inventory, avg_inventory
FROM (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY avg_inventory ORDER BY store_id DESC)
FROM store_film
)
WHERE avg_inventory > total_inventory
ORDER BY store_id DESC;

-- Question 21: Calculate the total consistency of all months (with STDDEV)
WITH monthly_stddev AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', payment_date) AS payment_month,
        ROUND(STDDEV(amount), 2) AS stddev_payment,
        ROUND(AVG(amount), 2) AS avg_payment
    FROM payment
    GROUP BY customer_id, DATE_TRUNC('month', payment_date)
),
cumulative_stddev AS (
    SELECT *,
           SUM(stddev_payment) OVER (
               PARTITION BY customer_id 
               ORDER BY payment_month
           ) AS cumulative_stddev
    FROM monthly_stddev
)
SELECT *
FROM cumulative_stddev
ORDER BY customer_id, payment_month;


-- Question 22: Analyze customer payment amounts to determine which customers are most consistent and have the highest payouts. Calculate the average payout, standard deviation, and consistency score for each customer. Then, rank the customers with the most consistent and highest payouts first.
SELECT 
	c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name,
	ROUND(STDDEV(p.amount), 2) AS stddev_payment,
	ROUND(AVG(p.amount), 2) AS avg_payment,
	ROUND(AVG(p.amount) / (STDDEV(p.amount) + 1), 2) AS stability_score
FROM customer AS c
JOIN payment AS p ON p.customer_id = c.customer_id
GROUP BY c.customer_id
)
SELECT customer_id, full_name, stddev_payment, avg_payment, stability_score
FROM customer_stddev
ORDER BY stability_score DESC;

-- Question 23: Paying more than the average payment per customer
WITH customer_total AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS full_name,
        SUM(p.amount) AS total_payment
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
)

SELECT customer_id, full_name, total_payment
FROM customer_total
WHERE total_payment > (SELECT AVG(total_payment) FROM customer_total)
ORDER BY total_payment

-- Question 24: find the total revenue for each category
WITH most_revenue_films AS (
SELECT 
	fc.category_id,
	c.name AS category_name,
	SUM(p.amount) AS total_revenue
FROM payment AS p
JOIN rental AS r ON r.rental_id = p.rental_id
JOIN inventory AS i ON i.inventory_id = r.inventory_id
JOIN film_category AS fc ON i.film_id = fc.film_id
JOIN category AS c ON c.category_id = fc.category_id
GROUP BY fc.category_id, category_name

)
SELECT category_id, category_name, total_revenue
FROM (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY total_revenue ORDER BY category_id)
FROM most_revenue_films
)
ORDER BY total_revenue DESC ;

-- Question 25: Highest grossing customer in each category (correlated subquery + CTE)
WITH highest_grossing_customer AS (
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name,
	ca.category_id,
	ca.name AS category_name,
	SUM(p.amount) AS total_payment
FROM payment AS p
JOIN rental AS r ON r.rental_id = p.rental_id
JOIN inventory AS i ON i.inventory_id = r.rental_id
JOIN film AS f ON f.film_id = i.film_id
JOIN customer AS c ON c.customer_id = r.customer_id
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS ca ON fc.category_id = ca.category_id
GROUP BY c.customer_id, full_name, ca.category_id
)
SELECT h.customer_id, h.full_name, h.category_id, h.category_name, h.total_payment
FROM highest_grossing_customer h
WHERE h.total_payment = (
    SELECT MAX(h2.total_payment)
    FROM highest_grossing_customer h2
    WHERE h2.category_id = h.category_id
)
ORDER BY h.category_id;

-- Question 26: The highest-grossing movie series (pattern recognition + string aggregation)
WITH film_series AS (
    SELECT 
        title,
        split_part(title, ' ', 1) AS series_name,
        rental_rate
    FROM film
)
SELECT 
    series_name,
    SUM(rental_rate) AS total_revenue,
    string_agg(title, ' → ') AS film_chain
FROM film_series
GROUP BY series_name
ORDER BY total_revenue DESC;

-- Question 27: Most variable paying customers (standard deviation + aggregation).
WITH variable_paying_customers AS (
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name,
	ROUND(STDDEV(p.amount), 2) AS stddev_payment
FROM customer AS c
JOIN payment AS p ON p.customer_id = c.customer_id
GROUP BY c.customer_id, full_name
)
SELECT customer_id, full_name, stddev_payment
FROM variable_paying_customers
ORDER BY stddev_payment

-- Question 28: Find each actor's most frequent acting partner.
WITH RECURSIVE actor_chain AS (
    -- Base case
    SELECT a1.actor_id AS actor_start,
           a2.actor_id AS actor_next,
           a1.first_name || ' ' || a1.last_name || ' → ' || a2.first_name || ' ' || a2.last_name AS chain
    FROM actor a1
    JOIN film_actor fa1 ON a1.actor_id = fa1.actor_id
    JOIN film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id <> fa2.actor_id
    JOIN actor a2 ON fa2.actor_id = a2.actor_id

    UNION ALL

    -- Recursive step
    SELECT ac.actor_start,
           fa2.actor_id,
           ac.chain || ' → ' || a2.first_name || ' ' || a2.last_name
    FROM actor_chain ac
    JOIN film_actor fa1 ON ac.actor_next = fa1.actor_id
    JOIN film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id <> fa2.actor_id
    JOIN actor a2 ON fa2.actor_id = a2.actor_id
    WHERE ac.chain NOT LIKE '%' || a2.actor_id || '%'
)
SELECT * FROM actor_chain
LIMIT 20;

-- Question 29: Find the actors each actor starred in.

WITH RECURSIVE actor_chain AS (
SELECT
	fa1.actor_id AS actor_a_id,
	a1.first_name || ' ' || a1.last_name AS actor_a_name,
	a2.actor_id AS actor_b_id,
	a2.first_name || ' ' || a2.last_name AS actor_b_name,
	f.title,
	1 AS depth
FROM film_actor AS fa1
JOIN film_actor AS fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id <> fa2.actor_id
JOIN film AS f ON f.film_id = fa1.film_id
JOIN actor AS a1 ON a1.actor_id = fa1.actor_id
JOIN actor AS a2 ON a2.actor_id = fa2.actor_id

UNION ALL
SELECT
	c.actor_a_id,
	c.actor_a_name,
	a2.actor_id AS actor_b_id,
	a2.first_name || ' ' || a2.last_name AS actor_b_name,
	f.title,
	c.depth + 1
FROM actor_chain AS c
JOIN film_actor AS fa1 ON fa1.actor_id = c.actor_b_id
JOIN film_actor AS fa2 ON fa1.film_id = fa2.film_id AND fa2.actor_id <> fa1.actor_id
JOIN film AS f ON f.film_id = fa1.film_id
JOIN actor AS a2 ON a2.actor_id = fa2.actor_id
WHERE c.depth < 3
)
SELECT * FROM actor_chain
LIMIT 500;





SELECT * FROM customer
SELECT * FROM rental
SELECT * FROM payment
SELECT * FROM film
SELECT * FROM category
SELECT * FROM film_category
SELECT * FROM city
SELECT * FROM store
SELECT * FROM address
SELECT * FROM actor
SELECT * FROM film_actor
SELECT * FROM inventory
SELECT * FROM staff
