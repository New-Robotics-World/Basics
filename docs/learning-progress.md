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

