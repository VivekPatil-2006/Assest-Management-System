// lib/lab_admin/category_hierarchy/services/category_hierarchy_service.dart
import '../../../services/api_service.dart';

class CategoryHierarchyService {
  /* =======================================================
     CATEGORIES
     ======================================================= */
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await ApiService.get('/labAdmin/asset-categories');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  /* =======================================================
     SUBCATEGORIES
     ======================================================= */
  Future<List<Map<String, dynamic>>> getSubCategories(String categoryId) async {
    final response = await ApiService.get('/labAdmin/subcategories/$categoryId');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createSubCategory({
    required String name,
    required String categoryId,
  }) async {
    final response = await ApiService.post('/labAdmin/subcategories', {
      'name': name.trim(),
      'categoryId': categoryId,
    });
    return Map<String, dynamic>.from(response['subCategory'] ?? {});
  }

  Future<Map<String, dynamic>> updateSubCategory({
    required String id,
    required String name,
  }) async {
    final response = await ApiService.put('/labAdmin/subcategories/$id', {
      'name': name.trim(),
    });
    return Map<String, dynamic>.from(response['subCategory'] ?? {});
  }

  Future<void> deleteSubCategory(String id) async {
    await ApiService.delete('/labAdmin/subcategories/$id');
  }

  /* =======================================================
     SPECIFICATIONS
     ======================================================= */
  Future<List<Map<String, dynamic>>> getSpecifications(String subCategoryId) async {
    final response = await ApiService.get('/labAdmin/specifications/$subCategoryId');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createSpecification({
    required String name,
    required String subCategoryId,
    required String categoryId,
  }) async {
    final response = await ApiService.post('/labAdmin/specifications', {
      'name': name.trim(),
      'subCategoryId': subCategoryId,
      'categoryId': categoryId,
    });
    return Map<String, dynamic>.from(response['specification'] ?? {});
  }

  Future<Map<String, dynamic>> updateSpecification({
    required String id,
    required String name,
  }) async {
    final response = await ApiService.put('/labAdmin/specifications/$id', {
      'name': name.trim(),
    });
    return Map<String, dynamic>.from(response['specification'] ?? {});
  }

  Future<void> deleteSpecification(String id) async {
    await ApiService.delete('/labAdmin/specifications/$id');
  }
}