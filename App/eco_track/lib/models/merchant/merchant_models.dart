import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'merchant_models.g.dart';

// Business Type Enum
enum BusinessType {
  @JsonValue('restaurant')
  restaurant,
  @JsonValue('retail')
  retail,
  @JsonValue('grocery')
  grocery,
  @JsonValue('pharmacy')
  pharmacy,
  @JsonValue('gas_station')
  gasStation,
  @JsonValue('clothing')
  clothing,
  @JsonValue('electronics')
  electronics,
  @JsonValue('other')
  other;

  String get displayName {
    switch (this) {
      case BusinessType.restaurant:
        return 'Restoran';
      case BusinessType.retail:
        return 'Perakende';
      case BusinessType.grocery:
        return 'Market';
      case BusinessType.pharmacy:
        return 'Eczane';
      case BusinessType.gasStation:
        return 'Benzin İstasyonu';
      case BusinessType.clothing:
        return 'Giyim';
      case BusinessType.electronics:
        return 'Elektronik';
      case BusinessType.other:
        return 'Diğer';
    }
  }

  String get value {
    switch (this) {
      case BusinessType.restaurant:
        return 'restaurant';
      case BusinessType.retail:
        return 'retail';
      case BusinessType.grocery:
        return 'grocery';
      case BusinessType.pharmacy:
        return 'pharmacy';
      case BusinessType.gasStation:
        return 'gas_station';
      case BusinessType.clothing:
        return 'clothing';
      case BusinessType.electronics:
        return 'electronics';
      case BusinessType.other:
        return 'other';
    }
  }

  static BusinessType? fromString(String? value) {
    if (value == null) return null;
    for (final type in BusinessType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

// Merchant Model
@JsonSerializable()
class Merchant extends Equatable {
  final String id;
  final String name;
  @JsonKey(name: 'business_type')
  final String? businessType;
  @JsonKey(name: 'api_key')
  final String? apiKey;
  @JsonKey(name: 'webhook_url')
  final String? webhookUrl;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  final String? address;
  @JsonKey(name: 'tax_number')
  final String? taxNumber;
  final Map<String, dynamic>? settings;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Merchant({
    required this.id,
    required this.name,
    this.businessType,
    this.apiKey,
    this.webhookUrl,
    required this.isActive,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.taxNumber,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) =>
      _$MerchantFromJson(json);

  Map<String, dynamic> toJson() => _$MerchantToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    businessType,
    apiKey,
    webhookUrl,
    isActive,
    contactEmail,
    contactPhone,
    address,
    taxNumber,
    settings,
    createdAt,
    updatedAt,
  ];

  Merchant copyWith({
    String? id,
    String? name,
    String? businessType,
    String? apiKey,
    String? webhookUrl,
    bool? isActive,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? taxNumber,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      apiKey: apiKey ?? this.apiKey,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      isActive: isActive ?? this.isActive,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Merchant Create Request
@JsonSerializable()
class MerchantCreateRequest extends Equatable {
  final String name;
  @JsonKey(name: 'business_type')
  final String? businessType;
  @JsonKey(name: 'webhook_url')
  final String? webhookUrl;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  final String? address;
  @JsonKey(name: 'tax_number')
  final String? taxNumber;
  final Map<String, dynamic>? settings;

  const MerchantCreateRequest({
    required this.name,
    this.businessType,
    this.webhookUrl,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.taxNumber,
    this.settings,
  });

  factory MerchantCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$MerchantCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MerchantCreateRequestToJson(this);

  @override
  List<Object?> get props => [
    name,
    businessType,
    webhookUrl,
    contactEmail,
    contactPhone,
    address,
    taxNumber,
    settings,
  ];
}

// Merchant Update Request
@JsonSerializable()
class MerchantUpdateRequest extends Equatable {
  final String? name;
  @JsonKey(name: 'business_type')
  final String? businessType;
  @JsonKey(name: 'webhook_url')
  final String? webhookUrl;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  final String? address;
  @JsonKey(name: 'tax_number')
  final String? taxNumber;
  final Map<String, dynamic>? settings;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  const MerchantUpdateRequest({
    this.name,
    this.businessType,
    this.webhookUrl,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.taxNumber,
    this.settings,
    this.isActive,
  });

  factory MerchantUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$MerchantUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MerchantUpdateRequestToJson(this);

  @override
  List<Object?> get props => [
    name,
    businessType,
    webhookUrl,
    contactEmail,
    contactPhone,
    address,
    taxNumber,
    settings,
    isActive,
  ];
}

// Merchant List Response
@JsonSerializable()
class MerchantListResponse extends Equatable {
  final List<Merchant> merchants;
  final int total;
  final int page;
  final int size;
  @JsonKey(name: 'has_next')
  final bool hasNext;

  const MerchantListResponse({
    required this.merchants,
    required this.total,
    required this.page,
    required this.size,
    required this.hasNext,
  });

  factory MerchantListResponse.fromJson(Map<String, dynamic> json) =>
      _$MerchantListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MerchantListResponseToJson(this);

  @override
  List<Object?> get props => [merchants, total, page, size, hasNext];
}

// API Key Regeneration Response
@JsonSerializable()
class ApiKeyRegenerationResponse extends Equatable {
  @JsonKey(name: 'api_key')
  final String apiKey;
  final String? message;

  const ApiKeyRegenerationResponse({required this.apiKey, this.message});

  factory ApiKeyRegenerationResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyRegenerationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiKeyRegenerationResponseToJson(this);

  @override
  List<Object?> get props => [apiKey, message];
}
