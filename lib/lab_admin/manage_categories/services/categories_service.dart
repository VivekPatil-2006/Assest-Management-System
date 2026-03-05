// lib/lab_admin/manage_categories/services/categories_service.dart
import '../../../services/api_service.dart';

class CategoriesService {
  /* =======================================================
     GET ALL CATEGORIES
     GET /api/labAdmin/asset-categories
     ======================================================= */
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final response = await ApiService.get('/labAdmin/asset-categories');

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }

    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  /* =======================================================
     ADD CATEGORY
     POST /api/labAdmin/asset-categories
     body: { name }
     ======================================================= */
  Future<Map<String, dynamic>> addCategory({
    required String name,
  }) async {
    final response = await ApiService.post('/labAdmin/asset-categories', {
      'name': name.trim(),
    });

    return Map<String, dynamic>.from(response['category'] ?? {});
  }

  /* =======================================================
     UPDATE CATEGORY
     PUT /api/labAdmin/asset-categories/:id
     body: { name }
     ======================================================= */
  Future<Map<String, dynamic>> updateCategory({
    required String categoryId,
    required String name,
  }) async {
    final response = await ApiService.put(
      '/labAdmin/asset-categories/$categoryId',
      {'name': name.trim()},
    );

    return Map<String, dynamic>.from(response['category'] ?? {});
  }

  /* =======================================================
     DELETE CATEGORY
     DELETE /api/labAdmin/asset-categories/:id
     ======================================================= */
  Future<void> deleteCategory(String categoryId) async {
    await ApiService.delete('/labAdmin/asset-categories/$categoryId');
  }
}