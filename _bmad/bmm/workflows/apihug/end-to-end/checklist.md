# End-to-End Pipeline Checklist

## 1. 应用启动（自动触发 wire）

- [ ] 命令 `./gradlew {module_gradle_module}:bootRun` 启动成功
- [ ] Wire 任务自动执行完成（日志中可见）
- [ ] `{module_path}/src/generated/main/wire/` 生成 Wire DTOs
- [ ] `{module_path}/src/generated/main/api/` 生成 Controllers、Service 接口
- [ ] `{module_path}/src/generated/main/domain/` 生成实体类
- [ ] 应用监听端口（默认 18899）正常
- [ ] 日志中无严重错误（ERROR 级别）
- [ ] Active Profile 与预期一致（如 `dev`）

## 2. OAS 与元数据验证

### 2.1 OAS 文档

- [ ] `http://localhost:18899/v3/api-docs` 可访问
- [ ] API 路径（paths）与 proto 定义相符
- [ ] HTTP 方法正确（GET/POST/PUT/DELETE/PATCH）
- [ ] 请求/响应 Schema 字段完整、类型正确
- [ ] 枚举值、约束（format/min/max 等）正确

### 2.2 错误码

- [ ] `http://localhost:18899/hope/meta/errors` 可访问
- [ ] 所有错误码有唯一 code
- [ ] message / message2 填写完整
- [ ] HTTP 状态码、错误分类、严重程度合理

### 2.3 权限 / 字典 / 版本

- [ ] `http://localhost:18899/hope/meta/authorities` 可访问且与 `authority_enum_class` 一致
- [ ] `http://localhost:18899/hope/meta/dictionaries` 可访问（如有字典）
- [ ] `http://localhost:18899/hope/meta/versions` 可访问，版本信息正确

## 3. API 功能验证

- [ ] 至少验证 1~2 条核心业务 API 的成功路径
- [ ] 至少验证 1~2 个典型错误场景（校验失败、无权限、对象不存在等）
- [ ] 返回的错误码与 proto 中定义一致
- [ ] 返回体结构与 OAS/DTO 定义一致

## 4. 测试执行

- [ ] 命令 `./gradlew {module_gradle_module}:test` 执行成功
- [ ] 所有测试通过（无 FAIL）
- [ ] 测试报告存在：`{module_path}/build/reports/tests/test/`
- [ ] 覆盖率达到团队标准（例如 80%+），如有覆盖率报告

## 5. 端到端结果总结

- [ ] 应用启动通过（Wire 任务自动执行）
- [ ] OAS 文档验证通过
- [ ] API 功能验证通过
- [ ] 错误码/权限/字典/版本信息正确
- [ ] 单元测试/集成测试通过

---

> 建议在重要发布前完整跑一遍本清单，并保留执行记录（如截图或报告链接）。
