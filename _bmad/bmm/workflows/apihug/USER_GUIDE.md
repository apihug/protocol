# ApiHug Workflows 用户指南

## 📚 四大核心工作流

### 1️⃣ proto-design - Proto 契约设计
**用途**：设计 API 契约和领域模型（Contract-First 开发）

**何时使用**：
- 新增 RESTful API 端点
- 设计数据库实体和字段
- 定义业务枚举或错误码
- 配置字段 Mock 数据规则

**输入**：业务需求描述
**输出**：`.proto` 文件 + 编译验证

**核心文件**：
- `bible.md` - Proto 设计规范（Constant/Domain/Swagger 三大规范）
- `specs/` - 详细规格文档（按需加载）
- `proto/protobuf/` - ApiHug proto 扩展定义

---

### 2️⃣ app-implement - 业务逻辑实现
**用途**：实现 Spring Boot 业务代码

**何时使用**：
- 实现 Service 接口业务逻辑
- 扩展 Repository 自定义查询
- 编写单元测试
- 配置 Spring Boot 参数

**前置条件**：proto 已设计并编译成功

**核心目录**：
- `src/main/java/` - 手写业务代码（Service 实现类）
- `src/main/trait/` - Repository 扩展（自定义查询方法）
- `src/main/_api_/` - 生成的接口（只读，不可修改）
- `src/main/_domain_/` - 生成的实体（只读，不可修改）

**关键约束**：
⚠️ **禁止修改任何 `_*_/` 目录**（下划线包裹的目录均为生成代码）

---

### 3️⃣ end-to-end - 端到端验证
**用途**：全流程自动化验证（从 proto 编译到测试通过）

**何时使用**：
- 验证整个开发流程是否畅通
- 集成测试前的预检
- CI/CD 流水线集成

**执行步骤**：
1. **Build** - 编译 proto 模块
2. **Stub** - 生成桩代码（Controller/Service/Entity）
3. **Boot** - 启动 Spring Boot 应用
4. **Test** - 运行自动化测试

**输出**：测试报告 + 验证清单

---

### 4️⃣ project-review - 项目质量评审
**用途**：结构化代码质量审查

**何时使用**：
- 项目里程碑评审
- 代码质量检查
- 架构演进评估
- 新人代码培训

**评审维度**：
- Proto 设计质量（API/Domain/Constant 规范性）
- 代码组织结构（目录职责分离）
- 依赖管理（模块依赖合理性）
- 可演进性（扩展性和维护性）

**输出**：评审报告 + 改进建议

---

## 🎯 典型开发流程

```
┌─────────────────┐
│ 1. proto-design │  设计 API 契约
└────────┬────────┘
         │ 生成 .proto 文件
         ↓
┌──────────────────┐
│ 2. app-implement │  实现业务逻辑
└────────┬─────────┘
         │ 编写 Service/Repository
         ↓
┌──────────────────┐
│ 3. end-to-end    │  端到端验证
└────────┬─────────┘
         │ 验证通过
         ↓
┌──────────────────┐
│ 4. project-review│  质量评审（可选）
└──────────────────┘
```

---

## 🔑 关键概念

### 📂 统一模块架构
**旧架构**（已废弃）：
- `order-app-proto` - Proto 定义模块
- `order-app` - 应用实现模块

**新架构**（当前）：
- `order-app` - 统一模块（包含 proto + 生成代码 + 手写代码）

### 📁 Source Set 目录约定

| 目录 | 职责 | 可修改 |
|------|------|--------|
| `proto/` | Proto 源码（API/Domain/Constant DSL） | ✅ |
| `java/` | 手写业务逻辑（Service 实现） | ✅ |
| `trait/` | Repository 扩展（自定义查询） | ✅ |
| `_api_/` | 生成的 REST 接口和 DTO | ❌ READ-ONLY |
| `_domain_/` | 生成的领域模型（Entity） | ❌ READ-ONLY |
| `_wire_/` | 生成的 Wire 组件 | ❌ READ-ONLY |
| `_mcp_/` | 生成的微服务契约 | ❌ READ-ONLY |
| `_cloud_/` | 生成的云适配器 | ❌ READ-ONLY |

