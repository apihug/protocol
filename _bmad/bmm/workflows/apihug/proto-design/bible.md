# Proto Design Quick Reference

## Proto 模块核心职责

本模块通过 `.proto` 文件统一描述和驱动以下内容：

1. **领域实体**：数据库/持久化建模
2. **API 标准**：HTTP 接口定义
3. **Plain Object**：请求/响应 DTO、View 对象等
4. **枚举类与业务错误码**：业务常量定义

## 🚨 关键规则

1. **Proto Files**: 放在 `src/main/proto/` → **唯一真理来源**
2. **Generated Code**: `src/generated/main/{api,domain,wire,mcp,cloud}` 自动生成 → **永远不要修改**
3. **Package Structure**: 必须与 hope-wire.json 中 `packageName` 保持一致
4. **Three Specs**: Constant、Domain、Swagger 必须严格遵循规范（Mock 嵌入在 Swagger 中）
5. **Meta Index**: 编译后生成 `apihug.idx.csv` → **模块完整快照（压缩索引）**

## Meta 索引格式（apihug.idx.csv）

编译后自动生成的组件索引，采用 CSV 格式，大幅减少 token 消耗，提升可读性。

**CSV 列定义**：
- **type**: Service | Component | Enum | Error | Authority | Table
- **class**: 全限定类名（如 `com.arken.aip.api.auth.AuthService`）
- **name**: Proto symbol 名称（如 `AuthService`）
- **description**: 业务描述
- **proto**: Proto 文件路径及行号（格式 `path/to/file.proto#L10`）
- **details**: 方法/字段/枚举项列表，用 `|` 分隔（可选带行号 `ItemName#L10`）

**示例行**：
```csv
Service,com.arken.aip.api.auth.AuthService,AuthService,"用户认证服务",com/arken/aip/api/auth/login_api.proto#L70,Login#L72|Logout#L85
Enum,com.arken.aip.infra.settings.ItemStatusEnum,ItemStatusEnum,"商品状态",com/arken/aip/infra/settings/item_constant.proto#L12,DRAFT|PUBLISHED|UNPUBLISHED
```

此索引替代了之前的 `apihug.json` 和 `entities.json`，在统计组件数量、查询类型存在性、定位 Proto 文件位置等场景下更高效。

## 三大设计规范（完整文档见 specs/）

### 1. Constant（枚举与错误码）

**权威规范**: `{spec_constant}` （279行完整文档）

**快速索引**:
- 枚举扩展：`(hope.constant.field)` - code, message, message2
- 错误扩展：`error: { title, tips, http_status, phase, severity }`
- 文件位置：`infra/settings/**/constant.proto` 或 `error.proto`

### 2. Domain（数据库建模）

**权威规范**: `{spec_domain}` （1018行完整文档）

**快速索引**:
- 表扩展：`(hope.persistence.table)` - name, description, wires, indexes
- 列扩展：`(hope.persistence.column)` - name, type, nullable, unique, length
- 内置 Wires：AUDITABLE, DELETABLE, TENANT_ISOLATE
- 文件位置：`domain/**/entity.proto`

### 3. Swagger（API 设计 & Mock）

**权威规范**: `{spec_swagger}` （1369行完整文档）

**快速索引**:
- Service: `(hope.swagger.svc)` - path, description, tag
- Operation: `(hope.swagger.operation)` - HTTP方法, 权限, 分页, Mock
- Field: `(hope.swagger.field)` - 验证规则, Mock配置
- 文件位置：`api/**/api.proto`

## Proto 模块目录结构

### 标准结构

```
{module}/
├── src/main/
│   ├── proto/                         → Proto 定义（手写）
│   │   └── {package_name}/
│   │       ├── api/                   → API 定义
│   │       ├── domain/                → 领域实体
│   │       └── infra/                 → 基础设施（枚举、错误）
│   ├── java/                          → 手写业务
│   ├── trait/                         → Repository扩展
│   └── resources/
│       └── hope-wire.json             → 模块配置
├── src/generated/main/                → 生成代码（只读）
│   ├── api/                           → API接口
│   ├── domain/                        → 领域实体
│   ├── wire/                          → DTO对象
│   ├── mcp/                           → 微服务契约
│   └── cloud/                         → 云适配器
├── src/test/
│   ├── java/                          → 单元测试
│   └── trait/                         → 测试扩展
└── src/generated/test/                → 生成测试代码（只读）
    ├── api/                           → API契约测试
    └── ...
```

### 目录约定

**重要**: `src/generated/**` 由 `wire` 任务生成 → **只读**

- **手写代码**: `src/main/{proto,java,trait}`
- **生成代码**: `src/generated/main/{api,domain,wire,mcp,cloud}`

## 关键原则

✅ **应该**:
- Proto 文件是唯一真理来源
- 严格遵循三大规范（Constant/Domain/Swagger，Mock 嵌入在 Swagger 中）
- 使用 hope-wire.json 管理模块配置
- Package 名称与目录结构保持一致
- 实体优先使用内置 wires（AUDITABLE/DELETABLE/TENANT_ISOLATE）
- API 必须定义权限控制
- 错误码全局唯一，分段管理
- Mock 配置伴生在字段/对象定义上
- DDD 分层与功能自包含：每个子功能点（如 `order`）在语义上自包含自己的 API、领域实体、枚举与错误（不要把某个功能的 API/Entity/Error 分散到其他功能包）；真正全局共享的设置（如 AUTHORITY）仅放在根级 `infra/settings/**`。

❌ **不应该**:
- 修改 `src/generated/` 目录下的生成代码
- 手写 DTO、Entity、Controller
- Proto 文件与 hope-wire.json 中 packageName 不一致
- 错误码重复
- 缺少 Mock 配置
- API 缺少权限定义

## 编译与生成

**核心命令**：`./gradlew {module}:wire -x test`

- **单一命令**：`wire` 任务完成所有代码生成（API/Domain/Wire/MCP/Cloud）
- **自动依赖**：`compileJava` 自动依赖 `wire`，无需显式调用
- **输出位置**：
  - Wire DTOs: `src/generated/main/wire/`
  - API (controller, service interface): `src/generated/main/api/`
  - Domain entities: `src/generated/main/domain/`
  - Meta index: `src/main/resources/apihug.idx.csv`

> 结论：**构建流程已简化为 `wire` 单一入口，bible 不再列举复杂命令组合。**

## 常见问题

### Q1: Proto 编译失败

**检查**:
1. Package 名称是否与 hope-wire.json 一致
2. Import 路径是否正确
3. Option 语法是否正确
4. Wire 插件版本是否兼容

### Q2: 错误码冲突

**解决**:
- 错误码按模块分段（如 order: 40xxxx, user: 41xxxx）
- 使用 `{project-root}/_bmad/apiguru/specs/constant.md` 统一管理

### Q3: Mock 数据不符合预期

**调整**:
- 检查字段上的 `mock` 配置（嵌入在 `(hope.swagger.field)` 或 `(hope.swagger.schema)` 中）
- 调整 `string_rule/number_rule` 参数
- 使用 `candidates` 指定候选值
- 参考 Swagger 规范文档的 Mock 配置章节

### Q4: API 权限不生效

**检查**:
- `authorize.roles` 是否定义
- `authority.enumClass` 在 hope-wire.json 中是否配置
- Authority enum 是否已定义

## 参考资源

- **Constant 规范**: `{spec_constant}`
- **Domain 规范**: `{spec_domain}`
- **Swagger 规范**: `{spec_swagger}` (包含 Mock 配置)
- **hope-wire.json**: `{hope_wire}`
