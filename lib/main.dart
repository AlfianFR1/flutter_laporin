import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laporin/firebase_options.dart';
import 'package:laporin/routes/app_router.dart';
import 'package:laporin/services/notification_service.dart';
import 'package:laporin/providers/user_provider.dart'; // AsyncNotifierProvider
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔔 Inisialisasi notifikasi
  await NotificationService.init();
  await initializeDateFormatting('id_ID', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    // Router akan dibuat berdasarkan status login user
    final router = userState.when(
      data: (user) => AppRouter.createRouter(user), // kamu harus modifikasi createRouter agar menerima UserState
      loading: () => AppRouter.createRouter(null),
      error: (e, _) => AppRouter.createRouter(null),
    );

    return MaterialApp.router(
      title: 'Lapor.in',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}