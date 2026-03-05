// lib/lab_admin/manage_skills/skills_list_screen.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/lab_admin_drawer.dart';
import 'services/skill_service.dart';
import 'skills_add_screen.dart';
import 'skills_details_screen.dart';

class SkillsListScreen extends StatefulWidget {
  const SkillsListScreen({super.key});

  @override
  State<SkillsListScreen> createState() => _SkillsListScreenState();
}

class _SkillsListScreenState extends State<SkillsListScreen> {
  final SkillService _skillService = SkillService();
  final TextEditingController _searchController = TextEditingController();

  bool loading = true;
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> filteredSkills = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearch);
    loadSkills();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearch);
    _searchController.dispose();
    super.dispose();
  }

  /* =======================================================
     LOAD SKILLS
     ======================================================= */
  Future<void> loadSkills() async {
    try {
      setState(() => loading = true);

      skills = await _skillService.getAllSkills();
      _applySearch();
    } catch (e) {
      skills = [];
      filteredSkills = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load skills')),
        );
      }
      debugPrint('loadSkills error: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  /* =======================================================
     SEARCH FILTER
     ======================================================= */
  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => filteredSkills = List<Map<String, dynamic>>.from(skills));
      return;
    }

    final result = skills.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final label = (s['label'] ?? '').toString().toLowerCase();
      return name.contains(q) || label.contains(q);
    }).toList();

    setState(() => filteredSkills = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabAdminDrawer(currentRoute: '/manageSkills'),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Manage Requirement Skills',
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
                hintText: 'Search skills by name or label...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: filteredSkills.isEmpty
                ? const Center(
              child: Text(
                'No skills found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: loadSkills,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                itemCount: filteredSkills.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final skill = filteredSkills[i];
                  final label = (skill['label'] ?? '-').toString();
                  final name = (skill['name'] ?? '-').toString();

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SkillsDetailsScreen(skill: skill),
                        ),
                      );

                      if (changed == true) {
                        await loadSkills();
                      }
                    },
                    child: Container(
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
                              label.isNotEmpty ? label[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
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
            MaterialPageRoute(builder: (_) => const SkillsAddScreen()),
          );

          if (created == true) {
            await loadSkills();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}