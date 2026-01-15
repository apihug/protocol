# ApiHug Project Review Checklist

## 1. 项目结构检查

- [ ] `settings.gradle` 中领域模块存在（如 `order-app`）
- [ ] 模块命名符合团队规范（小写、短横线分隔）
- [ ] 模块依赖关系清晰，无明显循环依赖
- [ ] `hope-wire.json` 中 `packageName/name/domain/application` 与实际工程一致
- [ ] `artifact.groupId/artifact.artifactId` 符合命名规范
- [ ] `authority.enumClass` 存在且可用

## 2. Proto 协议质量

### 2.1 目录组织

- [ ] `src/main/proto/{package_name}/api/**` 结构合理，按业务模块划分
- [ ] `src/main/proto/{package_name}/domain/**` 存在实体定义
- [ ] `src/main/proto/{package_name}/infra/**` 存在常量/错误码/权限等定义

### 2.2 Constant 规范

- [ ] 常量/错误码 proto 文件位于 `infra/**`（可有多个文件）
- [ ] Enum 使用 `(hope.constant.field)` 配置
- [ ] 错误码使用 `(hope.constant.error)` 配置
- [ ] code 唯一，无冲突
- [ ] message / message2 填写完整
- [ ] HTTP status、category、severity 合理

### 2.3 Domain 规范

- [ ] 实体使用 `(hope.persistence.table)` 配置
- [ ] 字段使用 `(hope.persistence.column)` 配置
- [ ] 主键定义明确（含生成策略）
- [ ] 索引与唯一约束合理
- [ ] wires（AUDITABLE/DELETABLE/TENANT_ISOLATE 等）使用合理
- [ ] 视图使用 `(hope.persistence.view)` 定义

### 2.4 Swagger 规范（包含 Mock 配置）

- [ ] service 使用 `(hope.swagger.svc)` 配置
- [ ] rpc 使用 `(hope.swagger.operation)` 配置
- [ ] 请求/响应消息使用 `(hope.swagger.schema)` 配置
- [ ] 字段使用 `(hope.swagger.field)` 配置必要的描述与校验
- [ ] 如存在 Mock：
  - [ ] Mock 配置嵌入在 swagger 的 field/schema 元数据中（`mock { ... }`）
  - [ ] `mock.nature`、`mock.*_rule` 合理

## 3. 生成代码质量

- [ ] 以下目录存在且视为只读（由 `wire` 任务生成）：
  - [ ] `src/generated/main/api/`
  - [ ] `src/generated/main/domain/`
  - [ ] `src/generated/main/wire/`
  - [ ] `src/generated/main/mcp/`
  - [ ] `src/generated/main/cloud/`
  - [ ] `src/generated/test/`
- [ ] 手写代码仅出现在：
  - [ ] `src/main/proto/`
  - [ ] `src/main/java/`
  - [ ] `src/main/trait/`
  - [ ] `src/test/java/`
- [ ] 未发现：
  - [ ] 手写 Controller/Service 接口/DTO/Entity
  - [ ] 修改 `src/generated/` 目录代码
  - [ ] 使用 jakarta persistence 注解 (`@Entity`, `@Table` 等)
  - [ ] 使用字段注入 (`@Autowired` on fields)

## 4. 依赖关系

- [ ] 领域模块的 `build.gradle` 正确依赖 `it-common-proto`
- [ ] 正确配置、应用 wire 插件与 protobuf 插件
- [ ] 使用 `wire` 任务生成代码到 `src/generated/`
- [ ] 使用 Spring Data JDBC 而非 JPA
- [ ] Liquibase 配置正确（如需要持久化）
- [ ] 未发现模块间循环依赖

## 5. 可演进性与测试

- [ ] 协议有明确的版本策略（如 package/路径中体现）
- [ ] 新增字段采用向后兼容方式（可选/默认值）
- [ ] 未发现破坏性变更（删除字段、修改类型等）
- [ ] 错误码历史保持向后兼容
- [ ] 单元测试覆盖率达到团队要求
- [ ] 集成测试覆盖关键业务场景
- [ ] 契约测试有效并集成到流水线

## 6. Review 输出

- [ ] 为本次 Review 生成结构化报告（Markdown/文档）
- [ ] 每个维度有评分与说明
- [ ] 严重问题/一般问题/优化建议列表完整
- [ ] 明确短期/中期/长期改进计划
