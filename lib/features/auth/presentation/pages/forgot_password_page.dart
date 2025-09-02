import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../utils/colors.dart';
import '../../../../custom_widgets/contra_button.dart';
import '../../../../custom_widgets/contra_text.dart';
import '../../../../custom_widgets/custom_header.dart';
import '../widgets/auth_text_field.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
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
                  lineOneText: "Recuperar",
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
                    Icons.lock_reset,
                    size: 40,
                    color: lightening_yellow,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Título
                const ContraText(
                  text: "¿Olvidaste tu contraseña?",
                  size: 24,
                  weight: FontWeight.bold,
                  color: wood_smoke,
                  alignment: Alignment.center,
                ),
                
                const SizedBox(height: 20),
                
                // Descripción
                const ContraText(
                  text: "No te preocupes, te ayudaremos a recuperarla. Ingresa tu nombre de usuario y te enviaremos un código de recuperación.",
                  size: 16,
                  color: trout,
                  alignment: Alignment.center,
                ),
                
                const SizedBox(height: 40),
                
                // Campo de usuario
                AuthTextField(
                  controller: _usernameController,
                  label: "Nombre de Usuario",
                  hint: "Ingresa tu nombre de usuario",
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu nombre de usuario';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Botón de enviar
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ContraButton(
                      text: "Enviar Código",
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: authProvider.isLoading ? null : _handleSendCode,
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
                    Navigator.of(context).pop();
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

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      username: _usernameController.text.trim(),
    );

    if (success && mounted) {
      // Navegar a la página de reset de contraseña
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(
            username: _usernameController.text.trim(),
          ),
        ),
      );
    } else if (mounted) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Error al enviar el código'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
