import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laporin/firebase_options.dart';
import 'package:laporin/providers/user_provider.dart';
import 'package:laporin/routes/app_router.dart';
import 'package:laporin/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔔 Inisialisasi notifikasi
  await NotificationService.init();

  final userProvider = UserProvider();
  await userProvider.loadUserFromStorage();
  await initializeDateFormatting('id_ID', null);

  runApp(
    ChangeNotifierProvider<UserProvider>.value(
      value: userProvider,
      child: MyApp(userProvider: userProvider),
    ),
  );
}




class MyApp extends StatelessWidget {
  final UserProvider userProvider;

  const MyApp({super.key, required this.userProvider});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter(userProvider);
    return MaterialApp.router(
      title: 'Lapor.in',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

