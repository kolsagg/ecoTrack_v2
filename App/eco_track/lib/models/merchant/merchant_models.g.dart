// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Merchant _$MerchantFromJson(Map<String, dynamic> json) => Merchant(
  id: json['id'] as String,
  name: json['name'] as String,
  businessType: json['business_type'] as String?,
  apiKey: json['api_key'] as String?,
  webhookUrl: json['webhook_url'] as String?,
  isActive: json['is_active'] as bool,
  contactEmail: json['contact_email'] as String?,
  contactPhone: json['contact_phone'] as String?,
  address: json['address'] as String?,
  taxNumber: json['tax_number'] as String?,
  settings: json['settings'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MerchantToJson(Merchant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'business_type': instance.businessType,
  'api_key': instance.apiKey,
  'webhook_url': instance.webhookUrl,
  'is_active': instance.isActive,
  'contact_email': instance.contactEmail,
  'contact_phone': instance.contactPhone,
  'address': instance.address,
  'tax_number': instance.taxNumber,
  'settings': instance.settings,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

MerchantCreateRequest _$MerchantCreateRequestFromJson(
  Map<String, dynamic> json,
) => MerchantCreateRequest(
  name: json['name'] as String,
  businessType: json['business_type'] as String?,
  webhookUrl: json['webhook_url'] as String?,
  contactEmail: json['contact_email'] as String?,
  contactPhone: json['contact_phone'] as String?,
  address: json['address'] as String?,
  taxNumber: json['tax_number'] as String?,
  settings: json['settings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MerchantCreateRequestToJson(
  MerchantCreateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'business_type': instance.businessType,
  'webhook_url': instance.webhookUrl,
  'contact_email': instance.contactEmail,
  'contact_phone': instance.contactPhone,
  'address': instance.address,
  'tax_number': instance.taxNumber,
  'settings': instance.settings,
};

MerchantUpdateRequest _$MerchantUpdateRequestFromJson(
  Map<String, dynamic> json,
) => MerchantUpdateRequest(
  name: json['name'] as String?,
  businessType: json['business_type'] as String?,
  webhookUrl: json['webhook_url'] as String?,
  contactEmail: json['contact_email'] as String?,
  contactPhone: json['contact_phone'] as String?,
  address: json['address'] as String?,
  taxNumber: json['tax_number'] as String?,
  settings: json['settings'] as Map<String, dynamic>?,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$MerchantUpdateRequestToJson(
  MerchantUpdateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'business_type': instance.businessType,
  'webhook_url': instance.webhookUrl,
  'contact_email': instance.contactEmail,
  'contact_phone': instance.contactPhone,
  'address': instance.address,
  'tax_number': instance.taxNumber,
  'settings': instance.settings,
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
  size: (json['size'] as num).toInt(),
  hasNext: json['has_next'] as bool,
);

Map<String, dynamic> _$MerchantListResponseToJson(
  MerchantListResponse instance,
) => <String, dynamic>{
  'merchants': instance.merchants,
  'total': instance.total,
  'page': instance.page,
  'size': instance.size,
  'has_next': instance.hasNext,
};

ApiKeyRegenerationResponse _$ApiKeyRegenerationResponseFromJson(
  Map<String, dynamic> json,
) => ApiKeyRegenerationResponse(
  apiKey: json['api_key'] as String,
  message: json['message'] as String?,
);

Map<String, dynamic> _$ApiKeyRegenerationResponseToJson(
  ApiKeyRegenerationResponse instance,
) => <String, dynamic>{'api_key': instance.apiKey, 'message': instance.message};
