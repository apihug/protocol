# Project Bootstrap Rules

用于空项目或尚未建立 `docs/planning-artifacts/domains/` 的项目初始化。

本文件只定义“何时创建、创建哪些路径、如何处理已有文件”。文件内容结构以 `references/output-contract.md` 为准，具体落盘内容使用 `templates/` 下的模板。

## 最低初始化范围

若以下路径不存在，则补齐：

- `docs/`
- `docs/planning-artifacts/`
- `docs/planning-artifacts/domains/`
- `docs/planning-artifacts/domains/README.md`
- `docs/planning-artifacts/domains/domain-design-rules.md`
- `docs/planning-artifacts/domains/<domain>/`

不再要求创建：

- `docs/planning-artifacts/domains/<domain>/diagrams/`

## 初始化原则

1. 只补缺，不覆盖已有项目内容。
2. 使用 skill 自带模板生成 README 和项目本地规则副本。
3. `domain-design-rules.md` 是项目可编辑副本，用于本项目覆盖。
4. 若项目已有同名文件，保留原文件；除非用户明确要求吸收或重写。
5. Bootstrap 只建立项目级入口和目标大域目录，不预先创建空的 `01~06` 文件。

## 模板映射

- `docs/planning-artifacts/domains/README.md`
  - 使用 `templates/domains-readme-template.md`
  - 固定结构见 `references/output-contract.md`
- `docs/planning-artifacts/domains/domain-design-rules.md`
  - 使用 `templates/project-domain-design-rules-template.md`
  - 固定结构见 `references/output-contract.md`

## 领域目录的最小文件集

目标大域目录最终应能承载：

- `tactical-design.md`
- `01-events-commands-terms.md`
- `02-domain-rules.md`
- `03-uml.md`
- `04-glossary.md`
- `05-architecture.md`
- `06-physical-data-model.md`

Bootstrap 阶段不要求先创建空文件，可按实际生成时再落盘。
