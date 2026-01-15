# APIHug Protocol Framework

APIHug is a comprehensive Protobuf-based framework designed to streamline API development, database modeling, and service integration. It provides standardized extensions for creating robust enterprise applications with consistent data models and API contracts.

## Overview

This repository contains the core protocol definitions for the APIHug framework, which enables developers to:
- Define RESTful APIs using Protobuf with OpenAPI/Swagger documentation
- Model database entities directly from Protobuf messages
- Create business enumerations with multilingual support and error handling
- Build LLM-friendly APIs with natural language descriptions

## Directory Structure

```
proto/
├── apihug/
│   └── protobuf/
│       ├── domain/          # Database entity modeling extensions
│       │   ├── annotations.proto  # Domain annotations
│       │   ├── persistence.proto  # Persistence configurations
│       │   └── view.proto         # View definitions
│       ├── extend/          # Extended functionality
│       │   ├── constant.proto     # Constant/enum extensions
│       │   └── version.proto      # Version information
│       ├── mock/            # Mock data definitions
│       │   └── mock.proto
│       └── swagger/         # API documentation extensions
│           ├── annotations.proto  # Swagger annotations
│           └── swagger.proto      # Swagger configurations
specs/
├── constant.md             # Constant/enum usage guide
├── domain.md               # Domain modeling guide
└── swagger.md              # API documentation guide
```

## Core Features

### 1. Swagger API Extensions
Define RESTful APIs with comprehensive metadata:

```proto
import "apihug/protobuf/swagger/annotations.proto";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {
    option (hope.swagger.operation) = {
      get: "/users/{id}"
      description: "Get user by ID"
      questions: ["How do I get a user by ID?", "What's the endpoint to fetch a user?"]
      authorization: {
        rbac: { roles: ["ADMIN", "USER_READ"] }
      }
    };
  }
}
```

### 2. Database Modeling
Model database entities directly from Protobuf messages:

```proto
import "apihug/protobuf/domain/annotations.proto";

message User {
  option (hope.persistence.table) = {
    name: "USERS"
    description: "User information table"
    wires: [IDENTIFIABLE, AUDITABLE, DELETABLE]
  };

  string name = 1 [(hope.persistence.column) = {
    name: "NAME"
    nullable: false
    length: 100
    type: VARCHAR
  }];
}
```

### 3. Business Constants
Define enums with business codes and multilingual support:

```proto
import "apihug/protobuf/extend/constant.proto";

enum UserStatus {
  ACTIVE = 0 [(hope.constant.field) = {
    code: 1
    message: "active"
    message2: "活跃"
  }];
  
  INACTIVE = 1 [(hope.constant.field) = {
    code: 2
    message: "inactive"
    message2: "非活跃"
  }];
}
```

## Getting Started

### Prerequisites
- Protocol Buffers (Protobuf) compiler
- Appropriate language plugins for code generation

### Installation
1. Clone the repository
2. Import the required proto files in your service definitions
3. Use the extensions as demonstrated in the examples above

### Usage Examples

#### Creating an API Service
1. Define your service in a `.proto` file
2. Import `apihug/protobuf/swagger/annotations.proto`
3. Use the `(hope.swagger.operation)` extension to define API metadata
4. Generate client/server code using the appropriate plugin

#### Modeling a Database Entity
1. Define your message in a `.proto` file
2. Import `apihug/protobuf/domain/annotations.proto`
3. Use the `(hope.persistence.table)` and `(hope.persistence.column)` extensions
4. Generate database schema using the framework tools

## Architecture Principles

### Layer Isolation
- API layer (swagger/) must not reference Domain entities
- Domain layer (domain/) must remain architecture-pure and not reference API layers
- Cross-layer referencing is strictly prohibited to maintain clean architecture boundaries

### Extension System
The framework uses Google's Protobuf extension mechanism to add custom options to standard Protobuf constructs:
- `MethodOptions` for API operations
- `MessageOptions` for entity/table definitions
- `ServiceOptions` for service-level configurations
- `FieldOptions` for column/parameter definitions
- `EnumOptions` for enum metadata

## Documentation

Detailed guides for each component can be found in the `specs/` directory:
- [API Documentation Guide](./specs/swagger.md) - How to define and document APIs
- [Domain Modeling Guide](./specs/domain.md) - How to model database entities
- [Constants Guide](./specs/constant.md) - How to define enums and error codes

## LLM Integration

The framework includes features specifically designed for Large Language Model integration:
- Natural language questions in API definitions using the `questions` field
- Semantic descriptions that make APIs more discoverable by AI
- Structured documentation that can be consumed by language models

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the terms specified in the LICENSE file.