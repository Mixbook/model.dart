## Description

Simple implementation of 'Model'.
Supports retrieving and persisting data to the server.

## Single model example

E.g. we have a model - Post

```dart
class PostConnector extends ModelConnector {
  PostConnector() {
    var request = new Request("localhost", 3000, "http", "/path/to");
    this.storage = new RestfulStorage(request, "post", "posts", buildModel);
  }

  Post buildModel(Params params) => new Post(storage, params);
}

class Post extends Model {
  static PostConnector connector = new PostConnector();
  Post(Storage storage, [Params params]) : super(storage, params);
}

main() {
  Post.connector.find(123).then((post) {
    // Do whatever you want with 'post'
  });
}
```

It will make the following request to the server:

* ```new PostConnector().find(123)``` - GET http://localhost:3000/path/to/posts/123
* (new, no "id") ```post.save()``` - POST http://localhost:3000/path/to/posts, with params: {"post": {"name": "some name", ...}}
* (upd, with "id") ```post.save()``` - PUT http://localhost:3000/path/to/posts/123, with params: {"post": {"name": "some name", ...}}
* ```post.delete()``` - DELETE http://localhost:3000/path/to/posts/123

## With has-many associations example

Post has many comments:

```dart
// post.dart
class PostConnector extends ModelConnector<Post> {
  PostConnector() {
    var request = new Request("localhost", 3000, "http", "/path/to");
    this.storage = new RestfulStorage(request, "post", "posts", buildModel);
  }
  Post buildModel(Params params) => new Post(storage, params);
}

class Post extends Model {
  CommentAssociation comments;
  static PostConnector connector = new PostConnector();
  Post(Storage storage, [Params params]) : super(storage, params) {
    comments = new CommentAssociation(this);
    comments.load(attributes["comments"]);
  }
}

// comment.dart
class CommentAssociation extends ModelAssociation<Post, Comment> {
  CommentAssociation(parent) : super(parent);
  CommentConnector buildConnector() => new CommentConnector(parent);
}

class CommentConnector extends ModelConnector<Comment> {
  Post post;
  CommentConnector(this.post) {
    this.request = new Request("localhost", 3000, "http", "/path/to/posts/${post.id}");
    this.storage = new RestfulStorage(request, "comment", "comments", buildModel);
  }
  Comment buildModel(Params params) => new Comment(storage, post, params);
}

class Comment extends Model {
  Post post;
  Comment(Storage storage, Post post, [Params params]) : super(storage, params), this.post = post;
}

// main.dart
main() {
  Post.connector.find(123).then((post) {
    post.comments.forEach((comment) {
      // Do whatever you want with 'comment'
    });
  });

  // Or you could do:
  Post.connector.find(123).then((post) {
    post.comments[0].isLoaded // => false
    post.comments[0].load().then((result) {
      post.comments[0].isLoaded // => true
      post.comments[0].attributes // => {"id": 213, "name": "blabla", ...}
    });
  });

  // Or you can load all of them:
  Post.connector.find(123).then((post) {
    post.comments.load().then((result) {
      post.comments[0].isLoaded // => true
    });
  });
}
```
