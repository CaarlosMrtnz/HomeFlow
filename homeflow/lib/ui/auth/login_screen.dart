import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import '../../logic/auth/login_cubit.dart';

/// Punto de entrada a la vista de autenticación.
/// Configura la inyección de dependencias proveyendo una instancia acotada de [LoginCubit] a esta rama del árbol.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(authRepository: context.read<AuthRepository>()),
      child: const _LoginForm(),
    );
  }
}

/// Widget con estado que aisla la lógica de los controladores de texto y la reactividad de la interfaz.
class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  /// Libera los recursos de memoria asignados a los controladores al destruir el widget.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Analiza el string de la excepción de red y devuelve un mensaje de interfaz legible.
  // Traductor de errores
  String _getFriendlyErrorMessage(String rawError) {
    final errorLower = rawError.toLowerCase();
    
    if (errorLower.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    } else if (errorLower.contains('user already registered') || errorLower.contains('already exists')) {
      return 'An account with this email already exists.';
    } else if (errorLower.contains('rate limit')) {
      return 'Too many attempts. Please try again later.';
    } else if (errorLower.contains('socketexception') || errorLower.contains('network') || errorLower.contains('host lookup')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorLower.contains('password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }
    
    // Fallback estandarizado para excepciones no contempladas en el dominio
    return 'An unexpected error occurred. Please try again.';
  }

  /// Dispara el flujo de autenticación si se superan las barreras de validación local.
  void _submit(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validación en el frontend
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar(context, 'Please fill in all fields.');
      return;
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorSnackBar(context, 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar(context, 'Password must be at least 6 characters long.');
      return;
    }
 
    // Llamada al cubit
    final cubit = context.read<LoginCubit>();
    if (_isLoginMode) {
      cubit.signIn(email, password);
    } else {
      cubit.signUp(email, password);
    }
  }

  /// Helper visual que estandariza los mensajes de error superpuestos en la pantalla.
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE57373),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state is LoginFailure) {
                  // Pasamos el error por nuestro traductor antes de mostrarlo
                  final friendlyMessage = _getFriendlyErrorMessage(state.error);
                  _showErrorSnackBar(context, friendlyMessage);
                } else if (state is LoginSuccess) {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        'HomeFlow',
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoginMode ? 'Welcome back' : 'Create an account',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 48),

                    Container(
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
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF71B9FD)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFBDB2FF)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: state is LoginLoading ? null : () => _submit(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF203DA3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: state is LoginLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      _isLoginMode ? 'Sign In' : 'Sign Up',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                        });
                      },
                      child: Text(
                        _isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Sign In",
                        style: const TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}