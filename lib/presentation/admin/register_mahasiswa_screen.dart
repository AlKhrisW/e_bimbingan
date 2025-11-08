// lib/presentation/admin/register_mahasiswa_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/user_model.dart';
import '../viewmodels/admin_viewmodel.dart';
import 'dart:async';

class RegisterMahasiswaScreen extends StatefulWidget {
  final UserModel adminUser;
  const RegisterMahasiswaScreen({super.key, required this.adminUser});

  @override
  State<RegisterMahasiswaScreen> createState() => _RegisterMahasiswaScreenState();
}

class _RegisterMahasiswaScreenState extends State<RegisterMahasiswaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nimController = TextEditingController();
  final _placementController = TextEditingController();
  final _passwordController = TextEditingController(text: 'password'); 
  
  DateTime? _startDate; 
  UserModel? _selectedDosen;
  List<UserModel> _dosenList = [];
  late Future<List<UserModel>> _mahasiswaListFuture;
  bool _isDosenListLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nimController.dispose();
    _placementController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<List<UserModel>> _fetchMahasiswaList() {
    final viewModel = Provider.of<AdminViewModel>(context, listen: false);
    return viewModel.fetchMahasiswaList();
  }

  Future<void> _fetchInitialData() async {
    final viewModel = Provider.of<AdminViewModel>(context, listen: false);
    
    // 1. Ambil daftar Mahasiswa (untuk list di UI)
    _mahasiswaListFuture = _fetchMahasiswaList();

    // 2. Ambil daftar Dosen untuk Dropdown
    try {
      final list = await viewModel.fetchDosenList();
      setState(() {
        _dosenList = list.where((u) => u.role == 'dosen').toList();
        if (_dosenList.isNotEmpty) {
           _selectedDosen = _dosenList.first; 
        }
        _isDosenListLoading = false;
      });
    } catch (e) {
      setState(() => _isDosenListLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat daftar Dosen.')));
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2026, 12),
        helpText: 'Pilih Tanggal Mulai Magang',
        confirmText: 'Pilih',
        cancelText: 'Batal',
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue.shade700, 
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
              ),
            ),
            child: child!,
          );
        },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submitMahasiswaRegistration() async {
    if (_formKey.currentState!.validate() && _startDate != null && _selectedDosen != null) {
      _formKey.currentState!.save();
      
      final viewModel = Provider.of<AdminViewModel>(context, listen: false);

      final success = await viewModel.registerMahasiswa(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        nim: _nimController.text.trim(), 
        placement: _placementController.text.trim(), 
        startDate: _startDate!, 
        dosenUid: _selectedDosen!.uid,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.successMessage!)));
        // Reset form
        _nameController.clear();
        _emailController.clear();
        _nimController.clear();
        _placementController.clear();
        setState(() {
            _startDate = null;
            // Perbarui daftar mahasiswa setelah berhasil
            _mahasiswaListFuture = _fetchMahasiswaList(); 
        });
      } else if (viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      }
    } else if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal Mulai Magang wajib diisi.')));
    } else if (_selectedDosen == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dosen Pembimbing wajib dipilih.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Mahasiswa & Relasi'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: DAFTAR MAHASISWA (LIST VIEW) ---
            Text('Daftar Mahasiswa Terdaftar', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            _buildMahasiswaList(context),

            const SizedBox(height: 40),

            // --- BAGIAN 2: FORM REGISTRASI MAHASISWA ---
            Text('Formulir Registrasi Mahasiswa Baru', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pemilihan Dosen Pembimbing
                  if (_isDosenListLoading)
                    const Center(child: LinearProgressIndicator())
                  else if (_dosenList.isEmpty)
                    const Text('❗ Belum ada Dosen terdaftar. Harap daftarkan Dosen terlebih dahulu.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                  else
                    DropdownButtonFormField<UserModel>(
                      decoration: const InputDecoration(labelText: 'Dosen Pembimbing', prefixIcon: Icon(Icons.people)),
                      value: _selectedDosen,
                      items: _dosenList.map((dosen) {
                        return DropdownMenuItem(value: dosen, child: Text(dosen.name));
                      }).toList(),
                      onChanged: (UserModel? newValue) {
                        setState(() { _selectedDosen = newValue; });
                      },
                    ),
                  const SizedBox(height: 30),

                  Text('Data Akun & Magang Mahasiswa', style: Theme.of(context).textTheme.titleMedium),
                  
                  // Input Data Diri
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Mahasiswa', prefixIcon: Icon(Icons.person)), validator: (value) => (value == null || value.isEmpty) ? 'Nama wajib diisi.' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _nimController, decoration: const InputDecoration(labelText: 'NIM', prefixIcon: Icon(Icons.badge)), keyboardType: TextInputType.number, validator: (value) => (value == null || value.isEmpty || value.length < 5) ? 'NIM wajib diisi (min 5 digit).' : null),
                  const SizedBox(height: 16),
                  
                  // Input Kredensial
                  TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Mahasiswa', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress, validator: (value) => (value == null || !value.contains('@') || !value.contains('.')) ? 'Email tidak valid.' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password Default (password)', prefixIcon: Icon(Icons.lock)), obscureText: true, enabled: false),
                  const SizedBox(height: 24),
                  
                  // Input Data Magang
                  TextFormField(controller: _placementController, decoration: const InputDecoration(labelText: 'Tempat/Perusahaan Magang', prefixIcon: Icon(Icons.apartment)), validator: (value) => (value == null || value.isEmpty) ? 'Tempat magang wajib diisi.' : null),
                  const SizedBox(height: 16),

                  // Pemilihan Tanggal Mulai
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Tanggal Mulai Magang: ${_startDate == null ? "Pilih Tanggal" : DateFormat('dd MMMM yyyy').format(_startDate!)}'),
                    leading: const Icon(Icons.calendar_month, color: Colors.blue),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _selectDate(context),
                  ),
                  const Divider(),
                  const SizedBox(height: 32),
                  
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitMahasiswaRegistration,
                        icon: const Icon(Icons.add_circle),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Buat Akun Mahasiswa & Relasi', style: TextStyle(fontSize: 18)),
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan daftar Mahasiswa
  Widget _buildMahasiswaList(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _mahasiswaListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error memuat data: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Belum ada Mahasiswa yang terdaftar.'),
          ));
        }

        final mahasiswaList = snapshot.data!;
        
        // Buat Map Dosen untuk lookup nama (Best Practice)
        final Map<String, String> dosenMap = {
          for (var dosen in _dosenList) dosen.uid: dosen.name
        };

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mahasiswaList.length,
          itemBuilder: (context, index) {
            final mhs = mahasiswaList[index];
            final dosenName = dosenMap[mhs.dosenUid] ?? 'Dosen Tidak Ditemukan';
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(mhs.name[0], style: TextStyle(color: Colors.blue.shade800)),
                ),
                title: Text('${mhs.name} (${mhs.nim ?? '-'})', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Pembimbing: $dosenName\nInstansi: ${mhs.placement ?? '-'}'),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detail Mahasiswa: ${mhs.name}')));
                },
              ),
            );
          },
        );
      },
    );
  }
}