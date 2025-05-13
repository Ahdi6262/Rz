import 'package:json_annotation/json_annotation.dart';

part 'blog_post.g.dart';

@JsonSerializable()
class BlogPost {
  @JsonKey(name: '_id')
  final String? id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final List<String> tags;
  final bool published;
  final String? featuredImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlogPost({
    this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.tags,
    required this.published,
    this.featuredImage,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating BlogPost from JSON
  factory BlogPost.fromJson(Map<String, dynamic> json) => _$BlogPostFromJson(json);

  // Method for converting BlogPost to JSON
  Map<String, dynamic> toJson() => _$BlogPostToJson(this);

  // Create a copy of BlogPost with specified fields updated
  BlogPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    List<String>? tags,
    bool? published,
    String? featuredImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      published: published ?? this.published,
      featuredImage: featuredImage ?? this.featuredImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class BlogComment {
  @JsonKey(name: '_id')
  final String? id;
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlogComment({
    this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating BlogComment from JSON
  factory BlogComment.fromJson(Map<String, dynamic> json) => _$BlogCommentFromJson(json);

  // Method for converting BlogComment to JSON
  Map<String, dynamic> toJson() => _$BlogCommentToJson(this);
}

@JsonSerializable()
class CreateBlogPostRequest {
  final String title;
  final String content;
  final List<String> tags;
  final bool published;
  final String? featuredImage;

  CreateBlogPostRequest({
    required this.title,
    required this.content,
    required this.tags,
    required this.published,
    this.featuredImage,
  });

  // Factory constructor for creating CreateBlogPostRequest from JSON
  factory CreateBlogPostRequest.fromJson(Map<String, dynamic> json) => _$CreateBlogPostRequestFromJson(json);

  // Method for converting CreateBlogPostRequest to JSON
  Map<String, dynamic> toJson() => _$CreateBlogPostRequestToJson(this);
}

@JsonSerializable()
class UpdateBlogPostRequest {
  final String? title;
  final String? content;
  final List<String>? tags;
  final bool? published;
  final String? featuredImage;

  UpdateBlogPostRequest({
    this.title,
    this.content,
    this.tags,
    this.published,
    this.featuredImage,
  });

  // Factory constructor for creating UpdateBlogPostRequest from JSON
  factory UpdateBlogPostRequest.fromJson(Map<String, dynamic> json) => _$UpdateBlogPostRequestFromJson(json);

  // Method for converting UpdateBlogPostRequest to JSON
  Map<String, dynamic> toJson() => _$UpdateBlogPostRequestToJson(this);
}

@JsonSerializable()
class CreateCommentRequest {
  final String content;

  CreateCommentRequest({
    required this.content,
  });

  // Factory constructor for creating CreateCommentRequest from JSON
  factory CreateCommentRequest.fromJson(Map<String, dynamic> json) => _$CreateCommentRequestFromJson(json);

  // Method for converting CreateCommentRequest to JSON
  Map<String, dynamic> toJson() => _$CreateCommentRequestToJson(this);
}
