
import '../../../services/api_service.dart';

class MyAssignedAsset {
  final String assignmentId;
  final String assetId;
  final String assetName;
  final String serialNumber;
  final String category;
  final String labLocation;
  final String deskLocation;
  final String condition;
  final String assignedByName;
  final DateTime? assignedDate;
  final String notes;
  final String status;

  const MyAssignedAsset({
    required this.assignmentId,
    required this.assetId,
    required this.assetName,
    required this.serialNumber,
    required this.category,
    required this.labLocation,
    required this.deskLocation,
    required this.condition,
    required this.assignedByName,
    required this.assignedDate,
    required this.notes,
    required this.status,
  });

  factory MyAssignedAsset.fromJson(Map<String, dynamic> json) {
    final assetMap = json['assetId'] is Map<String, dynamic>
        ? json['assetId'] as Map<String, dynamic>
        : <String, dynamic>{};

    final assignedByMap = json['assignedBy'] is Map<String, dynamic>
        ? json['assignedBy'] as Map<String, dynamic>
        : <String, dynamic>{};

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return MyAssignedAsset(
      assignmentId: (json['_id'] ?? '').toString(),
      assetId: (assetMap['_id'] ?? json['assetId'] ?? '').toString(),
      assetName: (assetMap['assetName'] ?? '-').toString(),
      serialNumber: (assetMap['serialNumber'] ?? '-').toString(),
      category: (assetMap['category'] ?? '-').toString(),
      labLocation: (assetMap['labLocation'] ?? '-').toString(),
      deskLocation: (assetMap['deskLocation'] ?? '-').toString(),
      condition: (assetMap['condition'] ?? '-').toString(),
      assignedByName: (assignedByMap['name'] ?? '-').toString(),
      assignedDate: parseDate(json['assignedDate'] ?? json['createdAt']),
      notes: (json['notes'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class UserMyAssetsService {
  static Future<List<MyAssignedAsset>> fetchMyAssets() async {
    final res = await ApiService.get('/asset-user/my-assets');

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid my-assets response format');
    }
    if (res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to fetch my assets').toString());
    }

    final list = (res['assets'] is List) ? (res['assets'] as List) : <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) => MyAssignedAsset.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}