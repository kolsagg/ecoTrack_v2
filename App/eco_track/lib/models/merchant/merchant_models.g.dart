// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Merchant _$MerchantFromJson(Map<String, dynamic> json) => Merchant(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  apiKey: json['api_key'] as String?,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MerchantToJson(Merchant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'api_key': instance.apiKey,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

MerchantCreateRequest _$MerchantCreateRequestFromJson(
  Map<String, dynamic> json,
) => MerchantCreateRequest(
  name: json['name'] as String,
  description: json['description'] as String?,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
);

Map<String, dynamic> _$MerchantCreateRequestToJson(
  MerchantCreateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
};

MerchantUpdateRequest _$MerchantUpdateRequestFromJson(
  Map<String, dynamic> json,
) => MerchantUpdateRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$MerchantUpdateRequestToJson(
  MerchantUpdateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'is_active': instance.isActive,
};

MerchantListResponse _$MerchantListResponseFromJson(
  Map<String, dynamic> json,
) => MerchantListResponse(
  merchants: (json['merchants'] as List<dynamic>)
      .map((e) => Merchant.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
);

Map<String, dynamic> _$MerchantListResponseToJson(
  MerchantListResponse instance,
) => <String, dynamic>{
  'merchants': instance.merchants,
  'total': instance.total,
  'page': instance.page,
  'per_page': instance.perPage,
  'total_pages': instance.totalPages,
};

ApiKeyRegenerationResponse _$ApiKeyRegenerationResponseFromJson(
  Map<String, dynamic> json,
) => ApiKeyRegenerationResponse(
  apiKey: json['api_key'] as String,
  regeneratedAt: DateTime.parse(json['regenerated_at'] as String),
);

Map<String, dynamic> _$ApiKeyRegenerationResponseToJson(
  ApiKeyRegenerationResponse instance,
) => <String, dynamic>{
  'api_key': instance.apiKey,
  'regenerated_at': instance.regeneratedAt.toIso8601String(),
};
