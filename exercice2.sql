-- 1- Combien y a-t-il de magasins, et dans quelle ville et dans quel pays ils se trouvent.
SELECT COUNT(*) AS store_count, city, country FROM store GROUP BY city, country;

--2- Combien d'heures de temps de visionnage il y a au total dans chaque magasin - en d'autres termes, la somme de la durée de chaque article d'inventaire dans chaque magasin.
SELECT SUM(inventory.length) AS total_hours, store.store_id FROM inventory 
JOIN store ON inventory.store_id = store.store_id 
LEFT JOIN rental ON inventory.inventory_id = rental.inventory_id AND rental.return_date IS NULL
WHERE rental.rental_id IS NULL
GROUP BY store.store_id;

-- 3- Assurez-vous d'exclure tous les articles en stock qui ne sont pas encore retournés. (Oui, même au temps des zombies il y a des gens qui ne rendent pas leurs DVD)
SELECT 
  store.store_id, 
  store.city, 
  store.country, 
  SUM(inventory.length) as total_viewing_time_minutes, 
  SUM(inventory.length) / 60 as total_viewing_time_hours, 
  SUM(inventory.length) / (60 * 24) as total_viewing_time_days
FROM 
  store 
  JOIN inventory ON store.store_id = inventory.store_id 
  JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE 
  rental.return_date IS NOT NULL
GROUP BY 
  store.store_id;



-- 4- Une liste de tous les clients dans les villes où se trouvent les magasins.
SELECT customer.first_name, customer.last_name, customer.email, city, country FROM customer 
JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id 
JOIN country ON city.country_id = country.country_id 
WHERE city IN (SELECT DISTINCT city FROM store);

-- 5- Une liste de tous les clients dans les pays où les magasins sont situés
SELECT customer.first_name, customer.last_name, customer.email, country FROM customer 
JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id 
JOIN country ON city.country_id = country.country_id 
WHERE country IN (SELECT DISTINCT country FROM store);

-- 6- Certaines personnes seront effrayées en regardant des films effrayants pendant que des zombies marchent dans les rues
CREATE VIEW safe_movies AS
SELECT * FROM film WHERE 
    category_id != (SELECT category_id FROM category WHERE name = 'Horror') AND 
    (
        LOWER(description) NOT LIKE '%beast%' AND 
        LOWER(description) NOT LIKE '%monster%' AND 
        LOWER(description) NOT LIKE '%ghost%' AND 
        LOWER(description) NOT LIKE '%dead%' AND 
        LOWER(description) NOT LIKE '%zombie%' AND 
        LOWER(description) NOT LIKE '%undead%' AND 
        LOWER(title) NOT LIKE '%beast%' AND 
        LOWER(title) NOT LIKE '%monster%' AND 
        LOWER(title) NOT LIKE '%ghost%' AND 
        LOWER(title) NOT LIKE '%dead%' AND 
        LOWER(title) NOT LIKE '%zombie%' AND 
        LOWER(title) NOT LIKE '%undead%'
    );
-- Obtenez la somme de leur temps de visionnage 
SELECT SUM(length) AS total_hours FROM inventory 
JOIN film ON inventory.film_id = film.film_id 
JOIN safe_movies ON film.film_id = safe_movies.film_id 
GROUP BY inventory.store_id;


-- 7- Pour les listes « générales » et « sûres » ci-dessus, calculez également le temps en heures et en jours (pas seulement en minutes).
-- Liste générale
SELECT 
    SUM(EXTRACT(MINUTE FROM length)) / 60.0 AS total_hours, 
    SUM(EXTRACT(MINUTE FROM length)) / (60.0 * 24) AS total_days
FROM inventory 
WHERE NOT EXISTS (
    SELECT * 
    FROM rental 
    WHERE inventory.inventory_id = rental.inventory_id 
        AND rental.return_date IS NULL
) 
    AND rating IN ('G', 'PG', 'PG-13', 'R')
-- Liste sûre
SELECT 
    SUM(EXTRACT(MINUTE FROM length)) / 60.0 AS total_hours, 
    SUM(EXTRACT(MINUTE FROM length)) / (60.0 * 24) AS total_days
FROM inventory 
WHERE NOT EXISTS (
    SELECT * 
    FROM rental 
    WHERE inventory.inventory_id = rental.inventory_id 
        AND rental.return_date IS NULL
) 
    AND rating IN ('G', 'PG', 'PG-13', 'R')
    AND (
        category != 'Horror' 
        AND (
            title NOT ILIKE '%beast%' 
            AND title NOT ILIKE '%monster%' 
            AND title NOT ILIKE '%ghost%' 
            AND title NOT ILIKE '%dead%' 
            AND title NOT ILIKE '%zombie%' 
            AND title NOT ILIKE '%undead%' 
            AND description NOT ILIKE '%beast%' 
            AND description NOT ILIKE '%monster%' 
            AND description NOT ILIKE '%ghost%' 
            AND description NOT ILIKE '%dead%' 
            AND description NOT ILIKE '%zombie%' 
            AND description NOT ILIKE '%undead%'
        )
    )

