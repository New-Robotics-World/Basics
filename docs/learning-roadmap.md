# TaskFlow Learning Roadmap

Welcome to **TaskFlow** — learning real-world, production-quality Flutter architecture from the ground up.

---

## 🧭 Philosophy & Guidelines
- **Understand First**: Never introduce an abstraction before feeling the friction it solves.
- **Incremental Growth**: Start simple (clean local state) -> decouple data access (repositories) -> compare state managers/architectures -> introduce persistence & remote networking -> harden with tests & CI/CD.
- **Production Mindset**: Separation of concerns, testability, strong typing, immutability, and robust error/empty states.

---

## 🗺️ Phases Overview

- [x] **Phase 1: Project Assessment & Architectural Setup**
  - Verify Flutter/Dart environment.
  - Establish foundational documentation (`learning-roadmap.md`, `architecture-decisions.md`, `learning-progress.md`).
  - Define core task domain and initial project structure.
- [x] **Phase 2: Task List UI & Local State (Clean Simplicity)**
  - Task model (immutable).
  - Task list screen, task item widget, task form/dialog.
  - State ownership with `setState` (understand direct callbacks and UI composition).
  - Validation, empty states, and completion toggling.
- [x] **Phase 3: Model & Data Layer (Decoupling UI from Data)**
  - Differentiate Entities vs. Models.
  - Abstract `TaskRepository` interface (Dependency Inversion).
  - In-memory repository implementation.
  - Unit tests for repository logic without Flutter widgets.
- [ ] **Phase 4: Architecture Comparison Lab**
  - Layer-first vs. Feature-first deep dive.
  - MVC vs. MVVM comparison on a slice of TaskFlow.
  - State management comparison: `setState` vs. `ChangeNotifier`/`Provider` vs. `Riverpod` vs. `Bloc`/`Cubit`.
- [ ] **Phase 5: Primary Application Architecture Implementation**
  - Establish final architecture: Feature-First + Riverpod + Repository Pattern.
  - Refactor cleanly with zero regression.
- [ ] **Phase 6: Local Persistence**
  - Compare SharedPreferences vs. SQLite (`sqflite` / `drift`) vs. Key-Value (`Hive`).
  - Implement durable persistence and offline support.
- [ ] **Phase 7: Remote API Integration**
  - HTTP client (`Dio`), RESTful contracts, error handling, network failure recovery.
  - Loading / Empty / Error / Success states.
- [ ] **Phase 8: Authentication & Multi-User Task Isolation**
  - Auth token storage, session expiration, login/logout flow.
- [ ] **Phase 9: Comprehensive Testing & Quality**
  - Unit tests, Widget tests, Integration tests.
  - Code analysis and strict linting.
- [ ] **Phase 10: Production Readiness & Polishing**
  - Performance profiling, responsive design, logging, error boundaries, CI/CD setup.
