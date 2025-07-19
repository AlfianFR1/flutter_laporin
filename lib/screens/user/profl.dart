import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laporin/providers/user_provider.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: userStateAsync.when(
        data: (userState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Foto profil Google
              CircleAvatar(
                radius: 50,
                backgroundImage: userState.photoURL != null
                    ? NetworkImage(userState.photoURL!)
                    : null,
                child: userState.photoURL == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                userState.displayName ?? 'Nama tidak tersedia',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                userState.email ?? 'Email tidak tersedia',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Terjadi kesalahan: $error'),
        ),
      ),
    );
  }
}
