import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../utils/colors.dart';
import '../../../../custom_widgets/contra_button.dart';
import '../../../../custom_widgets/contra_text.dart';
import '../../../../custom_widgets/custom_header.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';
import 'confirm_signup_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: wood_smoke),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Header
                const CustomHeader(
                  lineOneText: "Crear",
                  lineTwotext: "Cuenta",
                  color: wood_smoke,
                  fg_color: wood_smoke,
                  bg_color: athens_gray,
                ),
                
                const SizedBox(height: 40),
                
                // Subtítulo
                const ContraText(
                  text: "Completa los datos para crear tu cuenta",
                  size: 16,
                  color: trout,
                  alignment: Alignment.center,
                ),
                
                const SizedBox(height: 40),
                
                // Nombre de usuario
                AuthTextField(
                  controller: _usernameController,
                  label: "Nombre de Usuario",
                  hint: "Ingresa tu nombre de usuario",
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un nombre de usuario';
                    }
                    if (value.length < 3) {
                      return 'El nombre de usuario debe tener al menos 3 caracteres';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Solo se permiten letras, números y guiones bajos';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Email
                AuthTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Ingresa tu email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Nombre
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _firstNameController,
                        label: "Nombre",
                        hint: "Tu nombre",
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthTextField(
                        controller: _lastNameController,
                        label: "Apellido",
                        hint: "Tu apellido",
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu apellido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Teléfono (opcional)
                AuthTextField(
                  controller: _phoneController,
                  label: "Teléfono (opcional)",
                  hint: "Tu número de teléfono",
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
                        return 'Por favor ingresa un teléfono válido';
                      }
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Contraseña
                AuthTextField(
                  controller: _passwordController,
                  label: "Contraseña",
                  hint: "Crea una contraseña segura",
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
                      return 'Por favor ingresa una contraseña';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                      return 'La contraseña debe contener mayúsculas, minúsculas y números';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Confirmar contraseña
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: "Confirmar Contraseña",
                  hint: "Repite tu contraseña",
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: wood_smoke,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Términos y condiciones
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _acceptTerms ? lightening_yellow : white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _acceptTerms ? lightening_yellow : wood_smoke,
                          width: 2,
                        ),
                      ),
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: lightening_yellow,
                        checkColor: wood_smoke,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: wood_smoke,
                          ),
                          children: [
                            const TextSpan(text: "Acepto los "),
                            TextSpan(
                              text: "Términos y Condiciones",
                              style: const TextStyle(
                                color: lightening_yellow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: " y la "),
                            TextSpan(
                              text: "Política de Privacidad",
                              style: const TextStyle(
                                color: lightening_yellow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Botón de registro
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ContraButton(
                      text: "Crear Cuenta",
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: (authProvider.isLoading || !_acceptTerms) ? null : _handleRegister,
                      color: (_acceptTerms && !authProvider.isLoading) ? lightening_yellow : athens_gray,
                      textColor: (_acceptTerms && !authProvider.isLoading) ? wood_smoke : trout,
                      borderColor: wood_smoke,
                      shadowColor: athens_gray,
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Ya tienes cuenta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ContraText(
                      text: "¿Ya tienes una cuenta? ",
                      size: 14,
                      color: trout,
                      alignment: Alignment.center,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const ContraText(
                        text: "Inicia Sesión",
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
    );

    if (success && mounted) {
      // Navegar a la página de confirmación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmSignUpPage(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else if (mounted) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Error al crear la cuenta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
