// lib/presentation/viewmodels/admin_viewmodel.dart

import 'package:flutter/material.dart';
import '../../data/datasources/firebase_service.dart';
import '../../data/models/user_model.dart';


class AdminViewModel with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage({String? error, String? success}) {
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
  }

  // LOGIC REGISTER DOSEN
  Future<bool> registerDosen({
    required String email,
    required String password,
    required String name,
    required String? nip,
    required String? jabatan,
  }) async {
    _setLoading(true);
    _setMessage();
    try {
      await _firebaseService.registerUser(
        email: email,
        password: password,
        name: name,
        role: 'dosen',
        nip: nip,
        jabatan: jabatan,
      );
      _setMessage(success: 'Akun Dosen $name berhasil dibuat!');
      _setLoading(false);
      return true;
    } catch (e) {
      _setMessage(error: e.toString());
      _setLoading(false);
      return false;
    }
  }

  // LOGIC REGISTER MAHASISWA
  Future<bool> registerMahasiswa({
    required String email,
    required String password,
    required String name,
    required String nim,
    required String placement,
    required DateTime startDate,
    required String dosenUid,
  }) async {
    _setLoading(true);
    _setMessage();
    try {
      await _firebaseService.registerUser(
        email: email,
        password: password,
        name: name,
        role: 'mahasiswa',
        nim: nim,
        placement: placement,
        startDate: startDate,
        dosenUid: dosenUid,
      );
      _setMessage(success: 'Akun Mahasiswa $name berhasil dibuat dan direlasikan!');
      _setLoading(false);
      return true;
    } catch (e) {
      _setMessage(error: e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // MENDAPATKAN DAFTAR DOSEN
  Future<List<UserModel>> fetchDosenList() async {
    return _firebaseService.fetchDosenList();
  }

  // --- FUNGSI YANG HILANG/TERLUPAKAN: MENDAPATKAN DAFTAR MAHASISWA ---
  Future<List<UserModel>> fetchMahasiswaList() async {
    return _firebaseService.fetchMahasiswaList();
  }
}