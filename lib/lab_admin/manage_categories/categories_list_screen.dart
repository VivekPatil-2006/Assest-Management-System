// lib/lab_admin/manage_categories/categories_list_screen.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/lab_admin_drawer.dart';
import 'categories_add_screen.dart';
import 'categories_details_screen.dart';
import 'services/categories_service.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  final CategoriesService _service = CategoriesService();
  final TextEditingController _searchController = TextEditingController();

  bool loading = true;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearch);
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => loading = true);
      categories = await _service.getAllCategories();
      _applySearch();
    } catch (e) {
      categories = [];
      filteredCategories = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load categories')),
        );
      }
      debugPrint('load categories error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() {
        filteredCategories = List<Map<String, dynamic>>.from(categories);
      });
      return;
    }

    final result = categories.where((c) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();

    setState(() => filteredCategories = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabAdminDrawer(currentRoute: '/addCategories'),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Add New Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: filteredCategories.isEmpty
                ? const Center(
              child: Text(
                'No categories found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadCategories,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                itemCount: filteredCategories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final category = filteredCategories[i];
                  final name = (category['name'] ?? '-').toString();

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoriesDetailsScreen(
                            category: category,
                          ),
                        ),
                      );
                      if (changed == true) {
                        await _loadCategories();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6,
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const CategoriesAddScreen(),
            ),
          );

          if (created == true) {
            await _loadCategories();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}