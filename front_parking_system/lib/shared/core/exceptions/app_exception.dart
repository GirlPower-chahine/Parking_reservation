import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;

  AppException([this.message = 'An unexpected error occurred']);

  static AppException from(dynamic exception) {
    if (exception is AppException) return exception;

    if (exception is DioException) {
      final dioException = exception;

      // Vérifier d'abord le code de statut
      if (dioException.response?.statusCode == 401) {
        return InvalidCredentialsException();
      }

      if (dioException.response?.statusCode == 403) {
        return UnauthorizedException();
      }

      // Cas spécial : FormatException due à une réponse HTML au lieu de JSON
      if (dioException.type == DioExceptionType.unknown &&
          (dioException.message?.contains('FormatException') == true ||
              dioException.message?.contains('Unexpected character') == true)) {
        return AppException('Server response format error - operation may have succeeded');
      }

      // Pour les codes de succès (200-299), ne pas traiter comme une erreur
      if (dioException.response?.statusCode != null &&
          dioException.response!.statusCode! >= 200 &&
          dioException.response!.statusCode! < 300) {
        return AppException('Operation completed successfully');
      }

      // Gérer les différents types d'erreurs selon le type de requête
      String errorMessage = 'An error occurred';

      if (dioException.response?.data != null) {
        if (dioException.response!.data is Map) {
          errorMessage = dioException.response!.data['message'] ??
              dioException.response!.data['error'] ??
              'Server error';
        } else if (dioException.response!.data is String) {
          errorMessage = dioException.response!.data;
        }
      }

      // Déterminer le type d'exception selon la méthode HTTP
      switch (dioException.requestOptions.method.toUpperCase()) {
        case 'POST':
          return CreateException(errorMessage);
        case 'PUT':
        case 'PATCH':
          return UpdateException(errorMessage);
        case 'DELETE':
          return DeleteException(errorMessage);
        case 'GET':
          return FetchException(errorMessage);
        default:
          return NetworkException(errorMessage);
      }
    }

    // Vérifier les messages d'erreur spécifiques
    if (exception.toString().contains('401')) {
      return InvalidCredentialsException();
    }

    if (exception.toString().contains('403')) {
      return UnauthorizedException();
    }

    // Vérifier si c'est une FormatException
    if (exception.toString().contains('FormatException') ||
        exception.toString().contains('Unexpected character')) {
      return AppException('Response format error - operation may have succeeded');
    }

    return UnknownException();
  }
}

class UnknownException extends AppException {
  UnknownException() : super('An unexpected error occurred');
}

class AuthException extends AppException {
  AuthException([super.message = 'Authentication error']);
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password');
}

class UnauthorizedException extends AuthException {
  UnauthorizedException() : super('You are not authorized to perform this action');
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Network error']);
}

class CreateException extends AppException {
  CreateException([super.message = 'Error creating item']);
}

class UpdateException extends AppException {
  UpdateException([super.message = 'Error updating item']);
}

class DeleteException extends AppException {
  DeleteException([super.message = 'Error deleting item']);
}

class FetchException extends AppException {
  FetchException([super.message = 'Error fetching data']);
}

// Garder l'ancienne classe pour la compatibilité
class UpdatePostException extends UpdateException {
  UpdatePostException([super.message = 'Error updating post']);
}