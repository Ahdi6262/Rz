// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogPost _$BlogPostFromJson(Map<String, dynamic> json) => BlogPost(
      id: json['_id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      published: json['published'] as bool,
      featuredImage: json['featuredImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BlogPostToJson(BlogPost instance) => <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'tags': instance.tags,
      'published': instance.published,
      'featuredImage': instance.featuredImage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

BlogComment _$BlogCommentFromJson(Map<String, dynamic> json) => BlogComment(
      id: json['_id'] as String?,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BlogCommentToJson(BlogComment instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'postId': instance.postId,
      'userId': instance.userId,
      'userName': instance.userName,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreateBlogPostRequest _$CreateBlogPostRequestFromJson(
        Map<String, dynamic> json) =>
    CreateBlogPostRequest(
      title: json['title'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      published: json['published'] as bool,
      featuredImage: json['featuredImage'] as String?,
    );

Map<String, dynamic> _$CreateBlogPostRequestToJson(
        CreateBlogPostRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'tags': instance.tags,
      'published': instance.published,
      'featuredImage': instance.featuredImage,
    };

UpdateBlogPostRequest _$UpdateBlogPostRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateBlogPostRequest(
      title: json['title'] as String?,
      content: json['content'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      published: json['published'] as bool?,
      featuredImage: json['featuredImage'] as String?,
    );

Map<String, dynamic> _$UpdateBlogPostRequestToJson(
        UpdateBlogPostRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'tags': instance.tags,
      'published': instance.published,
      'featuredImage': instance.featuredImage,
    };

CreateCommentRequest _$CreateCommentRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCommentRequest(
      content: json['content'] as String,
    );

Map<String, dynamic> _$CreateCommentRequestToJson(
        CreateCommentRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
    };