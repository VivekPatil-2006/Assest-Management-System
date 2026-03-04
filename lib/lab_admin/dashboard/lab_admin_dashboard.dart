import 'package:flutter/material.dart';

import '../shared_widgets/lab_admin_drawer.dart';

class LabAdminDashboard extends StatelessWidget {
  const LabAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Lab Admin Dashboard"),
      ),

      drawer: const LabAdminDrawer(
        currentRoute: "/labAdminDashboard",
      ),

      body: const Center(
        child: Text(
          "Lab Admin Dashboard",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}