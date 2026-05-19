# Architecture Decision Document

> ApiHug: Convention over Configuration

---

## Core Decisions

### 1. Contract-First Development
**Proto DSL** → `gradlew :{module}:wire` → **Generated Code**

**Critical:**
- ❌ NEVER write Controller, Entity, DAO manually
- ❌ NEVER use Lombok
- ❌ NEVER throw raw exceptions

### 2. Module-First Organization
```
proto/
├── api/{feature}/      # API definitions
├── domain/{feature}/   # Entities
└── infra/{feature}/    # Enums, errors
```
- ❌ NEVER organize by artifact type (all APIs together)

### 3. Security
- JWT + RBAC via proto `authorization` option
- Access user: `HopeContextHolder.customer()`
- ❌ ZERO security code in ServiceImpl

### 4. Database Migration (Liquibase)
| File         | Purpose               | Editable |
|--------------|-----------------------|----------|
| `_full.xml`  | Auto-generated schema | ❌ NEVER  |
| `_after.xml` | Handwritten fixes     | ✅ YES    |

Changes: proto → wire → auto-generate

### 5. Request Design — 3-Field Rule
| Params | Approach                 | Example                      |
|--------|--------------------------|------------------------------|
| 0      | `google.protobuf.Empty`  | `rpc List (Empty)`           |
| 1-2    | `Empty` + `parameters{}` | `rpc Search (Empty)`         |
| 3+     | Create Request Message   | `rpc Create (CreateRequest)` |

---

## Naming Conventions

| Element          | Convention            | Example              |
|------------------|-----------------------|----------------------|
| Proto field      | snake_case            | `user_name`          |
| Enum/Table       | UPPER_CASE            | `USER_STATUS_ACTIVE` |
| Service          | PascalCase            | `UserService`        |
| Module           | `{domain}-app`        | `order-app`          |
| Repository trait | `_{Entity}Repository` | `_OrderRepository`   |

---

## Source Sets

### Backend
**Critical rule:** Everything under `src/generated/` = generated code = NEVER modify manually.

| Directory                    | Purpose                                  | Writable       |
|------------------------------|------------------------------------------|----------------|
| `src/main/proto/`            | Proto source (API/Domain/Constant DSL)   | YES            |
| `src/main/java/`             | Handwritten business logic (ServiceImpl) | YES            |
| `src/main/trait/`            | Repository extensions (custom queries)   | YES            |
| `src/main/resources/`        | Config (hope-wire.json, application.yml) | YES            |
| `src/generated/main/api/`    | Generated REST & Service interfaces      | NO — READ-ONLY |
| `src/generated/main/domain/` | Generated domain models (Entity)         | NO — READ-ONLY |
| `src/generated/main/wire/`   | Generated DTOs,Enums,Errors              | NO — READ-ONLY |

### Frontend
| Directory                | Writable | Purpose               |
|--------------------------|----------|-----------------------|
| `apps/{app}/src/views/`  | ✅        | Page components       |
| `packages/{module}-sdk/` | ❌        | Generated API service |
| `apps/{app}/src/router/` | ❌        | Generated routes      |

---

## hope-wire.json

Module metadata in `src/main/resources/`:

```json
{
  "packageName": "com.example.order",
  "domain": "order",
  "application": "order-app",
  "authority": {
    "enumClass": "com.example.order.infra.OrderAuthorityEnum",
    "codePrefix": 10240000
  }
}
```

**Key fields:**
- `packageName` — Root package, MUST match proto package
- `domain` — Business domain
- `application` — Gradle module name
- `authority.enumClass` — Permission enum for RBAC
- `authority.codePrefix` — Error code prefix

---

## Project Structure

This is a Gradle multi-module project. For a quick overview of its structure, refer to `{project-root}/docs/project.yaml`.

### Backend Module Structure (per domain)

