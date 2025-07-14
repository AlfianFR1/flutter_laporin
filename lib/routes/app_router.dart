
import 'package:go_router/go_router.dart';
import 'package:laporin/providers/user_provider.dart';
import 'package:laporin/screens/admin/daftar_pengguna.dart';
import 'package:laporin/screens/admin/manajemen_Laporan.dart';
import 'package:laporin/screens/admin/manajemen_laporan_detail.dart';
import 'package:laporin/screens/user/laporan_detail.dart';
import 'package:laporin/screens/user/profl.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/dashboard_admin.dart';
import '../screens/user/dashboard_user.dart';
import '../screens/user/buat_laporan.dart';
import '../screens/user/laporan_saya.dart';
// import '../screens/user/laporan_detail.dart'; // kalau perlu detail pakai path parameter



class AppRouter {
  static GoRouter createRouter(UserProvider userProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: userProvider,
      redirect: (context, state) {
        final isLoggedIn = userProvider.isLoggedIn;
        final role = userProvider.role;
        final isOnLoginPage = state.fullPath == '/login';

        // Jika belum login dan buka bukan /login, arahkan ke /login
        if (!isLoggedIn && !isOnLoginPage) {
          return '/login';
        }

        // Jika sudah login dan coba buka /login, arahkan ke dashboard sesuai role
        if (isLoggedIn && isOnLoginPage) {
          if (role == 'admin') return '/adminDashboard';
          return '/userDashboard';
        }

        // Jika user login tapi buka route yang tidak sesuai role
        if (isLoggedIn) {
          // Jika admin buka dashboard user
          if (role == 'admin' && state.fullPath == '/userDashboard') {
            return '/adminDashboard';
          }

          // Jika user biasa buka dashboard admin
          if (role == 'user' && state.fullPath == '/adminDashboard') {
            return '/userDashboard';
          }
        }

        // Selain itu, biarkan tetap
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/userDashboard',
          builder: (context, state) => const UserDashboardScreen(),
        ),
        GoRoute(
          path: '/adminDashboard',
          builder: (context, state) => const AdminDashboardScreen(),
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
            final id = int.parse(state.pathParameters['id']!);
            return LaporanDetailScreen(reportId: id);
          },
        ),
        GoRoute(
          path:'/profil',
          builder: (context, state) => const ProfilScreen(),
        ),

        // Tambahkan route lainnya seperti buat-laporan, dll

        GoRoute(
          path:'/manajemen-laporan',
          builder: (context, state) => const ManajemenLaporanScreen(),
        ),

        GoRoute(
          path: '/manajemen-laporan-detail/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ManajemenLaporanDetailScreen(reportId: id);
          },
        ),

        GoRoute(
          path:'/daftar-pengguna',
          builder: (context, state) => const DaftarPenggunaScreen(),
        ),
      ],
    );
  }
}