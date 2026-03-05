// lib/lab_admin/manage_departments/services/department_service.dart
import '../../../services/api_service.dart';

class DepartmentService {
  /* =======================================================
     DEPARTMENTS
     ======================================================= */
  Future<List<Map<String, dynamic>>> getAllDepartments() async {
    final response = await ApiService.get('/departments');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> addDepartment({
    required String label,
  }) async {
    final cleanLabel = label.trim();
    final name = cleanLabel.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

    final response = await ApiService.post('/departments', {
      'name': name,
      'label': cleanLabel,
    });

    return Map<String, dynamic>.from(response['data'] ?? {});
  }

  Future<Map<String, dynamic>> updateDepartment({
    required String departmentId,
    required String label,
  }) async {
    final cleanLabel = label.trim();
    final name = cleanLabel.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

    final response = await ApiService.put('/departments/$departmentId', {
      'name': name,
      'label': cleanLabel,
    });

    return Map<String, dynamic>.from(response['data'] ?? {});
  }

  Future<void> deleteDepartment(String departmentId) async {
    await ApiService.delete('/departments/$departmentId');
  }

  /* =======================================================
     ASSET INCHARGE USERS
     ======================================================= */
  Future<List<Map<String, dynamic>>> getAssetIncharges() async {
    final response = await ApiService.get('/labAdmin/approved-users?role=asset_incharge');

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }

    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  /* =======================================================
     ASSIGN / UNASSIGN DEPARTMENT
     ======================================================= */
  Future<void> assignDepartment({
    required String userId,
    required String departmentLabel,
  }) async {
    await ApiService.patch('/labAdmin/assign-department', {
      'userId': userId,
      'department': departmentLabel,
    });
  }

  Future<void> unassignDepartment({
    required String userId,
  }) async {
    await ApiService.patch('/labAdmin/assign-department', {
      'userId': userId,
      'department': '',
    });
  }
}