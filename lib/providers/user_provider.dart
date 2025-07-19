// lib/providers/user_provider.dart (lanjutan)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laporin/providers/user_notifier.dart';
import 'package:laporin/models/user_state.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserState>(() {
  return UserNotifier();
});
