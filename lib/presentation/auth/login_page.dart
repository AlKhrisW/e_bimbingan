// lib/presentation/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../admin/admin_dashboard.dart';
import '../dosen/dosen_dashboard.dart';
import '../mahasiswa/mahasiswa_dashboard.dart';
import 'auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(text: 'admin@prodi.ac.id');
  final TextEditingController _passwordController = TextEditingController(text: 'password');
  
  static InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final viewModel = Provider.of<AuthViewModel>(context, listen: false);
      final UserModel? user = await viewModel.login(email: email, password: password);

      if (user != null) {
        Widget destination;
        if (user.role == 'admin') {
          destination = AdminDashboard(user: user);
        } else if (user.role == 'dosen') {
          destination = DosenDashboard(user: user);
        } else { // Mahasiswa
          destination = MahasiswaDashboard(user: user);
        }
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => destination),
        );
      } else if (viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal: ${viewModel.errorMessage!}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context); 
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // --- LOGO ---
                Image.asset(
                  'assets/images/logo_e_bimbingan.png', 
                  height: 140, 
                ),
                
                const SizedBox(height: 40), 

                // --- TEKS SAMBUTAN ---
                Text(
                  'Selamat Datang',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 30),
                
                // --- INPUT EMAIL ---
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email (NIM/NIP)', Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Masukkan email yang valid.' : null,
                ),
                
                const SizedBox(height: 16.0),
                
                // --- INPUT PASSWORD ---
                TextFormField(
                  controller: _passwordController,
                  decoration: _inputDecoration('Password', Icons.lock),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'Password minimal 6 karakter.' : null,
                ),
                
                // Tombol Login
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                      : ElevatedButton(
                          onPressed: () => _handleLogin(context), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: const Text("LOGIN"),
                        ),
                ),
                
                // Pesan Keamanan
                const Text(
                  'Hubungi Admin (Staf Prodi) untuk mendapatkan akun Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}