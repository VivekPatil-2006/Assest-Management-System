import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'services/categories_service.dart';

class CategoriesAddScreen extends StatefulWidget {
  const CategoriesAddScreen({super.key});

  @override
  State<CategoriesAddScreen> createState() => _CategoriesAddScreenState();
}

class _CategoriesAddScreenState extends State<CategoriesAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoriesService _service = CategoriesService();

  final TextEditingController _nameController = TextEditingController();
  bool submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => submitting = true);

      await _service.addCategory(
        name: _nameController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add category')),
      );

      debugPrint('add category error: $e');
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
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
          'Add Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: submitting ? null : _addCategory,

                  icon: submitting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.add),

                  label: Text(
                    submitting ? 'Saving...' : 'Add Category',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}