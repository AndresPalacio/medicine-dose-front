// Configuración del Sandbox de Amplify Gen2
// Este archivo contiene la configuración generada automáticamente por el sandbox

class AmplifySandboxConfig {
  // Configuración de Autenticación
  static const String userPoolId = 'us-east-1_j6l5AqE8f';
  static const String appClientId = '3c31dfcufou80ktb9vejpfcenu';
  static const String region = 'us-east-1';
  static const String identityPoolId =
      'us-east-1:5fc809e3-5843-4540-a3a5-47531544c4b2';

  // Configuración de API GraphQL
  static const String graphqlEndpoint =
      'https://u4e7d3gya5g57jm73knprlzzra.appsync-api.us-east-1.amazonaws.com/graphql';

  // Configuración de Política de Contraseñas
  static const int minPasswordLength = 8;
  static const bool requireLowercase = true;
  static const bool requireUppercase = true;
  static const bool requireNumbers = true;
  static const bool requireSymbols = true;

  // Atributos de Usuario Requeridos
  static const List<String> requiredAttributes = ['email'];

  // Tipos de Verificación
  static const List<String> verificationTypes = ['email'];

  // Configuración de MFA
  static const String mfaConfiguration = 'NONE';

  // Identidades No Autenticadas
  static const bool unauthenticatedIdentitiesEnabled = true;

  // Información del Sandbox
  static const String sandboxIdentifier = 'USUARIO';
  static const String stackName =
      'amplify-medicinedosefront-USUARIO-sandbox-56a86f9d03';
}
