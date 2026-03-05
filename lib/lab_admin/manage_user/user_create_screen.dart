import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'services/user_service.dart';

class UserCreateScreen extends StatefulWidget {
  const UserCreateScreen({super.key});

  @override
  State<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends State<UserCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String selectedRole = 'lab_technician';

  bool submitting = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => submitting = true);

      await _userService.createUser(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        role: selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedRole == 'lab_technician'
                ? 'Technician created successfully'
                : 'Assets Incharge created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create user')),
      );

      debugPrint('create user error: $e');
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// ❌ Drawer removed

      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,

        /// ✅ Back Button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Add User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'User Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'lab_technician',
                    child: Text('Technician'),
                  ),
                  DropdownMenuItem(
                    value: 'asset_incharge',
                    child: Text('Assets Incharge'),
                  ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => selectedRole = v);
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'First name is required' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                    icon: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: hideConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => hideConfirmPassword = !hideConfirmPassword),
                    icon: Icon(hideConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Confirm password is required';
                  if (v != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: submitting ? null : _createUser,
                  icon: submitting
                      ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add),
                  label: Text(submitting ? 'Creating...' : 'Create User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}