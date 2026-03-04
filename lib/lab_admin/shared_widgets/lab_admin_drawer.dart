import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

class LabAdminDrawer extends StatefulWidget {
  final String currentRoute;

  const LabAdminDrawer({super.key, required this.currentRoute});

  @override
  State<LabAdminDrawer> createState() => _LabAdminDrawerState();
}

class _LabAdminDrawerState extends State<LabAdminDrawer> {
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawUser = prefs.getString('user');

      if (rawUser != null && rawUser.isNotEmpty) {
        final map = jsonDecode(rawUser);

        setState(() {
          _userEmail = map['email'] ?? '';
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.navy,
      child: Column(
        children: [

          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.darkBlue],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.neonBlue,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Asset Management System",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Lab Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _userEmail,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// MENU ITEMS

          _item(context, Icons.dashboard, "Dashboard", "/labAdminDashboard"),

          _item(context, Icons.pending_actions, "Pending Approvals", "/labAdminPendingApprovals"),

          _item(context, Icons.group, "Manage Users", "/labAdminUsers"),

          _item(context, Icons.settings, "Manage Skills Requirements", "/labAdminSkills"),

          _item(context, Icons.add_box, "Add New Categories", "/labAdminAddCategories"),

          _item(context, Icons.view_list, "Category Hierarchy", "/labAdminCategoryHierarchy"),

          _item(context, Icons.apartment, "Manage Departments", "/labAdminDepartments"),

          const Spacer(),

          const Divider(color: Colors.white24),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {

              await ApiService.clearToken();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }

  Widget _item(
      BuildContext context,
      IconData icon,
      String title,
      String route,
      ) {
    final bool selected = widget.currentRoute == route;

    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: selected ? AppColors.neonBlue : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppColors.neonBlue : Colors.white70,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}