```
{domain}-app/src/
├── main/                              # Handwritten source (WRITABLE)
│   ├── proto/{package}/               # Proto source
│   │   ├── api/                       # API endpoint definitions
│   │   ├── domain/                    # Entity definitions
│   │   └── infra/                     # Constants, enums, errors
│   ├── java/{package}/                # Business logic
│   │   ├── api/                       # api ServiceImpl classes
│   │   ├── adapter/mapper/            # Object mappers
│   │   ├── extra/                     # Extra utilities
│   │   └── infra/                     # Infrastructure
│   │       ├── audit/                 # Audit support
│   │       ├── beans/                 # Bean definitions
│   │       ├── config/                # Infra config
│   │       ├── contract/              # Contracts
│   │       ├── repository/            # Infra repositories
│   │       ├── security/              # Apihug Security config
│   │       ├── service/               # Infra services
│   │       ├── spa/                   # SPA support
│   │       └── utils/                 # Utilities
│   ├── trait/t/{package}/             # Repository extensions
│   │   └── domain/repository/         # Custom repository interfaces
│   └── resources/
│       ├── hope-wire.json             # Module metadata
│       ├── config/                    # Spring Boot config (application.yml etc)
│       └── liquibase/                 # DB migrations
├── generated/                         # All generated code (READ-ONLY)
│   ├── main/
│   │   ├── api/                       # Generated REST interfaces, DTO
│   │   ├── domain/                    # Generated entities, repositories
│   │   ├── wire/                      # Generated wire components
│   │   ├── mcp/                       # Generated MCP contracts
│   │   └── cloud/                     # Generated cloud adapters
│   └── test/                          # Generated test scaffolds
├── test/                              # Handwritten tests (WRITABLE)
└── test-kola/                         # Kola tests (WRITABLE)
```

### Frontend Module Structure

```
{ui_module}/
├── apps/
│   └── admin-app/                        # Admin app (admin is example, name by yourself)
│       ├── apis.yml                      # API dependencies config
│       ├── menu.json                     # Generated menu data
│       ├── src/
│       │   ├── views/                    # Page components (WRITABLE)
│       │   │   ├── dashboard/            # Dashboard pages
│       │   │   ├── hub/                  # Hub management
│       │   │   ├── metadata/             # Metadata views
│       │   │   ├── monitor/              # Monitoring pages
│       │   │   ├── tenants/              # Tenant management
│       │   │   └── _core/                # Core pages (auth, profile, about)
│       │   ├── adapter/                  # Component adapters (WRITABLE)
│       │   ├── api/                      # App-level API helpers (WRITABLE)
│       │   ├── store/                    # Pinia stores (WRITABLE)
│       │   ├── layouts/                  # Layout components (WRITABLE)
│       │   ├── locales/langs/            # i18n (en-US, zh-CN) (WRITABLE)
│       │   ├── router/routes/modules/    # Generated routes (READ-ONLY)
│       │   └── menus/                    # Generated menus (READ-ONLY)
│       ├── vite.config.mts
│       ├── tailwind.config.mjs
│       └── package.json
├── packages/
│   ├── {module}-sdk/                     # Generated API service (READ-ONLY)
│   │   └── src/
│   │       ├── api/                      # Service methods
│   │       ├── types/                    # TypeScript types
│   │       ├── schema/                   # Request/response schemas
│   │       └── model/                    # Enums, errors
│   ├── @core/                            # Core framework package
│   ├── api-core/                         # API core utilities
│   ├── constants/                        # Shared constants
│   ├── effects/                          # Shared effects
│   ├── icons/                            # Icon library
│   ├── locales/                          # Shared i18n
│   ├── preferences/                      # User preferences
│   ├── stores/                           # Shared stores
│   ├── styles/                           # Shared styles
│   ├── types/                            # Shared types
│   └── utils/                            # Shared utilities
├── ui.yml                                # UI module config
├── pnpm-workspace.yaml                   # Monorepo workspace
└── package.json
```

---

## Development Workflow

```
1. Design proto (API/Entity/Error)
2. Build proto and generate code:  gradlew :{module}:wire
3. Build all code (include step 2): gradlew :{module}:build
4. Implement ServiceImpl
5. Extend Repository trait
6. Generate frontend service:  gradlew :{ui_module}:ui
7. Implement Vue pages
8. End-to-end verification
```

---

## Proto Extension Quick Reference

