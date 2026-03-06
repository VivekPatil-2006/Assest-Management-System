
import '../../../services/api_service.dart';

class AvailableAsset {
  final String id;
  final String assetName;
  final String serialNumber;
  final String category;
  final String brand;
  final String model;
  final String labLocation;
  final String deskLocation;
  final String status;
  final String condition;
  final bool isAssigned;

  const AvailableAsset({
    required this.id,
    required this.assetName,
    required this.serialNumber,
    required this.category,
    required this.brand,
    required this.model,
    required this.labLocation,
    required this.deskLocation,
    required this.status,
    required this.condition,
    required this.isAssigned,
  });

  factory AvailableAsset.fromJson(Map<String, dynamic> json) {
    return AvailableAsset(
      id: (json['_id'] ?? '').toString(),
      assetName: (json['assetName'] ?? '').toString(),
      serialNumber: (json['serialNumber'] ?? '-').toString(),
      category: (json['category'] ?? '-').toString(),
      brand: (json['brand'] ?? '-').toString(),
      model: (json['model'] ?? '-').toString(),
      labLocation: (json['labLocation'] ?? '-').toString(),
      deskLocation: (json['deskLocation'] ?? '-').toString(),
      status: (json['status'] ?? '-').toString(),
      condition: (json['condition'] ?? '-').toString(),
      isAssigned: json['isAssigned'] == true,
    );
  }
}

class UserAvailableAssetsService {
  static Future<List<AvailableAsset>> fetchAvailableAssets({String? labId}) async {
    final query = (labId != null && labId.trim().isNotEmpty)
        ? '?labId=${Uri.encodeQueryComponent(labId.trim())}'
        : '';

    final res = await ApiService.get('/asset-user/available$query');

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid available assets response');
    }

    if (res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to fetch available assets').toString());
    }

    final list = (res['assets'] is List) ? (res['assets'] as List) : <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) => AvailableAsset.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}