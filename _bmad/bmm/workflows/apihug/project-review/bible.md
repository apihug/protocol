# ApiHug Project Review Bible

## 1. 目标与场景

本 workflow 用于对现有 ApiHug 项目进行 **结构化 Review**，评估：

- 协议设计质量（proto 三大规范：Constant / Domain / Swagger，Mock 嵌入在 Swagger 中）
- 代码生成与手写代码的边界是否清晰（`src/generated/` vs `src/main/`）
- 模块依赖关系是否合理
- 项目的可演进性（版本管理、向后兼容、扩展性、测试）

适用场景：

- 新项目首次接入 ApiHug，需要整体评估健康度
- 老项目大版本升级、架构调整前的现状评估
- 外部团队交付项目的验收评审

## 2. Review 维度概览

1. **项目结构**：Gradle 多模块结构、版本管理、Wire 配置
2. **Proto 协议质量**：目录组织、Constant/Domain/Swagger 规范（Mock 嵌入在 Swagger 中）
3. **生成代码质量**：`src/generated/` 与 `src/main/` 分层是否清晰
4. **依赖关系**：模块依赖、版本、循环依赖
5. **可演进性**：版本策略、向后兼容性、测试覆盖

## 3. 关键规范回顾

### 3.1 Proto 目录与包名

- 根路径：`{module_path}/src/main/proto/{package_name}/...`
- 推荐结构：
  - `api/`：对外 API 定义
  - `domain/`：实体、视图、持久化定义
  - `infra/`：常量、错误码、权限等基础设施
- 目录结构必须与 package 完全匹配，由 domain 的 `packageName` 作为前缀。

### 3.2 Constant 规范

- 常量/错误码位于 `infra/**` 下（可按业务模块拆分多个 proto）
- 使用：
  - `(hope.constant.field)` 标注枚举值
  - `(hope.constant.error)` 标注错误码
- 错误码规范：
  - code 唯一
  - message / message2 完整
  - HTTP status、category、severity 合理

### 3.3 Domain 规范

- 使用 `persistence.proto`、`view.proto` 等进行实体与视图建模
- 关键 options：
  - `(hope.persistence.table)`：表级元数据
  - `(hope.persistence.column)`：列级元数据
  - `(hope.persistence.view)`：视图定义
- 检查点：
  - 主键、索引、唯一约束
  - wires（如 AUDITABLE/DELETABLE/TENANT_ISOLATE）使用是否合理

### 3.4 Swagger 规范（包含 Mock 配置）

- API service 使用 `(hope.swagger.svc)`
- rpc 使用 `(hope.swagger.operation)`
- 请求/响应消息使用 `(hope.swagger.schema)` 定义 schema
- 字段级别使用 `(hope.swagger.field)` 细化描述与验证
- **Mock 配置嵌入在 Swagger 中**：
  - 在 `(hope.swagger.field)` 或 `(hope.swagger.schema)` option 中使用 `mock { ... }`
  - 常见字段：`mock.nature`、`mock.string_rule`、`mock.number_rule`、`mock.date_rule`、`mock.chinese_rule` 等
  - Mock 不是独立规范，是 Swagger 规范的一部分

## 4. 代码组织规范

源代码与生成代码的目录约定统一由 Proto Design Bible 中的 Source Set Convention 定义。本 workflow 仅强调 Review 视角下需要关注的点：

**生成代码（只读，由 `wire` 任务生成）**：
- `src/generated/main/api/`: Controllers、Service 接口、DTOs
- `src/generated/main/domain/`: 实体、领域模型
- `src/generated/main/wire/`: Wire DTOs、请求/响应对象
- `src/generated/main/mcp/`: 微服务契约
- `src/generated/main/cloud/`: 云适配器
- `src/generated/test/`: 测试生成代码

**手写代码**：
- `src/main/proto/`: Proto 定义（唯一真理来源）
- `src/main/java/`: 业务实现、Service 实现类
- `src/main/trait/`: Repository 扩展、自定义查询
- `src/test/java/`: 单元测试、集成测试

**Review 检查点**：
- ✅ 检查：`src/generated/**` 目录均为生成代码，无手写代码混入
- ✅ 检查：手写代码只出现在 `src/main/{proto,java,trait}` 和 `src/test/java/`
- ✅ 检查：测试结构与生产结构保持镜像关系
- ❌ 禁止：在 `src/generated/` 中手写任何代码
- ❌ 禁止：在 `src/main/java/` 中手写 Controller、Entity、DTO

## 5. 依赖与演进

### 5.1 模块依赖

- 领域模块：
  - 依赖 `it-common-proto`
  - 正确配置、应用 wire 插件与 protobuf 插件
  - 使用 `wire` 任务生成代码到 `src/generated/`
  - 使用 Spring Boot + Spring Data JDBC（非 JPA）

### 5.2 演进与版本

- 协议版本标记策略（如路径或 package 中体现）
- 向后兼容：
  - 新增字段采用可选方式
  - 避免删除字段或修改类型
  - 错误码保持向后兼容
- 测试覆盖：
  - 单元测试 + 集成测试 + 契约测试

## 6. Review 输出期望

最终 Review 报告应包含：

- 每个维度的评分（1–10）及简要说明
- 严重问题/一般问题/优化建议列表
- 短期/中期/长期改进计划

建议将报告落地为团队共享文档，并在后续迭代中跟踪改进完成情况。
