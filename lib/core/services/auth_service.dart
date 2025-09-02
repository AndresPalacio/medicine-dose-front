import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      safePrint('Error verificando autenticación: $e');
      return false;
    }
  }

  // Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();
      
      // Mapear atributos de Cognito a nuestro modelo
      String email = '';
      String firstName = '';
      String lastName = '';
      String phoneNumber = '';
      
      for (final attribute in attributes) {
        switch (attribute.userAttributeKey) {
          case AuthUserAttributeKey.email:
            email = attribute.value;
            break;
          case AuthUserAttributeKey.givenName:
            firstName = attribute.value;
            break;
          case AuthUserAttributeKey.familyName:
            lastName = attribute.value;
            break;
          case AuthUserAttributeKey.phoneNumber:
            phoneNumber = attribute.value;
            break;
        }
      }
      
      return UserModel(
        id: user.userId,
        email: email,
        username: user.username,
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
        phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
        isEmailVerified: attributes.any((attr) => 
          attr.userAttributeKey == AuthUserAttributeKey.emailVerified && 
          attr.value == 'true'
        ),
      );
    } catch (e) {
      safePrint('Error obteniendo usuario actual: $e');
      return null;
    }
  }

  // Iniciar sesión
  Future<AuthResult> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      
      if (result.isSignedIn) {
        return AuthResult.success(
          user: await getCurrentUser(),
          message: 'Inicio de sesión exitoso',
        );
      } else {
        return AuthResult.failure(
          message: 'No se pudo iniciar sesión',
        );
      }
    } on AuthException catch (e) {
      String message = 'Error de autenticación';
      
      switch (e.message) {
        case 'User is not confirmed.':
          message = 'Usuario no confirmado. Verifica tu email.';
          break;
        case 'Incorrect username or password.':
          message = 'Usuario o contraseña incorrectos';
          break;
        case 'User does not exist.':
          message = 'El usuario no existe';
          break;
        case 'Password attempts exceeded':
          message = 'Demasiados intentos fallidos. Intenta más tarde.';
          break;
        default:
          message = e.message ?? 'Error desconocido';
      }
      
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(
        message: 'Error inesperado: $e',
      );
    }
  }

  // Registrar usuario
  Future<AuthResult> signUp({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final userAttributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.email: email,
      };
      
      if (firstName != null && firstName.isNotEmpty) {
        userAttributes[AuthUserAttributeKey.givenName] = firstName;
      }
      
      if (lastName != null && lastName.isNotEmpty) {
        userAttributes[AuthUserAttributeKey.familyName] = lastName;
      }
      
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        userAttributes[AuthUserAttributeKey.phoneNumber] = phoneNumber;
      }

      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );

      if (result.isSignUpComplete) {
        return AuthResult.success(
          message: 'Usuario registrado exitosamente',
        );
      } else {
        return AuthResult.success(
          message: 'Usuario registrado. Verifica tu email para confirmar.',
        );
      }
    } on AuthException catch (e) {
      String message = 'Error en el registro';
      
      switch (e.message) {
        case 'Username already exists':
          message = 'El nombre de usuario ya existe';
          break;
        case 'Invalid email address format.':
          message = 'Formato de email inválido';
          break;
        case 'Password did not conform with policy':
          message = 'La contraseña no cumple con los requisitos de seguridad';
          break;
        default:
          message = e.message ?? 'Error desconocido';
      }
      
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(
        message: 'Error inesperado: $e',
      );
    }
  }

  // Confirmar registro
  Future<AuthResult> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      
      return AuthResult.success(
        message: 'Usuario confirmado exitosamente',
      );
    } on AuthException catch (e) {
      String message = 'Error confirmando usuario';
      
      switch (e.message) {
        case 'CodeMismatchException':
          message = 'Código de confirmación incorrecto';
          break;
        case 'ExpiredCodeException':
          message = 'Código de confirmación expirado';
          break;
        default:
          message = e.message ?? 'Error desconocido';
      }
      
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(
        message: 'Error inesperado: $e',
      );
    }
  }

  // Recuperar contraseña
  Future<AuthResult> resetPassword({
    required String username,
  }) async {
    try {
      await Amplify.Auth.resetPassword(username: username);
      
      return AuthResult.success(
        message: 'Se envió un código de recuperación a tu email',
      );
    } on AuthException catch (e) {
      String message = 'Error recuperando contraseña';
      
      switch (e.message) {
        case 'User does not exist.':
          message = 'El usuario no existe';
          break;
        default:
          message = e.message ?? 'Error desconocido';
      }
      
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(
        message: 'Error inesperado: $e',
      );
    }
  }

  // Confirmar nueva contraseña
  Future<AuthResult> confirmResetPassword({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: username,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
      
      return AuthResult.success(
        message: 'Contraseña actualizada exitosamente',
      );
    } on AuthException catch (e) {
      String message = 'Error confirmando nueva contraseña';
      
      switch (e.message) {
        case 'CodeMismatchException':
          message = 'Código de confirmación incorrecto';
          break;
        case 'ExpiredCodeException':
          message = 'Código de confirmación expirado';
          break;
        case 'Password did not conform with policy':
          message = 'La nueva contraseña no cumple con los requisitos de seguridad';
          break;
        default:
          message = e.message ?? 'Error desconocido';
      }
      
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(
        message: 'Error inesperado: $e',
      );
    }
  }

  // Cerrar sesión
  Future<AuthResult> signOut() async {
    try {
      await Amplify.Auth.signOut();
      
      return AuthResult.success(
        message: 'Sesión cerrada exitosamente',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Error cerrando sesión: $e',
      );
    }
  }

  // Cambiar contraseña
  Future<AuthResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await Amplify.Auth.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      return AuthResult.success(
        message: 'Contraseña actualizada exitosamente',
      );
    } on AuthException catch (e) {
      String message = 'Error cambiando contraseña';
      
      switch (e.message) {
        case 'Incorrect username or password.':
          message = 'Contraseña actual incorrecta';
          break;
        case 'Password did not conform with policy':
          message = 'La nueva contraseña no cumple con los requisitos de seguridad';
          break;
        default:
          message = e.message ?? 'Error desconocido';
      }
      
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(
        message: 'Error inesperado: $e',
      );
    }
  }
}

// Resultado de operaciones de autenticación
class AuthResult {
  final bool isSuccess;
  final String message;
  final UserModel? user;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.user,
    this.error,
  });

  factory AuthResult.success({
    String? message,
    UserModel? user,
  }) {
    return AuthResult._(
      isSuccess: true,
      message: message ?? 'Operación exitosa',
      user: user,
    );
  }

  factory AuthResult.failure({
    required String message,
    String? error,
  }) {
    return AuthResult._(
      isSuccess: false,
      message: message,
      error: error,
    );
  }
}
