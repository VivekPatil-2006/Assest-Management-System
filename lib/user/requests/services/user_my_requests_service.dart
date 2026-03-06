
import '../../../services/api_service.dart';

class UserRequestItem {
  final String id;
  final String assetId;
  final String assetName;
  final String assetSerial;
  final String status; // pending | approved | rejected
  final String requestType; // new_request | swap_request
  final String reason;
  final String deskLocation;
  final String duration;
  final DateTime? startDate;
  final DateTime? createdAt;
  final DateTime? approvalDate;
  final String remarks;
  final String rejectionReason;
  final String approvedByName;

  const UserRequestItem({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.assetSerial,
    required this.status,
    required this.requestType,
    required this.reason,
    required this.deskLocation,
    required this.duration,
    required this.startDate,
    required this.createdAt,
    required this.approvalDate,
    required this.remarks,
    required this.rejectionReason,
    required this.approvedByName,
  });

  factory UserRequestItem.fromJson(Map<String, dynamic> json) {
    final asset = json['assetId'] is Map<String, dynamic>
        ? json['assetId'] as Map<String, dynamic>
        : <String, dynamic>{};

    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return UserRequestItem(
      id: (json['_id'] ?? '').toString(),
      assetId: (asset['_id'] ?? json['assetId'] ?? '').toString(),
      assetName: (asset['assetName'] ?? '-').toString(),
      assetSerial: (asset['serialNumber'] ?? '-').toString(),
      status: (json['status'] ?? 'pending').toString(),
      requestType: (json['requestType'] ?? 'new_request').toString(),
      reason: (json['reason'] ?? '').toString(),
      deskLocation: (json['deskLocation'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      startDate: parseDate(json['startDate']),
      createdAt: parseDate(json['createdAt']),
      approvalDate: parseDate(json['approvalDate']),
      remarks: (json['remarks'] ?? '').toString(),
      rejectionReason: (json['rejectionReason'] ?? '').toString(),
      approvedByName: json['approvedBy'] is Map<String, dynamic>
          ? ((json['approvedBy']['name'] ?? '').toString())
          : '',
    );
  }
}

class UserMyRequestsService {
  static Future<List<UserRequestItem>> fetchMyRequests({String? status}) async {
    final query = (status != null && status.isNotEmpty && status != 'all')
        ? '?status=${Uri.encodeQueryComponent(status)}'
        : '';

    final res = await ApiService.get('/asset-user/my-requests$query');

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid my-requests response');
    }
    if (res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to fetch my requests').toString());
    }

    final list = (res['requests'] is List) ? (res['requests'] as List) : <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) => UserRequestItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> deletePendingRequest(String requestId) async {
    final res = await ApiService.delete('/asset-user/request/$requestId');
    if (res is Map<String, dynamic> && res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to delete request').toString());
    }
  }

  static Future<void> updatePendingRequest({
    required String requestId,
    required String reason,
    required String deskLocation,
  }) async {
    final body = <String, dynamic>{
      'reason': reason,
      'deskLocation': deskLocation,
    };

    final res = await ApiService.put('/asset-user/request/$requestId', body);
    if (res is Map<String, dynamic> && res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to update request').toString());
    }
  }
}