// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryResponse _$CategoryResponseFromJson(Map<String, dynamic> json) =>
    CategoryResponse(
      id: json['id'] as String?,
      name: json['name'] as String,
      userId: json['user_id'] as String?,
      isSystem: json['is_system'] as bool,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CategoryResponseToJson(CategoryResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'user_id': instance.userId,
      'is_system': instance.isSystem,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

CategoryCreateRequest _$CategoryCreateRequestFromJson(
  Map<String, dynamic> json,
) => CategoryCreateRequest(name: json['name'] as String);

Map<String, dynamic> _$CategoryCreateRequestToJson(
  CategoryCreateRequest instance,
) => <String, dynamic>{'name': instance.name};

CategoryUpdateRequest _$CategoryUpdateRequestFromJson(
  Map<String, dynamic> json,
) => CategoryUpdateRequest(name: json['name'] as String?);

Map<String, dynamic> _$CategoryUpdateRequestToJson(
  CategoryUpdateRequest instance,
) => <String, dynamic>{'name': instance.name};
