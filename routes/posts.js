const express = require("express");
const router = express.Router();
const catchAsync = require("../utils/catchAsync");
const posts = require('../controllers/posts');

router.route("/")
    .get(catchAsync(posts.index))
    .post(catchAsync(posts.createPost));

router.get("/new", posts.renderNewForm);

router.route("/:id")
    .get(catchAsync(posts.showPost))
    .put(catchAsync(posts.updatePost))
    .delete(catchAsync(posts.deletePost));
    
router.get("/:id/edit", catchAsync(posts.renderEditForm));

module.exports = router;