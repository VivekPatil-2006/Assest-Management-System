import 'package:assest_management_system/user/available_assests/services/user_available_assets_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../shared_widgets/user_drawer.dart';

class UserAvailableScreen extends StatefulWidget {
  const UserAvailableScreen({super.key});

  @override
  State<UserAvailableScreen> createState() => _UserAvailableScreenState();
}

class _UserAvailableScreenState extends State<UserAvailableScreen> {
  bool _loading = false;
  String? _error;
  List<AvailableAsset> _assets = [];

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await UserAvailableAssetsService.fetchAvailableAssets();

      if (!mounted) return;
      setState(() {
        _assets = data;
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

  List<AvailableAsset> get _filteredAssets {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return _assets;

    return _assets.where((a) {
      return a.assetName.toLowerCase().contains(query) ||
          a.serialNumber.toLowerCase().contains(query) ||
          a.brand.toLowerCase().contains(query) ||
          a.model.toLowerCase().contains(query) ||
          a.category.toLowerCase().contains(query) ||
          a.labLocation.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAssets;

    return Scaffold(
      drawer: const UserDrawer(currentRoute: '/userAvailableAssets'),
      appBar: AppBar(
        title: const Text('Available'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssets,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            if (_error != null) _buildErrorCard(_error!),
            if (_loading && _assets.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No available assets found')),
                ),
              )
            else
              _buildGrid(filtered),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (value) => setState(() => _searchText = value),
      decoration: InputDecoration(
        hintText: 'Search asset, serial, brand, category...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchText.isEmpty
            ? null
            : IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchCtrl.clear();
            setState(() => _searchText = '');
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
    );
  }

  Widget _buildErrorCard(String message) {
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
              onPressed: _loading ? null : _loadAssets,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<AvailableAsset> assets) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 1;
        if (width >= 1200) {
          crossAxisCount = 4;
        } else if (width >= 900) {
          crossAxisCount = 3;
        } else if (width >= 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          itemCount: assets.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            return _assetCard(assets[index]);
          },
        );
      },
    );
  }

  Widget _assetCard(AvailableAsset asset) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    asset.assetName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _pill(asset.category, Colors.indigo),
              ],
            ),
            const SizedBox(height: 10),
            _infoRow('Serial', asset.serialNumber),
            _infoRow('Brand', asset.brand),
            _infoRow('Model', asset.model),
            _infoRow('Location', asset.labLocation),
            _infoRow('Status', _pretty(asset.status), valueWidget: _pill(_pretty(asset.status), _statusColor(asset.status))),
            _infoRow('Condition', _pretty(asset.condition), valueWidget: _pill(_pretty(asset.condition), _conditionColor(asset.condition))),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/userRequestAsset',
                    arguments: {
                      'assetId': asset.id,
                      'assetName': asset.assetName,
                    },
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Request Asset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 66,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: valueWidget ??
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
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
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _pretty(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'in_use':
        return Colors.blue;
      case 'under_maintenance':
        return Colors.orange;
      case 'disposed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _conditionColor(String condition) {
    switch (condition) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'damaged':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}