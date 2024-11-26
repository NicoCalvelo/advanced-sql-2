
-- Table: users
SELECT setval(pg_get_serial_sequence('users', 'user_id'), MAX(user_id)) FROM users;

-- Table: posts
SELECT setval(pg_get_serial_sequence('posts', 'post_id'), MAX(post_id)) FROM posts;

-- Table: comments
SELECT setval(pg_get_serial_sequence('comments', 'comment_id'), MAX(comment_id)) FROM comments;

-- Table: likes
SELECT setval(pg_get_serial_sequence('likes', 'like_id'), MAX(like_id)) FROM likes;

-- Table: user_tags
SELECT setval(pg_get_serial_sequence('user_tags', 'tag_id'), MAX(tag_id)) FROM user_tags;

-- Table: post_views
SELECT setval(pg_get_serial_sequence('post_views', 'view_id'), MAX(view_id)) FROM post_views;
