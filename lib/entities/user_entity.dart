import 'package:equatable/equatable.dart';

enum AccountType {
  seeker,
  landlord,
  agent,
  serviceProvider,
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String accountType; // 'seeker', 'landlord', 'agent', 'service_provider'
  final String verificationStatus;
  final List<String> roles;
  final bool isActive;
  final DateTime? createdAt;
  
  // Subscription fields
  final String? subscriptionTier; // 'none', 'daily', 'weekly', 'monthly', 'quarterly', 'bi_annual', 'annual'
  final DateTime? subscriptionExpiry;

  // Privacy fields
  final bool isPublicProfile;
  final bool showActivityStatus;
  final bool allowPersonalizedAds;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.accountType = 'seeker',
    this.verificationStatus = 'unverified',
    this.roles = const ['user'],
    this.isActive = true,
    this.createdAt,
    this.subscriptionTier = 'none',
    this.subscriptionExpiry,
    this.isPublicProfile = true,
    this.showActivityStatus = false,
    this.allowPersonalizedAds = true,
  });

  bool get isAdmin => roles.contains('admin');
  bool get isAgent => accountType == 'agent';
  bool get isLandlord => accountType == 'landlord';
  bool get isServiceProvider => accountType == 'service_provider';
  bool get isSeeker => accountType == 'seeker';
  bool get isVerified => verificationStatus == 'verified';
  
  bool get hasActiveSubscription {
    if (subscriptionTier == null || subscriptionTier == 'none') return false;
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? accountType,
    String? verificationStatus,
    List<String>? roles,
    bool? isActive,
    DateTime? createdAt,
    String? subscriptionTier,
    DateTime? subscriptionExpiry,
    bool? isPublicProfile,
    bool? showActivityStatus,
    bool? allowPersonalizedAds,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accountType: accountType ?? this.accountType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      isPublicProfile: isPublicProfile ?? this.isPublicProfile,
      showActivityStatus: showActivityStatus ?? this.showActivityStatus,
      allowPersonalizedAds: allowPersonalizedAds ?? this.allowPersonalizedAds,
    );
  }

  @override
  List<Object?> get props => [
    id, email, fullName, phone, avatarUrl,
    accountType, verificationStatus, roles, isActive,
    subscriptionTier, subscriptionExpiry,
    isPublicProfile, showActivityStatus, allowPersonalizedAds,
  ];
}
