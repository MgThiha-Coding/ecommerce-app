import 'package:dio/dio.dart';

typedef ApiCall<T> = Future<T> Function();

Future<T?> safeApiCall<T>(
  ApiCall<T> call, {
  required void Function(String message) onError,
}) async {
  try {
    return await call();
  } on DioException catch (e) {
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Connection timed out. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message = 'Check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        message = e.response?.data['message'] ?? 'Something went wrong.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }

    onError(message);
  } on Exception catch (e) {
    // Any other error
    onError(e.toString());
  }

  return null;
}
