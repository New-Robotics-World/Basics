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
