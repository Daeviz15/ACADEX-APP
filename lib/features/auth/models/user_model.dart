import 'package:acadex/core/network/api_endpoints.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bannerUrl;
  final int walletBalance;
  final bool isActive;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bannerUrl,
    this.walletBalance = 0,
    this.isActive = true,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      bannerUrl: json['banner_url'],
      walletBalance: json['wallet_balance'] ?? 0,
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'banner_url': bannerUrl,
      'wallet_balance': walletBalance,
      'is_active': isActive,
      'is_verified': isVerified,
    };
  }

  /// Returns the absolute avatar URL by prepending the backend host if it's a relative path.
  String? get fullAvatarUrl {
    if (avatarUrl == null) return null;
    if (avatarUrl!.startsWith('http')) return avatarUrl;
    return "${ApiEndpoints.baseHost}$avatarUrl";
  }

  /// Returns the absolute banner URL by prepending the backend host if it's a relative path.
  String? get fullBannerUrl {
    if (bannerUrl == null) return null;
    if (bannerUrl!.startsWith('http')) return bannerUrl;
    return "${ApiEndpoints.baseHost}$bannerUrl";
  }
}
