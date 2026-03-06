import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

class UserDrawer extends StatefulWidget {
  final String currentRoute;

  const UserDrawer({super.key, required this.currentRoute});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  String _userEmail = '';
  String _userName = 'Asset User';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawUser = prefs.getString('user');

      if (rawUser != null && rawUser.isNotEmpty) {
        final map = jsonDecode(rawUser) as Map<String, dynamic>;
        if (!mounted) return;

        setState(() {
          _userEmail = (map['email'] ?? '').toString();
          _userName = (map['name'] ?? 'Asset User').toString();
        });
      }
    } catch (_) {
      // Keep defaults if user data is not available.
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final titleSize = width < 400 ? 18.0 : 20.0;
    final subtitleSize = width < 400 ? 14.0 : 16.0;
    final emailSize = width < 400 ? 12.0 : 14.0;
    final menuSize = width < 400 ? 15.0 : 17.0;
    final iconSize = width < 400 ? 22.0 : 26.0;

    return Drawer(
      backgroundColor: AppColors.navy,
      child: Column(
        children: [
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
                  height: width < 400 ? 60 : 72,
                  width: width < 400 ? 60 : 72,
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
                Text(
                  'Asset Management System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: subtitleSize,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _userEmail,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: emailSize,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          _item(context, Icons.pie_chart, 'Overview', '/userOverview', menuSize, iconSize),
          _item(context, Icons.inventory_2, 'All Assets', '/userAllAssets', menuSize, iconSize),
          _item(context, Icons.widgets_outlined, 'Available', '/userAvailableAssets', menuSize, iconSize),
          _item(context, Icons.check_circle, 'My Assets', '/userMyAssets', menuSize, iconSize),
          _item(context, Icons.assignment, 'My Requests', '/userMyRequests', menuSize, iconSize),
          _item(context, Icons.add_card, 'Request Asset', '/userRequestAsset', menuSize, iconSize),

          const Spacer(),
          const Divider(color: Colors.white24),

          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent, size: iconSize),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: menuSize,
              ),
            ),
            onTap: () async {
              await ApiService.clearToken();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
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
      double textSize,
      double iconSize,
      ) {
    final selected = widget.currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        size: iconSize,
        color: selected ? AppColors.neonBlue : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: textSize,
          color: selected ? AppColors.neonBlue : Colors.white70,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: () {
        if (selected) {
          Navigator.pop(context);
          return;
        }
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}