# APIHug Protocol Framework


 [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/apihug/protocol)

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


## Refer

1. [Apihug Protocol](https://github.com/apihug/protocol)
2. [Apihug Github](https://apihug.github.io/)
3. [ApiHug](https://apihug.com/)
4. [ApiHug starter](https://apihug.com/docs/start)
5. [Apihug GitHub Repository](https://github.com/apihug/apihug.com/)
6. [Apihug Wire Plugin Documentation](https://github.com/apihug/apihug.com/blob/master/docs/handbook/004_dsl_implement_wire.md)
7. [Apihug Stub Plugin Documentation](https://github.com/apihug/apihug.com/blob/master/docs/handbook/005_dsl_implement_stub.md)
8. [Apihug Trivial Information](https://github.com/apihug/apihug.com/blob/master/docs/handbook/099_trivial.md)
9. [Apihug Frequently Asked Questions](https://github.com/apihug/apihug.com/blob/master/docs/handbook/999_faq.md)
10. [Official Gradle Documentation](https://docs.gradle.org)
11. [Spring Boot Gradle Plugin Reference Guide](https://docs.spring.io/spring-boot/docs/3.2.0/gradle-plugin/reference/html/)
12. [ApiHug - API Design Copilot IDEA Plugin](https://plugins.jetbrains.com/plugin/23534-apihug--api-design-copilot)
13. [ApiHug - IDEA FAQ](https://github.com/apihug/apihug.com/blob/master/docs/IDE/999_FAQ.md)
14. [ApiHug - IDEA Handbook](https://github.com/apihug/apihug.com/blob/master/docs/IDE/README.md)
15. [ApiHug101 on Bilibili](https://www.bilibili.com/video/BV1KK421k7J8/)
16. [ApiHug101 on YouTube](https://youtube.com/@ApiHug?si=C1yw0poHA01zbmyj)
17. [ApiHug Official Website](https://apihug.github.io) | [ApiHug Commercial Site](https://www.apihug.com)
18. [Release Notes for 0.7.8-RELEASE](https://github.com/apihug/apihug.com/blob/master/docs/framework/versions/0.7.8.md)
