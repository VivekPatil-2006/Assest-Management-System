// lib/lab_admin/manage_user/services/user_service.dart
import '../../../services/api_service.dart';

class UserService {
  /* =======================================================
     GET USERS BY FILTER
     filter values:
     - all
     - lab_technician
     - asset_incharge
     - asset_user
     ======================================================= */
  Future<List<Map<String, dynamic>>> getUsers({
    required String filter,
  }) async {
    if (filter == 'lab_technician' || filter == 'asset_incharge') {
      final response =
      await ApiService.get('/labAdmin/approved-users?role=$filter');
      return _toList(response);
    }

    if (filter == 'asset_user') {
      final response = await ApiService.get('/labAdmin/approved-asset-users');
      return _toList(response);
    }

    // all => approved technicians + asset incharge + asset users
    final approvedUsersFuture = ApiService.get('/labAdmin/approved-users');
    final assetUsersFuture = ApiService.get('/labAdmin/approved-asset-users');

    final results = await Future.wait([approvedUsersFuture, assetUsersFuture]);

    final approvedUsers = _toList(results[0]);
    final assetUsers = _toList(results[1]);

    // Deduplicate by _id when merging
    final map = <String, Map<String, dynamic>>{};
    for (final u in [...approvedUsers, ...assetUsers]) {
      final id = (u['_id'] ?? '').toString();
      if (id.isNotEmpty) {
        map[id] = u;
      }
    }

    return map.values.toList();
  }

  /* =======================================================
     CREATE USER (TECHNICIAN / ASSET INCHARGE)
     POST /api/auth/signup
     ======================================================= */
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role, // lab_technician | asset_incharge
  }) async {
    await ApiService.post('/auth/signup', {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'password': password,
      'confirmPassword': confirmPassword,
      'role': role,
      'skills': <String>[],
    });
  }

  /* =======================================================
     DELETE USER
     DELETE /api/labAdmin/users/:userId
     ======================================================= */
  Future<void> deleteUser(String userId) async {
    await ApiService.delete('/labAdmin/users/$userId');
  }

  // ------------------------
  // Helpers
  // ------------------------
  List<Map<String, dynamic>> _toList(dynamic response) {
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
}