**重要**：`_下划线_` 包裹的目录 = 生成代码 = **禁止手动修改**

### 🔧 核心配置文件

#### `hope-wire.json`
模块元数据配置：
```json
{
  "packageName": "com.example.order",
  "domain": "order",
  "application": "order-system",
  "artifact": {
    "groupId": "com.example.order",
    "artifactId": "order-app"
  }
}
```

#### `config.yaml`
域配置（BMAD 管理）：
```yaml
domains:
  all: [order, customer, product]
  details:
    order:
      path: "order-app"
      gradleModule: ":order-app"
```

---

## 🚀 快速开始

### 启动 proto-design 工作流
```bash
# BMAD CLI（推荐）
bmad run proto-design --domain=order

# 或手动触发（在 BMAD 环境中）
workflow execute apihug-proto-design
```

### 启动 app-implement 工作流
```bash
bmad run app-implement --domain=order
```

### 运行端到端验证
```bash
bmad run end-to-end --domain=order
```

### 执行项目评审
```bash
bmad run project-review --domain=order
```

---

## ⚠️ 常见陷阱

### ❌ 不要这样做
1. **修改 `_api_/` 或 `_domain_/` 目录中的代码**
   - 下次 `stub` 任务会覆盖你的修改

2. **硬编码模块名**
   - ❌ `./gradlew :order-app-proto:build`
   - ✅ 使用变量 `{module_gradle_module}`

3. **假设 proto/app 是分离的模块**
   - 旧架构已废弃，现在是统一模块

4. **直接修改 `settings.gradle` 添加模块**
   - 应该通过 `config.yaml` 管理域配置

### ✅ 正确做法
1. **扩展 Repository 功能**
   - 在 `src/main/trait/` 创建自定义接口
   - 例如：`UserRepositoryCustom.java`

2. **实现业务逻辑**
   - 在 `src/main/java/` 创建 `*ServiceImpl.java`
   - 依赖注入生成的接口（来自 `_api_/`）

3. **查看生成代码**
   - IDE 中直接打开 `_api_/` 目录查看
   - **不是**隐藏在 `build/generated-src/`

---

## 📖 进阶参考

### 规范文档
- `proto-design/bible.md` - Proto 设计圣经
- `specs/constant.md` - 枚举和错误码规范
- `specs/domain.md` - 数据库实体规范
- `specs/swagger.md` - API 和 Mock 规范

### 模板文件
- `app-implement/template.md` - Service 实现模板

### 验证清单
- `*/checklist.md` - 各工作流质量检查清单

---

## 🆘 故障排查

### Proto 编译失败
1. 检查 `hope-wire.json` 中 `packageName` 是否与 proto 文件中 `package` 声明一致
2. 检查 proto 文件路径：`src/main/proto/{packageName}/api|domain|infra/`
3. 查看编译错误提示，定位具体 `.proto` 文件和行号

### Stub 生成失败
1. 确保 proto 模块已编译成功（`./gradlew :module:build`）
2. 检查 `hope-wire.json` 配置完整性
3. 验证 Stub 插件版本兼容性

### 应用启动失败
1. 检查 `application.yml` 数据库配置
2. 验证实体类与数据库表结构一致
3. 确认所有 Service 接口都已实现

---

## 💡 最佳实践

1. **契约优先**：先设计 proto，再实现业务
2. **增量开发**：一个 API 完成后再开发下一个
3. **及时验证**：每完成一个功能立即运行 end-to-end
4. **定期评审**：里程碑节点执行 project-review
5. **遵守约定**：严格遵循 Source Set 目录职责分离

---

**版本**：2025-12-31  
**维护者**：ApiHug Team
