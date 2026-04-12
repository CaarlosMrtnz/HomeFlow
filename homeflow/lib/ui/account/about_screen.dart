import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF203DA3)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "Logo" de la App
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF71B9FD).withOpacity(0.3), blurRadius: 30, spreadRadius: 10),
                  ],
                ),
                child: const Icon(Icons.home_rounded, size: 80, color: Color(0xFF71B9FD)),
              ),
              const SizedBox(height: 32),
              
              // Nombre y versión
              const Text(
                'HomeFlow',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
              ),
              
              const SizedBox(height: 60),

              // Créditos del TFG
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.school_outlined, color: Color(0xFFBDB2FF), size: 32),
                    SizedBox(height: 16),
                    Text(
                      'Final Degree Project', // Trabajo de Fin de Grado
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF203DA3)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Designed and developed by\nCarlos Martínez Agustín.', 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              const Text(
                '© 2026 HomeFlow. All rights reserved.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}