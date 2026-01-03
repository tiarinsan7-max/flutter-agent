import 'package:dio/dio.dart';
import 'logger.dart';

class ExceptionHandler {
  /// Parse exception and return user-friendly message
  static String getErrorMessage(dynamic error) {
    String message = 'An error occurred';

    if (error is DioException) {
      message = _handleDioError(error);
    } else if (error is FormatException) {
      message = 'Invalid data format';
    } else if (error is Exception) {
      message = error.toString();
    } else {
      message = error.toString();
    }

    AppLogger.error('Error: $message');
    return message;
  }

  /// Handle Dio errors specifically
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again';
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode ?? 0);
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection';
      case DioExceptionType.unknown:
        return 'Unknown error occurred';
      default:
        return 'An error occurred';
    }
  }

  /// Handle HTTP status codes
  static String _handleStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized. Please login again';
      case 403:
        return 'Access forbidden';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Server error. Please try again later';
      case 502:
        return 'Bad gateway. Please try again later';
      case 503:
        return 'Service unavailable. Please try again later';
      default:
        return 'Error: $statusCode';
    }
  }

  /// Log exception with full details
  static void logException(
    dynamic error, [
    StackTrace? stackTrace,
    String? additionalInfo,
  ]) {
    String message = 'Exception: ${error.toString()}';
    if (additionalInfo != null) {
      message += '\nAdditional Info: $additionalInfo';
    }

    AppLogger.error(message, error, stackTrace);
  }
}
