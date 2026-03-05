// lib/lab_admin/category_hierarchy/category_hierarchy_screen.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/lab_admin_drawer.dart';
import 'services/category_hierarchy_service.dart';

class CategoryHierarchyScreen extends StatefulWidget {
  const CategoryHierarchyScreen({super.key});

  @override
  State<CategoryHierarchyScreen> createState() => _CategoryHierarchyScreenState();
}

class _CategoryHierarchyScreenState extends State<CategoryHierarchyScreen> {
  final CategoryHierarchyService _service = CategoryHierarchyService();

  final TextEditingController _newSubCategoryController = TextEditingController();
  final TextEditingController _newSpecificationController = TextEditingController();

  bool loading = true;
  bool actionLoading = false;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subCategories = [];
  List<Map<String, dynamic>> specifications = [];

  Map<String, dynamic>? selectedCategory;
  Map<String, dynamic>? selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _newSubCategoryController.dispose();
    _newSpecificationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    try {
      setState(() => loading = true);

      categories = await _service.getCategories();
      if (categories.isNotEmpty) {
        selectedCategory = categories.first;
        await _loadSubCategories();
      }
    } catch (e) {
      _showSnack('Failed to load hierarchy');
      debugPrint('loadInitial error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadSubCategories() async {
    final categoryId = (selectedCategory?['_id'] ?? '').toString();
    if (categoryId.isEmpty) {
      subCategories = [];
      specifications = [];
      selectedSubCategory = null;
      return;
    }

    subCategories = await _service.getSubCategories(categoryId);

    if (subCategories.isNotEmpty) {
      final selectedId = (selectedSubCategory?['_id'] ?? '').toString();
      selectedSubCategory = subCategories.firstWhere(
            (s) => (s['_id'] ?? '').toString() == selectedId,
        orElse: () => subCategories.first,
      );
      await _loadSpecifications();
    } else {
      selectedSubCategory = null;
      specifications = [];
    }
  }

  Future<void> _loadSpecifications() async {
    final subCategoryId = (selectedSubCategory?['_id'] ?? '').toString();
    if (subCategoryId.isEmpty) {
      specifications = [];
      return;
    }
    specifications = await _service.getSpecifications(subCategoryId);
  }

  Future<void> _createSubCategory() async {
    final name = _newSubCategoryController.text.trim();
    final categoryId = (selectedCategory?['_id'] ?? '').toString();

    if (name.isEmpty || categoryId.isEmpty) {
      _showSnack('Please select category and enter subcategory name');
      return;
    }

    try {
      setState(() => actionLoading = true);

      await _service.createSubCategory(name: name, categoryId: categoryId);
      _newSubCategoryController.clear();
      await _loadSubCategories();

      _showSnack('Subcategory added');
      setState(() {});
    } catch (e) {
      _showSnack('Failed to add subcategory');
      debugPrint('createSubCategory error: $e');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _createSpecification() async {
    final name = _newSpecificationController.text.trim();
    final categoryId = (selectedCategory?['_id'] ?? '').toString();
    final subCategoryId = (selectedSubCategory?['_id'] ?? '').toString();

    if (name.isEmpty || categoryId.isEmpty || subCategoryId.isEmpty) {
      _showSnack('Please select category/subcategory and enter specification');
      return;
    }

    try {
      setState(() => actionLoading = true);

      await _service.createSpecification(
        name: name,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
      );
      _newSpecificationController.clear();
      await _loadSpecifications();

      _showSnack('Specification added');
      setState(() {});
    } catch (e) {
      _showSnack('Failed to add specification');
      debugPrint('createSpecification error: $e');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _editSubCategory(Map<String, dynamic> item) async {
    final controller = TextEditingController(text: (item['name'] ?? '').toString());
    final newName = await _showNameDialog(
      title: 'Edit Subcategory',
      controller: controller,
      hint: 'Enter subcategory name',
    );
    if (newName == null) return;

    try {
      setState(() => actionLoading = true);
      await _service.updateSubCategory(id: item['_id'].toString(), name: newName);
      await _loadSubCategories();
      _showSnack('Subcategory updated');
      setState(() {});
    } catch (e) {
      _showSnack('Failed to update subcategory');
      debugPrint('editSubCategory error: $e');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _deleteSubCategory(Map<String, dynamic> item) async {
    final ok = await _confirm('Delete this subcategory?');
    if (ok != true) return;

    try {
      setState(() => actionLoading = true);
      await _service.deleteSubCategory(item['_id'].toString());
      await _loadSubCategories();
      _showSnack('Subcategory deleted');
      setState(() {});
    } catch (e) {
      _showSnack('Failed to delete subcategory');
      debugPrint('deleteSubCategory error: $e');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _editSpecification(Map<String, dynamic> item) async {
    final controller = TextEditingController(text: (item['name'] ?? '').toString());
    final newName = await _showNameDialog(
      title: 'Edit Specification',
      controller: controller,
      hint: 'Enter specification',
    );
    if (newName == null) return;

    try {
      setState(() => actionLoading = true);
      await _service.updateSpecification(id: item['_id'].toString(), name: newName);
      await _loadSpecifications();
      _showSnack('Specification updated');
      setState(() {});
    } catch (e) {
      _showSnack('Failed to update specification');
      debugPrint('editSpecification error: $e');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _deleteSpecification(Map<String, dynamic> item) async {
    final ok = await _confirm('Delete this specification?');
    if (ok != true) return;

    try {
      setState(() => actionLoading = true);
      await _service.deleteSpecification(item['_id'].toString());
      await _loadSpecifications();
      _showSnack('Specification deleted');
      setState(() {});
    } catch (e) {
      _showSnack('Failed to delete specification');
      debugPrint('deleteSpecification error: $e');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<String?> _showNameDialog({
    required String title,
    required TextEditingController controller,
    required String hint,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirm(String text) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabAdminDrawer(currentRoute: '/categoryHierarchy'),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Manage Category Hierarchy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 1: Select a Category',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: (selectedCategory?['_id'] ?? '').toString().isEmpty
                  ? null
                  : selectedCategory!['_id'].toString(),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: categories.map((c) {
                return DropdownMenuItem<String>(
                  value: c['_id'].toString(),
                  child: Text((c['name'] ?? '').toString()),
                );
              }).toList(),
              onChanged: (v) async {
                selectedCategory = categories.firstWhere(
                      (c) => c['_id'].toString() == v,
                  orElse: () => {},
                );
                selectedSubCategory = null;
                setState(() {});
                await _loadSubCategories();
                setState(() {});
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Step 2: Manage Subcategories for "${(selectedCategory?['name'] ?? '-')}"',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSubCategoryController,
                    decoration: const InputDecoration(
                      hintText: 'Enter subcategory name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: actionLoading ? null : _createSubCategory,
                  child: const Text('+ Add SubCategory'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: subCategories.map((s) {
                final selected = (selectedSubCategory?['_id'] ?? '').toString() ==
                    (s['_id'] ?? '').toString();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? Colors.blue : Colors.grey.shade300,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            selectedSubCategory = s;
                            await _loadSpecifications();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              (s['name'] ?? '').toString(),
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          selectedSubCategory = s;
                          await _loadSpecifications();
                          setState(() {});
                        },
                        child: const Text('Manage Specs'),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: actionLoading ? null : () => _editSubCategory(s),
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: actionLoading ? null : () => _deleteSubCategory(s),
                        icon: const Icon(Icons.delete, color: Colors.black87),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            Text(
              'Step 3: Manage Specifications for "${(selectedSubCategory?['name'] ?? '-')}"',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSpecificationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter specification',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: actionLoading ? null : _createSpecification,
                  child: const Text('+ Add Specification'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: specifications.map((sp) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (sp['name'] ?? '').toString(),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: actionLoading ? null : () => _editSpecification(sp),
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: actionLoading ? null : () => _deleteSpecification(sp),
                        icon: const Icon(Icons.delete, color: Colors.black87),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/*
// lib/lab_admin/category_hierarchy/category_hierarchy_screen.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/lab_admin_drawer.dart';
import 'services/category_hierarchy_service.dart';

class CategoryHierarchyScreen extends StatefulWidget {
  const CategoryHierarchyScreen({super.key});

  @override
  State<CategoryHierarchyScreen> createState() =>
      _CategoryHierarchyScreenState();
}

class _CategoryHierarchyScreenState extends State<CategoryHierarchyScreen> {
  final CategoryHierarchyService _service = CategoryHierarchyService();

  final TextEditingController _newSubCategoryController =
  TextEditingController();

  final TextEditingController _newSpecificationController =
  TextEditingController();

  bool loading = true;
  bool actionLoading = false;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subCategories = [];
  List<Map<String, dynamic>> specifications = [];

  Map<String, dynamic>? selectedCategory;
  Map<String, dynamic>? selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _newSubCategoryController.dispose();
    _newSpecificationController.dispose();
    super.dispose();
  }

  /* =======================================================
     INITIAL LOAD
  ======================================================= */

  Future<void> _loadInitial() async {
    try {
      setState(() => loading = true);

      categories = await _service.getCategories();

      if (categories.isNotEmpty) {
        selectedCategory = categories.first;
        await _loadSubCategories();
      }
    } catch (e) {
      _showSnack('Failed to load hierarchy');
      debugPrint('loadInitial error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadSubCategories() async {
    final categoryId = (selectedCategory?['_id'] ?? '').toString();

    if (categoryId.isEmpty) {
      subCategories = [];
      specifications = [];
      selectedSubCategory = null;
      return;
    }

    subCategories = await _service.getSubCategories(categoryId);

    if (subCategories.isNotEmpty) {
      selectedSubCategory = subCategories.first;
      await _loadSpecifications();
    } else {
      selectedSubCategory = null;
      specifications = [];
    }
  }

  Future<void> _loadSpecifications() async {
    final subCategoryId = (selectedSubCategory?['_id'] ?? '').toString();

    if (subCategoryId.isEmpty) {
      specifications = [];
      return;
    }

    specifications = await _service.getSpecifications(subCategoryId);
  }

  /* =======================================================
     CREATE SUBCATEGORY
  ======================================================= */

  Future<void> _createSubCategory() async {
    final name = _newSubCategoryController.text.trim();
    final categoryId = (selectedCategory?['_id'] ?? '').toString();

    if (name.isEmpty || categoryId.isEmpty) {
      _showSnack('Please select category and enter subcategory name');
      return;
    }

    try {
      setState(() => actionLoading = true);

      await _service.createSubCategory(
        name: name,
        categoryId: categoryId,
      );

      _newSubCategoryController.clear();

      await _loadSubCategories();

      _showSnack('Subcategory added');

      setState(() {});
    } catch (e) {
      _showSnack('Failed to add subcategory');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  /* =======================================================
     CREATE SPECIFICATION
  ======================================================= */

  Future<void> _createSpecification() async {
    final name = _newSpecificationController.text.trim();

    final categoryId = (selectedCategory?['_id'] ?? '').toString();

    final subCategoryId = (selectedSubCategory?['_id'] ?? '').toString();

    if (name.isEmpty || categoryId.isEmpty || subCategoryId.isEmpty) {
      _showSnack('Please select category/subcategory and enter specification');
      return;
    }

    try {
      setState(() => actionLoading = true);

      await _service.createSpecification(
        name: name,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
      );

      _newSpecificationController.clear();

      await _loadSpecifications();

      _showSnack('Specification added');

      setState(() {});
    } catch (e) {
      _showSnack('Failed to add specification');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  /* =======================================================
     SNACKBAR
  ======================================================= */

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /* =======================================================
     UI
  ======================================================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabAdminDrawer(
        currentRoute: '/labAdminCategoryHierarchy',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Manage Category Hierarchy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 10 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// STEP 1
                  Text(
                    'Step 1: Select a Category',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedCategory?['_id']?.toString(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['_id'].toString(),
                        child: Text(c['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (v) async {
                      selectedCategory = categories.firstWhere(
                              (c) => c['_id'].toString() == v);
                      selectedSubCategory = null;
                      setState(() {});
                      await _loadSubCategories();
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 24),

                  /// STEP 2
                  Text(
                    'Step 2: Manage Subcategories',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  isMobile
                      ? Column(
                    children: [
                      TextField(
                        controller: _newSubCategoryController,
                        decoration: const InputDecoration(
                          hintText: 'Enter subcategory name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: actionLoading
                              ? null
                              : _createSubCategory,
                          child:
                          const Text('+ Add SubCategory'),
                        ),
                      ),
                    ],
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                          _newSubCategoryController,
                          decoration: const InputDecoration(
                            hintText: 'Enter subcategory name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: actionLoading
                            ? null
                            : _createSubCategory,
                        child: const Text('+ Add SubCategory'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: subCategories.map((s) {
                      final selected =
                          selectedSubCategory?['_id'] ==
                              s['_id'];

                      return Container(
                        width: isMobile ? double.infinity : 340,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () async {
                            selectedSubCategory = s;
                            await _loadSpecifications();
                            setState(() {});
                          },
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 8),
                            child: Text(
                              s['name'].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  /// STEP 3
                  Text(
                    'Step 3: Manage Specifications',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  isMobile
                      ? Column(
                    children: [
                      TextField(
                        controller:
                        _newSpecificationController,
                        decoration: const InputDecoration(
                          hintText: 'Enter specification',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: actionLoading
                              ? null
                              : _createSpecification,
                          child: const Text(
                              '+ Add Specification'),
                        ),
                      ),
                    ],
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                          _newSpecificationController,
                          decoration: const InputDecoration(
                            hintText: 'Enter specification',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: actionLoading
                            ? null
                            : _createSpecification,
                        child: const Text(
                            '+ Add Specification'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: specifications.map((sp) {
                      return Container(
                        width: isMobile ? double.infinity : 340,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Text(
                          sp['name'].toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
 */