// lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin', 'dosen', atau 'mahasiswa'
  final String? dosenUid; 
  final String? nim;
  final String? placement;
  final DateTime? startDate; 

  // --- FIELD BARU UNTUK DOSEN ---
  final String? nip;
  final String? jabatan; 
  // ------------------------------

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.dosenUid,
    this.nim,
    this.placement,
    this.startDate,
    this.nip,
    this.jabatan,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? '',
      role: data['role'] ?? 'unknown',
      dosenUid: data['dosen_uid'], 
      nim: data['nim'],
      placement: data['placement'],
      startDate: (data['start_date'] as Timestamp?)?.toDate(), 
      // Ambil field baru
      nip: data['nip'],
      jabatan: data['jabatan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (dosenUid != null) 'dosen_uid': dosenUid,
      
      // Simpan fields Magang Mahasiswa
      if (role == 'mahasiswa') ...{
        'nim': nim,
        'placement': placement,
        'start_date': startDate != null ? Timestamp.fromDate(startDate!) : null,
      },
      
      // Simpan fields Dosen
      if (role == 'dosen') ...{
        'nip': nip,
        'jabatan': jabatan,
      }
    };
  }
}