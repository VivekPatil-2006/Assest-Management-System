// services/pending_approval_service.dart
import '../../../../services/api_service.dart';

class PendingApprovalService {
  /* =======================================================
     LIST PENDING STAFF USERS
     GET /api/labAdmin/pending-users
     ======================================================= */
  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    final response = await ApiService.get('/labAdmin/pending-users');

    // backend returns plain array for this endpoint
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }

    // fallback if wrapped
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  /* =======================================================
     APPROVE / REJECT STAFF USER
     PUT /api/labAdmin/approve-reject/:userId
     body: { approve: true/false }
     ======================================================= */
  Future<void> handleApproval({
    required String userId,
    required bool approve,
  }) async {
    await ApiService.put(
      '/labAdmin/approve-reject/$userId',
      {'approve': approve},
    );
  }
}