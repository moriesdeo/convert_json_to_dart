class User {
  final int id;
  final String name;
  final String email;
  final Settings settings;
  final List<Post> posts;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.settings,
    required this.posts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      settings: Settings.fromJson(json['settings']),
      posts: (json['posts'] as List).map((post) => Post.fromJson(post)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'settings': settings.toJson(),
      'posts': posts.map((post) => post.toJson()).toList(),
    };
  }
}

class Settings {
  final bool notifications;
  final String theme;
  final Privacy privacy;

  Settings({
    required this.notifications,
    required this.theme,
    required this.privacy,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      notifications: json['notifications'],
      theme: json['theme'],
      privacy: Privacy.fromJson(json['privacy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'theme': theme,
      'privacy': privacy.toJson(),
    };
  }
}

class Privacy {
  final String profileVisibility;
  final bool locationSharing;

  Privacy({
    required this.profileVisibility,
    required this.locationSharing,
  });

  factory Privacy.fromJson(Map<String, dynamic> json) {
    return Privacy(
      profileVisibility: json['profileVisibility'],
      locationSharing: json['locationSharing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileVisibility': profileVisibility,
      'locationSharing': locationSharing,
    };
  }
}

class Post {
  final int id;
  final String title;
  final String content;
  final List<String> tags;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags']),
      comments: (json['comments'] as List).map((comment) => Comment.fromJson(comment)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}

class Comment {
  final int id;
  final String author;
  final String content;

  Comment({
    required this.id,
    required this.author,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      author: json['author'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'content': content,
    };
  }
}

class Metadata {
  final String timestamp;
  final String requestId;
  final Source source;

  Metadata({
    required this.timestamp,
    required this.requestId,
    required this.source,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      timestamp: json['timestamp'],
      requestId: json['requestId'],
      source: Source.fromJson(json['source']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'requestId': requestId,
      'source': source.toJson(),
    };
  }
}

class Source {
  final String app;
  final String version;

  Source({
    required this.app,
    required this.version,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      app: json['app'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app': app,
      'version': version,
    };
  }
}
