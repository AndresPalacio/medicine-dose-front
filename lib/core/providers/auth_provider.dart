import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _authState = const AuthState();
  AuthState get authState => _authState;

  // Getters para facilitar el acceso
  bool get isLoading => _authState.isLoading;
  bool get isAuthenticated => _authState.isAuthenticated;
  UserModel? get user => _authState.user;
  String? get error => _authState.error;
  bool get isInitialized => _authState.isInitialized;

  AuthProvider() {
    _initializeAuth();
  }

  // Inicializar autenticación
  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    try {
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        final currentUser = await _authService.getCurrentUser();
        _setAuthenticated(currentUser);
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setError('Error inicializando autenticación: $e');
    } finally {
      _setInitialized();
    }
  }

  // Iniciar sesión
  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.signIn(
        username: username,
        password: password,
      );
      
      if (result.isSuccess) {
        _setAuthenticated(result.user);
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Registrar usuario
  Future<bool> signUp({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.signUp(
        username: username,
        password: password,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      
      if (result.isSuccess) {
        // No establecemos el usuario como autenticado hasta que confirme su email
        _setMessage(result.message);
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Confirmar registro
  Future<bool> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      
      if (result.isSuccess) {
        _setMessage(result.message);
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Recuperar contraseña
  Future<bool> resetPassword({
    required String username,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.resetPassword(username: username);
      
      if (result.isSuccess) {
        _setMessage(result.message);
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Confirmar nueva contraseña
  Future<bool> confirmResetPassword({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.confirmResetPassword(
        username: username,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
      
      if (result.isSuccess) {
        _setMessage(result.message);
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cerrar sesión
  Future<bool> signOut() async {
    _setLoading(true);
    
    try {
      final result = await _authService.signOut();
      
      if (result.isSuccess) {
        _setUnauthenticated();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      if (result.isSuccess) {
        _setMessage(result.message);
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar usuario
  Future<void> refreshUser() async {
    if (isAuthenticated) {
      try {
        final currentUser = await _authService.getCurrentUser();
        if (currentUser != null) {
          _setAuthenticated(currentUser);
        }
      } catch (e) {
        // Silenciar error al refrescar usuario
      }
    }
  }

  // Métodos privados para actualizar estado
  void _setLoading(bool loading) {
    _authState = _authState.copyWith(isLoading: loading);
    notifyListeners();
  }

  void _setAuthenticated(UserModel? user) {
    _authState = _authState.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: user,
      error: null,
    );
    notifyListeners();
  }

  void _setUnauthenticated() {
    _authState = _authState.copyWith(
      isLoading: false,
      isAuthenticated: false,
      user: null,
      error: null,
    );
    notifyListeners();
  }

  void _setError(String error) {
    _authState = _authState.copyWith(
      isLoading: false,
      error: error,
    );
    notifyListeners();
  }

  void _setMessage(String message) {
    _authState = _authState.copyWith(
      isLoading: false,
      error: null,
    );
    notifyListeners();
  }

  void _clearError() {
    _authState = _authState.copyWith(error: null);
    notifyListeners();
  }

  void _setInitialized() {
    _authState = _authState.copyWith(isInitialized: true);
    notifyListeners();
  }
}
