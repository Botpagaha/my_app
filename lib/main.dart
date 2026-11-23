import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final storageService = StorageService();
  await storageService.init();

  runApp(BerduaApp(storageService: storageService));
}

class BerduaApp extends StatelessWidget {
  final StorageService storageService;

  const BerduaApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: storageService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Berdua — Ruang Privat Miftah & Cinta',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: storageService.isLoggedIn
              ? MainNavigationScreen(
                  storageService: storageService,
                  onLogout: () {},
                )
              : LoginScreen(
                  storageService: storageService,
                  onLoginSuccess: () {},
                ),
        );
      },
    );
  }
}
