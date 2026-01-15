# End-to-End Pipeline Bible

## 1. 目标与范围

本 workflow 覆盖一个 ApiHug 领域模块从 **应用启动（自动触发 wire）→ API/OAS 验证 → 测试执行** 的完整端到端（End-to-End）流程。

- **起点**：已经存在领域模块，并完成基本的 proto 设计。
- **终点**：验证 API、错误码、权限、测试结果均符合预期，可用于日常回归或上线前检查。
- **核心简化**：`bootRun` 自动依赖 `wire` 任务，无需手动执行编译和代码生成步骤。

## 2. 关键参与模块

- **统一模块架构**：
  - 位置：`{module_path}`
  - 协议定义：`src/main/proto/`
  - 生成代码：`src/generated/main/{api,domain,wire,mcp,cloud}`（由 `wire` 任务自动生成）
  - 业务实现：`src/main/{java,trait}`
  - 测试代码：`src/test/java/` + `src/generated/test/`

- **运行时元数据**：
  - OAS 文档：`/v3/api-docs`
  - 错误码：`/hope/meta/errors`
  - 权限：`/hope/meta/authorities`
  - 字典：`/hope/meta/dictionaries`
  - 版本：`/hope/meta/versions`

## 3. 端到端流程分解

### Phase 1: 应用启动（自动触发 wire）

**目标**：启动应用并自动完成所有代码生成，验证基础运行状态。

- **核心命令**：`./gradlew {module}:bootRun`
  - `bootRun` 自动依赖 `compileJava`
  - `compileJava` 自动依赖 `wire`
  - `wire` 任务完成所有代码生成（API/Domain/Wire/MCP/Cloud）

- **自动完成**：
  - Proto 编译：`wire` 任务自动处理
  - 代码生成：输出到 `src/generated/main/{api,domain,wire,mcp,cloud}`
  - 应用启动：Spring Boot 应用运行在配置端口（默认 18899）

- **检查启动日志**：
  - 应用成功启动（无严重错误）
  - 端口绑定正确
  - 激活的 Profile（如 `dev`）
  - Wire 任务执行成功（日志中可见）

### Phase 2: OAS 与元数据验证

**目标**：验证协议在运行时的呈现（OpenAPI、错误码、权限等）。

- 关键 URL：
  - 应用根：`http://localhost:18899/`
  - OAS：`http://localhost:18899/v3/api-docs`
  - 错误码：`http://localhost:18899/hope/meta/errors`
  - 权限：`http://localhost:18899/hope/meta/authorities`
  - 字典：`http://localhost:18899/hope/meta/dictionaries`
  - 版本：`http://localhost:18899/hope/meta/versions`

- 核心检查点：
  - OAS 中 API 路径、方法、请求/响应 Schema 与 proto 定义一致
  - 错误码列表完整且无冲突（code、message、message2、HTTP 状态）
  - 权限定义与 `authority_enum_class` 对应的枚举一致

### Phase 3: API 功能验证

**目标**：通过 curl/Postman 等工具验证核心 API 的行为。

- 典型步骤：
  - 成功路径：创建/查询/更新/删除等正常调用
  - 错误路径：校验错误、权限不足、对象不存在等
- 关注点：
  - 请求参数校验是否生效
  - 错误码是否与设计一致
  - 返回结构是否符合 OAS/DTO 定义

### Phase 4: 测试执行

**目标**：执行模块的单元测试和集成测试，验证自动化质量。

- **核心命令**：`./gradlew {module}:test`
- **检查项**：
  - 所有测试通过
  - 报告位置：`{module_path}/build/reports/tests/test/`
  - 覆盖率是否达到团队标准（例如 80%+）

### Phase 5: 总结与回归价值

**目标**：汇总端到端执行结果，沉淀为可复用的回归流程。

- 汇总内容：
  - 每个 Phase 的通过/失败状态
  - 关键问题列表
  - 风险评估与建议
- 价值：
  - 支持上线前端到端检查
  - 支持大版本升级后的回归验证
  - 为持续集成/流水线脚本提供参考

## 4. 使用建议

- 将本 End-to-End 流程视为：
  - **日常回归脚本**：开发完成后快速验证整体链路
  - **预发布检查清单**：在重要发布前完整跑一遍
- 与其它工作流的关系：
  - `proto-design`：负责协议设计与演进，使用 `wire` 命令完成代码生成
  - `app-implement`：负责业务实现，基于 `src/generated/main/{api,domain}` 中的接口和实体
  - `end-to-end`：验证整体链路是否健康，单命令 `bootRun` 完成所有构建和启动
  - `project-review`：评估项目整体设计质量
