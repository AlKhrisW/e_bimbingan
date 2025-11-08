// lib/presentation/auth/auth_viewmodel.dart

import 'package:flutter/material.dart';
import '../../data/datasources/firebase_service.dart';
import '../../data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Logic Login: Mendapatkan UserModel dan menentukan tujuan
  Future<UserModel?> login({required String email, required String password}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final user = await _firebaseService.signInUser(email: email, password: password);
      if (user != null) {
        // 🚨 CRITICAL ZONE: Membaca dokumen dari Firestore
        final UserModel userModel = await _firebaseService.getUserData(user.uid);
        
        // Logging di console saat berhasil
        print('LOGIN SUCCESS: UID=${userModel.uid}, Role=${userModel.role}, Email=${userModel.email}');
        
        _setLoading(false);
        return userModel;
      }
    } catch (e) {
      // Menangkap exception dari FirebaseService (misal: "Data pengguna tidak ditemukan")
      final String errorMsg = e.toString().contains('Data pengguna tidak ditemukan')
          ? 'Login Gagal: Akun tidak terdaftar di Firestore. Hubungi Admin.'
          : 'Login Gagal: Terjadi kesalahan server ($e)';

      print('LOGIN FAILURE: $errorMsg'); 
      _setErrorMessage(errorMsg);
    }
    _setLoading(false);
    return null;
  }
  
  // Logic Register (Digunakan oleh AdminViewModel)
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? dosenUid,
    String? nim,
    String? placement,
    DateTime? startDate,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final newUser = await _firebaseService.registerUser(
        email: email,
        password: password,
        name: name,
        role: role,
        dosenUid: dosenUid,
        nim: nim,
        placement: placement,
        startDate: startDate,
      );
      _setLoading(false);
      return newUser;
    } catch (e) {
      _setErrorMessage(e.toString());
    }
    _setLoading(false);
    return null;
  }
  
  // Logic untuk Reset Password
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message ?? 'Gagal mengirim link reset password.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Logic Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error saat logout: $e");
    } finally {
      _setLoading(false);
    }
  }
}