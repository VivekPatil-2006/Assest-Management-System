// pending_approvals_screen.dart
import 'package:assest_management_system/lab_admin/approval/services/approval_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../shared_widgets/lab_admin_drawer.dart';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  bool loading = true;
  bool actionLoading = false;

  final PendingApprovalService _service = PendingApprovalService();
  List<Map<String, dynamic>> approvals = [];

  @override
  void initState() {
    super.initState();
    loadPendingApprovals();
  }

  /* =======================================================
     LOAD PENDING USERS
     ======================================================= */
  Future<void> loadPendingApprovals() async {
    try {
      final data = await _service.getPendingApprovals();
      approvals = data;
    } catch (e) {
      approvals = [];
      debugPrint('loadPendingApprovals error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load pending approvals')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /* =======================================================
     APPROVE / REJECT
     ======================================================= */
  Future<void> onHandleApproval({
    required String userId,
    required bool approve,
  }) async {
    setState(() => actionLoading = true);

    try {
      await _service.handleApproval(userId: userId, approve: approve);

      approvals.removeWhere((u) => (u['_id']?.toString() ?? '') == userId);

      if (!mounted) return;
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve ? 'User approved successfully' : 'User rejected successfully',
          ),
        ),
      );
    } catch (e) {
      debugPrint('handleApproval error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error processing request')),
      );
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabAdminDrawer(currentRoute: "/labAdminApprovals"),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Pending User Approvals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : approvals.isEmpty
          ? const Center(
        child: Text(
          'No pending approvals',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : RefreshIndicator(
        onRefresh: loadPendingApprovals,
        child: ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: approvals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final item = approvals[i];

            final firstName = item['firstName']?.toString() ?? '';
            final lastName = item['lastName']?.toString() ?? '';
            final fullName = '$firstName $lastName'.trim().isEmpty
                ? (item['name']?.toString() ?? '-')
                : '$firstName $lastName';

            return buildApprovalCard(
              userId: item['_id']?.toString() ?? '',
              name: fullName,
              email: item['email']?.toString() ?? '-',
              role: item['role']?.toString() ?? '-',
            );
          },
        ),
      ),
    );
  }

  Widget buildApprovalCard({
    required String userId,
    required String name,
    required String email,
    required String role,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7CC5F7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B4A8F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      role.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A58CA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: actionLoading ? null : () => onHandleApproval(userId: userId, approve: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: actionLoading ? null : () => onHandleApproval(userId: userId, approve: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}