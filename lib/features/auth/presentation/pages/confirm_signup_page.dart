import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../utils/colors.dart';
import '../../../../custom_widgets/contra_button.dart';
import '../../../../custom_widgets/contra_text.dart';
import '../../../../custom_widgets/custom_header.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';

class ConfirmSignUpPage extends StatefulWidget {
  final String username;
  final String email;

  const ConfirmSignUpPage({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  State<ConfirmSignUpPage> createState() => _ConfirmSignUpPageState();
}

class _ConfirmSignUpPageState extends State<ConfirmSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  
  bool _isResending = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    _startTimer();
  }

  void _startTimer() {
    if (_resendCountdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _resendCountdown--;
          });
          _startTimer();
        }
      });
    }
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
                  lineOneText: "Confirmar",
                  lineTwotext: "Cuenta",
                  color: wood_smoke,
                  fg_color: wood_smoke,
                  bg_color: athens_gray,
                ),
                
                const SizedBox(height: 40),
                
                // Icono de verificación
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
                    Icons.email_outlined,
                    size: 40,
                    color: lightening_yellow,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Título
                const ContraText(
                  text: "Verifica tu email",
                  size: 24,
                  weight: FontWeight.bold,
                  color: wood_smoke,
                  alignment: Alignment.center,
                ),
                
                const SizedBox(height: 20),
                
                // Descripción
                ContraText(
                  text: "Hemos enviado un código de verificación a:",
                  size: 16,
                  color: trout,
                  alignment: Alignment.center,
                ),
                
                const SizedBox(height: 10),
                
                // Email
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: athens_gray,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: wood_smoke, width: 1),
                  ),
                  child: ContraText(
                    text: widget.email,
                    size: 16,
                    weight: FontWeight.w600,
                    color: wood_smoke,
                    alignment: Alignment.center,
                  ),
                ),
                
                const SizedBox(height: 30),
                
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
                
                const SizedBox(height: 30),
                
                // Botón de confirmar
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ContraButton(
                      text: "Confirmar Cuenta",
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: authProvider.isLoading ? null : _handleConfirm,
                      color: lightening_yellow,
                      textColor: wood_smoke,
                      borderColor: wood_smoke,
                      shadowColor: athens_gray,
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Reenviar código
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ContraText(
                      text: "¿No recibiste el código? ",
                      size: 14,
                      color: trout,
                      alignment: Alignment.center,
                    ),
                    if (_resendCountdown > 0)
                      ContraText(
                        text: "Reenviar en $_resendCountdown",
                        size: 14,
                        color: trout,
                        alignment: Alignment.center,
                      )
                    else
                      TextButton(
                        onPressed: _isResending ? null : _handleResendCode,
                        child: ContraText(
                          text: _isResending ? "Reenviando..." : "Reenviar código",
                          size: 14,
                          color: lightening_yellow,
                          alignment: Alignment.center,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Cambiar email
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const ContraText(
                    text: "Cambiar email",
                    size: 14,
                    color: lightening_yellow,
                    alignment: Alignment.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
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

  Future<void> _handleConfirm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.confirmSignUp(
      username: widget.username,
      confirmationCode: _codeController.text.trim(),
    );

    if (success && mounted) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta confirmada exitosamente! Ya puedes iniciar sesión.'),
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
          content: Text(authProvider.error ?? 'Error al confirmar la cuenta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleResendCode() async {
    setState(() {
      _isResending = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(username: widget.username);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código reenviado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _startResendCountdown();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Error al reenviar el código'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isResending = false;
    });
  }
}
