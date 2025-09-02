import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../utils/colors.dart';
import '../../../../custom_widgets/contra_button.dart';
import '../../../../custom_widgets/contra_text.dart';
import '../../../../custom_widgets/custom_header.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String username;

  const ResetPasswordPage({
    super.key,
    required this.username,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                  lineOneText: "Nueva",
                  lineTwotext: "Contraseña",
                  color: wood_smoke,
                  fg_color: wood_smoke,
                  bg_color: athens_gray,
                ),
                
                const SizedBox(height: 40),
                
                // Icono de candado
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: lightening_yellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: lightening_yellow,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_open,
                    size: 40,
                    color: lightening_yellow,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Título
                const ContraText(
                  text: "Crea tu nueva contraseña",
                  size: 24,
                  weight: FontWeight.bold,
                  color: wood_smoke,
                  alignment: Alignment.center,
                ),
                
                const SizedBox(height: 20),
                
                // Descripción
                const ContraText(
                  text: "Ingresa el código de verificación que recibiste y crea una nueva contraseña segura.",
                  size: 16,
                  color: trout,
                  alignment: Alignment.center,
                ),
                
                const SizedBox(height: 40),
                
                // Campo de código
                AuthTextField(
                  controller: _codeController,
                  label: "Código de Verificación",
                  hint: "Ingresa el código de 6 dígitos",
                  prefixIcon: Icons.security,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el código de verificación';
                    }
                    if (value.length != 6) {
                      return 'El código debe tener 6 dígitos';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return 'El código solo debe contener números';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Nueva contraseña
                AuthTextField(
                  controller: _newPasswordController,
                  label: "Nueva Contraseña",
                  hint: "Crea una nueva contraseña segura",
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureNewPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                      color: wood_smoke,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa una nueva contraseña';
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
                
                // Confirmar nueva contraseña
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: "Confirmar Nueva Contraseña",
                  hint: "Repite tu nueva contraseña",
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
                      return 'Por favor confirma tu nueva contraseña';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Botón de resetear contraseña
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ContraButton(
                      text: "Cambiar Contraseña",
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: authProvider.isLoading ? null : _handleResetPassword,
                      color: lightening_yellow,
                      textColor: wood_smoke,
                      borderColor: wood_smoke,
                      shadowColor: athens_gray,
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Volver al login
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const ContraText(
                    text: "Volver al inicio de sesión",
                    size: 14,
                    color: lightening_yellow,
                    alignment: Alignment.center,
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.confirmResetPassword(
      username: widget.username,
      newPassword: _newPasswordController.text,
      confirmationCode: _codeController.text.trim(),
    );

    if (success && mounted) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Contraseña cambiada exitosamente! Ya puedes iniciar sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navegar al login
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
            (route) => false,
          );
        }
      });
    } else if (mounted) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Error al cambiar la contraseña'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
