import 'package:go_router/go_router.dart';
import 'package:laporin/models/user_state.dart';

// Screens
import 'package:laporin/screens/splash_screen.dart';
import 'package:laporin/screens/auth/login_screen.dart';
import 'package:laporin/screens/admin/dashboard_admin.dart';
import 'package:laporin/screens/user/dashboard_user.dart';
import 'package:laporin/screens/user/buat_laporan.dart';
import 'package:laporin/screens/user/laporan_saya.dart';
import 'package:laporin/screens/user/laporan_detail.dart';
import 'package:laporin/screens/user/profl.dart';
import 'package:laporin/screens/admin/manajemen_Laporan.dart';
import 'package:laporin/screens/admin/manajemen_laporan_detail.dart';
import 'package:laporin/screens/admin/daftar_pengguna.dart';

class AppRouter {
  static GoRouter createRouter(UserState? userState) {
    return GoRouter(
      initialLocation: '/', // tetap splash
      debugLogDiagnostics: true, // opsional, untuk debugging
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
          redirect: (context, state) {
            // Redirect jika user sudah login
            if (userState?.isLoggedIn == true) {
              if (userState?.role == 'admin') {
                return '/adminDashboard';
              } else {
                return '/userDashboard';
              }
            }
            return null; // tetap splash jika belum login
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        // USER ROUTES
        GoRoute(
          path: '/userDashboard',
          builder: (context, state) => const UserDashboardScreen(),
        ),
        GoRoute(
          path: '/buat-laporan',
          builder: (context, state) => const BuatLaporanScreen(),
        ),
        GoRoute(
          path: '/laporan-saya',
          builder: (context, state) => const LaporanSayaScreen(),
        ),
        GoRoute(
          path: '/laporan/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) return const UserDashboardScreen(); // fallback
            return LaporanDetailScreen(reportId: id);
          },
        ),
        GoRoute(
          path: '/profil',
          builder: (context, state) => const ProfilScreen(),
        ),

        // ADMIN ROUTES
        GoRoute(
          path: '/adminDashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/manajemen-laporan',
          builder: (context, state) => const ManajemenLaporanScreen(),
        ),
        GoRoute(
          path: '/manajemen-laporan-detail/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) return const AdminDashboardScreen(); // fallback
            return ManajemenLaporanDetailScreen(reportId: id);
          },
        ),
        GoRoute(
          path: '/daftar-pengguna',
          builder: (context, state) => const DaftarPenggunaScreen(),
        ),
      ],
      redirect: (context, state) {
        final loggedIn = userState?.isLoggedIn ?? false;
        final isLoggingIn = state.matchedLocation == '/login';

        // Jika belum login dan bukan di halaman login, redirect ke login
        if (!loggedIn && !isLoggingIn) return '/login';

        // Jika sudah login dan ke /login, arahkan ke dashboard sesuai role
        if (loggedIn && isLoggingIn) {
          return userState?.role == 'admin' ? '/adminDashboard' : '/userDashboard';
        }

        return null; // tidak redirect
      },
    );
  }
}
