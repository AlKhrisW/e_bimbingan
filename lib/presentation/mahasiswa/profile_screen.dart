// lib/presentation/mahasiswa/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../data/models/user_model.dart';
import '../auth/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel currentUser;
  final String dosenName;
  const ProfileScreen({super.key, required this.currentUser, required this.dosenName});

  // Fungsi untuk menampilkan dialog Reset Password
  Future<void> _showResetPasswordDialog(BuildContext context) async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Text('Link reset password akan dikirimkan ke email Anda:\n\n${currentUser.email}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Kirim Link Reset', style: TextStyle(color: Colors.blue.shade700)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Tutup dialog
                
                // Panggil logic Reset Password dari AuthViewModel
                final success = await viewModel.resetPassword(email: currentUser.email);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Link reset password berhasil dikirim ke ${currentUser.email}. Cek inbox.' 
                          : 'Gagal mengirim link reset: ${viewModel.errorMessage}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final startDateFormatted = user.startDate != null 
        ? DateFormat('dd MMMM yyyy').format(user.startDate!)
        : 'N/A';
    
    // Tampilan Profil Mahasiswa
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.blue),
            const SizedBox(height: 10),
            Text(user.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 40),

            // --- DATA AKADEMIK & KONTAK ---
            _buildProfileCard(
              context, 
              title: 'Data Akademik & Kontak',
              items: {
                'NIM': user.nim ?? 'Belum Diisi',
                'Email': user.email,
              },
            ),
            const SizedBox(height: 20),

            // --- DETAIL BIMBINGAN & MAGANG ---
            _buildProfileCard(
              context, 
              title: 'Detail Bimbingan & Magang',
              items: {
                'Dosen Pembimbing': dosenName,
                'Instansi Magang': user.placement ?? 'Belum Diisi',
                'Tanggal Mulai': startDateFormatted,
              },
            ),
            const SizedBox(height: 40),

            // --- TOMBOL RESET PASSWORD ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showResetPasswordDialog(context),
                icon: const Icon(Icons.lock_reset),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Reset Password', style: TextStyle(fontSize: 16)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, {required String title, required Map<String, String> items}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue.shade700)),
            const Divider(),
            ...items.entries.map((entry) => _buildInfoRow(context, entry.key, entry.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          const Text(': '),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}