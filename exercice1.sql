-- 1- Obtenez une liste de toutes les locations qui sont sorties (n'ont pas été rendues). Comment identifier ces films dans la base de données ?
SELECT * FROM rental WHERE return_date IS NULL;

-- 2- Obtenez une liste de tous les clients qui n'ont pas rendu leurs locations. Assurez-vous de grouper vos résultats.
SELECT customer.first_name, customer.last_name, COUNT(*) as num_rentals_not_returned
FROM rental
JOIN customer ON rental.customer_id = customer.customer_id
WHERE rental.return_date IS NULL
GROUP BY customer.customer_id;

-- 3- Obtenez une liste de tous les films d'action avec Joe Swank.
SELECT film.title
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE film.rating = 'R' AND actor.first_name = 'Joe' AND actor.last_name = 'Swank' AND film.special_features LIKE '%Action%';

-- Avant de commencer, existe-t-il un raccourci pour obtenir ces informations ? Peut-être une vue ?
-- OUI
CREATE VIEW joe_swank_movies AS
SELECT film.title
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE actor.first_name = 'Joe' AND actor.last_name = 'Swank';

SELECT title FROM joe_swank_movies WHERE special_features LIKE '%Action%';

