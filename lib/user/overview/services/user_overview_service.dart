// lib/features/user/services/user_overview_service.dart

import '../../../services/api_service.dart';

class UserOverviewData {
  final int totalAssets;
  final int unassigned;
  final int assigned;
  final int underMaintenance;
  final int disposed;
  final int myAssets;

  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;

  final Map<String, int> assetsByStatus;
  final Map<String, int> assetsByCondition;
  final Map<String, int> assetsByCategory;
  final Map<String, int> assetsByLocation;

  const UserOverviewData({
    required this.totalAssets,
    required this.unassigned,
    required this.assigned,
    required this.underMaintenance,
    required this.disposed,
    required this.myAssets,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
    required this.assetsByStatus,
    required this.assetsByCondition,
    required this.assetsByCategory,
    required this.assetsByLocation,
  });

  factory UserOverviewData.fromApi(Map<String, dynamic> response) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final stats = (response['stats'] is Map<String, dynamic>)
        ? response['stats'] as Map<String, dynamic>
        : <String, dynamic>{};

    final status = (stats['statusBreakdown'] is Map<String, dynamic>)
        ? stats['statusBreakdown'] as Map<String, dynamic>
        : <String, dynamic>{};

    final assignment = (stats['assignmentBreakdown'] is Map<String, dynamic>)
        ? stats['assignmentBreakdown'] as Map<String, dynamic>
        : <String, dynamic>{};

    final condition = (stats['conditionBreakdown'] is Map<String, dynamic>)
        ? stats['conditionBreakdown'] as Map<String, dynamic>
        : <String, dynamic>{};

    final myRequests = (stats['myRequests'] is Map<String, dynamic>)
        ? stats['myRequests'] as Map<String, dynamic>
        : <String, dynamic>{};

    Map<String, int> listToMap(dynamic listValue) {
      if (listValue is! List) return {};
      final out = <String, int>{};
      for (final item in listValue) {
        if (item is Map) {
          final name = (item['name'] ?? 'Unknown').toString();
          final count = toInt(item['count']);
          out[name] = count;
        }
      }
      return out;
    }

    return UserOverviewData(
      totalAssets: toInt(stats['totalAssets']),
      unassigned: toInt(assignment['unassigned']),
      assigned: toInt(assignment['assigned']),
      underMaintenance: toInt(status['underMaintenance']),
      disposed: toInt(status['disposed']),
      myAssets: toInt(stats['myAssets']),
      pendingRequests: toInt(myRequests['pending']),
      approvedRequests: toInt(myRequests['approved']),
      rejectedRequests: toInt(myRequests['rejected']),
      assetsByStatus: {
        'Available': toInt(status['available']),
        'In Use': toInt(status['inUse']),
        'Maintenance': toInt(status['underMaintenance']),
        'Disposed': toInt(status['disposed']),
      },
      assetsByCondition: {
        'Excellent': toInt(condition['excellent']),
        'Good': toInt(condition['good']),
        'Fair': toInt(condition['fair']),
        'Damaged': toInt(condition['damaged']),
      },
      assetsByCategory: listToMap(stats['byCategory']),
      assetsByLocation: listToMap(stats['byLocation']),
    );
  }
}

class UserOverviewService {
  // Correct backend route
  static const String _endpoint = '/asset-user/dashboard-stats';

  static Future<UserOverviewData> fetchOverview() async {
    final res = await ApiService.get(_endpoint);

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid overview response format');
    }

    if (res['success'] == false) {
      throw Exception((res['message'] ?? 'Failed to load overview').toString());
    }

    return UserOverviewData.fromApi(res);
  }
}