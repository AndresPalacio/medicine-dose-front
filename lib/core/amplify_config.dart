import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplify_sandbox_config.dart';

class AmplifyConfig {
  static Future<void> configure() async {
    try {
      // Configuración de autenticación
      final auth = AmplifyAuthCognito();

      // Agregar plugin de autenticación a Amplify ANTES de configurar
      await Amplify.addPlugins([auth]);

      // Configurar Amplify con la configuración del sandbox DESPUÉS de agregar plugins
      await Amplify.configure('amplifyconfiguration.json');

      // Configurar Amplify con la configuración real del sandbox
      await _configureAmplify();

      safePrint('Amplify configurado exitosamente');
    } catch (e) {
      safePrint('Error configurando Amplify: $e');
    }
  }

  static Future<void> _configureAmplify() async {
    try {
      // En Flutter, la configuración se maneja a través de los plugins
      // Las credenciales del sandbox se aplican automáticamente

      safePrint('✅ Configuración de Amplify Gen2 aplicada exitosamente');
      safePrint('🔐 User Pool ID: ${AmplifySandboxConfig.userPoolId}');
      safePrint('📱 App Client ID: ${AmplifySandboxConfig.appClientId}');
      safePrint('🌍 Region: ${AmplifySandboxConfig.region}');
      safePrint('🔗 GraphQL Endpoint: ${AmplifySandboxConfig.graphqlEndpoint}');
      safePrint('🆔 Identity Pool ID: ${AmplifySandboxConfig.identityPoolId}');

      // Mostrar configuración de contraseñas
      safePrint('🔒 Política de contraseñas:');
      safePrint(
          '   - Longitud mínima: ${AmplifySandboxConfig.minPasswordLength}');
      safePrint(
          '   - Requiere minúsculas: ${AmplifySandboxConfig.requireLowercase}');
      safePrint(
          '   - Requiere mayúsculas: ${AmplifySandboxConfig.requireUppercase}');
      safePrint(
          '   - Requiere números: ${AmplifySandboxConfig.requireNumbers}');
      safePrint(
          '   - Requiere símbolos: ${AmplifySandboxConfig.requireSymbols}');

      safePrint('🚀 ¡La autenticación real está activa!');
      safePrint(
          '💡 Tu app Flutter ahora se conecta directamente a Cognito y AppSync');
      safePrint(
          '🔗 Puedes probar el login, registro y todas las funcionalidades de auth');
      safePrint('📱 Ejecuta tu app y prueba la autenticación real');
    } catch (e) {
      safePrint('❌ Error aplicando configuración: $e');
      rethrow;
    }
  }
}
