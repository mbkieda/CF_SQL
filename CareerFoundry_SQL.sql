/*
Query 1:  Find the top 10 countries for Rockbuster in terms
of customer numbers.
*/
SELECT o.country, COUNT(c.customer_id) AS number_of_customers
FROM customer c
LEFT JOIN address a ON a.address_id = c.address_id
LEFT JOIN city i ON i.city_id = a.city_id
LEFT JOIN country o ON o.country_id = i.country_id
GROUP BY o.country
ORDER BY number_of_customers DESC
LIMIT 10

/*
Query 2:  Find the top 10 cities within the top 10 countries (from
Query 1) in term of customer numbers.
*/
SELECT o.country, i.city, COUNT(c.customer_id) AS number_of_customers
FROM customer c
LEFT JOIN address a ON a.address_id = c.address_id
LEFT JOIN city i ON i.city_id = a.city_id
LEFT JOIN country o ON o.country_id = i.country_id
GROUP BY o.country, i.city
ORDER BY number_of_customers DESC
LIMIT 10

/*
Query 4:  Find the top 5 customers in the top 10 cities who have paid
the highest total amounts to Rockbuster.
*/
WITH top10 AS
  (SELECT o.country,
    i.city,
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(c.customer_id) AS number_of_customers
  FROM customer c
  LEFT JOIN address a ON a.address_id = c.address_id
  LEFT JOIN city i ON i.city_id = a.city_id
  LEFT JOIN country o ON o.country_id = i.country_id
  GROUP BY o.country, i.city, customer_id, c.first_name, c.last_name
  ORDER by number_of_customers DESC
  LIMIT 10)

SELECT t.customer_id,
  t.first_name,
  t.last_name,
  t.country,
  t.city,
  SUM(p.amount) AS total_amount_paid
FROM top10 t
LEFT JOIN payment p ON p.customer_id = t.customer_id
GROUP by t.customer_id, t.first_name, t.last_name, t.country, t.city
ORDER BY total_amount_paid DESC
LIMIT 5

/*
Query 5:  Alternate solution for the above using subquery rather than CTE
*/
SELECT t10.customer_id,
  t10.first_name,
  t10.last_name,
  t10.country,
  t10.city,
  SUM(p.amount) AS total_amount_paid
FROM
  (SELECT o.country,
    i.city,
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(c.customer_id) AS number_of_customers
  FROM customer c
  LEFT JOIN address a ON a.address_id = c.address_id
  LEFT JOIN city i ON i.city_id = a.city_id
  LEFT JOIN country o ON o.country_id = i.country_id
  GROUP BY o.country, i.city, customer_id, c.first_name, c.last_name
  ORDER by number_of_customers DESC
  LIMIT 10) t10

LEFT JOIN payment p ON p.customer_id = t10.customer_id
GROUP by t10.customer_id, t10.first_name, t10.last_name, t10.country, t10.city
ORDER BY total_amount_paid DESC
LIMIT 5

/*
Query 6:  Find the average amount paid by the top 5 number_of_customers
*/
SELECT AVG(t5.total_amount_paid) AS average
FROM
  (SELECT t10.customer_id,
    t10.first_name,
    t10.last_name,
    t10.country,
    t10.city,
    SUM(p.amount) AS total_amount_paid
  FROM
    (SELECT o.country,
      i.city,
      c.customer_id,
      c.first_name,
      c.last_name,
      COUNT(c.customer_id) AS number_of_customers
    FROM customer c
    LEFT JOIN address a ON a.address_id = c.address_id
    LEFT JOIN city i ON i.city_id = a.city_id
    LEFT JOIN country o ON o.country_id = i.country_id
    GROUP BY o.country, i.city, customer_id, c.first_name, c.last_name
    LIMIT 10) AS top10

LEFT JOIN payment p ON p.customer_id = t10.customer_id
GROUP BY t10.customer_id, t10.first_name, t10.last_name, t10.country, t10.city_id
ORDER BY total_amount_paid DESC
LIMIT 5) as t5

/*
Query 7:  Find out how many of the top 5 customers are based within each country
*/
SELECT o.country,
  COUNT (DISTINCT c.customer_id) AS all_customer_count,
  COUNT (DISTINCT t5.customer_id) AS top_customer_count
