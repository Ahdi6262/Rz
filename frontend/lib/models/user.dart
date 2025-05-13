import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String fullName;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? web3Wallet;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
    this.web3Wallet,
  });

  // Factory constructor for creating User from JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Method for converting User to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Create a copy of User with specified fields updated
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? web3Wallet,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      web3Wallet: web3Wallet ?? this.web3Wallet,
    );
  }
}

@JsonSerializable()
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  // Factory constructor for creating AuthResponse from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  // Method for converting AuthResponse to JSON
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  // Factory constructor for creating LoginRequest from JSON
  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  // Method for converting LoginRequest to JSON
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String? web3Wallet;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.web3Wallet,
  });

  // Factory constructor for creating RegisterRequest from JSON
  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);

  // Method for converting RegisterRequest to JSON
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class Web3LoginRequest {
  final String walletAddress;
  final String message;
  final String signature;

  Web3LoginRequest({
    required this.walletAddress,
    required this.message,
    required this.signature,
  });

  // Factory constructor for creating Web3LoginRequest from JSON
  factory Web3LoginRequest.fromJson(Map<String, dynamic> json) => _$Web3LoginRequestFromJson(json);

  // Method for converting Web3LoginRequest to JSON
  Map<String, dynamic> toJson() => _$Web3LoginRequestToJson(this);
}

@JsonSerializable()
class SocialLinks {
  final String? twitter;
  final String? linkedin;
  final String? github;
  final String? website;

  SocialLinks({
    this.twitter,
    this.linkedin,
    this.github,
    this.website,
  });

  // Factory constructor for creating SocialLinks from JSON
  factory SocialLinks.fromJson(Map<String, dynamic> json) => _$SocialLinksFromJson(json);

  // Method for converting SocialLinks to JSON
  Map<String, dynamic> toJson() => _$SocialLinksToJson(this);
}

@JsonSerializable()
class UserProfile {
  final String userId;
  final String? bio;
  final String? profilePicture;
  final SocialLinks socialLinks;
  final List<String> skills;

  UserProfile({
    required this.userId,
    this.bio,
    this.profilePicture,
    required this.socialLinks,
    required this.skills,
  });

  // Factory constructor for creating UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  // Method for converting UserProfile to JSON
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
