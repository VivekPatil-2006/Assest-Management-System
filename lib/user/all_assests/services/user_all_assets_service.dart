
import '../../../services/api_service.dart';

class UserAssetItem {
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

  const UserAssetItem({
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

  factory UserAssetItem.fromJson(Map<String, dynamic> json) {
    return UserAssetItem(
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

  String get brandModel {
    final b = brand.trim();
    final m = model.trim();
    if (b.isEmpty && m.isEmpty) return '-';
    if (b.isEmpty) return m;
    if (m.isEmpty) return b;
    return '$b / $m';
  }
}

class UserAllAssetsResponse {
  final List<UserAssetItem> assets;
  final int total;
  final int page;
  final int totalPages;

  const UserAllAssetsResponse({
    required this.assets,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

class UserAllAssetsService {
  static Future<UserAllAssetsResponse> fetchAllAssets({
    String? search,
    String? status,
    String? condition,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };

    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    if (status != null && status.trim().isNotEmpty && status != 'all') {
      params['status'] = status.trim();
    }
    if (condition != null && condition.trim().isNotEmpty && condition != 'all') {
      params['condition'] = condition.trim();
    }
    if (category != null && category.trim().isNotEmpty && category != 'all') {
      params['category'] = category.trim();
    }

    final query = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    final path = '/asset-user/all-assets?$query';
    final res = await ApiService.get(path);

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid all-assets response format');
    }
    if (res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to fetch assets').toString());
    }

    final list = (res['assets'] is List) ? (res['assets'] as List) : <dynamic>[];
    final assets = list
        .whereType<Map>()
        .map((e) => UserAssetItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    int toInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      if (value is double) return value.toInt();
      return fallback;
    }

    return UserAllAssetsResponse(
      assets: assets,
      total: toInt(res['total'], assets.length),
      page: toInt(res['page'], page),
      totalPages: toInt(res['totalPages'], 1),
    );
  }
}