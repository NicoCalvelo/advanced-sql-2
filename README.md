
# Explication du Schéma de Base de Données

Voici le schéma des tables utilisées pour l'évaluation :

### Table `users`
- **user_id** (SERIAL PRIMARY KEY) : Identifiant unique de l'utilisateur.
- **username** (VARCHAR) : Nom unique de l'utilisateur.
- **email** (VARCHAR) : Email unique de l'utilisateur.
- **password** (VARCHAR) : Mot de passe de l'utilisateur.
- **created_at** (TIMESTAMP) : Date de création de l'utilisateur.

### Table `posts`
- **post_id** (SERIAL PRIMARY KEY) : Identifiant unique du post.
- **user_id** (INTEGER) : Référence à l'utilisateur ayant créé le post.
- **content** (TEXT) : Contenu du post.
- **created_at** (TIMESTAMP) : Date de création du post.

### Table `comments`
- **comment_id** (SERIAL PRIMARY KEY) : Identifiant unique du commentaire.
- **post_id** (INTEGER) : Référence au post commenté.
- **user_id** (INTEGER) : Référence à l'utilisateur ayant fait le commentaire.
- **parent_comment_id** (INTEGER) : Référence au commentaire parent, pour les réponses.
- **content** (TEXT) : Contenu du commentaire.
- **created_at** (TIMESTAMP) : Date de création du commentaire.

### Table `likes`
- **like_id** (SERIAL PRIMARY KEY) : Identifiant unique du "like".
- **user_id** (INTEGER) : Référence à l'utilisateur ayant aimé.
- **post_id** (INTEGER) : Référence au post aimé (ou `NULL` si commentaire).
- **comment_id** (INTEGER) : Référence au commentaire aimé (ou `NULL` si post).
- **created_at** (TIMESTAMP) : Date du "like".
- **CHECK** : Soit `post_id` est renseigné, soit `comment_id`.

### Table `user_tags`
- **tag_id** (SERIAL PRIMARY KEY) : Identifiant unique de la mention.
- **post_id** (INTEGER) : Référence au post contenant la mention.
- **tagged_user_id** (INTEGER) : Référence à l'utilisateur mentionné.
- **tagged_by_user_id** (INTEGER) : Référence à l'utilisateur ayant fait la mention.
- **created_at** (TIMESTAMP) : Date de la mention.

### Table `post_views`
- **view_id** (SERIAL PRIMARY KEY) : Identifiant unique de la vue.
- **post_id** (INTEGER) : Référence au post vu.
- **user_id** (INTEGER) : Référence à l'utilisateur ayant vu le post.
- **viewed_at** (TIMESTAMP) : Date de la vue.

---

# Énoncé des Exercices

## Exercice 1 : Utilisation des CTE et sous-requêtes (6 points)
Trouvez les utilisateurs qui ont commenté leurs propres posts. Affichez les colonnes :
- `username` : le nom d'utilisateur
- `post_id` : l'ID du post commenté
- `comment_id` : l'ID du commentaire

## Exercice 2 : Fonctions Fenêtres (5 points)
Trouvez les trois utilisateurs les plus actifs en termes de nombre total de likes reçus sur leurs posts. Affichez :
- `username` : le nom d'utilisateur
- `total_likes` : le nombre total de likes reçus
- `rank` : le rang de l'utilisateur basé sur le nombre de likes.

## Exercice 3 : GROUPING SETS, ROLLUP, CUBE (5 points)
Calculez le nombre total de posts et de commentaires créés par chaque utilisateur. Affichez :
- `user_id` : l'ID de l'utilisateur (peut être `NULL` pour les totaux globaux)
- `content_type` : 'Post', 'Comment' ou `NULL` pour les totaux globaux
- `total_count` : le nombre total de contenus créés pour ce groupe.

## Exercice 4 : Triggers ou Procédures Stockées (4 points)
Créez un trigger qui, à chaque fois qu'un utilisateur est tagué dans un post, insère une notification dans une table `notifications`.
La table `notifications` doit contenir les colonnes suivantes :

`notification_id` : clé primaire
`user_id` : l'ID de l'utilisateur qui reçoit la notification
`message` : le contenu de la notification
`created_at` : la date et l'heure de la notification

## Exercice Bonus : Optimisation avec Index et EXPLAIN
Analysez et optimisez cette requête lente en ajoutant un index ou en optimisant cette requête.
Montrez les plans d'exécution avant et après optimisation.
<pre>
SELECT p.post_id, p.content, u.username
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.created_at >= NOW() - INTERVAL '7 days'
ORDER BY p.created_at DESC;
</pre>
