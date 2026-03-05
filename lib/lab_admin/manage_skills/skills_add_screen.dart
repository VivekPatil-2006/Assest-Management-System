import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'services/skill_service.dart';

class SkillsAddScreen extends StatefulWidget {
  const SkillsAddScreen({super.key});

  @override
  State<SkillsAddScreen> createState() => _SkillsAddScreenState();
}

class _SkillsAddScreenState extends State<SkillsAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final SkillService _skillService = SkillService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();

  bool submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  /* =======================================================
     ADD SKILL
  ======================================================= */

  Future<void> addSkill() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => submitting = true);

      await _skillService.addSkill(
        name: _nameController.text,
        label: _labelController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill added successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add skill')),
      );

      debugPrint('addSkill error: $e');
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// ❌ NO DRAWER

      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,

        /// ✅ BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Add Skill',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Skill Label (e.g. Printer Repair)',
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
                decoration: const InputDecoration(
                  labelText: 'Skill Name (e.g. printer_repair)',
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

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: submitting ? null : addSkill,

                  icon: submitting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.add),

                  label: Text(submitting ? 'Saving...' : 'Add Skill'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}