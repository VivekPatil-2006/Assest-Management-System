import 'package:assest_management_system/user/overview/services/user_overview_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../shared_widgets/user_drawer.dart';

class UserOverview extends StatefulWidget {
  const UserOverview({super.key});

  @override
  State<UserOverview> createState() => _UserOverviewState();
}

class _UserOverviewState extends State<UserOverview> {
  bool _loading = false;
  String? _error;
  UserOverviewData? _data;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await UserOverviewService.fetchOverview();
      if (!mounted) return;

      setState(() {
        _data = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const UserDrawer(currentRoute: '/userOverview'),
      appBar: AppBar(
        title: const Text('Overview'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOverview,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _data == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildErrorCard(_error!),
        ],
      );
    }

    final data = _data;
    if (data == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('No data available'),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Quick Stats'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _kpiCard('Total Assets', data.totalAssets, Colors.blue),
            _kpiCard('Unassigned', data.unassigned, Colors.teal),
            _kpiCard('Assigned', data.assigned, Colors.indigo),
            _kpiCard('Maintenance', data.underMaintenance, Colors.orange),
            _kpiCard('Disposed', data.disposed, Colors.red),
            _kpiCard('My Assets', data.myAssets, Colors.deepPurple),
          ],
        ),
        const SizedBox(height: 18),
        _buildSectionTitle('My Requests'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _requestChip('Pending', data.pendingRequests, Colors.orange.shade700),
            _requestChip('Approved', data.approvedRequests, Colors.green.shade700),
            _requestChip('Rejected', data.rejectedRequests, Colors.red.shade700),
          ],
        ),
        const SizedBox(height: 18),
        _buildSectionTitle('Assets by Status'),
        const SizedBox(height: 8),
        _simpleBarList(data.assetsByStatus, Colors.blue),
        const SizedBox(height: 18),
        _buildSectionTitle('Assets by Category'),
        const SizedBox(height: 8),
        _simpleBarList(data.assetsByCategory, Colors.teal),
        const SizedBox(height: 18),
        _buildSectionTitle('Assets by Lab Location'),
        const SizedBox(height: 8),
        _simpleBarList(data.assetsByLocation, Colors.deepPurple),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Failed to load overview',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadOverview,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _kpiCard(String label, int value, Color accent) {
    return SizedBox(
      width: 165,
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: accent.withValues(alpha: 0.12),
                child: Icon(Icons.inventory_2, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _requestChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _simpleBarList(Map<String, int> map, Color color) {
    if (map.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('No chart data available'),
        ),
      );
    }

    final maxValue = map.values.fold<int>(0, (p, e) => e > p ? e : p).clamp(1, 1 << 30);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: map.entries.map((entry) {
            final ratio = entry.value / maxValue;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      entry.key,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}