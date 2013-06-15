## Description

Simple implementation of 'Model'.
Supports retrieving and persisting data to the server.

Example:
E.g. we have a model - Post

```dart
class PostFactory extends ModelFactory {
  PostFactory() {
    var request = new Request("localhost", 3000, "http", "/path/to");
    this.storage = new RestfulStorage(request, "post", "posts", (params) {
      return new Post(storage, params);
    });
  }
}

class Post extends Model {
  Post(Storage storage, [Params params]) : super(storage, params);
}

main() {
  new PostFactory().find(123).then((post) {
    // Do whatever you want with 'post'
  });
}
```

It will make the following request to the server:

* ```new PostFactory().find(123)``` - GET http://localhost:3000/path/to/posts/123
* (new, no "id") ```post.save()``` - POST http://localhost:3000/path/to/posts, with params: {"post": {"name": "some name", ...}}
* (upd, with "id") ```post.save()``` - PUT http://localhost:3000/path/to/posts/123, with params: {"post": {"name": "some name", ...}}
* ```post.delete()``` - DELETE http://localhost:3000/path/to/posts/123
