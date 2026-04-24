# 领域战术设计目录说明

本目录用于存放各一级业务大域的 DDD 战术设计文档。目录按**大域**组织，而不是按平铺 Bounded Context 组织。

## 当前目录

当前已落目录：

- `<domain>`

项目级领域规则文档：

- `domain-design-rules.md`

## 目录定位

本目录主要解决：

- 某个大域内部有哪些子域 / BC。
- 聚合根、实体、值对象如何划分。
- 命令、事件、查询如何定义。
- 领域规则、UML、领域架构、物理模型如何落文档。

本目录不负责：

- 产品范围定义。
- 全系统 Context Map。
- 项目级架构选型。
- Epic / Story 拆解。

这些内容分别回到：

- `docs/planning-artifacts/prd.md`
- `docs/planning-artifacts/context-map.md`
- `docs/planning-artifacts/architecture.md`
- `docs/planning-artifacts/epics.md`

## 标准大域文档包

每个大域目录下标准上应保留：

- `tactical-design.md`
- `01-events-commands-terms.md`
- `02-domain-rules.md`
- `03-uml.md`
- `04-glossary.md`
- `05-architecture.md`
- `06-physical-data-model.md`

可选目录：

- `decisions/`

默认不要求：

- `diagrams/`
- SVG 渲染图

## 各文件分别做什么

### `tactical-design.md`

大域战术设计主文，负责收敛：

- 领域边界。
- 子域 / BC 归属。
- 聚合划分。
- Application Service / Domain Service。
- 入站 / 出站事件。
- Command / Query 主面。
- 关键约束。
- Phase 2 演进。
- 待确认项。

它是整套文档的主事实来源。

### `01-events-commands-terms.md`

把事件、命令、查询、领域名词整理成标准表格，便于后续 Story 与接口设计引用。

### `02-domain-rules.md`

沉淀领域规则、校验条件、状态限制和触发结果。

### `03-uml.md`

表达大域内部的结构模型。要求先给“子域建模总览”，再给关系说明表和 Mermaid 图。

### `04-glossary.md`

统一大域语言，只收业务词汇，不收技术类名。

### `05-architecture.md`

描述大域内部的领域架构，不替代项目级 `architecture.md`。

### `06-physical-data-model.md`

描述该大域的物理数据模型，包括 Mermaid ER、核心表、字段、索引和落库约束。

## 主文与标准件关系

当前采用“主文 + 标准件”结构：

- `tactical-design.md` 是主文。
- `01~06` 是派生标准件。

规则是：

1. 先改主文。
2. 再同步 `01~06`。
3. 再做一致性审查。

不允许长期只改标准件而不回写主文。

## Mermaid 规则

对于 `03-uml.md` 和 `06-physical-data-model.md`，当前统一要求：

- 文档内保留 Mermaid 源码。
- 不要求渲染 SVG。
- 不要求文内图片。
- 不要求 `diagrams/` 目录。

如果项目后续需要额外产图，可在项目内另行约定，但不属于当前 skill 的标准完成态。

## 写作边界

适合写进 `domains/<domain>/` 的内容：

- 聚合、实体、值对象。
- 事件、命令、查询。
- 领域规则。
- 子域划分。
- 领域内 UML。
- 领域内架构。
- 领域物理模型。

不适合写进 `domains/<domain>/` 的内容：

- 产品目标与范围。
- 一级业务大域划分。
- 全系统战略边界。
- 项目级模块矩阵。
- 全局技术选型与部署架构。

这些内容分别回到：

- `prd.md`
- `context-map.md`
- `architecture.md`

## 建议阅读顺序

1. `context-map.md`
2. 目标大域的 `tactical-design.md`
3. `03-uml.md`
4. `05-architecture.md`
5. `06-physical-data-model.md`
6. `01-events-commands-terms.md`
7. `02-domain-rules.md`
8. `04-glossary.md`
