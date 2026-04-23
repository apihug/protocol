# APIHug Skills

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/apihug/skills)

**APIHug Skills** is a comprehensive knowledge base and development skill set for the APIHug framework—a contract-first, Protobuf-based platform for enterprise API development, database modeling, and service integration.

This repository provides:
- **Proto DSL Extension Guides**: Complete references for API, domain, and enum/error modeling
- **Implementation Golden Rules**: Backend (ServiceImpl/Repository) and frontend (Vben Admin) standards
- **BMAD Method Integration**: Structured workflows for AI-driven development
- **Spring Extension Modules**: Security, core infrastructure, and common abstractions
- **Development Workflows**: Automated skills for story creation, implementation, and review

---

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Core Capabilities](#core-capabilities)
- [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Architecture Principles](#architecture-principles)
- [Documentation Guides](#documentation-guides)
- [BMAD Method Integration](#bmad-method-integration)
- [Contributing](#contributing)
- [References](#references)

---

## Overview

APIHug is a **contract-first enterprise development framework** that uses Protocol Buffers as the single source of truth for:

- **RESTful API Design**: Protobuf RPC definitions with OpenAPI/Swagger documentation generation
- **Database Schema Modeling**: Message-to-table mapping with automatic Liquibase migration
- **Business Enumerations**: Type-safe enums with multilingual support and error metadata
- **LLM-Friendly Contracts**: Natural language descriptions and semantic questions for AI discovery

The framework enforces **clean architecture boundaries** through proto layer isolation and generates 80%+ of boilerplate code via the ApiHug Gradle plugin (built on Square Wire).

### Key Benefits

| Benefit | Description |
|---------|-------------|
| **Single Source of Truth** | Proto DSL generates API interfaces, entities, DTOs, migrations, and frontend SDKs |
| **Zero Manual Boilerplate** | No handwritten Controllers, Entities, DAOs, or raw HTTP clients |
| **Type Safety End-to-End** | Strong typing from proto definition to frontend TypeScript SDK |
| **AI-Optimized Contracts** | Semantic metadata (`questions`, `description`) enables LLM-powered discovery |
| **Convention Over Configuration** | Sensible defaults eliminate decision fatigue and ensure consistency |

---

## Directory Structure

```
skills/
├── README.md                          # This file
├── docs/                              # Architecture & methodology documentation
│   ├── architecture.md                # Architecture Decision Records (ADRs)
│   ├── BMAD.md                        # BMAD method integration guide
│   └── project-context.md             # Project context for AI agents
├── protobuf/                          # Proto extension reference sources
│   └── apihug/protobuf/
│       ├── domain/                    # Database entity modeling extensions
│       │   ├── annotations.proto      # @Table, @Column definitions
│       │   ├── persistence.proto      # Table, Column, Index, Wire types
│       │   └── view.proto             # View and aggregation definitions
│       ├── extend/                    # Business constants and error metadata
│       │   ├── constant.proto         # Enum field extensions (code, message)
│       │   └── error.proto            # Error details (http_status, phase, severity)
│       ├── mock/                      # Mock data generation rules
│       │   └── mock.proto             # Nature, StringRule, NumberRule
│       └── swagger/                   # API documentation extensions
│           ├── annotations.proto      # @operation, @schema, @svc definitions
│           └── swagger.proto          # Operation, Authorization, JSONSchema
├── rules/                             # Implementation rule documents
│   ├── apihug-proto-api-extension-guide.md       # API design rules
│   ├── apihug-proto-database-modeling-guide.md   # Database modeling rules
│   ├── apihug-proto-enum-error-extension-guide.md # Enum/error definition rules
│   ├── apihug-impl-golden-rule.md                # Backend implementation rules
│   ├── apihug-impl-front-vben-guide.md           # Frontend (Vben Admin) rules
│   └── rules.csv                      # Rule manifest
├── skills/                         # BMAD skill workflows
│   ├── apihug-create-story/           # Story creation skill
│   │   ├── SKILL.md                   # Skill definition
│   │   ├── workflow.md                # Execution steps
│   │   └── template.md                # Story template
│   ├── apihug-dev-story/              # Story implementation skill
│   │   ├── SKILL.md
│   │   ├── workflow.md
│   │   └── steps/                     # Implementation phases
│   ├── apihug-proto-review/           # Proto design review skill
│   ├── apihug-impl-review/            # Implementation review skill
│   └── apihug.skill-manifest.csv      # Skill registry
│   └── apihug-domain-strategic-design # Create or refine a DDD strategic design context-map.md
│   └── apihug-domain-tactical-design  # Generate, review, and refine domain tactical design documents
│   └── apihug-docs-readme             # Initialize or update docs/README.md 
└── spring-extension/                  # Spring framework integration modules
    ├── it-common-spring.md            # Base abstractions (Customer, SecurityContext)
    ├── it-common-spring-core.md       # Exception handling, validation, aspects
    ├── it-common-spring-security.md   # JWT authentication, RBAC enforcement
    ├── it-common-spring-data.md       # Spring Data JDBC extensions
    ├── it-common-spring-api.md        # API layer utilities
    ├── it-common-spring-cache.md      # Caching abstractions
    ├── it-common-spring-integration.md # Integration patterns
    ├── it-common-spring-log.md        # Logging utilities
    ├── it-common-spring-mock.md       # Mocking support
    ├── it-common-spring-tool.md       # Developer tools
    └── it-common-spring-ai-mcp.md     # AI/MCP integration
```

---

## Core Capabilities

### 1. API Design with Swagger Extensions

Define RESTful APIs using Protobuf with comprehensive metadata for OpenAPI generation:

```proto
import "apihug/protobuf/swagger/annotations.proto";

service UserService {
  option (hope.swagger.svc) = {
    path: "/users"
    description: "User management service"
  };

  rpc GetUser(GetUserRequest) returns (UserSummary) {
    option (hope.swagger.operation) = {
      get: "/users/{id}"
      description: "Get user by ID"
      questions: [
        "How do I retrieve a user by ID?",
        "What's the endpoint to fetch user details?"
      ]
      authorization: {
        rbac: {
          roles: ["ADMIN", "USER_READ"]
          combinator: OR
        }
      }
      pageable: false
    };
  }

  rpc SearchUsers(SearchUsersRequest) returns (UserSummary) {
    option (hope.swagger.operation) = {
      post: "/users/search"
      description: "Search users with filters"
      pageable: true  // Framework injects pagination
    };
  }
}

message GetUserRequest {
  int64 id = 1 [(hope.swagger.field) = {
    description: "User unique identifier"
    empty: false
  }];
}

message SearchUsersRequest {
  string keyword = 1 [(hope.swagger.field) = {
    description: "Search keyword"
    max_length: 100
  }];
  int32 status = 2;  // Business filters only - NO page/size/sort
}
```

**Key Features:**
- **HTTP Method Mapping**: `get`, `post`, `put`, `patch`, `delete`
- **Authorization**: RBAC with roles/authorities, SpEL expressions
- **Pagination**: `pageable: true` auto-injects `PageRequest`
- **Validation**: Field-level constraints (`empty`, `max_length`, `pattern`)
- **AI Discovery**: `questions` field for natural language queries

### 2. Database Entity Modeling

Map Protobuf messages directly to database tables with automatic DDL generation:

```proto
import "apihug/protobuf/domain/annotations.proto";

message UserEntity {
  option (hope.persistence.table) = {
    name: "SYS_USER"
    description: "User information table"
    wires: [IDENTIFIABLE, AUDITABLE, DELETABLE, TENANTABLE]
    unique_constraints: {
      name: "UK_USER_EMAIL"
      column_list: ["email"]
    }
    indexes: {
      name: "IDX_USER_TENANT"
      column_list: ["tenant_id"]
    }
  };

  int64 id = 1 [(hope.persistence.column) = {
    name: "ID"
    id: true
    generated_value: { strategy: AUTO }
  }];

  string user_name = 2 [(hope.persistence.column) = {
    name: "USER_NAME"
    nullable: false
    length: 64
    type: VARCHAR
    searchable: true
    sortable: true
  }];

  string email = 3 [(hope.persistence.column) = {
    name: "EMAIL"
    nullable: false
    length: 128
    type: VARCHAR
    unique: true
  }];

  com.example.user.infra.UserStatusEnum status_code = 4 [(hope.persistence.column) = {
    name: "STATUS_CODE"
    type: VARCHAR
    length: 32
    enum_type: STRING  // Persist as enum name
  }];
}
```

**Built-in Wire Features:**
| Wire | Auto-Added Columns |
|------|-------------------|
| `IDENTIFIABLE` | `ID` (BIGINT) |
| `AUDITABLE` | `CREATED_AT`, `CREATED_BY`, `UPDATED_AT`, `UPDATED_BY` |
| `DELETABLE` | `DELETED`, `DELETED_AT`, `DELETED_BY` (soft delete) |
| `TENANTABLE` | `TENANT_ID` (multi-tenancy) |
| `VERSIONABLE` | `VERSION` (optimistic locking) |
| `ALL` | All above (extends `Domain` base class) |

### 3. Business Enumerations & Error Codes

Define type-safe enums with business codes, multilingual messages, and error metadata:

```proto
import "apihug/protobuf/extend/constant.proto";
import "apihug/protobuf/swagger/annotations.proto";

// Business Enum (no error{} block)
enum UserStatusEnum {
  option (hope.swagger.enm) = {
    title: "User Status"
    description: "User lifecycle states"
  };

  ACTIVE = 0 [(hope.constant.field) = {
    code: 1
    message: "Active"
    message2: "活跃"
  }];

  INACTIVE = 1 [(hope.constant.field) = {
    code: 2
    message: "Inactive"
    message2: "非活跃"
  }];
}

// Error Enum (HAS error{} block)
enum UserError {
  USER_NOT_FOUND = 0 [(hope.constant.field) = {
    code: 10001
    message: "User not found"
    message2: "用户不存在"
    error: {
      title: "User Not Found"
      tips: "Check if the user ID is correct"
      http_status: NOT_FOUND
      phase: SERVICE
      severity: ERROR
    }
  }];

  USER_ALREADY_EXISTS = 1 [(hope.constant.field) = {
    code: 10002
    message: "User already exists"
    message2: "用户已存在"
    error: {
      title: "Duplicate User"
      http_status: CONFLICT
      phase: SERVICE
      severity: WARN
    }
  }];
}
```

**Error Metadata Fields:**
| Field | Type | Values |
|-------|------|--------|
| `http_status` | `HttpStatus` | `BAD_REQUEST`, `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`, `INTERNAL_SERVER_ERROR` |
| `phase` | `Phase` | `CONTROLLER` (validation), `SERVICE` (business logic), `DOMAIN` (data access) |
| `severity` | `Severity` | `LOW`, `WARN`, `ERROR`, `FATAL` |

### 4. Backend Implementation (ServiceImpl & Repository)

Implement business logic following the Onion Architecture pattern:

```java
// ServiceImpl: Fill method bodies ONLY (skeleton generated by wire)
@Service
public class UserServiceImpl implements UserService {

    private final UserEntityRepository userRepo;  // Constructor injection

    public UserServiceImpl(UserEntityRepository userRepo) {
        this.userRepo = userRepo;
    }

    @Override
    public void getUser(SimpleResultBuilder<UserSummary> builder, GetUserRequest request) {
        UserEntity user = userRepo.findById(request.getId())
            .orElseThrow(() -> HopeErrorDetailException.errorBuilder(UserError.USER_NOT_FOUND).build());

        UserSummary summary = UserSummary.newBuilder()
            .setId(user.getId())
            .setUserName(user.getUserName())
            .setEmail(user.getEmail())
            .build();

        builder.ok().payload(summary).done();
    }

    @Override
    public void searchUsers(PageableResultBuilder<UserSummary> builder,
                            SearchUsersRequest request,
                            PageRequest pageParameter) {
        // Delegate query to repository trait
        Page<UserEntity> page = userRepo.search(
            request.getTenantId(),
            request.getKeyword(),
            request.getStatus(),
            pageParameter
        );

        builder.setPageIndex(pageParameter.getPage())
               .setPageSize(pageParameter.getSize())
               .setTotalCount(page.getTotalElements())
               .setTotalPage(page.getTotalPages())
               .setData(page.getContent());
        // NEVER call done() - controller handles response
    }
}
```

**Repository Trait Extension (custom queries):**
```java
// Trait interface is AUTO-GENERATED - extend in src/main/trait/
interface _UserEntityRepository extends UserEntityRepository {

    default Page<UserEntity> search(Long tenantId, String keyword,
                                    String status, PageRequest page) {
        Criteria criteria = EasyCriteria.eq(_Tenantable_.TENANT_ID, tenantId)
                .and(EasyCriteria.eq(_Deletable_.DELETED, false));

        if (keyword != null && !keyword.isBlank()) {
            criteria = criteria.and(EasyCriteria.like(UserEntityDSL.USER_NAME, keyword));
        }
        if (status != null) {
            criteria = criteria.and(EasyCriteria.eq(UserEntityDSL.STATUS_CODE, status));
        }

        return findAll(criteria, this.page(page));  // DB-level pagination
    }

    // Efficient exists check
    default boolean existsByEmail(String email, Long tenantId) {
        return exists(EasyCriteria.eq(UserEntityDSL.EMAIL, email)
                .and(EasyCriteria.eq(_Tenantable_.TENANT_ID, tenantId)));
    }
}
```

### 5. Frontend Development (Vben Admin + Vue 3)

Auto-generated TypeScript SDK with IoC HTTP client:

```typescript
// Import generated SDK (NEVER write raw fetch/axios)
import { UserService } from '@my-scope/user-app-sdk';
import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { Button, Space, message, Modal } from 'ant-design-vue';

// LIST_PAGE pattern (views/user/index.vue)
const gridOptions: VxeGridProps = {
  columns: [
    { type: 'seq', width: 60, title: $t('page.common.seq') },
    { field: 'userName', minWidth: 150, title: $t('pages.user.userName') },
    { field: 'email', minWidth: 200, title: $t('pages.user.email') },
    { field: 'action', fixed: 'right', slots: { default: 'action' }, width: 180 },
  ],
  proxyConfig: {
    ajax: {
      query: async ({ page }) => {
        // Page index is 0-based (vxe-table currentPage starts at 1)
        const res = await UserService.searchUsers({}, {
          page: page.currentPage - 1,
          size: page.pageSize
        });
        return { items: res.data, total: res.totalCount };
      },
    },
  },
  pagerConfig: { enabled: true },
};

const [Grid, gridApi] = useVbenVxeGrid({ gridOptions });

function handleDelete(row: any) {
  Modal.confirm({
    title: $t('page.common.confirmDelete'),
    okType: 'danger',
    async onOk() {
      await UserService.deleteUser(row.id);
      message.success($t('page.common.deleteSuccess'));
      gridApi.reload();
    },
  });
}
```

**Auto-Router Generation:**
```vue
<script setup lang="ts">
defineOptions({
  name: 'UserList',
  meta: {
    title: 'pages.user.title',
    icon: 'lucide:users',
    order: 10,
    authority: ['admin', 'user-mgr'],
    keepAlive: true,
  },
});
</script>
```

Run `gradlew :frontend-ui-module:ui` to auto-generate routes and menus from `views/**/*.vue`.

---

## Technology Stack

| Component | Version | Description |
|-----------|---------|-------------|
| **Backend** | | |
| Java | 17+ | Core language |
| Spring Boot | 3.5+ | Application framework |
| Spring Data JDBC | Extended | Persistence layer |
| ApiHug SDK | 2.4+ | Proto extensions, runtime |
| Protobuf | proto3 | Interface definition language |
| Liquibase | Latest | Database migration |
| **Frontend** | | |
| Vue | 3.x | UI framework |
| Vben Admin | Latest | Admin template |
| Ant Design Vue | 4.x | Component library |
| vxe-table | Latest | Data grid |
| TailwindCSS | 3.x | Utility CSS |
| **Build Tools** | | |
| Gradle | 8+ | Build automation |
| pnpm | Latest | Frontend package manager |
| **IDE** | | |
| IntelliJ IDEA | 2022+ | Recommended IDE |
| ApiHug Plugin | Latest | Proto DSL copilot |

---

## Getting Started

### Prerequisites

| # | Requirement | Details |
|---|-------------|---------|
| 1 | ✅ **JDK 17+** | [OpenJDK](https://openjdk.org/) or Oracle JDK |
| 2 | ✅ **Gradle 8+** | [Installation Guide](https://gradle.org/install/) |
| 3 | ✅ **IDEA 2022+** | (Optional) [Download](https://www.jetbrains.com/idea/) |
| 4 | ✅ **ApiHug Plugin** | [ApiHug - API design Copilot](https://plugins.jetbrains.com/plugin/23534-apihug--api-design-copilot) |
| 5 | ✅ **Spring Initializr** | Accessible or [local deployment alternatives](https://start.spring.io/) |

---

### Quick Start (15 Minutes)

Follow the official [ApiHug Getting Started Guide](https://apihug.github.io/docs/start) to create your first ApiHug project.

#### Step 1: One-Click Initialization

Transform an empty directory into an ApiHug workspace with a single command.

**Windows (PowerShell):**
```powershell
iex (irm 'https://raw.githubusercontent.com/apihug/apihug.github.io/main/helper/apihug-install.ps1')
```

**Windows (Command Prompt):**
```cmd
powershell -c "irm https://raw.githubusercontent.com/apihug/apihug.github.io/main/helper/apihug-install.ps1 | iex"
```

**Linux/macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/apihug/apihug.github.io/main/helper/apihug-install.sh | bash
```

---

#### Step 2: Install IDEA Plugin （Optional）

1. **File** → **Settings** → **Plugins**
2. Search for **ApiHug**
3. Click **Install** & Restart IDEA

---

#### Step 3: Create New Project

1. **File** → **New** → **Project** → **ApiHug**
2. Configure project settings:
   - Package name
   - Project name
   - Description
   - SDK settings
   - Version
   - DB Vendor
   - Cache
   - Port

> 💡 **Tip:** Keep default settings for your first project!

**Project Structure:**
```
order/                          # (1) Project root
├── order-app/                  # (2) Protocol module: API Definition  & Application module: Implementation & Service
```

---

#### Step 4: Spring Configuration

Configure Spring Initializr settings:
1. Select project type
2. Choose dependencies (e.g., Spring Web)
3. Click **Create** → **Open Project**

---

#### Step 5: Build & Run

**5.1 Wire Task** (compile proto definitions)

```bash
# In project root
./gradlew clean build -x test -x wireTest
```

Check generated code: `demo-app/src/generated/main/wire/`


**5.2 Run Application**

```bash
./gradlew demo-app:bootRun
```

**Expected Output:**
```
----------------------------------------------------------
Application 'demo-app' is running! Access URLs:

Local                             http://localhost:18089/
External                          http://192.168.0.115:18089/
OAS                               http://192.168.0.115:18089/v3/api-docs
Actuator                          http://192.168.0.115:18089/management
Api-Errors                        http://192.168.0.115:18089/hope/meta/errors
Api-Dictionaries                  http://192.168.0.115:18089/hope/meta/dictionaries
Api-Authorities                   http://192.168.0.115:18089/hope/meta/authorities
Profile(s)                        dev
----------------------------------------------------------
```

**5.4 Verify OAS (OpenAPI Specification)**
```
Copy the /v3/api-docs URL from console and open in browser
```

---

#### Step 6: ApiHug Tool Window

The **ApiHug Tool Window** should dock on the right side of IDEA. If not visible:
- Go to menu: **ApiHug** → **ApiHug Designer**

---

### Project Layout Reference


#### Backend
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

#### Frontend
| Directory                | Writable | Purpose               |
|--------------------------|----------|-----------------------|
| `apps/{app}/src/views/`  | ✅        | Page components       |
| `packages/{module}-sdk/` | ❌        | Generated API service |
| `apps/{app}/src/router/` | ❌        | Generated routes      |

---

### Next Steps

After completing the quick start:
1. Explore the [ApiHug REPL](https://apihug.github.io/docs/tool/apihug-repl) for interactive development
2. Read the [API Extension Guide](rules/apihug-proto-api-extension-guide.md) for API design patterns
3. Study the [Database Modeling Guide](rules/apihug-proto-database-modeling-guide.md) for entity definitions
4. Review the [Backend Golden Rules](rules/apihug-impl-golden-rule.md) for implementation standards

---

## Development Workflow

### Contract-First Development Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│  1. DESIGN: Define Proto DSL (API / Entity / Enum / Error)     │
│     - api/{feature}/service.proto                              │
│     - domain/{feature}/entity.proto                            │
│     - infra/{feature}/constant.proto & error.proto             │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│  2. GENERATE: Run wire plugin                                   │
│     ./gradlew :{module}:wire                                    │
│     → Controller, Entity, DTO, Repository, ServiceImpl skeleton │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│  3. IMPLEMENT: Backend logic                                    │
│     - Fill ServiceImpl method bodies                            │
│     - Extend Repository trait with queries                      │
│     - Add DomainService (optional)                              │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│  4. GENERATE: Frontend SDK & Routes                             │
│     ./gradlew :{ui-module}:ui                                   │
│     → TypeScript SDK, Vue routes, menus                         │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│  5. IMPLEMENT: Frontend pages                                   │
│     - Create views/{module}/index.vue (LIST_PAGE)              │
│     - Create views/{module}/components/*Modal.vue (FORM_PAGE)  │
│     - Use generated SDK for API calls                           │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│  6. REVIEW: Proto & Implementation                              │
│     - ./gradlew :{module}:proto-review (check proto rules)     │
│     - ./gradlew :{module}:impl-review (check impl rules)       │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│  7. TEST & DEPLOY                                               │
│     - Write integration tests (src/test/)                       │
│     - Run Kola tests (src/test-kola/)                           │
│     - Deploy via CI/CD pipeline                                 │
└─────────────────────────────────────────────────────────────────┘
```

### BMAD Workflow Integration

For structured AI-driven development, use BMAD workflows:

| Workflow | Command | Purpose |
|----------|---------|---------|
| `bmad-product-brief` | `/bmad-product-brief` | Capture strategic vision |
| `bmad-create-prd` | `/bmad-create-prd` | Define requirements (FRs/NFRs) |
| `bmad-create-epics-and-stories` | `/bmad-create-epics-and-stories` | Break into implementable work |
| `apihug-create-story` | `/apihug-create-story` | Prepare story with ApiHug context |
| `apihug-dev-story` | `/apihug-dev-story` | Implement story (backend + frontend) |
| `apihug-proto-review` | `/apihug-proto-review` | Review proto against design rules |
| `apihug-impl-review` | `/apihug-impl-review` | Review implementation against golden rules |
| `bmad-code-review` | `/bmad-code-review` | Validate implementation quality |

---

## Architecture Principles

### Layer Isolation (Critical)

```
┌──────────────────────────────────────────────────────────────┐
│  API Layer (api/)                                            │
│  - RPC definitions with @operation extensions                │
│  - Request/Response DTOs                                     │
│  - CAN import: infra/                                        │
│  - CANNOT import: domain/ (STRICT)                           │
└──────────────────────────────────────────────────────────────┘
                           ↑
┌──────────────────────────────────────────────────────────────┐
│  Domain Layer (domain/)                                      │
│  - Entity definitions with @table/@column                    │
│  - Business logic (DomainService)                            │
│  - CAN import: infra/                                        │
│  - CANNOT import: api/ (STRICT)                              │
└──────────────────────────────────────────────────────────────┘
                           ↑
┌──────────────────────────────────────────────────────────────┐
│  Infrastructure Layer (infra/)                               │
│  - Enums, constants, error codes                             │
│  - Shared across all layers                                  │
│  - CANNOT import: api/, domain/                              │
└──────────────────────────────────────────────────────────────┘
```

### 3-Field Rule for Request Design

| Parameters | Approach | Example |
|------------|----------|---------|
| 0 | `google.protobuf.Empty` | `rpc List(Empty)` |
| 1-2 | `Empty` + `parameters{}` | `rpc Get(Empty)` with path/query in `parameters` |
| 3+ | Create Request Message | `rpc Create(CreateRequest)` |

### Security Architecture

```
HTTP Request
    → JWTFilter (extract JWT → build Customer)
    → HopeContextHolder.setContext()  // ThreadLocal injection
    → Controller
    → SecurityAspect (AOP BEFORE, priority=100)
    → HopeSecurityManager.check()     // Proto RBAC vs Customer
    → ServiceImpl (ZERO auth code needed)
    → HopeContextHolder.clear()       // Cleanup
```

**Critical Security Rules:**
- ❌ **ZERO RBAC code** in ServiceImpl/DomainService/Repository
- ❌ **NEVER** use `@PreAuthorize`, `@Secured`, `@RolesAllowed`
- ✅ **ALWAYS** define auth in proto `authorization` option
- ✅ **ALWAYS** use `HopeContextHolder.customer()` for current user

### Source Sets

| Directory | Writable | Purpose |
|-----------|----------|---------|
| `src/main/proto/` | ✅ YES | Proto DSL source |
| `src/main/java/` | ✅ YES | ServiceImpl, DomainService |
| `src/main/trait/` | ✅ YES | Repository extensions |
| `src/main/resources/` | ✅ YES | Config (hope-wire.json, application.yml) |
| `src/generated/` | ❌ NO | Auto-generated (READ-ONLY) |
| `packages/{module}-sdk/` | ❌ NO | Generated frontend SDK |
| `apps/{app}/src/router/` | ❌ NO | Generated routes |

---

## Documentation Guides

### Proto Design Guides

| Guide | Description |
|-------|-------------|
| [API Extension Guide](rules/apihug-proto-api-extension-guide.md) | RPC-to-REST mapping, OpenAPI generation, pageable APIs |
| [Database Modeling Guide](rules/apihug-proto-database-modeling-guide.md) | Table/column mapping, Liquibase integration, SQL reserved words |
| [Enum/Error Extension Guide](rules/apihug-proto-enum-error-extension-guide.md) | Business codes, error metadata, multilingual support |

### Implementation Guides

| Guide | Description |
|-------|-------------|
| [Backend Golden Rules](rules/apihug-impl-golden-rule.md) | ServiceImpl, Repository trait, DomainService, security, error handling |
| [Frontend Vben Guide](rules/apihug-impl-front-vben-guide.md) | Vben Admin, auto-router, HTTP client IoC, real-time (SSE/WebSocket) |

### Architecture & Context

| Document | Description |
|----------|-------------|
| [Architecture.md](docs/architecture.md) | ADRs, project structure, naming conventions, proto extension reference |
| [Project Context](docs/project-context.md) | AI agent constitution (tech stack, constraints, source sets) |
| [BMAD Integration](docs/BMAD.md) | BMAD method workflows, story lifecycle |

---

## BMAD Method Integration

APIHug seamlessly integrates with the **BMAD Method** (BMM), a structured approach for AI-driven software development. BMAD provides clear context engineering and planning to enable AI agents to perform optimally.

### BMAD Workflow Map

```
Analysis → Plan → Solutioning → Implementation → Review → Retrospective
```

| Phase | Workflow | Produces |
|-------|----------|----------|
| **Analysis** | `bmad-create-product-brief` | `product-brief.md` |
| **Plan** | `bmad-create-prd` | `PRD.md` (FRs/NFRs) |
| **Solutioning** | `bmad-create-architecture` | `architecture.md` (ADRs) |
| **Solutioning** | `bmad-create-epics-and-stories` | Epic files with stories |
| **Gate Check** | `bmad-check-implementation-readiness` | PASS/CONCERNS/FAIL |
| **Implementation** | `apihug-create-story` | `story-[slug].md` |
| **Implementation** | `apihug-dev-story` | Working code + tests |
| **Review** | `apihug-proto-review` | Proto approval/changes |
| **Review** | `apihug-impl-review` | Implementation approval |
| **Review** | `bmad-code-review` | Quality validation |
| **Retrospective** | `bmad-retrospective` | Lessons learned |

For details, see [BMAD Method Documentation](https://docs.bmad-method.org/).

---

## Contributing

We welcome contributions to the APIHug Skills knowledge base!

### How to Contribute

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/your-improvement`
3. **Make your changes**:
   - Update relevant guides in `rules/` or `docs/`
   - Add examples if applicable
   - Ensure consistency with existing conventions
4. **Test your changes**: Verify against real ApiHug projects
5. **Submit a pull request**: Describe the problem solved and changes made

### Contribution Guidelines

- **Clarity**: Write clear, concise documentation with examples
- **Consistency**: Follow existing formatting and structure
- **Correctness**: Verify all code snippets compile and work as described
- **Completeness**: Cover edge cases and common mistakes

---

## References

### Official Resources

1. [ApiHug Protocol](https://github.com/apihug/protocol) - Core protocol definitions
2. [ApiHug GitHub](https://apihug.github.io/) - Framework documentation
3. [ApiHug Commercial Site](https://www.apihug.com/) - Enterprise features
4. [ApiHug Starter Guide](https://apihug.github.io/docs/start) - Quick start
5. [ApiHug REPL](https://apihug.github.io/docs/tool/apihug-repl) - Interactive development

### Documentation & Handbooks

6. [Wire Plugin Documentation](https://github.com/apihug/apihug.com/blob/master/docs/handbook/004_dsl_implement_wire.md)
7. [Stub Plugin Documentation](https://github.com/apihug/apihug.com/blob/master/docs/handbook/005_dsl_implement_stub.md)
8. [Trivial Information](https://github.com/apihug/apihug.com/blob/master/docs/handbook/099_trivial.md)
9. [FAQ](https://github.com/apihug/apihug.com/blob/master/docs/handbook/999_faq.md)
10. [Release Notes (0.7.8)](https://github.com/apihug/apihug.com/blob/master/docs/framework/versions/0.7.8.md)

### IDE & Tooling

11. [ApiHug IDEA Plugin](https://plugins.jetbrains.com/plugin/23534-apihug--api-design-copilot)
12. [IDEA FAQ](https://github.com/apihug/apihug.com/blob/master/docs/IDE/999_FAQ.md)
13. [IDEA Handbook](https://github.com/apihug/apihug.com/blob/master/docs/IDE/README.md)

### Video Tutorials

14. [ApiHug 101 (Bilibili)](https://www.bilibili.com/video/BV1KK421k7J8/)
15. [ApiHug 101 (YouTube)](https://youtube.com/@ApiHug?si=C1yw0poHA01zbmyj)

### Build & Framework

16. [Gradle Documentation](https://docs.gradle.org)
17. [Spring Boot Gradle Plugin](https://docs.spring.io/spring-boot/docs/3.2.0/gradle-plugin/reference/html/)

### BMAD Method

18. [BMAD Documentation](https://docs.bmad-method.org/)
19. [BMAD Workflow Map](https://docs.bmad-method.org/reference/workflow-map/)
20. [Project Context Guide](https://docs.bmad-method.org/explanation/project-context/)


---

**APIHug Skills** - Empowering enterprise development with contract-first, AI-optimized Protobuf DSL.
