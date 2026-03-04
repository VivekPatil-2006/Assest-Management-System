import 'package:flutter/material.dart';

class AssetInchargeDashboard extends StatelessWidget {
  const AssetInchargeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assets Incharge Dashboard"),
      ),
      body: const Center(
        child: Text(
          "Assets Incharge Dashboard",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}