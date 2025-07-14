import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/providers/user_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Foto profil Google
            CircleAvatar(
              radius: 50,
              backgroundImage: userProvider.photoURL != null
                  ? NetworkImage(userProvider.photoURL!)
                  : null,
              child: userProvider.photoURL == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              userProvider.displayName ?? 'Nama tidak tersedia',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              userProvider.email ?? 'Email tidak tersedia',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
