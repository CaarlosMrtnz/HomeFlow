import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../logic/profile/profile_cubit.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC), 
      body: SafeArea(
        child: Column(
          children: [
            ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF71B9FD), Color(0xFFBDB2FF)],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'Account',
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
            
            const SizedBox(height: 20),

            // El bloque del perfil conectado a Supabase
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading || state is ProfileInitial) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF71B9FD)));
                }

                if (state is ProfileError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is ProfileLoaded) {
                  return Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF71B9FD),
                        child: Icon(Icons.person_outline, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Mi Perfil", // En el futuro añadiré el campo 'name' 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.profile.email, // Traemos el email real de la base de datos
                        style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const Spacer(),

            // Botón para cerrar sesión
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Lanzamos el evento que se encarga de borrar el token y el router nos echará a la pantalla de Login.
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  icon: const Icon(Icons.logout, color: Color(0xFFE57373)),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFE57373)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Espacio para el menú inferior
          ],
        ),
      ),
    );
  }
}