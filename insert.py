import psycopg2
from psycopg2.extras import execute_values
from faker import Faker
import random

def create_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="social_network",
        user="postgres",
        password="postgres"
    )
    return conn

def populate_users(conn, num_users=50):
    fake = Faker()
    users = []
    for _ in range(num_users):
        username = fake.unique.user_name()
        email = fake.unique.email()
        password = fake.password(length=12)
        users.append((username, email, password))
    with conn.cursor() as cur:
        execute_values(cur, """
            INSERT INTO users (username, email, password)
            VALUES %s
            ON CONFLICT DO NOTHING
        """, users)
    conn.commit()
    print(f"{num_users} utilisateurs insérés.")

def populate_posts(conn, num_posts=100):
    fake = Faker()
    posts = []
    with conn.cursor() as cur:
        cur.execute("SELECT user_id FROM users")
        user_ids = [row[0] for row in cur.fetchall()]
    for _ in range(num_posts):
        user_id = random.choice(user_ids)
        content = fake.paragraph(nb_sentences=5)
        posts.append((user_id, content))
    with conn.cursor() as cur:
        execute_values(cur, """
            INSERT INTO posts (user_id, content)
            VALUES %s
        """, posts)
    conn.commit()
    print(f"{num_posts} posts insérés.")

def populate_comments(conn, num_comments=200):
    fake = Faker()
    comments = []
    with conn.cursor() as cur:
        cur.execute("SELECT post_id FROM posts")
        post_ids = [row[0] for row in cur.fetchall()]
        cur.execute("SELECT comment_id FROM comments")
        comment_ids = [row[0] for row in cur.fetchall()]
        cur.execute("SELECT user_id FROM users")
        user_ids = [row[0] for row in cur.fetchall()]
    for _ in range(num_comments):
        post_id = random.choice(post_ids)
        user_id = random.choice(user_ids)
        parent_comment_id = random.choice(comment_ids) if comment_ids and random.random() > 0.5 else None
        content = fake.sentence(nb_words=10)
        comments.append((post_id, user_id, parent_comment_id, content))
    with conn.cursor() as cur:
        execute_values(cur, """
            INSERT INTO comments (post_id, user_id, parent_comment_id, content)
            VALUES %s
        """, comments)
    conn.commit()
    print(f"{num_comments} commentaires insérés.")

def populate_likes(conn, num_likes=300):
    likes = []
    with conn.cursor() as cur:
        cur.execute("SELECT user_id FROM users")
        user_ids = [row[0] for row in cur.fetchall()]
        cur.execute("SELECT post_id FROM posts")
        post_ids = [row[0] for row in cur.fetchall()]
        cur.execute("SELECT comment_id FROM comments")
        comment_ids = [row[0] for row in cur.fetchall()]
    for _ in range(num_likes):
        user_id = random.choice(user_ids)
        if random.random() > 0.5:
            # Like sur un post
            post_id = random.choice(post_ids)
            comment_id = None
        else:
            # Like sur un commentaire
            post_id = None
            comment_id = random.choice(comment_ids)
        likes.append((user_id, post_id, comment_id))
    with conn.cursor() as cur:
        execute_values(cur, """
            INSERT INTO likes (user_id, post_id, comment_id)
            VALUES %s
            ON CONFLICT DO NOTHING
        """, likes)
    conn.commit()
    print(f"{num_likes} likes insérés.")

def populate_user_tags(conn, num_tags=50):
    user_tags = []
    with conn.cursor() as cur:
        cur.execute("SELECT post_id FROM posts")
        post_ids = [row[0] for row in cur.fetchall()]
        cur.execute("SELECT user_id FROM users")
        user_ids = [row[0] for row in cur.fetchall()]
    for _ in range(num_tags):
        post_id = random.choice(post_ids)
        tagged_user_id = random.choice(user_ids)
        tagged_by_user_id = random.choice([uid for uid in user_ids if uid != tagged_user_id])
        user_tags.append((post_id, tagged_user_id, tagged_by_user_id))
    with conn.cursor() as cur:
        execute_values(cur, """
            INSERT INTO user_tags (post_id, tagged_user_id, tagged_by_user_id)
            VALUES %s
        """, user_tags)
    conn.commit()
    print(f"{num_tags} tags d'utilisateurs insérés.")

# **Nouvelle fonction : populate_post_views**
def populate_post_views(conn, num_views=500):
    post_views = []
    fake = Faker()
    with conn.cursor() as cur:
        cur.execute("SELECT post_id FROM posts")
        post_ids = [row[0] for row in cur.fetchall()]
        cur.execute("SELECT user_id FROM users")
        user_ids = [row[0] for row in cur.fetchall()]
    for _ in range(num_views):
        post_id = random.choice(post_ids)
        user_id = random.choice(user_ids)
        viewed_at = fake.date_time_between(start_date='-1y', end_date='now')
        post_views.append((post_id, user_id, viewed_at))
    with conn.cursor() as cur:
        execute_values(cur, """
            INSERT INTO post_views (post_id, user_id, viewed_at)
            VALUES %s
        """, post_views)
    conn.commit()
    print(f"{num_views} vues de posts insérées.")

def main():
    conn = create_connection()
    try:
        populate_users(conn)
        populate_posts(conn)
        populate_comments(conn)
        populate_likes(conn)
        populate_user_tags(conn)
        populate_post_views(conn)  # **Appel à la nouvelle fonction**
    except Exception as e:
        print(f"Une erreur s'est produite : {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    main()
