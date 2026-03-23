import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Rutina asíncrona sin await para no bloquear el hilo; la UI del Splash necesita pintarse de inmediato.
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Este delay, una simulación del tiempo de carga, reserva el espacio lógico donde más adelante validaremos el token contra Supabase o precargaremos cachés pesadas. 
    await Future.delayed(const Duration(seconds: 3));

    // Evita un crash si el contexto de la vista se destruye durante la espera asíncrona de arriba.
    if (!mounted) return;

    // pushReplacement evita que el usuario pueda volver al Splash dándole al botón de "Atrás"
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // Degradado del diseño de Figma
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF71B9FD),
              Color(0xFFFBFBFC), 
              Color(0xFFFBFBFC), 
              Color(0xFFFBFBFC), 
              Color(0xFFBDB2FF), 
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              'assets/images/logo_homeflow.png', 
              height: 251, 
              width: 318,
              fit: BoxFit.contain, 
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Text(
                "Master your home's flow with us.",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFBFBFC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}