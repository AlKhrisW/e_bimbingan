// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'presentation/auth/auth_viewmodel.dart';
import 'presentation/auth/login_page.dart';
// Asumsikan AdminViewModel dan LogbookViewModel akan ditambahkan nanti
import 'presentation/viewmodels/admin_viewmodel.dart'; 
// import 'presentation/viewmodels/logbook_viewmodel.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Anda harus mengganti dengan Firebase options yang sesuai
  await Firebase.initializeApp(); 
  runApp(const EBimbinganApp());
}

class EBimbinganApp extends StatelessWidget {
  const EBimbinganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()), // Akan ditambahkan di Fitur Admin
        // ChangeNotifierProvider(create: (_) => LogbookViewModel()), // Akan ditambahkan di Fitur Logbook
      ],
      child: MaterialApp(
        title: 'E-Bimbingan App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginPage(),
      ),
    );
  }
}