> **AI AGENTS: When writing proto files, you MUST use the correct import paths below.**
> The import paths (`apihug/protobuf/...`) are resolved by the ApiHug gradle plugin (based on [Square Wire](https://github.com/square/wire)) at compile time — they are NOT filesystem paths.
> `_bmad/protobuf/` contains **reference copies** of these proto sources for AI agents to look up message structures and extension options. Do NOT confuse the two.

### Import Paths

| What You Need | Import Statement | Use Case |
|---|---|---|
| API method options | `import "apihug/protobuf/swagger/annotations.proto";` | `option (hope.swagger.operation) = {...}` on rpc methods |
| API field validation | `import "apihug/protobuf/swagger/annotations.proto";` | `[(hope.swagger.field) = {...}]` on message fields |
| Service options | `import "apihug/protobuf/swagger/annotations.proto";` | `option (hope.swagger.svc) = {...}` on services |
| Entity table mapping | `import "apihug/protobuf/domain/annotations.proto";` | `option (hope.persistence.table) = {...}` on messages |
| Column mapping | `import "apihug/protobuf/domain/annotations.proto";` | `[(hope.persistence.column) = {...}]` on fields |
| Enum/Error metadata | `import "apihug/protobuf/extend/constant.proto";` | `[(hope.constant.field) = {...}]` on enum values |

### Extension Points

| Proto Element | Extension Name | Package | Defined In |
|---|---|---|---|
| `MethodOptions` | `operation` (Operation) | `hope.swagger` | `swagger/annotations.proto` |
| `MessageOptions` | `schema` (Schema) | `hope.swagger` | `swagger/annotations.proto` |
| `ServiceOptions` | `svc` (ServiceSchema) | `hope.swagger` | `swagger/annotations.proto` |
| `FieldOptions` | `field` (JSONSchema) | `hope.swagger` | `swagger/annotations.proto` |
| `EnumOptions` | `enm` (JSONSchema) | `hope.swagger` | `swagger/annotations.proto` |
| `MessageOptions` | `table` (Table) | `hope.persistence` | `domain/annotations.proto` |
| `FieldOptions` | `column` (Column) | `hope.persistence` | `domain/annotations.proto` |
| `EnumValueOptions` | `field` (Meta) | `hope.constant` | `extend/constant.proto` |

### Key Message Types (read source for full fields)

| Message | Purpose | Source File |
|---|---|---|
| `Operation` | API method: path, auth, pageable, parameters, priority | `swagger/swagger.proto` |
| `Authorization` | Security: ANONYMOUS/LOGIN/ACTIVE, RBAC, SpEL | `swagger/swagger.proto` |
| `JSONSchema` | Field validation: empty, max_length, pattern, email, mock | `swagger/swagger.proto` |
| `Parameters` / `Parameter` | Query/path/header/cookie params with IN enum | `swagger/swagger.proto` |
| `ServiceSchema` | Service-level tag and base path | `swagger/swagger.proto` |
| `Table` | Entity table: name, indexes, unique_constraints, wires, liquibase | `domain/persistence.proto` |
| `Column` | Field column: nullable, length, precision, id, enum_type, default_value | `domain/persistence.proto` |
| `Meta` | Enum value: code, message, message2, error | `extend/constant.proto` |
| `Error` | Error detail: title, tips, http_status, phase, severity | `extend/constant.proto` |

### Proto Source Reference (for AI lookup only)

The directory `_bmad/protobuf/` holds **reference copies** of ApiHug's extension proto sources. These are for AI agents to look up message fields, enum values, and extension options — they are **NOT** used in compilation.

```
_bmad/protobuf/apihug/protobuf/              ← Reference copies (NOT compile dependencies)
├── swagger/
│   ├── annotations.proto       # Extension definitions (operation, schema, svc, field, enm)
│   └── swagger.proto           # Operation, Authorization, RBAC, JSONSchema, Parameters
├── domain/
│   ├── annotations.proto       # Extension definitions (table, column)
│   ├── persistence.proto       # Table, Column, Index, UniqueConstraint, EnumType, Wire
│   └── view.proto              # View, AggregatedField (JOIN support)
├── extend/
│   ├── constant.proto          # Extension definition (field/Meta), Error, HttpStatus
└── mock/
    └── mock.proto              # Mock data rules (Nature, StringRule, NumberRule, etc.)
```

> **When unsure about an extension's available fields or enum values**, search and read these reference files. But in your proto code, always use the `import "apihug/protobuf/..."` paths shown in the Import Paths table above.

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
