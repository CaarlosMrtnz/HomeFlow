import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Repositorios
import 'data/alerts_repository.dart';
import 'data/auth_repository.dart';
import 'data/dashboard_repository.dart';
import 'data/profile_repository.dart';

// BLoCs / Cubits
import 'logic/dashboard/dashboard_bloc.dart';
import 'logic/alerts/alerts_bloc.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/profile/profile_cubit.dart';

// Pantallas
import 'ui/splash/splash_screen.dart';
import 'ui/auth/login_screen.dart';
import 'ui/main/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: dotenv.env['SPB_URL']!,
    anonKey: dotenv.env['SPB_KEY']!,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // RepositoryProvider a nivel raíz. Así el LoginScreen siempre lo encontrará.
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        )..add(AuthSubscriptionRequested()),
        child: MaterialApp(
          title: 'HomeFlow',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Outfit', 
            colorSchemeSeed: const Color(0xFFE5EDFC),
            scaffoldBackgroundColor: const Color(0xFFE5EDFC),
          ),
          initialRoute: '/', 
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => DashboardBloc(repository: DashboardRepository())..add(StartListeningReadings())),
                BlocProvider(create: (context) => AlertsBloc(alertsRepository: AlertsRepository())..add(StartListeningAlerts())),
                BlocProvider(create: (context) => ProfileCubit(repository: ProfileRepository())..loadProfile()),
              ],
              child: const MainScaffold(),
            ), 
          },
        ),
      ),
    );
  }
}