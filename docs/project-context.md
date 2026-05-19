---
apihug_version: '#APIHUG_VERSION#'
date: '#TIMESTAMP#'
---

# Project Context for AI Agents

Critical rules for AI agents implementing ApiHug projects. Focus on unobvious constraints that agents might miss. Loaded by all BMAD workflows.

---

## Technology Stack & Versions

| Component   | Version                                  |
|-------------|------------------------------------------|
| Java        | 18+                                      |
| Spring Boot | 4.0+                                     |
| Spring Data | JDBC (ApiHug extended)                   |
| ApiHug      | 3.0+ SDK, gradle plugin, proto extension |
| Protobuf    | proto3 + ApiHug extensions               |
| Frontend    | Vue 3 + Vben Admin + TailwindCSS         |
| Build       | Gradle 8+ + pnpm                         |

---

## Project Discovery

**ALWAYS discover dynamically — NEVER hardcode module names:**

```bash
# Read project structure (modules, relationships, paths)
cat docs/project.yaml

# Read module metadata (packageName, domain, authority)
cat {module}/src/main/resources/hope-wire.json
```

---

## Source Sets

| Directory                | Writable | Notes                                                     |
|--------------------------|----------|-----------------------------------------------------------|
| `src/main/proto/`        | YES      | Proto DSL (API/Domain/Infra)                              |
| `src/main/java/`         | YES      | ServiceImpl + DomainService only                          |
| `src/main/trait/`        | YES      | Repository extensions (custom queries)                    |
| `src/main/resources/`    | YES      | Config (hope-wire.json, application.yml)                  |
| `src/generated/`         | **NO**   | Auto-generated — NEVER modify (comments are wire markers) |
| `packages/{module}-sdk/` | **NO**   | Auto-generated frontend SDK                               |
| `apps/{app}/src/router/` | **NO**   | Auto-generated routes                                     |

---

## Critical Constraints

### Architecture
- **Onion Architecture**: Adapter (ServiceImpl) → Domain (DomainService) → Infrastructure (Repository)
- **Contract-First**: Proto DSL → `gradlew :{module}:wire` → Generated Code
- **Lombok**: FORBIDDEN — explicit getters/setters/constructors only

### Proto
- **Package**: Module-first (`api/{module}/`, `domain/{module}/`, `infra/{module}/`)
- **Request**: 3-Field Rule (0→Empty, 1-2→Empty+params, 3+→Message)
- **Enum**: Full package path reference (NEVER `string` for enum values)
- **Naming**: `snake_case` for fields; API MUST NOT import domain entities
- **Imports**: MUST use `import "apihug/protobuf/..."` paths (resolved by ApiHug gradle plugin at compile time, NOT filesystem paths). See `docs/architecture.md` § Proto Extension Quick Reference for the complete import table. To look up extension message fields/enums, read the reference copies in `BMAD/src/protobuf/`.

### Backend
- **Query**: ONLY in Repository trait (NOT ServiceImpl)
- **Error**: `HopeErrorDetailException.errorBuilder().error(ENUM).build()`
- **Security**: ZERO RBAC code in ServiceImpl/DomainService (proto `authorization` only)
- **User**: `HopeContextHolder.customer()` for current user context

### Database
- **Migration**: `_full.xml` auto-generated (NEVER edit), `_after.xml` for manual fixes

### Frontend
- **API**: Import from generated `{module}-sdk` (NEVER raw HTTP / NEVER `fetch` directly)
- **HTTP Client**: IoC via `configureApiClient()` — ONE-TIME in `bootstrap.ts`
- **Page**: LIST_PAGE → `index.vue`, FORM_PAGE → `components/*Modal.vue`

---

## Rules Reference

| Topic          | Document                                                        |
|----------------|-----------------------------------------------------------------|
| Proto API      | `_bmad/apihug/rules/apihug-proto-api-extension-guide.md`        |
| Proto Database | `_bmad/apihug/rules/apihug-proto-database-modeling-guide.md`    |
| Proto Enum     | `_bmad/apihug/rules/apihug-proto-enum-error-extension-guide.md` |
| Backend impl   | `_bmad/apihug/rules/apihug-impl-golden-rule.md`                 |
| Frontend impl  | `_bmad/apihug/rules/apihug-impl-front-vben-guide.md`            |
| Project config | `docs/project-context.md`                                       |

For detailed architecture decisions, project structure trees, naming conventions, and rule documents, see `docs/architecture.md`.
