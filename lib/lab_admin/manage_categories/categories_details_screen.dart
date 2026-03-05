import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'services/categories_service.dart';

class CategoriesDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoriesDetailsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoriesDetailsScreen> createState() =>
      _CategoriesDetailsScreenState();
}

class _CategoriesDetailsScreenState extends State<CategoriesDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoriesService _service = CategoriesService();

  late TextEditingController _nameController;

  bool editing = false;
  bool saving = false;
  bool deleting = false;

  String get categoryId => (widget.category['_id'] ?? '').toString();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: (widget.category['name'] ?? '').toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /* =======================================================
     UPDATE CATEGORY
  ======================================================= */

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (categoryId.isEmpty) return;

    try {
      setState(() => saving = true);

      await _service.updateCategory(
        categoryId: categoryId,
        name: _nameController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update category')),
      );

      debugPrint('update category error: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  /* =======================================================
     DELETE CATEGORY
  ======================================================= */

  Future<void> _deleteCategory() async {
    if (categoryId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content:
        const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => deleting = true);

      await _service.deleteCategory(categoryId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete category')),
      );

      debugPrint('delete category error: $e');
    } finally {
      if (mounted) setState(() => deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// ❌ NO DRAWER

      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,

        /// ✅ BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Category Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          if (!editing)
            IconButton(
              onPressed: () => setState(() => editing = true),
              icon: const Icon(Icons.edit),
            ),

          IconButton(
            onPressed: deleting ? null : _deleteCategory,
            icon: deleting
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                enabled: editing,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Category name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              if (editing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : _updateCategory,
                    icon: saving
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                      CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.save),
                    label:
                    Text(saving ? 'Saving...' : 'Update Category'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}