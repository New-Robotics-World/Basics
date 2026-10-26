# Learning Progress Tracker

## Milestone Log

### Milestone 1: Environment & Project Setup (Phase 1)
- **Status**: Completed
- **Concepts Introduced**:
  - Flutter SDK inspection & environment constraints (`sdk: ^3.11.0`, Flutter `3.41.2`).
  - Project baseline verification with `flutter test`.
  - Feature-first vs. Layer-first structural theory.
  - The philosophy of evolutionary architecture in production systems.
- **Features Implemented**: Initial Flutter project scaffolding.
- **Tests Added**: Base smoke test verified.
- **Commands & Checks Performed**:
  - `flutter --version` -> Exited 0.
  - `flutter create --org com.taskflow --project-name taskflow .` -> Exited 0.
  - `flutter test` -> Exited 0 (All tests passed).
- **Exercises Completed**: N/A (Introductory).
- **Next Recommended Task**: Phase 2 Step 1 — Model design (`Task` and `TaskPriority`) and building the task list UI with clean local state.

### Milestone 2: Task List UI & Local State (Phase 2)
- **Status**: Completed
- **Concepts Introduced**:
  - Immutability in domain models (`final` fields, `copyWith`, `operator ==`, `hashCode`).
  - State ownership & lifting state up: `TaskListScreen` owns the state, while `TaskItemTile` is a pure presenter.
  - Declarative form validation using `GlobalKey<FormState>`.
  - Material 3 theme configuration (light/dark modes with dynamic seed palette).
  - Dismissible gestures with undo actions (`SnackBarAction`).
- **Features Implemented**:
  - Task model & `TaskPriority` enum ([task.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/domain/task.dart)).
  - `TaskItemTile` reusable widget ([task_item_tile.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/presentation/widgets/task_item_tile.dart)).
  - `TaskFormDialog` creation modal ([task_form_dialog.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/presentation/widgets/task_form_dialog.dart)).
  - `TaskListScreen` with search, filter tabs (All, Active, Done), and completion toggling ([task_list_screen.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/presentation/screens/task_list_screen.dart)).
