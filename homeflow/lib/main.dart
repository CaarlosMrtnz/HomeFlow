import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
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

/// Punto de entrada de la aplicación.
/// Inicializa el framework, inyecta las variables de entorno estáticas y establece la conexión asíncrona con el backend.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  final String supabaseUrl = dotenv.env['SPB_URL'] ?? (throw Exception('Falta SPB_URL en el archivo .env'));
  final String supabaseKey = dotenv.env['SPB_KEY'] ?? (throw Exception('Falta SPB_KEY en el archivo .env'));
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const MainApp());

  runApp(const MainApp());
}

/// Raíz del árbol de widgets.
/// Se define como StatefulWidget para aislar y preservar propiedades que no deben re-instanciarse en cada repintado del framework.
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  /// Permite ejecutar operaciones de enrutamiento desde capas de lógica sin requerir un [BuildContext] local.
  final _navigatorKey = GlobalKey<NavigatorState>();

  /// Construye el proveedor de estado global y el sistema de rutas estáticas.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        )..add(AuthSubscriptionRequested()),
        
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Cuando el estado cambie a "desautenticado"
            if (state is Unauthenticated) {
              _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
          child: MaterialApp(
            navigatorKey: _navigatorKey, // Conexión de la llave al MaterialApp
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
              // Acota el ciclo de vida de los BLoCs de dominio a la existencia de la ruta principal.
              // Al cerrar sesión y destruir la ruta, estos BLoCs se destruyen automáticamente liberando memoria y cerrando los WebSockets.
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
      ),
    );
  }
}