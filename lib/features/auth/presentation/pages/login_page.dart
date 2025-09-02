import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../utils/colors.dart';
import '../../../../custom_widgets/contra_button.dart';
import '../../../../custom_widgets/contra_text.dart';
import '../../../../custom_widgets/custom_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Header
                const CustomHeader(
                  lineOneText: "Bienvenido",
                  lineTwotext: "de vuelta",
                  color: wood_smoke,
                  fg_color: wood_smoke,
                  bg_color: athens_gray,
                ),
                
                const SizedBox(height: 40),
                
                // Subtítulo
                const ContraText(
                  text: "Inicia sesión para continuar con tu experiencia",
                  size: 16,
                  color: trout,
                  alignment: Alignment.center,
                ),
                
                const SizedBox(height: 40),
                
                // Campo de usuario
                AuthTextField(
                  controller: _usernameController,
                  label: "Usuario o Email",
                  hint: "Ingresa tu usuario o email",
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu usuario o email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Campo de contraseña
                AuthTextField(
                  controller: _passwordController,
                  label: "Contraseña",
                  hint: "Ingresa tu contraseña",
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: wood_smoke,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Recordar contraseña y olvidé contraseña
                Row(
                  children: [
                    // Checkbox recordar
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _rememberMe ? lightening_yellow : white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _rememberMe ? lightening_yellow : wood_smoke,
                              width: 2,
                            ),
                          ),
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: lightening_yellow,
                            checkColor: wood_smoke,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const ContraText(
                          text: "Recordarme",
                          size: 14,
                          color: wood_smoke,
                          alignment: Alignment.centerLeft,
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Olvidé contraseña
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const ContraText(
                        text: "¿Olvidaste tu contraseña?",
                        size: 14,
                        color: lightening_yellow,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Botón de login
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ContraButton(
                      text: "Iniciar Sesión",
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: authProvider.isLoading ? null : _handleLogin,
                      color: lightening_yellow,
                      textColor: wood_smoke,
                      borderColor: wood_smoke,
                      shadowColor: athens_gray,
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Separador
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: athens_gray,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const ContraText(
                        text: "o continúa con",
                        size: 14,
                        color: trout,
                        alignment: Alignment.center,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: athens_gray,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Botones de redes sociales
                Row(
                  children: [
                    Expanded(
                      child: SocialLoginButton(
                        text: "Google",
                        iconPath: 'assets/icons/ic_google.svg',
                        onPressed: () {
                          // TODO: Implementar login con Google
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SocialLoginButton(
                        text: "Facebook",
                        iconPath: 'assets/icons/facebook.svg',
                        onPressed: () {
                          // TODO: Implementar login con Facebook
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // No tienes cuenta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ContraText(
                      text: "¿No tienes una cuenta? ",
                      size: 14,
                      color: trout,
                      alignment: Alignment.center,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const ContraText(
                        text: "Regístrate",
                        size: 14,
                        color: lightening_yellow,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Navegar a la página principal
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Error al iniciar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
