# Architecture Decision Records (ADRs)

## ADR 001: Initial Project Strategy & Phase 2 Baseline

### Status
Accepted

### Context
We are building TaskFlow to progress from basic Flutter familiarity to production-grade software engineering. Many tutorials immediately jump into heavy third-party boilerplate (multiple packages, code generation, dozens of files) before the developer understands the core problem those libraries solve.

### Decision
1. **Phase 2 Baseline**: Begin with pure Flutter primitives (`StatefulWidget`, clear widget composition, immutable data classes).
2. **Phase 3 Evolution**: Extract data handling into an abstract `TaskRepository` interface with an in-memory implementation to master Dependency Inversion and testability without UI dependencies.
3. **Phase 4 & 5 Architectural Target**:
   - Organization: **Feature-first** (`lib/features/tasks/...`) because it scales naturally with team size and feature count, preventing bloated global layer folders.
   - Primary State Management: **Riverpod** (once justified), due to compile-time safety, clean test overrides, and no reliance on `BuildContext` for reading state logic.
4. **Design System**: Material 3 with a refined color palette, accessible typography, and clear visual state feedback.

### Consequences
- **Positive**: We will understand *why* each abstraction exists before adopting it.
- **Trade-off**: Requires writing a clean foundational version first, then deliberately refactoring it across phases.

---

## ADR 002: Client-First Mocking Strategy & Live Backend Sync

### Status
Accepted

### Context
In building a fullstack system, developing the backend and frontend simultaneously without a stable contract leads to moving targets, blocking dependencies, and fragile integration. 

### Decision
1. **Frontend Readiness First**:
   - Build client-side models, repositories (`ApiTaskRepository`), Dio HTTP client, and mock network adapters using dummy/mock data.
   - Verify UI rendering, pull-to-refresh, error boundaries, and state resilience completely in Flutter.
2. **Dedicated Fullstack Backend Phase**:
   - Following the completion of the mobile/web architecture journey (Phases 1–10), construct the real backend server (database schemas, auth, endpoints).
   - Swap the client's dummy/mock repository configuration with the live server base URL without altering presentation UI or domain models.

### Consequences
- **Positive**: Zero coupling between client progress and backend readiness. Client is 100% bug-free and tested ahead of time.
- **Trade-off**: Requires maintaining an accurate API contract so the mock data matches the real server schema.

