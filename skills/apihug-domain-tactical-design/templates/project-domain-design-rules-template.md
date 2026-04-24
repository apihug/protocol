# Domain Design Rules

本文用于规范 `docs/planning-artifacts/domains/` 下的大域战术设计文档产出、审查、派生和维护。

## 一、适用范围

适用于：

- 已进入正式战术设计，并将继续进入 Epic / Story / Code 实现的大域。
- 需要输出 `tactical-design.md` 与 `01~06` 标准件的大域。
- 需要在 BMAD 主流程下持续维护的领域文档。

不强制适用于：

- 临时探索性草稿。
- 尚未确认边界的分析稿。
- 纯技术实现细节文档。

## 二、目录约束

每个大域固定目录：

`docs/planning-artifacts/domains/<domain>/`

固定文件：

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

## 三、主文与标准件关系

### 1. `tactical-design.md`

定位：

- 大域战术设计主文。
- 大域级主事实来源。
- AI 建立上下文的首要入口。

必须覆盖：

- 领域边界与职责。
- 聚合与建模决策。
- Application Service / Domain Service。
- 入站事件 / 出站事件。
- Command / Query 主面。
- 关键约束。
- 与 source 对齐后的建模解释。
- Phase 2 演进。
- 待确认项。

### 2. `01~06`

定位：

- 标准化交付件。
- 面向评审、协作、归档、审计。

要求：

- 从 `tactical-design.md` 派生。
- 不得独立发散。
- 不得引入未被 source 或主文支持的新设计事实。

## 四、标准件职责

- `01-events-commands-terms.md`：事件、命令、查询、领域名词。
- `02-domain-rules.md`：领域规则、一致性规则、生命周期规则、规则来源。
- `03-uml.md`：子域建模总览、关系说明、类图、事件协作图、必要的状态图。
- `04-glossary.md`：统一领域语言、中英映射、简称、描述。
- `05-architecture.md`：大域职责、聚合划分、分层职责、上下游关系、架构约束、必要实现提示。
- `06-physical-data-model.md`：Mermaid ER、核心表设计、字段明细、索引设计、状态与数据约束、生命周期与清理策略、落库说明、待确认事项。

细节格式以 skill 的 `references/output-contract.md` 为准。

## 五、核心设计约束

- 不重划 `context-map.md` 已锁定的大域和 Bounded Context。
- `tactical-design.md` 是大域战术设计的主事实源。
- `01~06` 必须从 `tactical-design.md` 派生。
- source 不足时必须写入“待确认项”，不得补脑。
- 战术设计只做业务建模、规则、事件、聚合和落库约束，不直接产出代码目录树、package tree 或 source-set 设计。
- 多租户隔离由框架层注入和过滤，`tenant_id` 不允许被业务输入覆盖。
- 跨大域协作优先使用事件、命令契约、Published Language 或框架能力。
- 不允许跨大域共享 Repository 或直接访问其它大域内部表。

## 六、更新流程

1. 先改 `tactical-design.md`。
2. 再同步 `01~06`。
3. 再做一致性审查。
4. 必要时回写 `architecture.md` 中的大域战术设计路径索引。

禁止：

- 先改 `01~06` 再倒推主文。
- 只改局部文档不回写主文。
- 改完后不做一致性审查。

补充：

- 若在 `01~06` 审查中发现主文遗漏、冲突或表达不足，必须反向修订 `tactical-design.md`。
- 不允许长期保留“主文未声明、标准件单独补出”的关键设计事实。

## 七、审查规则

每次至少完成以下审查：

- Round 0: Structure Completeness
- Round 1: Source Alignment
- Round 2: DDD Consistency
- Round 3: Implementation Readiness

项目级规则只保留审查入口。详细检查项以 skill 的 `references/review-checklist.md` 为准。

## 八、定稿标准

当前大域的定稿等级只能是：

- `Draft`
- `Ready With Gaps`
- `Final Baseline`

若正式上游为 `Ready With Gaps`，当前大域 `finalizationLevel` 不得高于 `Ready With Gaps`。

详细判定条件以 skill 的 `references/finalization-standard.md` 为准。

## 九、与后续流程关系

- `architecture.md` 应登记大域战术设计路径。
- 后续 workflow 如 `bmad-create-epics-and-stories` 可基于 `architecture.md` 自动索引并载入相关大域战术设计。
- Story 文件应引用相关大域 `tactical-design.md` 作为设计来源。
