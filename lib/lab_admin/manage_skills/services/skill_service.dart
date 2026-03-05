// lib/lab_admin/manage_skills/services/skill_service.dart
import '../../../services/api_service.dart';

class SkillService {
  /* =======================================================
     GET ALL SKILLS
     GET /api/skills
     ======================================================= */
  Future<List<Map<String, dynamic>>> getAllSkills() async {
    final response = await ApiService.get('/skills');

    return List<Map<String, dynamic>>.from(
      response['data'] ?? [],
    );
  }

  /* =======================================================
     ADD SKILL
     POST /api/skills
     body: { name, label }
     ======================================================= */
  Future<Map<String, dynamic>> addSkill({
    required String name,
    required String label,
  }) async {
    final response = await ApiService.post('/skills', {
      'name': name.trim(),
      'label': label.trim(),
    });

    return Map<String, dynamic>.from(response['data'] ?? {});
  }

  /* =======================================================
     UPDATE SKILL
     PUT /api/skills/:id
     body: { name, label }
     ======================================================= */
  Future<Map<String, dynamic>> updateSkill({
    required String skillId,
    required String name,
    required String label,
  }) async {
    final response = await ApiService.put('/skills/$skillId', {
      'name': name.trim(),
      'label': label.trim(),
    });

    return Map<String, dynamic>.from(response['data'] ?? {});
  }

  /* =======================================================
     DELETE SKILL
     DELETE /api/skills/:id
     ======================================================= */
  Future<void> deleteSkill(String skillId) async {
    await ApiService.delete('/skills/$skillId');
  }
}