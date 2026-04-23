import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feedback_screen.dart';
import 'personal_info_screen.dart'; 
import 'settings_screen.dart';
import 'about_screen.dart';

import '../../logic/profile/profile_cubit.dart';
import '../../logic/auth/auth_bloc.dart';

/// Pantalla principal de la cuenta del usuario.
/// Muestra los datos del perfil escuchando reactivamente a [ProfileCubit] y sirve como menú de navegación para ajustes de la app.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC),
      body: SafeArea(
        // Escucha los cambios de estado del perfil para repintar automáticamente si el usuario edita su información.
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              // Bloquea la vista con un indicador mientras el repositorio resuelve la petición a Supabase.
              return const Center(child: CircularProgressIndicator(color: Color(0xFF71B9FD)));
            }

            if (state is ProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is ProfileLoaded) {
              final profile = state.profile;
              
              return ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // Cabecera del perfil
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF71B9FD),
                        child: Icon(Icons.person_outline, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // Fallback de seguridad en caso de que el registro en BD no tenga nombre asignado.
                              profile.fullName?.isNotEmpty == true ? profile.fullName! : "Personal Profile",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF203DA3)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF203DA3), fontWeight: FontWeight.w600),
                            ),
                            if (profile.phoneNumber?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text(
                                profile.phoneNumber!,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF203DA3), fontWeight: FontWeight.w600),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  _buildMenuCard(
                    icon: Icons.person_outline,
                    title: 'Personal Info',
                    onTap: () {
                      // BlocProvider.value para pasar el Cubit a la nueva pantalla
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfileCubit>(),
                          child: const PersonalInfoScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.cloud_download_outlined,
                    title: 'Updates',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Las actualizaciones están al día.'),
                          backgroundColor: Color(0xFF71B9FD),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.ios_share,
                    title: 'Share App',
                    onTap: () async {
                      await Clipboard.setData(const ClipboardData(text: 'www.homeflow.com'));
                      // Valida que el widget siga en el árbol antes de usar el context tras el await para evitar excepciones.
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enlace copiado al portapapeles'),
                            backgroundColor: Color(0xFFBDB2FF),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.sentiment_satisfied_alt,
                    title: 'Send Feedback',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: () {
                      // Dispara el evento al Bloc global para destruir la sesión
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                  ),

                  const SizedBox(height: 100), // Espacio para el BottomNavigationBar
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Genera las tarjetas del menú reutilizando estilos y comportamiento táctil.
  // Helper para construir cada tarjeta del menú de forma idéntica a tu diseño.
  Widget _buildMenuCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF203DA3), size: 28),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF203DA3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}