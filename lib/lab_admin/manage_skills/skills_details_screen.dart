import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'services/skill_service.dart';

class SkillsDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> skill;

  const SkillsDetailsScreen({
    super.key,
    required this.skill,
  });

  @override
  State<SkillsDetailsScreen> createState() => _SkillsDetailsScreenState();
}

class _SkillsDetailsScreenState extends State<SkillsDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final SkillService _skillService = SkillService();

  late TextEditingController _nameController;
  late TextEditingController _labelController;

  bool editing = false;
  bool saving = false;
  bool deleting = false;

  String get skillId => (widget.skill['_id'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: (widget.skill['name'] ?? '').toString());

    _labelController =
        TextEditingController(text: (widget.skill['label'] ?? '').toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  /* =======================================================
     UPDATE SKILL
  ======================================================= */

  Future<void> updateSkill() async {
    if (!_formKey.currentState!.validate()) return;
    if (skillId.isEmpty) return;

    try {
      setState(() => saving = true);

      await _skillService.updateSkill(
        skillId: skillId,
        name: _nameController.text,
        label: _labelController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill updated successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update skill')),
      );

      debugPrint('updateSkill error: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  /* =======================================================
     DELETE SKILL
  ======================================================= */

  Future<void> deleteSkill() async {
    if (skillId.isEmpty) return;

    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Skill'),
        content: const Text('Are you sure you want to delete this skill?'),
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

      await _skillService.deleteSkill(skillId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill deleted successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete skill')),
      );

      debugPrint('deleteSkill error: $e');
    } finally {
      if (mounted) setState(() => deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// NO DRAWER HERE

      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,

        /// BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Skill Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          if (!editing)
            IconButton(
              onPressed: () => setState(() => editing = true),
              icon: const Icon(Icons.edit),
            ),
          IconButton(
            onPressed: deleting ? null : deleteSkill,
            icon: deleting
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              TextFormField(
                controller: _labelController,
                enabled: editing,
                decoration: const InputDecoration(
                  labelText: 'Skill Label',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Skill label is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                enabled: editing,
                decoration: const InputDecoration(
                  labelText: 'Skill Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Skill name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              if (editing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : updateSkill,
                    icon: saving
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.save),
                    label: Text(saving ? 'Saving...' : 'Update Skill'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}