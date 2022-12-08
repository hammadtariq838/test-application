const pool = require("../db");

module.exports.index = async (req, res) => {
    const posts = await pool.query("SELECT * FROM posts");
    res.render("posts/index", { posts: posts.rows });
}

module.exports.renderNewForm = (req, res) => {
    res.render("posts/new");
}

module.exports.createPost = async (req, res) => {
    if (!req.body.post) throw new ExpressError("Invalid post Data", 400);
    const { title, body } = req.body.post;
    const member_id = "86638b5b-e2e2-4c13-bd14-6633267ad301";
    const newPost = await pool.query(
        "INSERT INTO posts (title, body, member_id) VALUES ($1, $2, $3) RETURNING *",
        [title, body, member_id]
    );
    res.redirect(`/posts/${newPost.rows[0].id}`);
}

module.exports.showPost = async (req, res) => {
    const id = req.params.id;
    const post = await pool.query("SELECT * FROM posts WHERE id = $1", [id]);
    res.render("posts/show", { post: post.rows[0] });
}

module.exports.renderEditForm = async (req, res) => {
    const { id } = req.params;
    const post = await pool.query("SELECT * FROM posts WHERE id = $1", [id]);
    res.render("posts/edit", { post: post.rows[0] });
}

module.exports.updatePost = async (req, res) => {
    const { id } = req.params;
    const { title, body } = req.body.post;
    const updatedPost = await pool.query(
        "UPDATE posts SET title = $1, body = $2 WHERE id = $3 RETURNING *",
        [title, body, id]
    );
    res.redirect(`/posts/${updatedPost.rows[0].id}`);
}


module.exports.deletePost = async (req, res) => {
    const { id } = req.params;
    await pool.query("DELETE FROM posts WHERE id = $1", [id]);
    res.redirect("/posts");
}