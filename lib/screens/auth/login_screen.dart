import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'signup_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  String role = "asset_user";

  bool loading = false;
  bool hidePassword = true;

  Future<void> login() async {

    try {

      setState(() => loading = true);

      final response = await ApiService.login(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        role: role,
      );

      final user = response["user"];

      final prefs = await SharedPreferences.getInstance();
      prefs.setString("user", jsonEncode(user));

      if (!mounted) return;

      switch (user["role"]) {

        case "lab_admin":
          Navigator.pushReplacementNamed(context, "/labAdminDashboard");
          break;

        case "asset_incharge":
          Navigator.pushReplacementNamed(context, "/assetInchargeDashboard");
          break;

        case "lab_technician":
          Navigator.pushReplacementNamed(context, "/technicianDashboard");
          break;

        case "asset_user":
          Navigator.pushReplacementNamed(context, "/assetDashboard");
          break;

        default:
          throw Exception("Unknown role");
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Container(
              width: 420,
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.2),
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const Icon(Icons.security,size:70,color:Colors.blue),

                  const SizedBox(height:10),

                  const Text(
                    "Asset Management System",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize:24,fontWeight:FontWeight.bold),
                  ),

                  const SizedBox(height:30),

                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height:16),

                  TextField(
                    controller: passwordCtrl,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height:16),

                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(
                      labelText: "Login As",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [

                      DropdownMenuItem(
                        value: "lab_admin",
                        child: Text("Lab Admin"),
                      ),

                      DropdownMenuItem(
                        value: "asset_incharge",
                        child: Text("Assets Incharge"),
                      ),

                      DropdownMenuItem(
                        value: "lab_technician",
                        child: Text("Lab Technician"),
                      ),

                      DropdownMenuItem(
                        value: "asset_user",
                        child: Text("Asset User"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        role = value!;
                      });
                    },
                  ),

                  const SizedBox(height:28),

                  SizedBox(
                    height:50,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize:16,
                          fontWeight:FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height:15),

                  if (role == "asset_user" || role == "asset_incharge")
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}