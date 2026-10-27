import 'package:dio/dio.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/domain/task_repository.dart';

/// Exception thrown when remote API operations encounter a failure.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

/// Remote REST API implementation of [TaskRepository] using [Dio].
///
/// Communicates with backend endpoints:
/// - `GET /api/v1/tasks`: Retrieve tasks
/// - `GET /api/v1/tasks/:id`: Retrieve single task
/// - `POST /api/v1/tasks`: Create task
/// - `PUT /api/v1/tasks/:id`: Update task
/// - `DELETE /api/v1/tasks/:id`: Delete task
class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._dio);

  final Dio _dio;

  static const String _tasksEndpoint = '/api/v1/tasks';

  @override
  Future<List<Task>> getTasks() async {
    try {
      final response = await _dio.get<List<dynamic>>(_tasksEndpoint);
      final data = response.data;
      if (data == null) return [];

      return data
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_tasksEndpoint/$id',
      );
      if (response.data == null) return null;
      return Task.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      await _dio.post<dynamic>(_tasksEndpoint, data: task.toJson());
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      await _dio.put<dynamic>(
        '$_tasksEndpoint/${task.id}',
        data: task.toJson(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete<dynamic>('$_tasksEndpoint/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timed out. Check your network.',
          statusCode: status,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          'Server returned error: ${e.response?.statusMessage ?? "Unknown"}',
          statusCode: status,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection. Please verify your network.',
        );
      default:
        return ApiException(
          e.message ?? 'An unexpected network error occurred.',
          statusCode: status,
        );
    }
  }
}
