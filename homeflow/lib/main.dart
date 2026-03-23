import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/dashboard_repository.dart';
import 'logic/dashboard/dashboard_bloc.dart';

import 'ui/splash/splash_screen.dart';
import 'ui/main/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carga variables de entorno
  await dotenv.load(fileName: ".env");
  
  // Inicializa Supabase
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

    return MaterialApp(
      title: 'HomeFlow',
      debugShowCheckedModeBanner: false, // Quita el banner rojo de "Debug"

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Outfit', 
        colorSchemeSeed: const Color(0xFFE5EDFC),
      ),

      initialRoute: '/', 
      routes: {
        '/': (context) => const SplashScreen(),
        // Aíslo los BLoCs en la ruta en lugar de inyectarlos sobre el MaterialApp para no saturar el context global.
        '/home': (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              // El operador en cascada evita depender del initState de la UI; se crea el BLoC e inmediatamente empieza a escuchar la DB.
              create: (context) => DashboardBloc(
                repository: DashboardRepository(),
                )..add(StartListeningReadings()),
            )
            // AlertsBloc 
          ],
          child: const MainScaffold(),
        ), 
      },
    );
  }
}
