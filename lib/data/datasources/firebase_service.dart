// lib/data/datasources/firebase_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Register User (Digunakan oleh Admin untuk membuat akun)
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? dosenUid,
    String? nim,
    String? placement,
    DateTime? startDate,
    String? nip,
    String? jabatan,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      final UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        dosenUid: role == 'mahasiswa' ? dosenUid : null,
        nim: nim,
        placement: placement,
        startDate: startDate,
        nip: nip,
        jabatan: jabatan,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Terjadi kesalahan saat pendaftaran.';
    }
  }

  // 2. Sign In User
  Future<User?> signInUser({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      throw 'Email atau password salah.';
    }
  }

  // 3. Get User Role and Data (Setelah Login berhasil)
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw 'Data pengguna tidak ditemukan di database.';
    }
    return UserModel.fromMap(doc.data()!);
  }

  // 4. Fetch list of Dosen (Digunakan di Admin Registration)
  Future<List<UserModel>> fetchDosenList() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'dosen')
        .get();
    
    return querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }
  
  // 5. IMPLEMENTASI YANG HILANG: Fetch list of Mahasiswa
  Future<List<UserModel>> fetchMahasiswaList() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'mahasiswa')
        .get();
    
    return querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }
}