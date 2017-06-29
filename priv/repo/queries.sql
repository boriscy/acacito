SELECT full_name, status, ST_AsText(pos), orders FROM user_transports;

SELECT u0."id", u0."email", u0."full_name", u0."encrypted_password", u0."locale", u0."settings",
 u0."extra_data", u0."mobile_number", u0."plate", u0."pos", u0."status", u0."vehicle", u0."orders",
  u0."verified", u0."inserted_at", u0."updated_at"
  FROM "user_transports" AS u0
  WHERE ((u0."status" = 'listen') AND ST_DISTANCE_SPHERE(u0."pos", ST_MakePoint(-63.16683769226075, -17.808713451622758)) <= 2000)


-- Calculate the rating for organizations from clients
WITH ratings AS (
 SELECT to_id, AVG(rating) as rating, COUNT(*) AS total, comment_type
 FROM comments GROUP BY to_id, comment_type HAVING comment_type='cli_org'
)
SELECT o.name, ratings.rating, o.id, ratings.total
FROM organizations o join ratings ON ratings.to_id=o.id;

-- update organizations
WITH ratings AS (
 SELECT to_id, AVG(rating) as rate, COUNT(*) AS total, comment_type
 FROM comments GROUP BY to_id, comment_type HAVING comment_type='cli_org'
)
UPDATE organizations SET rating = ratings.rate, rating_count = ratings.total
FROM ratings WHERE ratings.to_id = id;
