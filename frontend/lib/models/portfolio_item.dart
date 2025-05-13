import 'package:json_annotation/json_annotation.dart';

part 'portfolio_item.g.dart';

@JsonSerializable()
class PortfolioItem {
  @JsonKey(name: '_id')
  final String? id;
  final String userId;
  final String title;
  final String description;
  final List<String> technologies;
  final List<String> imageUrls;
  final String? projectUrl;
  final String? githubUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PortfolioItem({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.technologies,
    required this.imageUrls,
    this.projectUrl,
    this.githubUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating PortfolioItem from JSON
  factory PortfolioItem.fromJson(Map<String, dynamic> json) => _$PortfolioItemFromJson(json);

  // Method for converting PortfolioItem to JSON
  Map<String, dynamic> toJson() => _$PortfolioItemToJson(this);

  // Create a copy of PortfolioItem with specified fields updated
  PortfolioItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? technologies,
    List<String>? imageUrls,
    String? projectUrl,
    String? githubUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      imageUrls: imageUrls ?? this.imageUrls,
      projectUrl: projectUrl ?? this.projectUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class CreatePortfolioItemRequest {
  final String title;
  final String description;
  final List<String> technologies;
  final List<String> imageUrls;
  final String? projectUrl;
  final String? githubUrl;

  CreatePortfolioItemRequest({
    required this.title,
    required this.description,
    required this.technologies,
    required this.imageUrls,
    this.projectUrl,
    this.githubUrl,
  });

  // Factory constructor for creating CreatePortfolioItemRequest from JSON
  factory CreatePortfolioItemRequest.fromJson(Map<String, dynamic> json) => _$CreatePortfolioItemRequestFromJson(json);

  // Method for converting CreatePortfolioItemRequest to JSON
  Map<String, dynamic> toJson() => _$CreatePortfolioItemRequestToJson(this);
}

@JsonSerializable()
class UpdatePortfolioItemRequest {
  final String? title;
  final String? description;
  final List<String>? technologies;
  final List<String>? imageUrls;
  final String? projectUrl;
  final String? githubUrl;

  UpdatePortfolioItemRequest({
    this.title,
    this.description,
    this.technologies,
    this.imageUrls,
    this.projectUrl,
    this.githubUrl,
  });

  // Factory constructor for creating UpdatePortfolioItemRequest from JSON
  factory UpdatePortfolioItemRequest.fromJson(Map<String, dynamic> json) => _$UpdatePortfolioItemRequestFromJson(json);

  // Method for converting UpdatePortfolioItemRequest to JSON
  Map<String, dynamic> toJson() => _$UpdatePortfolioItemRequestToJson(this);
}
