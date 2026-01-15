# ApiHug App Development Bible

## App 模块核心职责

这是一个依赖于 proto 模块协议定义的 Spring Boot 应用。

## 🚨 关键规则

1. **Controllers & Service Interfaces**: 自动生成 → **不要手写**
2. **Request/Response DTOs**: 在 Wire proto 中定义 → **不要手写**
3. **Entities**: 在 Wire proto 中定义 → **不要手写**
4. **所有 `src/generated/` 目录**: 由 `wire` 任务生成，只读 → **永远不要修改**（会被覆盖）
5. **手写代码仅限于**: `src/main/java/` 和 `src/main/trait/`

## 你需要编写什么

### 1. 服务实现（src/main/java/）

- 实现服务接口（接口是自动生成的）
- 业务逻辑和编排
- 使用 `@Service` + 构造器注入
- 使用 `@Transactional` 处理事务

### 2. Repository 扩展（src/main/trait/）

- 扩展自动生成的 repository 接口
- 添加自定义查询方法
- 复杂数据访问逻辑

### 3. 配置（src/main/java/）

- Spring beans 和配置
- Profile 特定设置
- 无需 Security 配置（ApiHug 不使用 Spring Security）

### 4. 验证器 & 领域逻辑（src/main/java/）

- 自定义验证器
- 业务规则
- 工具类

## 自动生成的内容（只读）

❌ **不要触碰这些目录** - 由 `wire` 任务从 proto 生成：

- `src/generated/main/api/`: Controllers、服务接口、DTOs、路由
- `src/generated/main/domain/`: 实体模型、领域对象
- `src/generated/main/wire/`: Wire DTOs、请求/响应对象
- `src/generated/main/mcp/`: 协议契约
- `src/generated/main/cloud/`: 云集成 stubs
- `src/generated/test/api/`: 契约测试
- `src/generated/test/domain/`: 测试领域对象

## 技术栈

- **Java 17+**
- **Spring Boot 3.x**
- **Spring Data JDBC** (无 JPA/Hibernate)
- **Gradle** (构建工具)
- **JUnit 5** (测试)
- **Liquibase** (数据库迁移，由 apihug 管理)

## 代码风格

**命名**:
- `PascalCase`: 类（如 `UserService`）
- `camelCase`: 方法/变量（如 `findById`）
- `ALL_CAPS`: 常量（如 `MAX_SIZE`）

**注入**: 始终使用构造器注入

**要使用的注解**:
- `@Service`, `@Repository`, `@Transactional`, `@Valid`, `@ConfigurationProperties`

**要避免的注解**:
- ❌ `@RestController`, `@RequestMapping`: Controllers 是生成的
- ❌ `@Entity`, `@Table`: Entities 来自 proto

## 数据库访问（Spring Data JDBC）

- **无 JPA** - 仅使用 Spring Data JDBC
- Entities 从 Wire proto 自动生成
- 自定义查询在 `src/main/trait/`
- 对复杂查询使用 `JdbcTemplate`
- 通过 Liquibase 进行数据库迁移（由 apihug 处理）

## 测试策略

**服务测试** (`src/test/java/`): 使用 `@SpringBootTest`

**Repository 测试** (`src/test/java/`): 使用 `@DataJdbcTest`

**契约测试** (`src/test/_api_/`): 自动生成，只读

## 配置管理

- 使用 `application.yml` 或 `application.properties`
- Spring Profiles 用于不同环境
- `@ConfigurationProperties` 用于类型安全的配置

## 最佳实践

✅ **应该**:
- 专注于服务实现和业务逻辑
- 在 `trait/` 中编写自定义 repository 方法
- 使用构造器注入
- 在需要时保持方法事务性
- 在服务层处理异常
- 编写全面的测试
- 按 DDD 子功能分包组织实现类：例如 `order` 子域下，使用 `order` 包组织 Service/Repository 实现（如 `OrderServiceImpl`），对应 proto 中的 `order/api`、`order/domain`、`order/settings`。

❌ **不应该**:
- 编写 controllers、REST endpoints 或服务接口
- 手动创建 DTOs 或 entities
- 修改任何 `src/generated/` 目录
- 使用 JPA 注解
- 使用字段注入

## 源代码目录结构

详细的 Source Set 约定请参考 Proto Design Quick Reference 中的"Proto 模块目录结构"。本模块遵守同一规则，仅补充 App 侧职责：

**手写代码**:
- 业务实现：`src/main/java/`
- Repository 扩展：`src/main/trait/`
- 单元测试：`src/test/java/`

**生成代码**（只读，由 `wire` 任务生成）:
- API 接口：`src/generated/main/api/`
- 领域实体：`src/generated/main/domain/`
- Wire DTOs：`src/generated/main/wire/`
- 微服务契约：`src/generated/main/mcp/`
- 云适配器：`src/generated/main/cloud/`
- 测试代码：`src/generated/test/{api,domain,wire}`
