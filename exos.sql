-- docker exec -it social_network_db psql -U postgres -d social_network

-- Exercice 1 : Utilisation des CTE et sous-requêtes
SELECT
    u.username,
    p.post_id,
    c.comment_id
FROM
    posts as p
INNER JOIN comments as c ON c.post_id = p.post_id
INNER JOIN users as u ON p.user_id = u.user_id
WHERE
    c.user_id = p.user_id;

-- Exercice 2 : Fonctions Fenêtres (5 points)
WITH post_likes as (
    SELECT p.post_id, COUNT(l.like_id) as likes
    FROM posts as p
    INNER JOIN likes as l ON l.post_id = p.post_id
    GROUP BY p.post_id
)
SELECT
    u.username,
    SUM(pl.likes) as total_likes,
    RANK() OVER (ORDER BY SUM(pl.likes) DESC) as rank
FROM
    users as u
INNER JOIN posts as p ON p.user_id = u.user_id
INNER JOIN post_likes as pl ON pl.post_id = p.post_id
GROUP BY u.username
LIMIT 10;

-- Exercice 3 : GROUPING SETS, ROLLUP, CUBE (5 points)
SELECT 
    u.user_id,
    CASE
        WHEN p.user_id IS NOT NULL THEN 'Post'
        WHEN c.user_id IS NOT NULL THEN 'Comment'
        ELSE NULL
    END as content_type,
    CASE
        WHEN p.user_id IS NOT NULL THEN Count(Distinct p.post_id)
        WHEN c.user_id IS NOT NULL THEN Count(Distinct c.comment_id)
        ELSE Count(Distinct p.post_id) + Count(Distinct c.comment_id)
    END  as total_count
FROM users as u
LEFT JOIN posts as p ON p.user_id = u.user_id
LEFT JOIN comments as c ON c.user_id = u.user_id
GROUP BY GROUPING SETS ((u.user_id, p.user_id), (u.user_id, c.user_id), (u.user_id), ())
ORDER BY u.user_id, content_type;


-- Exercice 4 : Triggers ou Procédures Stockées (4 points)
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION notify_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, message)
    VALUES (NEW.tagged_user_id, 'Vous avez été tagué dans un post');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tag_notification
AFTER INSERT ON user_tags
FOR EACH ROW
EXECUTE FUNCTION notify_user();

-- test
INSERT INTO user_tags (post_id, tagged_user_id, tagged_by_user_id) VALUES (1, 2, 1);

-- Exercice Bonus : Optimisation avec Index et EXPLAIN
SELECT p.post_id, p.content, u.username
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.created_at >= NOW() - INTERVAL '7 days'
ORDER BY p.created_at DESC;

-- Avant optimisation
-- QUERY PLAN                                                       
-- ------------------------------------------------------------------------------------------------------------------------
--  Sort  (cost=20.37..20.62 rows=100 width=293) (actual time=0.428..0.436 rows=100 loops=1)
--    Sort Key: p.created_at DESC
--    Sort Method: quicksort  Memory: 47kB
--    ->  Hash Join  (cost=12.03..17.05 rows=100 width=293) (actual time=0.220..0.310 rows=100 loops=1)
--          Hash Cond: (p.user_id = u.user_id)
--          ->  Seq Scan on posts p  (cost=0.00..4.75 rows=100 width=179) (actual time=0.055..0.118 rows=100 loops=1)
--                Filter: (created_at >= (now() - '7 days'::interval))
--          ->  Hash  (cost=10.90..10.90 rows=90 width=122) (actual time=0.085..0.085 rows=50 loops=1)
--                Buckets: 1024  Batches: 1  Memory Usage: 11kB
--                ->  Seq Scan on users u  (cost=0.00..10.90 rows=90 width=122) (actual time=0.030..0.038 rows=50 loops=1)
--  Planning Time: 1.445 ms
--  Execution Time: 0.636 ms
-- (12 rows)

-- On crée un index sur la colonne created_at de la table posts
CREATE INDEX posts_created_at_idx ON posts(created_at);
-- On crée un index sur la colonne user_id de la table posts
CREATE INDEX posts_user_id_idx ON posts(user_id);

-- Après optimisation
-- QUERY PLAN                                                       
-- ------------------------------------------------------------------------------------------------------------------------
--  Sort  (cost=20.37..20.62 rows=100 width=293) (actual time=0.306..0.322 rows=100 loops=1)
--    Sort Key: p.created_at DESC
--    Sort Method: quicksort  Memory: 47kB
--    ->  Hash Join  (cost=12.03..17.05 rows=100 width=293) (actual time=0.070..0.215 rows=100 loops=1)
--          Hash Cond: (p.user_id = u.user_id)
--          ->  Seq Scan on posts p  (cost=0.00..4.75 rows=100 width=179) (actual time=0.019..0.114 rows=100 loops=1)
--                Filter: (created_at >= (now() - '7 days'::interval))
--          ->  Hash  (cost=10.90..10.90 rows=90 width=122) (actual time=0.030..0.031 rows=50 loops=1)
--                Buckets: 1024  Batches: 1  Memory Usage: 11kB
--                ->  Seq Scan on users u  (cost=0.00..10.90 rows=90 width=122) (actual time=0.006..0.013 rows=50 loops=1)
--  Planning Time: 1.141 ms
--  Execution Time: 0.423 ms
-- (12 rows)

-- On voit des améliorations dans le temps d'exécution