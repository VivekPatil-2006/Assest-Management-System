// import 'package:flutter/material.dart';
//
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/signup_screen.dart';
//
// void main() {
//   runApp(const AMSApp());
// }
//
// class AMSApp extends StatelessWidget {
//   const AMSApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Asset Management System',
//       debugShowCheckedModeBanner: false,
//
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.blue,
//         ),
//         useMaterial3: true,
//       ),
//
//       // Initial screen
//       initialRoute: "/login",
//
//       routes: {
//
//         "/login": (context) => const LoginScreen(),
//
//         "/signup": (context) => const SignupScreen(),
//
//         "/adminDashboard": (context) => const AdminDashboard(),
//
//         "/technicianDashboard": (context) => const TechnicianDashboard(),
//
//         "/assetDashboard": (context) => const AssetDashboard(),
//
//       },
//     );
//   }
// }
//
//
//
//
//
//
// /* =========================================================
//    TEMP DASHBOARD SCREENS
//    Replace later with real dashboards
// ========================================================= */
//
// class AdminDashboard extends StatelessWidget {
//   const AdminDashboard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Lab Admin Dashboard')),
//       body: const Center(
//         child: Text(
//           "Welcome Lab Admin",
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }
//
// class TechnicianDashboard extends StatelessWidget {
//   const TechnicianDashboard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Technician Dashboard')),
//       body: const Center(
//         child: Text(
//           "Welcome Technician",
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }
//
// class AssetDashboard extends StatelessWidget {
//   const AssetDashboard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Asset User Dashboard')),
//       body: const Center(
//         child: Text(
//           "Welcome Asset User",
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'assets_incharge/dashboard/assets_incharge_dashboard.dart';
import 'lab_admin/approval/approval_screen.dart';
import 'lab_admin/category_hierarchy/category_hierarchy_screen.dart';
import 'lab_admin/dashboard/lab_admin_dashboard.dart';
import 'lab_admin/manage_categories/categories_add_screen.dart';
import 'lab_admin/manage_categories/categories_list_screen.dart';
import 'lab_admin/manage_departments/manage_departments_screen.dart';
import 'lab_admin/manage_skills/skills_list_screen.dart';
import 'lab_admin/manage_user/user_list_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

void main() {
  runApp(const AMSApp());
}

class AMSApp extends StatelessWidget {
  const AMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Management System',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      // Initial screen
      initialRoute: "/login",

      routes: {

        "/login": (context) => const LoginScreen(),

        "/signup": (context) => const SignupScreen(),

        "/labAdminDashboard": (context) => const LabAdminDashboard(),


        "/technicianDashboard": (context) => const TechnicianDashboard(),

        "/assetDashboard": (context) => const AssetDashboard(),

        "/assetInchargeDashboard": (context) => const AssetInchargeDashboard(),

        "/labAdminApprovals": (context) => const PendingApprovalsScreen(),

        "/manageUsers": (context) => const UserListScreen(),

        "/manageSkills": (context) => const SkillsListScreen(),

        "/addCategories": (context) => const CategoriesListScreen(),

        "/categoryHierarchy": (context) => const CategoryHierarchyScreen(),

        "/manageDepartments": (context) => const ManageDepartmentsScreen(),
      },
    );
  }
}






/* =========================================================
   TEMP DASHBOARD SCREENS
   Replace later with real dashboards
========================================================= */

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab Admin Dashboard')),
      body: const Center(
        child: Text(
          "Welcome Lab Admin",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class TechnicianDashboard extends StatelessWidget {
  const TechnicianDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Technician Dashboard')),
      body: const Center(
        child: Text(
          "Welcome Technician",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class AssetDashboard extends StatelessWidget {
  const AssetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asset User Dashboard')),
      body: const Center(
        child: Text(
          "Welcome Asset User",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}