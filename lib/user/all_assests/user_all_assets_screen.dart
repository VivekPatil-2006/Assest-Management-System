import 'package:assest_management_system/user/all_assests/services/user_all_assets_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../shared_widgets/user_drawer.dart';

class UserAllAssetsScreen extends StatefulWidget {
  const UserAllAssetsScreen({super.key});

  @override
  State<UserAllAssetsScreen> createState() => _UserAllAssetsScreenState();
}

class _UserAllAssetsScreenState extends State<UserAllAssetsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  List<UserAssetItem> _assets = [];
  int _total = 0;
  int _page = 1;
  int _totalPages = 1;

  String _status = 'all';
  String _condition = 'all';
  String _category = 'all';

  final List<String> _statusOptions = const [
    'all',
    'available',
    'in_use',
    'under_maintenance',
    'disposed',
  ];

  final List<String> _conditionOptions = const [
    'all',
    'excellent',
    'good',
    'fair',
    'damaged',
  ];

  final List<String> _categoryOptions = const [
    'all',
    'Computer Hardware',
    'Computer',
    'Electronics',
    'IT',
  ];

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

  Future<void> _loadAssets({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await UserAllAssetsService.fetchAllAssets(
        search: _searchCtrl.text,
        status: _status,
        condition: _condition,
        category: _category,
        page: page ?? _page,
        limit: 50,
      );

      if (!mounted) return;
      setState(() {
        _assets = res.assets;
        _total = res.total;
        _page = res.page;
        _totalPages = res.totalPages;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _resetFilters() {
    setState(() {
      _status = 'all';
      _condition = 'all';
      _category = 'all';
      _searchCtrl.clear();
      _page = 1;
    });
    _loadAssets(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const UserDrawer(currentRoute: '/userAllAssets'),
      appBar: AppBar(
        title: Text('All Assets ($_total)'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadAssets(page: _page),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _searchBar(),
            const SizedBox(height: 10),
            _filtersCard(),
            const SizedBox(height: 10),
            if (_error != null) _errorCard(),
            if (_loading && _assets.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _tableCard(),
            const SizedBox(height: 10),
            _paginationBar(),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search name, serial, brand...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
            onSubmitted: (_) => _loadAssets(page: 1),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _loading ? null : () => _loadAssets(page: 1),
          child: const Text('Search'),
        ),
      ],
    );
  }

  Widget _filtersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _dropdown(
              label: 'Status',
              value: _status,
              items: _statusOptions,
              onChanged: (v) => setState(() => _status = v),
            ),
            const SizedBox(height: 8),
            _dropdown(
              label: 'Condition',
              value: _condition,
              items: _conditionOptions,
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: 8),
            _dropdown(
              label: 'Category',
              value: _category,
              items: _categoryOptions,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : _resetFilters,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _loadAssets(page: 1),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(_pretty(e)),
      ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _errorCard() {
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
                _error ?? 'Unknown error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: _loading ? null : () => _loadAssets(page: _page),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCard() {
    if (_assets.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No assets found')),
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Serial #')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Brand / Model')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Assigned')),
            DataColumn(label: Text('Condition')),
            DataColumn(label: Text('Action')),
          ],
          rows: _assets.map((a) {
            return DataRow(
              cells: [
                DataCell(Text(a.assetName)),
                DataCell(Text(a.serialNumber)),
                DataCell(Text(a.category)),
                DataCell(Text(a.brandModel)),
                DataCell(Text(a.labLocation)),
                DataCell(_chip(_pretty(a.status), _statusColor(a.status))),
                DataCell(_chip(a.isAssigned ? 'Taken' : 'Free', a.isAssigned ? Colors.pink : Colors.green)),
                DataCell(_chip(_pretty(a.condition), _conditionColor(a.condition))),
                DataCell(
                  a.isAssigned
                      ? const Text('-')
                      : ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/userRequestAsset',
                        arguments: {'assetId': a.id, 'assetName': a.assetName},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(88, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('+ Request'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _paginationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Page $_page of $_totalPages'),
        Row(
          children: [
            IconButton(
              onPressed: (_loading || _page <= 1) ? null : () => _loadAssets(page: _page - 1),
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: (_loading || _page >= _totalPages) ? null : () => _loadAssets(page: _page + 1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
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