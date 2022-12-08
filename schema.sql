CREATE DATABASE ldf;

\c ldf;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    hashedpassword VARCHAR(60) NOT NULL,
    displayname VARCHAR(30) NOT NULL,
    picture TEXT,
    bio TEXT
);

CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT,
    picture TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS votes (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vote BOOLEAN NOT NULL,
    PRIMARY KEY (post_id, member_id)
);

CREATE TABLE IF NOT EXISTS roles (
    member_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    member_role INT NOT NULL,
    PRIMARY KEY (member_id)
);

CREATE TABLE IF NOT EXISTS bookmarks (
    member_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pinned (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE
);

CREATE VIEW popular AS 
    WITH votecount AS
        (SELECT post_id as id, count(post_id) FROM votes GROUP BY post_id)
    SELECT id, coalesce(count, 0) votes FROM posts NATURAL LEFT OUTER JOIN votecount;

CREATE INDEX IF NOT EXISTS post_id ON posts (id);
CREATE INDEX IF NOT EXISTS comment_post ON comments (post_id);
CREATE INDEX IF NOT EXISTS post_vote ON votes (post_id);
CREATE INDEX IF NOT EXISTS user_vote ON votes (member_id);
CREATE INDEX IF NOT EXISTS commenter ON comments (member_id);
CREATE INDEX IF NOT EXISTS bookmarker ON bookmarks (member_id);
CREATE INDEX IF NOT EXISTS comment_id ON comments (id);
CREATE INDEX IF NOT EXISTS post_time ON posts (created_at);
CREATE INDEX IF NOT EXISTS comment_parent ON comments (parent_id);