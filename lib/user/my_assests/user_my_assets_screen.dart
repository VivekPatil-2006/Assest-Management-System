import 'package:assest_management_system/user/my_assests/services/user_my_assets_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../shared_widgets/user_drawer.dart';

class UserMyAssetsScreen extends StatefulWidget {
  const UserMyAssetsScreen({super.key});

  @override
  State<UserMyAssetsScreen> createState() => _UserMyAssetsScreenState();
}

class _UserMyAssetsScreenState extends State<UserMyAssetsScreen> {
  bool _loading = false;
  String? _error;
  List<MyAssignedAsset> _items = [];

  @override
  void initState() {
    super.initState();
    _loadMyAssets();
  }

  Future<void> _loadMyAssets() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await UserMyAssetsService.fetchMyAssets();
      if (!mounted) return;
      setState(() => _items = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const UserDrawer(currentRoute: '/userMyAssets'),
      appBar: AppBar(
        title: const Text('My Assets'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyAssets,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text(
              'Assets Assigned to You (${_items.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (_error != null) _errorCard(_error!),
            if (_loading && _items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No assets assigned yet')),
                ),
              )
            else
              _assetsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: _loading ? null : _loadMyAssets,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int count = 1;
        if (width >= 1200) {
          count = 4;
        } else if (width >= 900) {
          count = 3;
        } else if (width >= 600) {
          count = 2;
        }

        return GridView.builder(
          itemCount: _items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            return _assetCard(_items[index]);
          },
        );
      },
    );
  }

  Widget _assetCard(MyAssignedAsset a) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blue.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Header
              Row(
                children: [
                  const Icon(Icons.devices, size: 18, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      a.assetName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _pill('Assigned', Colors.green),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),

              const SizedBox(height: 10),

              _info(Icons.confirmation_number, 'Serial', a.serialNumber),
              _info(Icons.category, 'Category', a.category),
              _info(Icons.location_on, 'Lab', a.labLocation),
              _info(Icons.desk, 'Desk', a.deskLocation),
              _info(Icons.person, 'Assigned By', a.assignedByName),
              _info(Icons.calendar_today, 'Assigned', _fmtDate(a.assignedDate)),

              if (a.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          a.notes,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _fmtDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}