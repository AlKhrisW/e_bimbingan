// lib/presentation/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../auth/auth_viewmodel.dart';
import '../auth/login_page.dart';
import 'manage_dosen_screen.dart';
import 'register_mahasiswa_screen.dart';

class AdminDashboard extends StatelessWidget {
  final UserModel user; 
  const AdminDashboard({super.key, required this.user}); 

  void _handleLogout(BuildContext context) async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    await viewModel.logout();
    
    // Kembali ke halaman Login dan membersihkan semua rute
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin (${user.name})'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          // TOMBOL LOGOUT (STANDAR UI/UX)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Halo Admin ${user.name}!', 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.blue.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              const Text(
                'Pilih menu di bawah untuk mengelola Master Data.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- TOMBOL 1: KELOLA AKUN DOSEN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ManageDosenScreen(adminUser: user)),
                    );
                  }, 
                  icon: const Icon(Icons.people_alt, size: 28), 
                  label: const Text('Kelola Akun Dosen'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 15)),
                ),
              ),
              const SizedBox(height: 15),

              // --- TOMBOL 2: REGISTRASI MAHASISWA & RELASI ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RegisterMahasiswaScreen(adminUser: user)),
                    );
                  }, 
                  icon: const Icon(Icons.school, size: 28), 
                  label: const Text('Registrasi Mahasiswa & Relasi Bimbingan'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, padding: const EdgeInsets.symmetric(vertical: 15)),
                ),
              ),

              const SizedBox(height: 50),
              
              // Logout di body (opsional, tapi bagus untuk penekanan)
              TextButton.icon(
                onPressed: () => _handleLogout(context), 
                icon: const Icon(Icons.exit_to_app, color: Colors.grey), 
                label: const Text('Logout', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}