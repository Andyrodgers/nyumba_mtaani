import 'package:nyumba_mtaani/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phone,
    super.avatarUrl,
    super.accountType,
    super.verificationStatus,
    super.roles,
    super.isActive,
    super.createdAt,
    super.subscriptionTier,
    super.subscriptionExpiry,
    super.isPublicProfile,
    super.showActivityStatus,
    super.allowPersonalizedAds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      accountType: json['account_type'] as String? ?? 'seeker',
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? ['user'],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      subscriptionTier: json['subscription_tier'] as String? ?? 'none',
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.parse(json['subscription_expiry'] as String)
          : null,
      isPublicProfile: json['is_public_profile'] as bool? ?? true,
      showActivityStatus: json['show_activity_status'] as bool? ?? false,
      allowPersonalizedAds: json['allow_personalized_ads'] as bool? ?? true,
    );
  }

  factory UserModel.fromSupabaseUser(dynamic user, Map<String, dynamic>? profileData) {
    return UserModel(
      id: user.id as String,
      email: user.email ?? '',
      fullName: profileData?['full_name'] as String? ?? user.userMetadata?['full_name'] as String?,
      phone: profileData?['phone'] as String? ?? user.phone,
      avatarUrl: profileData?['avatar_url'] as String?,
      accountType: profileData?['account_type'] as String? ?? 'seeker',
      verificationStatus: profileData?['verification_status'] as String? ?? 'unverified',
      roles: (profileData?['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? ['user'],
      isActive: profileData?['is_active'] as bool? ?? true,
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt) : null,
      subscriptionTier: profileData?['subscription_tier'] as String? ?? 'none',
      subscriptionExpiry: profileData?['subscription_expiry'] != null
          ? DateTime.parse(profileData!['subscription_expiry'] as String)
          : null,
      isPublicProfile: profileData?['is_public_profile'] as bool? ?? true,
      showActivityStatus: profileData?['show_activity_status'] as bool? ?? false,
      allowPersonalizedAds: profileData?['allow_personalized_ads'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'account_type': accountType,
      'verification_status': verificationStatus,
      'is_active': isActive,
      'subscription_tier': subscriptionTier,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'is_public_profile': isPublicProfile,
      'show_activity_status': showActivityStatus,
      'allow_personalized_ads': allowPersonalizedAds,
    };
  }
}
