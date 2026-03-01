# Boundaries Audit

Detect architectural layer violations and improper dependencies between modules.

## The Core Problem

Clean Architecture's fundamental rule: "Source code dependencies can only point inwards." Violations create tight coupling, make testing difficult, and undermine the architecture's benefits.

## What This Command Detects

| Pattern | Description |
|---------|-------------|
| **UI → Database Direct** | Presentation layer accessing persistence directly |
| **Domain → Infrastructure** | Core business logic depending on external services |
| **Business Logic in Controllers** | Fat controllers doing too much |
| **ORM Outside Repository** | Database queries scattered across codebase |
| **Scattered Environment Variables** | Config access outside config module |
| **Cross-bounded-context Imports** | DDD boundary violations |

## Phase 1: Discover the Codebase

1. **Identify architecture style**:
   - Clean/Hexagonal/Onion Architecture
   - MVC/MVVM
   - Layered Architecture
   - Module-based
   - No clear architecture (flag this)

2. **Infer layers from structure**:

**Layer folder patterns**:

```javascript
LAYERS = {
  presentation: ["controllers", "handlers", "routes", "views", "components", "pages", "ui"],
  application: ["services", "usecases", "use-cases", "commands", "queries", "interactors"],
  domain: ["domain", "entities", "models", "core", "aggregates", "valueobjects"],
  infrastructure: ["repositories", "persistence", "db", "infrastructure", "adapters", "gateways"],
  configuration: ["config", "settings", "env"]
}
```

**File naming patterns**:

| Pattern | Inferred Layer |
|---------|---------------|
| `*Controller.*`, `*Handler.*` | Presentation |
| `*Service.*`, `*UseCase.*` | Application |
| `*Entity.*`, `*Model.*` | Domain |
| `*Repository.*`, `*Gateway.*` | Infrastructure |

## Phase 2: Parallel Audit (Using Subagents)

**Launch these subagents in parallel** using `Agent` with `subagent_type=Explore`.

Use the detailed prompt templates from [boundaries-subagents.md](boundaries-subagents.md). Each subagent covers one violation category:

1. **Presentation -> Data** — UI/controllers importing database layer directly
2. **Domain -> Infrastructure** — Core business logic depending on external services
3. **Fat Controllers** — Business logic, data transformation, or orchestration in controllers
4. **ORM Outside Repository** — Database queries scattered outside data layer
5. **Configuration Leakage** — Environment variables accessed outside config module

Fill in `[from Phase 1]` placeholders with detected tech stack and architecture style.

---

## Phase 3: Prioritize Findings

| Priority | Violation | Impact |
|----------|-----------|--------|
| **P1 Critical** | UI → Database direct | Bypasses validation, security risk |
| **P1 Critical** | Domain → Infrastructure | Core architecture violation |
| **P2 High** | Controller with DB queries | Untestable, tightly coupled |
| **P2 High** | Service → Controller (inverted) | Inverted dependency |
| **P2 High** | ORM outside repository | Data access scattered |
| **P3 Medium** | Cross-bounded-context import | DDD violation |
| **P3 Medium** | Env vars scattered | Testing difficulty |
| **P4 Low** | Controller slightly fat (<100 LOC) | Minor maintainability |

## Phase 4: Present Findings

```markdown
## Boundaries Audit Results

### Architecture Detected
- Style: [Clean/MVC/Layered/None]
- Layers found: [list]

### Summary
- X presentation → data violations
- X domain → infrastructure violations
- X fat controllers
- X ORM outside repository
- X scattered env var access

### P1 Critical
| Violation | Location | From → To | Fix |
|-----------|----------|-----------|-----|
| ... | file:line | ... | ... |

### P2 High
...
```

## Phase 5: Fix Options

1. **Dependency Rules File**:
   Generate `.dependency-cruiser.json` or similar config to prevent future violations

2. **Refactor Scripts**:
   - Move database access to repository
   - Extract controller logic to services
   - Centralize config

3. **Architecture Documentation**:
   Generate layer diagram showing current violations

## Recommended Fixes Reference

| Violation | Fix Strategy |
|-----------|--------------|
| UI→DB | Introduce service layer; use DTOs not raw entities |
| Domain→Infra | Define interfaces (ports) in domain, implement in infrastructure |
| Fat Controller | Extract to application service/use-case |
| ORM scattered | Encapsulate in repository classes |
| Scattered config | Create config module reading all env vars, export typed objects |
| Cross-feature coupling | Extract to shared module or use events/messages |

## Legitimate Cross-cutting Concerns

Don't flag these cross-layer imports:

- **Logging**: `/logging/`, `/logger/`
- **Errors**: `/errors/`, `/exceptions/`
- **Auth middleware**: `/auth/`, `/middleware/`
- **Shared types**: `/types/`, `/interfaces/`, `/contracts/`, `/dto/`
- **DI setup**: `main.*`, `bootstrap.*`, `container.*`, `app.*`
- **Tests**: All test directories

## Notes

- Some frameworks require certain patterns (e.g., Next.js API routes)
- Monorepos may have different boundaries per package
- Legacy codebases may need gradual migration strategy
- Consider generating architecture fitness functions for CI
