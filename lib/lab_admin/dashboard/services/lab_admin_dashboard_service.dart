import '../../../../services/api_service.dart';

class LabAdminDashboardService {
  /* =======================================================
     DASHBOARD DATA (REAL APIS)
     ======================================================= */
  Future<Map<String, dynamic>> getDashboardData() async {
    final responses = await Future.wait([
      ApiService.get('/assets/stats/dashboard'),
      ApiService.get('/assets'),
      ApiService.get('/issues'),
      ApiService.get('/maintenance'),
      ApiService.get('/maintenance/stats'),
      ApiService.get('/labAdmin/labs'),
      ApiService.get('/labAdmin/approved-users?role=lab_technician'),
      ApiService.get('/labAdmin/pending-users'),
    ]);

    final assetStatsResp = responses[0];
    final assetsResp = responses[1];
    final issuesResp = responses[2];
    final maintenanceResp = responses[3];
    final maintenanceStatsResp = responses[4];
    final labsResp = responses[5];
    final techniciansResp = responses[6];
    final pendingUsersResp = responses[7];

    final assetStats = _asMap(assetStatsResp['data']);
    final assets = _asList(assetsResp['data'] ?? assetsResp);
    final issues = _asList(issuesResp['data'] ?? issuesResp);
    final maintenanceLogs = _asList(maintenanceResp['data'] ?? maintenanceResp);
    final maintenanceStats = _asMap(maintenanceStatsResp['data']);
    final labs = _asList(labsResp);
    final technicians = _asList(techniciansResp);
    final pendingUsers = _asList(pendingUsersResp);

    final totalAssets = _toInt(assetStats['totalAssets']);
    final assignedAssets = _toInt(assetStats['inUseAssets']);
    final availableAssets = _toInt(assetStats['availableAssets']);
    final maintenanceAssets = _toInt(assetStats['underMaintenanceAssets']);

    final totalLabs = labs.length;
    final activeTechnicians = technicians.length;

    final issueCounts = _buildIssueCounts(issues);
    final openIssues = issueCounts['open'] ?? 0;
    final resolvedIssues = issueCounts['resolved'] ?? 0;

    final pendingRequests = pendingUsers.length;

    final utilizationCurrent = totalAssets == 0
        ? 0.0
        : (assignedAssets / totalAssets) * 100.0;
    const utilizationTarget = 85.0;

    final assetCategoryCount = _buildAssetCategoryCount(assets);
    final monthlyMaintenanceCost = _buildMonthlyMaintenanceCost(maintenanceLogs);
    final recentActivities = _buildRecentActivities(
      assets: assets,
      issues: issues,
      maintenanceLogs: maintenanceLogs,
      pendingUsers: pendingUsers,
    );

    return {
      'totalAssets': totalAssets,
      'assignedAssets': assignedAssets,
      'availableAssets': availableAssets,
      'maintenanceAssets': maintenanceAssets,
      'totalLabs': totalLabs,
      'activeTechnicians': activeTechnicians,
      'openIssues': openIssues,
      'resolvedIssues': resolvedIssues,
      'pendingRequests': pendingRequests,
      'utilizationTarget': utilizationTarget,
      'utilizationCurrent': utilizationCurrent,
      'monthlyMaintenanceCost': monthlyMaintenanceCost,
      'assetCategoryCount': assetCategoryCount,
      'recentActivities': recentActivities,
      'maintenanceTotalCost': _toDouble(maintenanceStats['totalCost']),
    };
  }

  Map<String, int> _buildIssueCounts(List<Map<String, dynamic>> issues) {
    int open = 0;
    int resolved = 0;

    for (final issue in issues) {
      final status = (issue['status'] ?? '').toString().toLowerCase();
      if (status == 'resolved' || status == 'closed') {
        resolved++;
      } else if (status == 'pending' || status == 'accepted' || status == 'in_progress') {
        open++;
      }
    }

    return {'open': open, 'resolved': resolved};
  }

  Map<String, int> _buildAssetCategoryCount(List<Map<String, dynamic>> assets) {
    final map = <String, int>{};

    for (final asset in assets) {
      final key = (asset['category'] ?? 'Other').toString().trim();
      if (key.isEmpty) continue;
      map[key] = (map[key] ?? 0) + 1;
    }

    return map;
  }

  Map<String, double> _buildMonthlyMaintenanceCost(List<Map<String, dynamic>> logs) {
    final map = <String, double>{};

    for (final log in logs) {
      final dt = _parseDate(
        log['completedDate'] ?? log['reportedDate'] ?? log['createdAt'],
      );
      if (dt == null) continue;

      final key = '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';
      final cost = _toDouble(log['cost']);
      map[key] = (map[key] ?? 0) + cost;
    }

    return map;
  }

  List<Map<String, dynamic>> _buildRecentActivities({
    required List<Map<String, dynamic>> assets,
    required List<Map<String, dynamic>> issues,
    required List<Map<String, dynamic>> maintenanceLogs,
    required List<Map<String, dynamic>> pendingUsers,
  }) {
    final activities = <Map<String, dynamic>>[];

    for (final m in maintenanceLogs.take(10)) {
      final t = _parseDate(m['reportedDate'] ?? m['createdAt']);
      if (t == null) continue;
      activities.add({
        'title': '${(m['maintenanceType'] ?? 'Maintenance').toString()} - ${(m['assetName'] ?? 'Asset').toString()}',
        'time': t,
        'type': 'maintenance',
      });
    }

    for (final i in issues.take(10)) {
      final t = _parseDate(i['reportedAt'] ?? i['updatedAt'] ?? i['createdAt']);
      if (t == null) continue;
      final issueType = (i['issueType'] ?? 'Issue').toString();
      final status = (i['status'] ?? '').toString();
      activities.add({
        'title': '$issueType issue ($status)',
        'time': t,
        'type': 'issue',
      });
    }

    for (final a in assets.take(10)) {
      final t = _parseDate(a['createdAt'] ?? a['purchaseDate']);
      if (t == null) continue;
      activities.add({
        'title': 'New asset: ${(a['assetName'] ?? 'Asset').toString()}',
        'time': t,
        'type': 'asset',
      });
    }

    for (final p in pendingUsers.take(10)) {
      final t = _parseDate(p['createdAt']);
      if (t == null) continue;
      final name = '${(p['firstName'] ?? '').toString()} ${(p['lastName'] ?? '').toString()}'.trim();
      activities.add({
        'title': 'Pending approval: ${name.isEmpty ? (p['email'] ?? 'User') : name}',
        'time': t,
        'type': 'request',
      });
    }

    activities.sort((a, b) {
      final at = a['time'] as DateTime;
      final bt = b['time'] as DateTime;
      return bt.compareTo(at);
    });

    return activities.take(8).toList();
  }

  List<Map<String, dynamic>> _asList(dynamic v) {
    if (v is List) return List<Map<String, dynamic>>.from(v);
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    return <String, dynamic>{};
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}