// lib/presentation/dosen/dosen_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../auth/auth_viewmodel.dart';
import '../auth/login_page.dart';

class DosenDashboard extends StatelessWidget {
  final UserModel user; 
  const DosenDashboard({super.key, required this.user}); 

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
        title: Text('Dashboard Dosen (${user.name})'),
        backgroundColor: Colors.blue.shade700, // Gunakan tema biru konsisten
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
                'Halo Dosen ${user.name}!', 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.blue.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Tombol Monitoring Logbook (Fokus utama Dosen)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menuju Monitoring Logbook... (Fitur 4)')));
                  }, 
                  icon: const Icon(Icons.monitor), 
                  label: const Text('Monitoring & Approval Logbook'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue.shade600
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              TextButton.icon(
                onPressed: () => _handleLogout(context), 
                icon: const Icon(Icons.exit_to_app, color: Colors.grey), 
                label: const Text('Logout Sekarang', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}