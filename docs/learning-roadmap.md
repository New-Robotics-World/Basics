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
- [x] **Phase 4: Architecture Comparison Lab**
  - Layer-first vs. Feature-first deep dive.
  - MVC vs. MVVM comparison on a slice of TaskFlow.
  - State management comparison: `setState` vs. `ChangeNotifier`/`Provider` vs. `Riverpod` vs. `Bloc`/`Cubit`.
- [x] **Phase 5: Primary Application Architecture Implementation**
  - Establish final architecture: Feature-First + Riverpod + Repository Pattern.
  - Refactor cleanly with zero regression.
- [x] **Phase 6: Local Persistence**
  - Compare SharedPreferences vs. SQLite (`sqflite` / `drift`) vs. Key-Value (`Hive`).
  - Implement durable persistence and offline support.
- [x] **Phase 7: Remote API Integration**
  - HTTP client (`Dio`), RESTful contracts, error handling, network failure recovery.
  - Loading / Empty / Error / Success states.
- [x] **Phase 8: Authentication & Multi-User Task Isolation**
  - Auth token storage, session expiration, login/logout flow.
- [x] **Phase 9: Comprehensive Testing & Quality**
  - Unit tests, Widget tests, Integration tests.
  - Code analysis and strict linting.
- [x] **Phase 10: Production Readiness & Polishing**
  - Performance profiling, responsive design, logging, error boundaries, CI/CD setup.

---

## 🚀 Fullstack Journey: Real Backend Implementation
*Following the completion of the Flutter mobile/web mastery, we build the real production backend to replace local mock APIs.*

- [ ] **Backend Phase 1: Server Architecture & Environment Setup**
  - Choosing backend stack (Node.js/Express, Python/FastAPI, or Dart Frog/Shelf).
  - RESTful API design principles & HTTP status codes.
- [ ] **Backend Phase 2: Database Modeling & Persistence**
  - Relational database setup (PostgreSQL / SQLite).
  - Migration schemas for Users and Tasks tables.
- [ ] **Backend Phase 3: Authentication & Security**
  - Password hashing (bcrypt / argon2).
  - JWT (JSON Web Token) generation, verification, and refresh token rotation.
- [ ] **Backend Phase 4: Full CRUD Task Endpoints**
  - `GET /api/v1/tasks`, `POST /api/v1/tasks`, `PUT /api/v1/tasks/:id`, `DELETE /api/v1/tasks/:id`.
  - Pagination, filtering, and search on the database level.
- [ ] **Backend Phase 5: End-to-End Integration**
  - Connecting TaskFlow Flutter client directly to our live backend server.
  - Handling real multi-user sync and offline-first queue syncing.

---

## 🎁 Elective / Bonus Tracks
- [ ] **Bonus Lab: GetX Fast-Track & Trade-off Analysis**
  - The GetX all-in-one philosophy (`GetxController`, `.obs`, `Obx`).
  - Context-less routing (`Get.to()`, `Get.snackbar()`) & Service Locator (`Get.put()`, `Get.find()`).
  - Side-by-side trade-off analysis: When to pick GetX vs. Riverpod in production.
