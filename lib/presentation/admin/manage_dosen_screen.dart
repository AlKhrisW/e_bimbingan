// lib/presentation/admin/manage_dosen_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../viewmodels/admin_viewmodel.dart';
import 'dart:async'; 

class ManageDosenScreen extends StatefulWidget {
  final UserModel adminUser;
  const ManageDosenScreen({super.key, required this.adminUser});

  @override
  State<ManageDosenScreen> createState() => _ManageDosenScreenState();
}

class _ManageDosenScreenState extends State<ManageDosenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nipController = TextEditingController(); // BARU: NIP
  String? _selectedJabatan; // BARU: Jabatan
  final _passwordController = TextEditingController(text: 'password'); 
  
  late Future<List<UserModel>> _dosenListFuture;
  final List<String> _jabatanOptions = ['Dosen Pengajar', 'Kepala Jurusan', 'Kepala Prodi'];

  @override
  void initState() {
    super.initState();
    _dosenListFuture = _fetchDosenList();
  }

  Future<List<UserModel>> _fetchDosenList() {
    final viewModel = Provider.of<AdminViewModel>(context, listen: false);
    return viewModel.fetchDosenList();
  }
  
  void _submitDosenRegistration() async {
    if (_formKey.currentState!.validate() && _selectedJabatan != null) {
      _formKey.currentState!.save();
      
      final viewModel = Provider.of<AdminViewModel>(context, listen: false);

      final success = await viewModel.registerDosen(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        nip: _nipController.text.trim(),
        jabatan: _selectedJabatan!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.successMessage!)));
        // Reset form
        _nameController.clear();
        _emailController.clear();
        _nipController.clear();
        setState(() {
          _selectedJabatan = null;
          _dosenListFuture = _fetchDosenList(); // Perbarui daftar
        });
      } else if (viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      }
    } else if (_selectedJabatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jabatan Dosen wajib dipilih.')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Akun Dosen'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: DAFTAR DOSEN (LIST VIEW) ---
            Text('Daftar Dosen Terdaftar', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            _buildDosenList(context),
            
            const SizedBox(height: 40),

            // --- BAGIAN 2: FORM REGISTRASI DOSEN ---
            Text('Daftarkan Dosen Baru (Biodata Akademik)', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap Dosen', prefixIcon: Icon(Icons.person)),
                    validator: (value) => (value == null || value.isEmpty) ? 'Nama wajib diisi.' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _nipController,
                    decoration: const InputDecoration(labelText: 'NIP', prefixIcon: Icon(Icons.badge)),
                    keyboardType: TextInputType.number,
                    validator: (value) => (value == null || value.isEmpty || value.length < 5) ? 'NIP wajib diisi.' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Jabatan Fungsional', prefixIcon: Icon(Icons.work)),
                    value: _selectedJabatan,
                    items: _jabatanOptions.map((jabatan) {
                      return DropdownMenuItem(value: jabatan, child: Text(jabatan));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() { _selectedJabatan = newValue; });
                    },
                    validator: (value) => value == null ? 'Jabatan wajib dipilih.' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Dosen', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains('@')) ? 'Email tidak valid.' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password Default (password)', prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    enabled: false, 
                  ),
                  const SizedBox(height: 32),
                  
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitDosenRegistration,
                        icon: const Icon(Icons.add_circle),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Daftarkan Dosen', style: TextStyle(fontSize: 18)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
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

  // Widget untuk menampilkan daftar Dosen
  Widget _buildDosenList(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _dosenListFuture,
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
            child: Text('Belum ada Dosen yang terdaftar.'),
          ));
        }

        final dosenList = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dosenList.length,
          itemBuilder: (context, index) {
            final dosen = dosenList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(dosen.name[0], style: TextStyle(color: Colors.blue.shade800)),
                ),
                title: Text(dosen.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('NIP: ${dosen.nip ?? '-'}\nJabatan: ${dosen.jabatan ?? '-'}', style: TextStyle(color: Colors.grey.shade600)),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detail Dosen: ${dosen.name}')));
                },
              ),
            );
          },
        );
      },
    );
  }
}