// lib/lab_admin/manage_user/user_list_screen.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/lab_admin_drawer.dart';
import 'services/user_service.dart';
import 'user_create_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  bool loading = true;
  bool deleting = false;

  String selectedFilter = 'all'; // all | lab_technician | asset_incharge | asset_user
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearch);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearch);
    _searchController.dispose();
    super.dispose();
  }

  /* =======================================================
     LOAD USERS
     ======================================================= */
  Future<void> _loadUsers() async {
    try {
      setState(() => loading = true);

      final data = await _userService.getUsers(filter: selectedFilter);
      users = data;
      _applySearch();
    } catch (e) {
      users = [];
      filteredUsers = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load users')),
        );
      }
      debugPrint('load users error: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  /* =======================================================
     SEARCH
     ======================================================= */
  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => filteredUsers = List<Map<String, dynamic>>.from(users));
      return;
    }

    final result = users.where((u) {
      final firstName = (u['firstName'] ?? '').toString().toLowerCase();
      final lastName = (u['lastName'] ?? '').toString().toLowerCase();
      final name = (u['name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final role = (u['role'] ?? '').toString().toLowerCase();

      return firstName.contains(q) ||
          lastName.contains(q) ||
          name.contains(q) ||
          email.contains(q) ||
          role.contains(q);
    }).toList();

    setState(() => filteredUsers = result);
  }

  /* =======================================================
     FILTER CHANGE
     ======================================================= */
  Future<void> _onFilterChange(String filter) async {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    await _loadUsers();
  }

  /* =======================================================
     DELETE USER
     ======================================================= */
  Future<void> _onDeleteUser(String userId) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
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

    if (yes != true) return;

    try {
      setState(() => deleting = true);
      await _userService.deleteUser(userId);

      users.removeWhere((u) => (u['_id'] ?? '').toString() == userId);
      _applySearch();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
      debugPrint('delete user error: $e');
    } finally {
      if (mounted) {
        setState(() => deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabAdminDrawer(currentRoute: '/manageUsers'),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Manage Users',
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
                hintText: 'Search by name, email or role...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('All', 'all'),
                _filterChip('Technician', 'lab_technician'),
                _filterChip('Assets Incharge', 'asset_incharge'),
                _filterChip('Assets User', 'asset_user'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
              child: Text(
                'No users found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final user = filteredUsers[i];
                  final id = (user['_id'] ?? '').toString();

                  final firstName = (user['firstName'] ?? '').toString();
                  final lastName = (user['lastName'] ?? '').toString();
                  final fallbackName = (user['name'] ?? '-').toString();
                  final fullName = '$firstName $lastName'.trim().isEmpty
                      ? fallbackName
                      : '$firstName $lastName';

                  final email = (user['email'] ?? '-').toString();
                  final role = (user['role'] ?? '-').toString();

                  return _userCard(
                    id: id,
                    name: fullName,
                    email: email,
                    role: role,
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
            MaterialPageRoute(builder: (_) => const UserCreateScreen()),
          );

          if (created == true) {
            await _loadUsers();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _onFilterChange(value),
    );
  }

  Widget _userCard({
    required String id,
    required String name,
    required String email,
    required String role,
  }) {
    return Container(
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
          CircleAvatar(
            radius: 22,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                _roleChip(role),
              ],
            ),
          ),
          deleting
              ? const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : IconButton(
            onPressed: id.isEmpty ? null : () => _onDeleteUser(id),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String role) {
    final normalized = role.toLowerCase();

    Color bg;
    Color fg;

    if (normalized == 'lab_technician') {
      bg = Colors.green.withOpacity(0.15);
      fg = Colors.green;
    } else if (normalized == 'asset_incharge') {
      bg = Colors.blue.withOpacity(0.15);
      fg = Colors.blue;
    } else {
      bg = Colors.orange.withOpacity(0.15);
      fg = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}