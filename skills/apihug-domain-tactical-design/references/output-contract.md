# Domain Tactical Design Output Contract

本文件定义 `apihug-domain-tactical-design` 的稳定输出格式。

## 总体要求

- 输出必须由规则驱动，不由历史目录驱动。
- `tactical-design.md` 是主事实来源。
- `tactical-design.md` 必须先经过主文建模收敛，再允许派生标准件。
- `01~06` 必须由主文派生。
- 若 `01~06` 审查中暴露出主文缺口，必须先回写 `tactical-design.md`，再重新同步标准件。
- `03` 与 `06` 只要求保留 Mermaid 源，不要求渲染图片。
- 文档中不再引入 SVG，不再要求 `diagrams/`。
- 对后续 Epic / Story 的影响，应通过 `architecture.md` 中登记的大域入口与 readiness 信号体现。
- 本 skill 负责战术建模，不直接产出代码目录树、package tree 或 source-set 结构。
- 本 skill 不重做战略设计，也不静默重划已锁定的大域或 BC。

## 文档骨架

### `tactical-design.md`

固定顺序：

1. 领域边界与职责
2. 聚合与建模决策
3. Application Service / Domain Service
4. 入站事件 / 出站事件
5. Command / Query 主面
6. 关键约束
7. 与 source 对齐后的建模解释
8. Phase 2 演进
9. 待确认项

要求：

- frontmatter 中 `sources:` 只记录实际采用的输入
- frontmatter 中必须包含：
  - `reviewStatus.round0StructureCompleteness`
  - `reviewStatus.round1SourceAlignment`
  - `reviewStatus.round2DDDConsistency`
  - `reviewStatus.round3ImplementationReadiness`
  - `reviewStatus.lastReviewedAt`
  - `reviewStatus.reviewNotes`
  - `finalizationLevel`
  - `epicStoryReadiness`
  - `architectureIndexSynced`
- 必须显式反映主文建模后的收敛结果，而不是模板占位摘要
- 若 source 存在冲突但暂不可解，必须在“待确认项”中留下人工判定入口

字段约束：

- `reviewStatus.round1SourceAlignment` 取值：`pending / passed / failed`
- `reviewStatus.round0StructureCompleteness` 取值：`pending / passed / failed`
- `reviewStatus.round2DDDConsistency` 取值：`pending / passed / failed`
- `reviewStatus.round3ImplementationReadiness` 取值：`pending / passed / failed`
- `finalizationLevel` 取值：`Draft / Ready With Gaps / Final Baseline`
- `epicStoryReadiness` 取值：`Blocked / Conditional / Ready`
- `architectureIndexSynced` 取值：`true / false`

### `01-events-commands-terms.md`

固定顺序：

1. 事件
2. 命令
3. 查询
4. 领域名词

### `02-domain-rules.md`

必须只有一张规则主表，至少包含：

- 序号
- 规则编号
- 类别
- 规则
- 触发条件
- 结果
- 来源

### `03-uml.md`

固定顺序：

1. 模型说明
2. 关系说明表
3. 类图
4. 事件协作图
5. 状态图（仅在确有生命周期时）
6. UML 一致性自检

规则：

- 先给“子域建模总览”表，至少包含：
  - 子域
  - 聚合根
  - 实体
  - 值对象 / 枚举
  - 说明
- 类图必须按子域分组
- 类图节点默认使用 `English(中文)` 显示
- 只允许出现：
  - 聚合根
  - 实体
  - 值对象
  - 枚举（可选）
- 默认不放：
  - Domain Service
  - Application Service
  - Repository
  - Adapter
  - 流程节点

基数规则：

- 只允许 `0..1`、`1..1`、`0..*`、`1..*`
- 表格双侧写法统一为 `1..1 : 0..*`

一致性自检必须覆盖：

- 子域建模总览中的聚合根、实体、值对象均来自 `tactical-design.md`
- 关系说明表中的对象均出现在类图或建模说明中
- 类图中的每条结构线均能回溯到关系说明表
- Mermaid classDiagram 语法已人工检查为可渲染

### `04-glossary.md`

至少包含：

- 中文术语
- English
- 简称
- 描述

### `05-architecture.md`

固定顺序：

1. 领域职责
2. 聚合划分
3. 分层职责
4. 上下游关系
5. 架构约束
6. 实现提示（可选）

### `docs/planning-artifacts/architecture.md`

不是标准件之一，但属于本 skill 的必须同步产物。

至少应同步：

1. 该大域的战术设计路径
2. 该大域覆盖的 BC / 子域范围
3. 当前状态，如 `Planned / Draft / Ready With Gaps / Final Baseline`
4. 是否可进入 Epic / Story 拆解
5. 必要时给出简短的拆解入口说明

必须在 `architecture.md` 中使用固定表头：

- `Macro Domain`
- `Status`
- `Tactical Design Doc`
- `Coverage`
- `Epic/Story Readiness`
- `Story Decomposition Rule`
- `Notes`

### `06-physical-data-model.md`

固定顺序：

1. 物理模型图
2. 关系说明
3. 核心表设计
4. 字段明细
5. 索引设计
6. 状态与数据约束
7. 生命周期与清理策略
8. 落库说明
9. 待确认事项

规则：

- 物理模型图使用 Mermaid ER
- 只出现可落库对象
- 默认按逻辑外键表达跨 BC 关联

## 完成态

一套大域战术设计文档的完成态至少满足：

- 主文完成并通过 Structure Completeness + 三轮审查
- `01~06` 全部存在
- `03/06` 保留 Mermaid 源
- 关键边界、规则、事件、聚合和落库结论一致
- 剩余待确认项不阻塞后续 Story 拆解
- `01~06` 中不存在“主文未声明、标准件单独成立”的关键设计事实
- `architecture.md` 中已登记该大域的路径、状态与 readiness 信息
- 主文 frontmatter 中的结构化状态字段与实际完成态一致

正式宣布定稿时，还应参考：

- `references/finalization-standard.md`
