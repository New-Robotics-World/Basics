import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/data/api_task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';

/// Test adapter to simulate mock HTTP network responses
class MockHttpClientAdapter implements HttpClientAdapter {
  late ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ApiTaskRepository Tests', () {
    late Dio dio;
    late MockHttpClientAdapter adapter;
    late ApiTaskRepository repository;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.taskflow.com'));
      adapter = MockHttpClientAdapter();
      dio.httpClientAdapter = adapter;
      repository = ApiTaskRepository(dio);
    });

    test('getTasks parses JSON list from remote server (200 OK)', () async {
      adapter.handler = (options) {
        expect(options.path, '/api/v1/tasks');
        expect(options.method, 'GET');

        final payload = jsonEncode([
          {
            'id': 'api-1',
            'title': 'Remote Cloud Task',
            'description': 'From Backend',
            'priority': 'high',
            'isCompleted': false,
          },
        ]);

        return ResponseBody.fromString(
          payload,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final tasks = await repository.getTasks();

      expect(tasks.length, 1);
      expect(tasks.first.id, 'api-1');
      expect(tasks.first.title, 'Remote Cloud Task');
      expect(tasks.first.priority, TaskPriority.high);
    });

    test('addTask sends POST request with task JSON', () async {
      const task = Task(
        id: 'new-api',
        title: 'New Cloud Task',
        priority: TaskPriority.low,
      );

      adapter.handler = (options) {
        expect(options.path, '/api/v1/tasks');
        expect(options.method, 'POST');
        expect((options.data as Map)['title'], 'New Cloud Task');

        return ResponseBody.fromString('{}', 201);
      };

      await expectLater(repository.addTask(task), completes);
    });

    test('getTaskById returns null on 404 response', () async {
      adapter.handler = (options) {
        return ResponseBody.fromString('{"message": "Not Found"}', 404);
      };

      final result = await repository.getTaskById('unknown-id');
      expect(result, isNull);
    });

    test('network failure throws friendly ApiException', () async {
      adapter.handler = (options) {
        return ResponseBody.fromString(
          '{"error": "Internal Server Error"}',
          500,
        );
      };

      expect(() => repository.getTasks(), throwsA(isA<ApiException>()));
    });
  });
}
