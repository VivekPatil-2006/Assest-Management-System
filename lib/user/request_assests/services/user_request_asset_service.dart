import '../../../services/api_service.dart';

class UserLocation {
  final String id;
  final String name;

  const UserLocation({
    required this.id,
    required this.name,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: (json['_id'] ?? '').toString(),
      name: (json['label'] ?? json['name'] ?? 'Unknown').toString(),
    );
  }
}

class CreateAssetRequestPayload {
  final String assetId;
  final String labId;
  final String duration;
  final DateTime startDate;
  final String requestType; // new_request | swap_request
  final String reason;
  final String deskLocation;
  final String? swapWithAssetId;

  const CreateAssetRequestPayload({
    required this.assetId,
    required this.labId,
    required this.duration,
    required this.startDate,
    this.requestType = 'new_request',
    this.reason = '',
    this.deskLocation = '',
    this.swapWithAssetId,
  });
}

class UserRequestAssetService {
  static Future<List<UserLocation>> fetchLocations() async {
    final res = await ApiService.get('/asset-user/locations');

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid locations response');
    }
    if (res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to fetch locations').toString());
    }

    final list = (res['locations'] is List) ? (res['locations'] as List) : <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) => UserLocation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<String> createRequest(CreateAssetRequestPayload payload) async {
    final body = <String, dynamic>{
      'assetId': payload.assetId,
      'labId': payload.labId,
      'duration': payload.duration,
      'startDate': payload.startDate.toIso8601String(),
      'requestType': payload.requestType,
      'reason': payload.reason,
      'deskLocation': payload.deskLocation,
      'swapWithAssetId': payload.requestType == 'swap_request' ? payload.swapWithAssetId : null,
    };

    final res = await ApiService.post('/asset-user/request', body);

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid create request response');
    }
    if (res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to create request').toString());
    }

    return (res['message'] ?? 'Request submitted successfully').toString();
  }
}