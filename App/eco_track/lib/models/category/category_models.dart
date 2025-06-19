import 'package:json_annotation/json_annotation.dart';

part 'category_models.g.dart';

@JsonSerializable()
class CategoryResponse {
  final String? id;
  final String name;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'is_system')
  final bool isSystem;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const CategoryResponse({
    this.id,
    required this.name,
    this.userId,
    required this.isSystem,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);
}

@JsonSerializable()
class CategoryCreateRequest {
  final String name;

  const CategoryCreateRequest({
    required this.name,
  });

  factory CategoryCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CategoryCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryCreateRequestToJson(this);
}

@JsonSerializable()
class CategoryUpdateRequest {
  final String? name;

  const CategoryUpdateRequest({
    this.name,
  });

  factory CategoryUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$CategoryUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryUpdateRequestToJson(this);
} 