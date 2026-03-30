import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import '../../logic/auth/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el Cubit localmente solo para esta pantalla
    return BlocProvider(
      create: (context) => LoginCubit(authRepository: context.read<AuthRepository>()),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true; // Controla si estamos en Login o Registro

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos')),
      );
      return;
    }

    final cubit = context.read<LoginCubit>();
    if (_isLoginMode) {
      cubit.signIn(email, password);
    } else {
      cubit.signUp(email, password);
    }
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error.replaceAll('AuthException', 'Error')),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else if (state is LoginSuccess) {
                  // Si el login/registro es correcto, navegamos al Dashboard.
                  // (El AuthBloc global también se enterará por detrás y guardará la sesión)
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

                    // Tarjeta del formulario
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
                          // Campo email
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
                          
                          // Campo contraseña
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

                          // Botón principal
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

                    // Selector de modo
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