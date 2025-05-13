// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioItem _$PortfolioItemFromJson(Map<String, dynamic> json) =>
    PortfolioItem(
      id: json['_id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      technologies: (json['technologies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      projectUrl: json['projectUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PortfolioItemToJson(PortfolioItem instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'technologies': instance.technologies,
      'imageUrls': instance.imageUrls,
      'projectUrl': instance.projectUrl,
      'githubUrl': instance.githubUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreatePortfolioItemRequest _$CreatePortfolioItemRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePortfolioItemRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      technologies: (json['technologies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      projectUrl: json['projectUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
    );

Map<String, dynamic> _$CreatePortfolioItemRequestToJson(
        CreatePortfolioItemRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'technologies': instance.technologies,
      'imageUrls': instance.imageUrls,
      'projectUrl': instance.projectUrl,
      'githubUrl': instance.githubUrl,
    };

UpdatePortfolioItemRequest _$UpdatePortfolioItemRequestFromJson(
        Map<String, dynamic> json) =>
    UpdatePortfolioItemRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      technologies: (json['technologies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      projectUrl: json['projectUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
    );

Map<String, dynamic> _$UpdatePortfolioItemRequestToJson(
        UpdatePortfolioItemRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'technologies': instance.technologies,
      'imageUrls': instance.imageUrls,
      'projectUrl': instance.projectUrl,
      'githubUrl': instance.githubUrl,
    };