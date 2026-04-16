import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/profile.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/profile/profile_cubit.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

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
        title: const Text(
          'Personal Info',
          style: TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w800, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF71B9FD))),
                );
              }

              if (state is ProfileError) {
                return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
              }

              if (state is ProfileLoaded) {
                return _PersonalInfoForm(profile: state.profile);
              }
              
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _PersonalInfoForm extends StatefulWidget {
  final Profile profile;
  
  const _PersonalInfoForm({required this.profile});

  @override
  State<_PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<_PersonalInfoForm> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isSubmitting = false; // Controla el estado de carga del botón

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName ?? '');
    _phoneController = TextEditingController(text: widget.profile.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Traductor de errores de PostgreSQL
  String _getFriendlyErrorMessage(String rawError) {
    final errorLower = rawError.toLowerCase();
    if (errorLower.contains('unique constraint') || errorLower.contains('duplicate key')) {
      return 'This phone number is already registered to another account.';
    } else if (errorLower.contains('socketexception') || errorLower.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF71B9FD),
          child: Icon(Icons.person_outline, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          widget.profile.email,
          style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
        
        const SizedBox(height: 40),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF71B9FD)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    // Expresión regular. Esto permite solo números del 0 al 9 y el símbolo '+'
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')), 
                  ],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFFBDB2FF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botón Save 
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () async {
                      FocusScope.of(context).unfocus(); 
                      setState(() => _isSubmitting = true); // Arranca el loader

                      try {
                        await context.read<ProfileCubit>().updateProfile(
                          _nameController.text.trim(),
                          _phoneController.text.trim(),
                        );
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully.'), 
                              backgroundColor: Color(0xFF71B9FD),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          // Si falla, mostramos el error limpio
                          final friendlyError = _getFriendlyErrorMessage(e.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(friendlyError), 
                              backgroundColor: const Color(0xFFE57373),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isSubmitting = false); // Apaga el loader siempre
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF203DA3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40), 
      ],
    );
  }
}