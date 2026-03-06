// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../shared_widgets/lab_admin_drawer.dart';
// import 'services/lab_admin_dashboard_service.dart';
// class LabAdminDashboard extends StatefulWidget {
//   const LabAdminDashboard({super.key});
//
//   @override
//   State<LabAdminDashboard> createState() => _LabAdminDashboardState();
// }
//
// class _LabAdminDashboardState extends State<LabAdminDashboard> {
//   bool loading = true;
//
//   // -------------------------
//   // Sample Dashboard Data
//   // -------------------------
//   int totalAssets = 325;
//   int assignedAssets = 238;
//   int availableAssets = 64;
//   int maintenanceAssets = 23;
//
//   int totalLabs = 9;
//   int activeTechnicians = 14;
//
//   int openIssues = 18;
//   int resolvedIssues = 42;
//   int pendingRequests = 11;
//
//   double utilizationTarget = 85;
//   double utilizationCurrent = 73.2;
//
//   List<Map<String, dynamic>> recentActivities = [];
//   Map<String, double> monthlyMaintenanceCost = {};
//   Map<String, int> assetCategoryCount = {};
//
//   // Theme colors (self-contained, no external AppColors needed)
//   static const Color cPrimary = Color(0xFF0E7490); // cyan-700
//   static const Color cPrimaryDark = Color(0xFF155E75); // cyan-800
//   static const Color cAccent = Color(0xFF0891B2); // cyan-600
//   static const Color cBg = Color(0xFFF4F8FA);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDashboardData();
//   }
//
//   Future<void> _loadDashboardData() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     monthlyMaintenanceCost = {
//       "2025-01": 18000,
//       "2025-02": 22000,
//       "2025-03": 27000,
//       "2025-04": 24000,
//       "2025-05": 31000,
//       "2025-06": 29000,
//     };
//
//     assetCategoryCount = {
//       "Computers": 112,
//       "Electronics": 84,
//       "Furniture": 51,
//       "Instruments": 78,
//     };
//
//     recentActivities = [
//       {
//         "title": "Microscope #MS-12 sent for preventive maintenance",
//         "time": DateTime.now().subtract(const Duration(hours: 3)),
//         "type": "maintenance",
//       },
//       {
//         "title": "Asset Request approved for Lab B (3 Laptops)",
//         "time": DateTime.now().subtract(const Duration(hours: 8)),
//         "type": "request",
//       },
//       {
//         "title": "Issue #ISS-204 marked as resolved",
//         "time": DateTime.now().subtract(const Duration(days: 1, hours: 2)),
//         "type": "issue",
//       },
//       {
//         "title": "New instrument added: Oscilloscope #OSC-44",
//         "time": DateTime.now().subtract(const Duration(days: 2)),
//         "type": "asset",
//       },
//     ];
//
//     if (!mounted) return;
//     setState(() => loading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: cBg,
//       drawer: const LabAdminDrawer(currentRoute: "/labAdminDashboard"),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white,
//         title: const Text(
//           "Lab Admin Dashboard",
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Column(
//           children: [
//             _headerUI(),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               child: Column(
//                 children: [
//                   GridView.count(
//                     crossAxisCount: 2,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     mainAxisSpacing: 10,
//                     crossAxisSpacing: 10,
//                     childAspectRatio: 1.35,
//                     children: [
//                       _kpiCard("Total Assets", "$totalAssets", Icons.inventory_2),
//                       _kpiCard("Assigned", "$assignedAssets", Icons.assignment_turned_in),
//                       _kpiCard("Available", "$availableAssets", Icons.check_circle),
//                       _kpiCard("In Maintenance", "$maintenanceAssets", Icons.build_circle),
//                       _kpiCard("Open Issues", "$openIssues", Icons.error_outline),
//                       _kpiCard("Pending Requests", "$pendingRequests", Icons.hourglass_top),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   _dashboardCard(
//                     title: "Lab Operations Snapshot",
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: _miniMetric(
//                             "Total Labs",
//                             "$totalLabs",
//                             Colors.indigo,
//                             Icons.apartment,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _miniMetric(
//                             "Technicians",
//                             "$activeTechnicians",
//                             Colors.teal,
//                             Icons.engineering,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _miniMetric(
//                             "Utilization",
//                             "${utilizationCurrent.toStringAsFixed(1)}%",
//                             Colors.orange,
//                             Icons.bar_chart,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _dashboardCard(
//                     title: "Asset Distribution by Category",
//                     child: SizedBox(
//                       height: 240,
//                       child: _buildAssetCategoryPieChart(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _dashboardCard(
//                     title: "Monthly Maintenance Cost",
//                     child: SizedBox(
//                       height: 250,
//                       child: _buildMaintenanceBarChart(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _dashboardCard(
//                     title: "Issue Resolution Status",
//                     child: _buildIssueProgress(),
//                   ),
//                   const SizedBox(height: 16),
//                   _dashboardCard(
//                     title: "Recent Activity",
//                     child: Column(
//                       children: recentActivities.map((activity) {
//                         final dt = activity["time"] as DateTime;
//                         return ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: CircleAvatar(
//                             radius: 18,
//                             backgroundColor: _activityColor(activity["type"]).withOpacity(0.15),
//                             child: Icon(
//                               _activityIcon(activity["type"]),
//                               color: _activityColor(activity["type"]),
//                               size: 18,
//                             ),
//                           ),
//                           title: Text(
//                             activity["title"] as String,
//                             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//                           ),
//                           subtitle: Text(
//                             DateFormat("dd MMM, hh:mm a").format(dt),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // -------------------------
//   // Sections
//   // -------------------------
//
//   Widget _headerUI() {
//     final formatter = NumberFormat.compact();
//     final totalMaintCost = monthlyMaintenanceCost.values.fold<double>(0, (a, b) => a + b);
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [cPrimaryDark, cAccent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(22),
//           bottomRight: Radius.circular(22),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Lab Performance Overview",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 21,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Maintenance Spend: ₹ ${formatter.format(totalMaintCost)}   |   Resolved: $resolvedIssues issues",
//             style: const TextStyle(color: Colors.white70),
//           ),
//           const SizedBox(height: 12),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(99),
//             child: LinearProgressIndicator(
//               minHeight: 9,
//               value: (utilizationCurrent / utilizationTarget).clamp(0, 1),
//               backgroundColor: Colors.white24,
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Utilization ${utilizationCurrent.toStringAsFixed(1)}% / Target ${utilizationTarget.toStringAsFixed(0)}%",
//             style: const TextStyle(color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAssetCategoryPieChart() {
//     final total = assetCategoryCount.values.fold<int>(0, (a, b) => a + b);
//     const palette = [Color(0xFF0891B2), Color(0xFF16A34A), Color(0xFFF59E0B), Color(0xFF7C3AED), Color(0xFF6B7280)];
//     final entries = assetCategoryCount.entries.toList();
//
//     return Row(
//       children: [
//         Expanded(
//           flex: 5,
//           child: PieChart(
//             PieChartData(
//               centerSpaceRadius: 38,
//               sectionsSpace: 2,
//               sections: List.generate(entries.length, (i) {
//                 final e = entries[i];
//                 final pct = total == 0 ? 0 : (e.value / total) * 100;
//                 return PieChartSectionData(
//                   color: palette[i % palette.length],
//                   value: e.value.toDouble(),
//                   radius: 58,
//                   title: "${pct.toStringAsFixed(0)}%",
//                   titleStyle: const TextStyle(
//                     fontSize: 11,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           flex: 4,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: List.generate(entries.length, (i) {
//               final e = entries[i];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 10,
//                       height: 10,
//                       decoration: BoxDecoration(
//                         color: palette[i % palette.length],
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         "${e.key} (${e.value})",
//                         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMaintenanceBarChart() {
//     final keys = monthlyMaintenanceCost.keys.toList()..sort();
//     final values = keys.map((k) => monthlyMaintenanceCost[k]!).toList();
//     final maxY = values.isEmpty ? 100 : values.reduce((a, b) => a > b ? a : b) * 1.25;
//
//     return BarChart(
//       BarChartData(
//         //maxY: maxY,
//         gridData: const FlGridData(show: true),
//         borderData: FlBorderData(show: false),
//         barTouchData: BarTouchData(enabled: true),
//         titlesData: FlTitlesData(
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 44,
//               getTitlesWidget: (value, _) => Text(
//                 "${(value / 1000).toStringAsFixed(0)}k",
//                 style: const TextStyle(fontSize: 10),
//               ),
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, _) {
//                 final idx = value.toInt();
//                 if (idx < 0 || idx >= keys.length) return const SizedBox.shrink();
//                 final parts = keys[idx].split("-");
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 6),
//                   child: Text(
//                     "${parts[1]}/${parts[0].substring(2)}",
//                     style: const TextStyle(fontSize: 10),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         barGroups: List.generate(keys.length, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(
//                 toY: values[i],
//                 width: 18,
//                 borderRadius: BorderRadius.circular(6),
//                 color: cPrimary,
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildIssueProgress() {
//     final total = openIssues + resolvedIssues;
//     final ratio = total == 0 ? 0.0 : resolvedIssues / total;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(child: _statusTag("Open", openIssues, Colors.red)),
//             const SizedBox(width: 8),
//             Expanded(child: _statusTag("Resolved", resolvedIssues, Colors.green)),
//           ],
//         ),
//         const SizedBox(height: 12),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(99),
//           child: LinearProgressIndicator(
//             minHeight: 12,
//             value: ratio,
//             backgroundColor: Colors.red.withOpacity(0.18),
//             valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "Resolution Rate: ${(ratio * 100).toStringAsFixed(1)}%",
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }
//
//   // -------------------------
//   // Reusable UI
//   // -------------------------
//
//   Widget _kpiCard(String title, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Icon(icon, size: 18, color: cPrimary),
//             ],
//           ),
//           const Spacer(),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _miniMetric(String label, String value, Color color, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 18),
//           const SizedBox(height: 6),
//           Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _statusTag(String label, int value, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.circle, size: 10, color: color),
//           const SizedBox(width: 8),
//           Text(
//             "$label: $value",
//             style: TextStyle(fontWeight: FontWeight.w700, color: color),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _dashboardCard({required String title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
//
//   IconData _activityIcon(String type) {
//     switch (type) {
//       case "maintenance":
//         return Icons.build;
//       case "request":
//         return Icons.assignment;
//       case "issue":
//         return Icons.bug_report;
//       case "asset":
//         return Icons.inventory;
//       default:
//         return Icons.notifications;
//     }
//   }
//
//   Color _activityColor(String type) {
//     switch (type) {
//       case "maintenance":
//         return Colors.orange;
//       case "request":
//         return Colors.blue;
//       case "issue":
//         return Colors.red;
//       case "asset":
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }




import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/lab_admin_drawer.dart';
import 'services/lab_admin_dashboard_service.dart';
class LabAdminDashboard extends StatefulWidget {
  const LabAdminDashboard({super.key});

  @override
  State<LabAdminDashboard> createState() => _LabAdminDashboardState();
}

class _LabAdminDashboardState extends State<LabAdminDashboard> {
  bool loading = true;

  final LabAdminDashboardService _dashboardService = LabAdminDashboardService();

  int totalAssets = 0;
  int assignedAssets = 0;
  int availableAssets = 0;
  int maintenanceAssets = 0;

  int totalLabs = 0;
  int activeTechnicians = 0;

  int openIssues = 0;
  int resolvedIssues = 0;
  int pendingRequests = 0;

  double utilizationTarget = 85;
  double utilizationCurrent = 0;

  List<Map<String, dynamic>> recentActivities = [];
  Map<String, double> monthlyMaintenanceCost = {};
  Map<String, int> assetCategoryCount = {};

  static const Color cPrimary = Color(0xFF0E7490);
  static const Color cPrimaryDark = Color(0xFF155E75);
  static const Color cAccent = Color(0xFF0891B2);
  static const Color cBg = Color(0xFFF4F8FA);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => loading = true);

      final data = await _dashboardService.getDashboardData();

      totalAssets = data['totalAssets'] ?? 0;
      assignedAssets = data['assignedAssets'] ?? 0;
      availableAssets = data['availableAssets'] ?? 0;
      maintenanceAssets = data['maintenanceAssets'] ?? 0;

      totalLabs = data['totalLabs'] ?? 0;
      activeTechnicians = data['activeTechnicians'] ?? 0;

      openIssues = data['openIssues'] ?? 0;
      resolvedIssues = data['resolvedIssues'] ?? 0;
      pendingRequests = data['pendingRequests'] ?? 0;

      utilizationTarget = (data['utilizationTarget'] ?? 85).toDouble();
      utilizationCurrent = (data['utilizationCurrent'] ?? 0).toDouble();

      monthlyMaintenanceCost =
      Map<String, double>.from(data['monthlyMaintenanceCost'] ?? {});
      assetCategoryCount =
      Map<String, int>.from(data['assetCategoryCount'] ?? {});
      recentActivities =
      List<Map<String, dynamic>>.from(data['recentActivities'] ?? []);
    } catch (e) {
      debugPrint('Lab admin dashboard load error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load dashboard data')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      drawer: const LabAdminDrawer(currentRoute: "/labAdminDashboard"),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          "Lab Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _headerUI(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.35,
                    children: [
                      _kpiCard("Total Assets", "$totalAssets", Icons.inventory_2),
                      _kpiCard("Assigned", "$assignedAssets", Icons.assignment_turned_in),
                      _kpiCard("Available", "$availableAssets", Icons.check_circle),
                      _kpiCard("In Maintenance", "$maintenanceAssets", Icons.build_circle),
                      _kpiCard("Open Issues", "$openIssues", Icons.error_outline),
                      _kpiCard("Pending Requests", "$pendingRequests", Icons.hourglass_top),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _dashboardCard(
                    title: "Lab Operations Snapshot",
                    child: Row(
                      children: [
                        Expanded(
                          child: _miniMetric(
                            "Total Labs",
                            "$totalLabs",
                            Colors.indigo,
                            Icons.apartment,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _miniMetric(
                            "Technicians",
                            "$activeTechnicians",
                            Colors.teal,
                            Icons.engineering,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _miniMetric(
                            "Utilization",
                            "${utilizationCurrent.toStringAsFixed(1)}%",
                            Colors.orange,
                            Icons.bar_chart,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dashboardCard(
                    title: "Asset Distribution by Category",
                    child: SizedBox(
                      height: 240,
                      child: _buildAssetCategoryPieChart(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dashboardCard(
                    title: "Monthly Maintenance Cost",
                    child: SizedBox(
                      height: 250,
                      child: _buildMaintenanceBarChart(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dashboardCard(
                    title: "Issue Resolution Status",
                    child: _buildIssueProgress(),
                  ),
                  const SizedBox(height: 16),
                  _dashboardCard(
                    title: "Recent Activity",
                    child: Column(
                      children: recentActivities.map((activity) {
                        final dt = activity["time"] as DateTime;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: _activityColor(activity["type"]).withOpacity(0.15),
                            child: Icon(
                              _activityIcon(activity["type"]),
                              color: _activityColor(activity["type"]),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            activity["title"] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormat("dd MMM, hh:mm a").format(dt),
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // Sections
  // -------------------------

  Widget _headerUI() {
    final formatter = NumberFormat.compact();
    final totalMaintCost = monthlyMaintenanceCost.values.fold<double>(0, (a, b) => a + b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [cPrimaryDark, cAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lab Performance Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Maintenance Spend: ₹ ${formatter.format(totalMaintCost)}   |   Resolved: $resolvedIssues issues",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: (utilizationCurrent / utilizationTarget).clamp(0, 1),
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Utilization ${utilizationCurrent.toStringAsFixed(1)}% / Target ${utilizationTarget.toStringAsFixed(0)}%",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCategoryPieChart() {
    final total = assetCategoryCount.values.fold<int>(0, (a, b) => a + b);
    const palette = [Color(0xFF0891B2), Color(0xFF16A34A), Color(0xFFF59E0B), Color(0xFF7C3AED), Color(0xFF6B7280)];
    final entries = assetCategoryCount.entries.toList();

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 38,
              sectionsSpace: 2,
              sections: List.generate(entries.length, (i) {
                final e = entries[i];
                final pct = total == 0 ? 0 : (e.value / total) * 100;
                return PieChartSectionData(
                  color: palette[i % palette.length],
                  value: e.value.toDouble(),
                  radius: 58,
                  title: "${pct.toStringAsFixed(0)}%",
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              final e = entries[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: palette[i % palette.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${e.key} (${e.value})",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceBarChart() {
    final keys = monthlyMaintenanceCost.keys.toList()..sort();
    final values = keys.map((k) => monthlyMaintenanceCost[k]!).toList();
    final maxY = values.isEmpty ? 100 : values.reduce((a, b) => a > b ? a : b) * 1.25;

    return BarChart(
      BarChartData(
        //maxY: maxY,
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, _) => Text(
                "${(value / 1000).toStringAsFixed(0)}k",
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= keys.length) return const SizedBox.shrink();
                final parts = keys[idx].split("-");
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "${parts[1]}/${parts[0].substring(2)}",
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(keys.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                width: 18,
                borderRadius: BorderRadius.circular(6),
                color: cPrimary,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildIssueProgress() {
    final total = openIssues + resolvedIssues;
    final ratio = total == 0 ? 0.0 : resolvedIssues / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _statusTag("Open", openIssues, Colors.red)),
            const SizedBox(width: 8),
            Expanded(child: _statusTag("Resolved", resolvedIssues, Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: ratio,
            backgroundColor: Colors.red.withOpacity(0.18),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Resolution Rate: ${(ratio * 100).toStringAsFixed(1)}%",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // -------------------------
  // Reusable UI
  // -------------------------

  Widget _kpiCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(icon, size: 18, color: cPrimary),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _statusTag(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text(
            "$label: $value",
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case "maintenance":
        return Icons.build;
      case "request":
        return Icons.assignment;
      case "issue":
        return Icons.bug_report;
      case "asset":
        return Icons.inventory;
      default:
        return Icons.notifications;
    }
  }

  Color _activityColor(String type) {
    switch (type) {
      case "maintenance":
        return Colors.orange;
      case "request":
        return Colors.blue;
      case "issue":
        return Colors.red;
      case "asset":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}