FROM customer c
LEFT JOIN address a ON a.address_id = c.address_id
LEFT JOIN city i ON i.city_id = a.city_id
LEFT JOIN country o ON o.country_id = i.country_id
LEFT JOIN
  (SELECT t10.customer_id,
    t10.first_name,
    t10.last_name,
    t10.country,
    t10.city,
    SUM(p.amount) AS total_amount_paid
  FROM
    (SELECT o.country,
      i.city,
      c.customer_id,
      c.first_name,
      c.last_name,
      COUNT(c.customer_id) AS number_of_customers
    FROM customer c
    LEFT JOIN address a ON a.address_id = c.address_id
    LEFT JOIN city i ON i.city_id = a.city_id
    LEFT JOIN country o ON o.country_id = i.country_id
    GROUP BY o.country, i.city, customer_id, c.first_name, c.last_name
    LIMIT 10) AS t10
  LEFT JOIN payment p ON p.customer_id = t10.customer_id
  GROUP BY t10.customer_id, t10.first_name, t10.last_name, t10.country, t10.city
  ORDER BY total_amount_paid DESC
  LIMIT 5) AS t5

  ON o.country = t5.country
GROUP BY o.country_id
HAVING COUNT(DISTINCT t5.customer_id) > 0

/*
Query 8:  Rewrite Query 6 using CTEs
*/
WITH
t10 (country, city, customer_id, first_name, last_name, number_of_customers) AS
  (SELECT o.country,
    i.city,
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(c.customer_id) AS number_of_customers
  FROM customer c
  LEFT JOIN address a ON a.address_id = c.address_id
  LEFT JOIN city i ON i.city_id = a.city_id
  LEFT JOIN country o ON o.country_id = i.country_id
  GROUP BY o.country, i.city, customer_id, c.first_name, c.last_name
  LIMIT 10),

t5 (customer_id, first_name, last_name, country, city, total_amount_paid) AS
  (SELECT t10.customer_id,
    t10.first_name,
    t10.last_name,
    t10.country,
    t10.city,
    SUM(p.amount) AS total_amount_paid
  FROM t10
  LEFT JOIN payment p ON p.customer_id = t10.customer_id
  GROUP BY t10.customer_id, t10.first_name, t10.last_name, t10.country, t10.city_id
  ORDER BY total_amount_paid DESC
  LIMIT 5)

SELECT AVG(t5.total_amount_paid) AS average
FROM t5

/*
Query 9:  Rewrite Query 7 using CTEs
*/
WITH
t10 (country, city, customer_id, first_name, last_name, number_of_customers) AS
  (SELECT o.country,
    i.city,
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(c.customer_id) AS number_of_customers
  FROM customer c
  LEFT JOIN address a ON a.address_id = c.address_id
  LEFT JOIN city i ON i.city_id = a.city_id
  LEFT JOIN country o ON o.country_id = i.country_id
  GROUP BY o.country, i.city, customer_id, c.first_name, c.last_name
  LIMIT 10),

t5 (customer_id, first_name, last_name, country, city, total_amount_paid) AS
  (SELECT t10.customer_id,
    t10.first_name,
    t10.last_name,
    t10.country,
    t10.city,
    SUM(p.amount) AS total_amount_paid
  FROM t10
  LEFT JOIN payment p ON p.customer_id = t10.customer_id
  GROUP BY t10.customer_id, t10.first_name, t10.last_name, t10.country, t10.city_id
  ORDER BY total_amount_paid DESC
  LIMIT 5)

SELECT o.country,
  COUNT (DISTINCT c.customer_id) AS all_customer_count,
  COUNT (DISTINCT t5.customer_id) AS top_customer_count
FROM customer c
LEFT JOIN address a ON a.address_id = c.address_id
LEFT JOIN city i ON i.city_id = a.city_id
LEFT JOIN country o ON o.country_id = i.country_id
LEFT JOIN t5 ON o.country = t5.country
GROUP BY o.country
HAVING COUNT(DISTINCT t5.customer_id) > 0
