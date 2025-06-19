import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'merchant_models.g.dart';

// Merchant Model
@JsonSerializable()
class Merchant extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  @JsonKey(name: 'api_key')
  final String? apiKey;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Merchant({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.apiKey,
    required this.isActive,
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
    description,
    address,
    phone,
    email,
    website,
    apiKey,
    isActive,
    createdAt,
    updatedAt,
  ];

  Merchant copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? apiKey,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      apiKey: apiKey ?? this.apiKey,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Merchant Create Request
@JsonSerializable()
class MerchantCreateRequest extends Equatable {
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;

  const MerchantCreateRequest({
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.website,
  });

  factory MerchantCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$MerchantCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MerchantCreateRequestToJson(this);

  @override
  List<Object?> get props => [
    name,
    description,
    address,
    phone,
    email,
    website,
  ];
}

// Merchant Update Request
@JsonSerializable()
class MerchantUpdateRequest extends Equatable {
  final String? name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  const MerchantUpdateRequest({
    this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.isActive,
  });

  factory MerchantUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$MerchantUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MerchantUpdateRequestToJson(this);

  @override
  List<Object?> get props => [
    name,
    description,
    address,
    phone,
    email,
    website,
    isActive,
  ];
}

// Merchant List Response
@JsonSerializable()
class MerchantListResponse extends Equatable {
  final List<Merchant> merchants;
  final int total;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;

  const MerchantListResponse({
    required this.merchants,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory MerchantListResponse.fromJson(Map<String, dynamic> json) =>
      _$MerchantListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MerchantListResponseToJson(this);

  @override
  List<Object?> get props => [merchants, total, page, perPage, totalPages];
}

// API Key Regeneration Response
@JsonSerializable()
class ApiKeyRegenerationResponse extends Equatable {
  @JsonKey(name: 'api_key')
  final String apiKey;
  @JsonKey(name: 'regenerated_at')
  final DateTime regeneratedAt;

  const ApiKeyRegenerationResponse({
    required this.apiKey,
    required this.regeneratedAt,
  });

  factory ApiKeyRegenerationResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyRegenerationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiKeyRegenerationResponseToJson(this);

  @override
  List<Object?> get props => [apiKey, regeneratedAt];
}
