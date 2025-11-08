// lib/presentation/mahasiswa/mahasiswa_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../data/models/user_model.dart';
import '../auth/auth_viewmodel.dart';
import '../auth/login_page.dart';
import 'profile_screen.dart'; 

class MahasiswaDashboard extends StatefulWidget {
  final UserModel user; 
  const MahasiswaDashboard({super.key, required this.user});

  @override
  State<MahasiswaDashboard> createState() => _MahasiswaDashboardState();
}

class _MahasiswaDashboardState extends State<MahasiswaDashboard> {
  String _dosenName = "Memuat...";
  bool _isLoadingDosen = true;

  @override
  void initState() {
    super.initState();
    _fetchDosenName();
  }

  // Fungsi untuk mengambil nama Dosen dari Firestore
  Future<void> _fetchDosenName() async {
    final dosenUid = widget.user.dosenUid;
    if (dosenUid == null) {
      setState(() {
        _dosenName = "Tidak Terdaftar";
        _isLoadingDosen = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(dosenUid).get();
      
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _dosenName = data!['name'] ?? "Nama Dosen Tidak Ditemukan";
          _isLoadingDosen = false;
        });
      } else {
        setState(() {
          _dosenName = "Dosen Tidak Ditemukan";
          _isLoadingDosen = false;
        });
      }
    } catch (e) {
      print('Error fetching Dosen name: $e');
      setState(() {
        _dosenName = "Error Memuat Data Dosen";
        _isLoadingDosen = false;
      });
    }
  }

  void _handleLogout(BuildContext context) async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    await viewModel.logout();
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
  
  // FUNGSI NAVIGASI KE PROFIL
  void _navigateToProfile(BuildContext context) {
    if (_isLoadingDosen) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon tunggu, data Dosen sedang dimuat.')));
       return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          currentUser: widget.user,
          dosenName: _dosenName, // Meneruskan nama Dosen yang sudah dimuat
        ),
      ),
    );
  }

  // FUNGSI NAVIGASI KE RIWAYAT LOGBOOK (Asumsi Fitur 3 sudah ada)
  void _navigateToLogbookHistory(BuildContext context) {
    // Navigasi ke LogbookHistoryScreen (jika file sudah ada)
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => LogbookHistoryScreen(currentUser: widget.user),
    //   ),
    // );
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Riwayat Logbook (Fitur 3) belum aktif.')));
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Mahasiswa (${user.name})'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          // Tombol Profile di AppBar
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _navigateToProfile(context),
            tooltip: 'Profil Saya',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Dosen Pembimbing: ${_dosenName}', 
                style: const TextStyle(color: Colors.white, fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BOX INFORMASI MAHASISWA & MAGANG ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Magang', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildInfoRow(context, 'NIM', user.nim ?? 'Belum Diisi'),
                    _buildInfoRow(context, 'Instansi', user.placement ?? 'Belum Diisi'),
                    
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _navigateToProfile(context),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Lihat Profil Lengkap & Reset Password'),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // --- TOMBOL AKSI LOGBOOK ---
            Text('Menu Logbook', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(thickness: 2),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                    // TODO: Navigasi ke Logbook Input (Fitur 2)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menuju Input Logbook... (Fitur 2)')));
                }, 
                icon: const Icon(Icons.edit_note, size: 28), 
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Input Logbook Harian', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToLogbookHistory(context), 
                icon: const Icon(Icons.history, size: 28), 
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Lihat Riwayat Logbook', style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white
                ),
              ),
            ),
            const SizedBox(height: 50),

            TextButton.icon(
              onPressed: () => _handleLogout(context), 
              icon: const Icon(Icons.exit_to_app, color: Colors.grey), 
              label: const Text('Logout', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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