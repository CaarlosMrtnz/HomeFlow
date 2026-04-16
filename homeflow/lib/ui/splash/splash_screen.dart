import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
      if (state is Authenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } 
    },
    child: Scaffold(
        body: Container(
          width: double.infinity,
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
      ),
    );
  }
}