- **Tests Added**:
  - Unit tests: [task_test.dart](file:///d:/kannan/projects/my%20practice/Basics/test/features/tasks/domain/task_test.dart) (defaults, `copyWith`, value equality).
  - Widget tests: [widget_test.dart](file:///d:/kannan/projects/my%20practice/Basics/test/widget_test.dart) (app render & tile callbacks).
- **Commands & Checks Performed**:
  - `dart format lib test` -> Formatted 7 files.
  - `flutter analyze` -> No issues found (0 warnings, 0 errors).
  - `flutter test` -> 5 of 5 tests passed.
- **Next Recommended Task**: Phase 3 — Decoupling UI from data access via Repository Pattern (Dependency Inversion).

### Milestone 3: Model & Data Layer (Phase 3)
- **Status**: Completed
- **Concepts Introduced**:
  - The Repository Pattern & Separation of Concerns.
  - Dependency Inversion Principle (DIP) with `abstract interface class TaskRepository`.
  - Concrete implementation `InMemoryTaskRepository` with unmodifiable collections.
  - Constructor-based Dependency Injection into `TaskListScreen`.
  - Lifecycle safeguards (`if (mounted)`) across asynchronous boundaries.
  - Runtime polymorphism / dynamic dispatch in Dart.
- **Features Implemented**:
  - Abstract repository interface ([task_repository.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/domain/task_repository.dart)).
  - Concrete in-memory repository ([in_memory_task_repository.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/data/in_memory_task_repository.dart)).
  - Refactored `TaskListScreen` to consume `TaskRepository` asynchronously with loading indicator.
- **Tests Added**:
  - Repository unit tests: [in_memory_task_repository_test.dart](file:///d:/kannan/projects/my%20practice/Basics/test/features/tasks/data/in_memory_task_repository_test.dart) (6 tests: get, find, add, update, delete).
- **Commands & Checks Performed**:
  - `flutter test` -> 11 of 11 tests passed across unit and widget suites.
- **Next Recommended Task**: Phase 4 — Architecture Comparison Lab (Understanding state management limitations & evolution: setState vs. ChangeNotifier/Provider vs. Riverpod vs. Bloc).

### Milestone 4: Architecture Comparison Lab (Phase 4)
- **Status**: Completed
- **Concepts Introduced**:
  - The architectural friction of `setState` across multi-screen flows.
  - Evolutionary generations of Flutter state management: `setState` -> `ChangeNotifier`/`Provider` -> `Bloc`/`Cubit` -> `Riverpod`.
  - Contrast between manual `notifyListeners()` and compile-safe reactive observables.
  - Position of GetX in the ecosystem (all-in-one microframework vs. decoupled architectures).
- **Next Recommended Task**: Phase 5 — Primary Application Architecture Implementation (Feature-First + Riverpod + Repository Pattern).

### Milestone 5: Primary Architecture Implementation with Riverpod (Phase 5)
- **Status**: Completed
- **Concepts Introduced**:
  - `flutter_riverpod` integration with `ProviderScope`.
  - Modern Riverpod 3.x patterns: `Notifier`, `AsyncNotifier`, and `AsyncValue.guard`.
  - Compile-safe computed/derived state: `filteredTasksProvider` combining tasks, filter, and search text.
  - Refactoring UI coordinators to pure `ConsumerWidget` with `WidgetRef ref.watch` / `ref.read`.
  - Headless unit testing of providers using `ProviderContainer` without Flutter engine delays.
- **Features Implemented**:
  - `task_providers.dart`: `taskRepositoryProvider`, `taskListProvider`, `taskFilterProvider`, `taskSearchQueryProvider`, `filteredTasksProvider`.
  - Refactored `TaskListScreen` to `ConsumerWidget` with pattern-matched `.when(loading, error, data)` UI.
  - Enabled `ProviderScope` at the app root in `main.dart`.
- **Tests Added**:
  - Riverpod provider unit tests: `test/features/tasks/presentation/providers/task_providers_test.dart` (5 tests for loading, adding, toggling, deleting, and filtering).
  - Updated widget tests to pump within `ProviderScope`.
- **Commands & Checks Performed**:
  - `flutter analyze` -> No issues found (0 warnings, 0 errors).
  - `flutter test` -> 16 of 16 tests passed across all unit and widget suites.
- **Next Recommended Task**: Phase 6 — Local Persistence (Offline Storage with SQLite / Drift / SharedPreferences).

### Milestone 6: Local Persistence & Serialization (Phase 6)
- **Status**: Completed
- **Concepts Introduced**:
  - Comparison of local storage strategies: Key-Value (`shared_preferences`) vs. Secure Hardware Vault (`flutter_secure_storage`) vs. Relational SQLite (`drift`/`sqflite`).
  - Model serialization and deserialization (`toJson` / `fromJson`) in pure Dart with ISO-8601 timestamps and enum mappings.
  - Asynchronous pre-initialization of durable services prior to `runApp()`.
  - Swapping data sources via `ProviderScope(overrides: [...])` with zero modifications to presentation UI widgets.
- **Features Implemented**:
  - `Task.toJson()` and `Task.fromJson()` serialization methods ([task.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/domain/task.dart)).
  - `SharedPreferencesTaskRepository` storing tasks persistently in JSON lists ([shared_preferences_task_repository.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/data/shared_preferences_task_repository.dart)).
  - Pre-initialization and injection in [main.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/main.dart).
- **Tests Added**:
  - Model serialization unit test in [task_test.dart](file:///d:/kannan/projects/my%20practice/Basics/test/features/tasks/domain/task_test.dart).
  - Storage unit tests in [shared_preferences_task_repository_test.dart](file:///d:/kannan/projects/my%20practice/Basics/test/features/tasks/data/shared_preferences_task_repository_test.dart) (4 tests using mock initial values).
- **Commands & Checks Performed**:
  - `flutter test` -> 21 of 21 tests passed.
- **Next Recommended Task**: Phase 7 — Remote API Integration (HTTP Client, RESTful contracts, network error handling, and sync).

### Milestone 7: Remote API Integration & Network Resilience (Phase 7)
- **Status**: Completed
- **Concepts Introduced**:
  - Industrial HTTP networking in Flutter using `dio: ^5.11.1`.
  - Structured error typing (`ApiException`) mapping HTTP status codes (200, 201, 404, 500) and network timeouts.
  - Designing client REST endpoints (`GET /api/v1/tasks`, `POST`, `PUT`, `DELETE`).
  - Pull-to-refresh interaction using Flutter's native `RefreshIndicator` and Riverpod `ref.invalidate`.
  - Headless HTTP mocking using Dio's `HttpClientAdapter` to test network failure recovery without an external live server.
- **Features Implemented**:
  - `ApiTaskRepository` implementing the standard `TaskRepository` interface ([api_task_repository.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/data/api_task_repository.dart)).
  - Pull-to-refresh on `TaskListScreen` ([task_list_screen.dart](file:///d:/kannan/projects/my%20practice/Basics/lib/features/tasks/presentation/screens/task_list_screen.dart)).
  - Documented the Fullstack Backend Roadmap for future implementation.
- **Tests Added**:
  - `test/features/tasks/data/api_task_repository_test.dart` (4 tests: list parsing, POST creation, 404 handling, and 500 error mapping).
- **Commands & Checks Performed**:
  - `flutter test` -> 25 of 25 tests passed.
- **Next Recommended Task**: Phase 8 — Authentication & Multi-User Task Isolation (`flutter_secure_storage` & Auth State).




