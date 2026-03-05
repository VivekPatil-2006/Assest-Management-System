// lib/lab_admin/manage_departments/manage_departments_screen.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/lab_admin_drawer.dart';
import 'services/department_service.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  State<ManageDepartmentsScreen> createState() => _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  final DepartmentService _service = DepartmentService();

  final TextEditingController _newDepartmentController = TextEditingController();

  bool loading = true;
  bool actionLoading = false;

  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> assetIncharges = [];

  String selectedDepartmentLabel = '';
  String selectedInchargeId = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _newDepartmentController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      setState(() => loading = true);

      final deptData = await _service.getAllDepartments();
      final inchargeData = await _service.getAssetIncharges();

      departments = deptData;
      assetIncharges = inchargeData;

      if (departments.isNotEmpty && selectedDepartmentLabel.isEmpty) {
        selectedDepartmentLabel = (departments.first['label'] ?? '').toString();
      }
      if (assetIncharges.isNotEmpty && selectedInchargeId.isEmpty) {
        selectedInchargeId = (assetIncharges.first['_id'] ?? '').toString();
      }
    } catch (e) {
      _showSnack('Failed to load departments');
      debugPrint('loadAll error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _addDepartment() async {
    final label = _newDepartmentController.text.trim();
    if (label.isEmpty) {
      _showSnack('Enter department name');
      return;
    }

    try {
      setState(() => actionLoading = true);
      await _service.addDepartment(label: label);
      _newDepartmentController.clear();
      await _loadAll();
      _showSnack('Department added successfully');
    } catch (e) {
      _showSnack('Failed to add department');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _assignDepartment() async {
    if (selectedDepartmentLabel.isEmpty || selectedInchargeId.isEmpty) {
      _showSnack('Select department and asset incharge');
      return;
    }

    try {
      setState(() => actionLoading = true);
      await _service.assignDepartment(
        userId: selectedInchargeId,
        departmentLabel: selectedDepartmentLabel,
      );
      await _loadAll();
      _showSnack('Department assigned successfully');
    } catch (e) {
      _showSnack('Failed to assign department');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _unassignDepartment(String userId) async {
    try {
      setState(() => actionLoading = true);
      await _service.unassignDepartment(userId: userId);
      await _loadAll();
      _showSnack('Department unassigned successfully');
    } catch (e) {
      _showSnack('Failed to unassign department');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _editDepartment(Map<String, dynamic> department) async {
    final controller = TextEditingController(
      text: (department['label'] ?? '').toString(),
    );

    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Department'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter department name',
            border: OutlineInputBorder(),
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

    if (updated == null || updated.isEmpty) return;

    try {
      setState(() => actionLoading = true);
      await _service.updateDepartment(
        departmentId: department['_id'].toString(),
        label: updated,
      );
      await _loadAll();
      _showSnack('Department updated successfully');
    } catch (e) {
      _showSnack('Failed to update department');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _deleteDepartment(String id) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Department'),
        content: const Text('Are you sure you want to delete this department?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (yes != true) return;

    try {
      setState(() => actionLoading = true);
      await _service.deleteDepartment(id);
      await _loadAll();
      _showSnack('Department deleted successfully');
    } catch (e) {
      _showSnack('Failed to delete department');
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _displayName(Map<String, dynamic> user) {
    final first = (user['firstName'] ?? '').toString().trim();
    final last = (user['lastName'] ?? '').toString().trim();
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    return (user['name'] ?? 'Unknown').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabAdminDrawer(currentRoute: '/manageDepartments'),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Manage Departments',
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ADD DEPARTMENT
                  const Text(
                    'Add New Department',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  isMobile
                      ? Column(
                    children: [
                      TextField(
                        controller: _newDepartmentController,
                        decoration: const InputDecoration(
                          hintText: 'Enter department name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: actionLoading ? null : _addDepartment,
                          child: const Text('+ Add Department'),
                        ),
                      )
                    ],
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newDepartmentController,
                          decoration: const InputDecoration(
                            hintText: 'Enter department name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: actionLoading ? null : _addDepartment,
                        child: const Text('+ Add Department'),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// ASSIGN SECTION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          'Assign Department to Asset Incharge',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedDepartmentLabel.isEmpty ? null : selectedDepartmentLabel,
                          decoration: const InputDecoration(
                            labelText: 'Select Department',
                            border: OutlineInputBorder(),
                          ),
                          items: departments
                              .map(
                                (d) => DropdownMenuItem<String>(
                              value: (d['label'] ?? '').toString(),
                              child: Text((d['label'] ?? '').toString()),
                            ),
                          )
                              .toList(),
                          onChanged: (v) => setState(() => selectedDepartmentLabel = v ?? ''),
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedInchargeId.isEmpty ? null : selectedInchargeId,
                          decoration: const InputDecoration(
                            labelText: 'Select Asset Incharge',
                            border: OutlineInputBorder(),
                          ),
                          items: assetIncharges
                              .map(
                                (u) => DropdownMenuItem<String>(
                              value: (u['_id'] ?? '').toString(),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${_displayName(u)} (${u['email'] ?? '-'})',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          )
                              .toList(),
                          onChanged: (v) => setState(() => selectedInchargeId = v ?? ''),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: actionLoading ? null : _assignDepartment,
                            child: const Text('Assign Department'),
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// DEPARTMENTS LIST
                  const Text(
                    'Departments',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: departments.map((dept) {

                      final label = (dept['label'] ?? '').toString();

                      final assigned = assetIncharges.where(
                            (u) => (u['department'] ?? '').toString() == label,
                      ).toList();

                      return Container(
                        width: isMobile ? double.infinity : 340,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                IconButton(
                                  onPressed: actionLoading ? null : () => _editDepartment(dept),
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                ),

                                IconButton(
                                  onPressed: actionLoading
                                      ? null
                                      : () => _deleteDepartment((dept['_id'] ?? '').toString()),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),

                            if (assigned.isNotEmpty) ...[

                              Text(
                                '${assigned.length} incharge assigned',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                'Assigned to:',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 6),

                              ...assigned.map(
                                    (u) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(_displayName(u))),
                                      TextButton(
                                        onPressed: actionLoading
                                            ? null
                                            : () => _unassignDepartment((u['_id'] ?? '').toString()),
                                        child: const Text('Unassign'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ],

                          ],
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