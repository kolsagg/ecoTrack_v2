import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category/category_models.dart';
import '../services/category_service.dart';
import '../core/utils/dependency_injection.dart';
import 'auth_provider.dart';

// Category service provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return CategoryService(authService, getIt());
});

// Categories state notifier
class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryResponse>>> {
  final CategoryService _categoryService;

  CategoriesNotifier(this._categoryService) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _categoryService.getCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createCategory(String name) async {
    try {
      final request = CategoryCreateRequest(name: name);
      await _categoryService.createCategory(request);
      await loadCategories(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCategory(String categoryId, String name) async {
    try {
      final request = CategoryUpdateRequest(name: name);
      await _categoryService.updateCategory(categoryId, request);
      await loadCategories(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoryService.deleteCategory(categoryId);
      await loadCategories(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Categories provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryResponse>>>((ref) {
  final categoryService = ref.watch(categoryServiceProvider);
  return CategoriesNotifier(categoryService);
}); 