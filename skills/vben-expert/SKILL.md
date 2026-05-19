---
name: vben-expert
description: Use when implementing or refining APIHug Vben Admin frontend pages during story execution and you need Vben-specific routing to the correct page-pattern docs, component docs, access-control references, or safe playground analogs. This skill does not own frontend policy; the canonical frontend guide does.
---

# Vben Expert

## Invocation Contract

This skill is the secondary router for APIHug frontend story execution.

- It MUST be invoked for all frontend tasks inside `apihug-dev-story`.
- It is for code agents designing and implementing frontend pages after the canonical frontend guide has approved the page pattern.
- It routes the task to the minimum Vben references needed for implementation.
- It may select multiple frontend sub-modes for the same task.

## Precedence

Always apply frontend decisions in this order:

1. `{project-root}/_bmad/apihug/rules/apihug-impl-front-vben-guide.md`
2. skill `vben-expert`
3. selected component docs and playground files

If a pattern reference, component doc, or playground example conflicts with the canonical frontend guide, the guide wins.

## Scope

This skill is responsible for:

- selecting the correct Vben component docs
- choosing between modal, drawer, grid, detail, lookup, and workflow presentation styles
- picking the nearest safe playground analog when a business-module reference is helpful
- keeping the implementation aligned with approved Vben behavior

This skill is NOT responsible for:

- SDK ownership
- route or menu generation contracts
- schema source-of-truth rules
- i18n completeness rules
- sort, reference, hierarchy, or business-code contracts
- failure-mode ownership

Those belong to `{project-root}/_bmad/apihug/rules/apihug-impl-front-vben-guide.md`.

## Sub-Mode Routing

Determine one or more frontend sub-modes, then read only the matching references.

| Sub-Mode | Use When | Read |
| --- | --- | --- |
| `LIST_GRID` | pageable list workbench, columns, toolbar, search area | `references/components/vben-vxe-table/docs.md` |
| `TREE_WORKBENCH` | hierarchy maintenance, tree table, create-child action | `references/components/vben-vxe-table/docs.md`, `references/playground/system-dept/` |
| `SPLIT_LAYOUT` | left-right work surface, master-detail layout | `references/playground/system-dept/`, `references/playground/system-menu/` |
| `FORM_SCHEMA` | fields, rules, validation, dependencies, `valueFormat`, schema updates | `references/components/vben-form/docs.md` |
| `MODAL_FLOW` | modal lifecycle, submit locking, row/context handoff | `references/components/vben-modal/docs.md` |
| `DRAWER_FLOW` | drawer lifecycle, side-panel editing, state handoff | `references/components/vben-drawer/docs.md` |
| `DETAIL_PRESENTATION` | detail page, trace view, long text, read-only presentation | `references/components/vben-ellipsis-text/docs.md` when long text is involved |
| `LOOKUP_MODAL` | read-only lookup or inspect-in-place modal | `references/components/vben-modal/docs.md` |
| `UPLOAD_IMPORT` | upload, import preview, uploaded-record follow-up flows | `references/components/vben-vxe-table/docs.md`, `references/playground/file-download/` |
| `DIAGNOSTIC_PANEL` | dry-run, simulation, test panel, result rendering | `references/components/vben-form/docs.md`, `references/components/vben-alert/docs.md` |
| `RESULT_STATE` | alert, result, loading, empty, fallback states | `references/components/vben-alert/docs.md` |
| `STEPPED_FLOW` | staged workflow with ordered steps | `references/components/vben-modal/docs.md`, `references/components/vben-drawer/docs.md` |
| `ACCESS_CONTROL` | route authority, button visibility, `v-access`, `AccessControl` | `references/common/access.md` |
| `THEME_ICON` | icon choice, small visual polish, theme alignment | `references/common/icons.md`, `references/common/theme.md` |
| `PLAYGROUND_ANALOG` | closest business-module interaction analog is useful | `references/playground/system-dept/`, `references/playground/system-menu/`, `references/playground/system-role/`, `references/playground/file-download/` |

## Output Contract

After invoking this skill, the code agent must keep explicit:

- the chosen page pattern from the canonical guide
- the selected frontend sub-modes
- the exact reference files used
- the concrete Vben behavior points that must be applied
- any example pattern that was rejected because it violates the canonical frontend guide

## Task Routing Notes

### `LIST_GRID`, `TREE_WORKBENCH`, `SPLIT_LAYOUT`

Read the VXE component docs first, then a playground analog only if the page shape still needs clarification.

Use this family for:

- list pages
- tree tables
- split pages
- grid-centric search and action flows

Design hints:

- `LIST_GRID`: keep search in `formOptions`, route row actions through one handler, and keep grid lifecycle in the page shell
- `TREE_WORKBENCH`: use non-pageable tree data and expose row-level create-child or append when required
- `SPLIT_LAYOUT`: use a left context surface and a right work surface without inventing custom page-shell layout rules

### `FORM_SCHEMA`, `MODAL_FLOW`, `DRAWER_FLOW`

Read the form or modal/drawer docs directly.

Use this family for:

- create and edit surfaces
- assignment and configuration forms
- schema-driven and semi-structured form work

Design hints:

- `FORM_SCHEMA`: keep schema-driven forms as the default and patch by `fieldName`
- `MODAL_FLOW`: prefer modal for smaller create/edit surfaces with lower contextual load
- `DRAWER_FLOW`: prefer drawer when the interaction benefits from more width or richer side-panel context

### `DETAIL_PRESENTATION`, `LOOKUP_MODAL`

Read the minimal read-only component docs directly.

Use this family for:

- read-only pages
- trace drawers
- lookup inspection
- dashboards and overview surfaces

Design hints:

- treat read-only presentation as read-only, not as a hidden editable form
- use lookup modal only for inspect-in-place flows
- use embedded raw tables only for small read-only summaries

### `UPLOAD_IMPORT`, `DIAGNOSTIC_PANEL`, `RESULT_STATE`, `STEPPED_FLOW`

Read the minimal component docs directly and use playground analogs only when needed.

Use this family for:

- upload and import flows
- diagnostic panels
- state-heavy pages
- stepped user journeys

Design hints:

- `UPLOAD_IMPORT`: keep upload trigger and uploaded-record follow-up handling clearly separated
- `DIAGNOSTIC_PANEL`: use `useVbenForm` by default and extract result rendering when it grows
- `RESULT_STATE`: prefer approved alert/result/loading/empty primitives instead of custom panels
- `STEPPED_FLOW`: use staged workflow primitives only when order genuinely matters

### `ACCESS_CONTROL`

Use `references/common/access.md` for UI visibility and interaction-point access control only.

### `THEME_ICON`

Use `references/common/icons.md` and `references/common/theme.md` for small, local visual decisions inside the existing product language.

### `PLAYGROUND_ANALOG`

Use playground files only as implementation analogs for interaction shape.

Playground code is never the source of truth for:

- API calling
- SDK usage
- paging contracts
- schema ownership
- route/menu contracts

## ApiHug Guardrails

- The canonical guide decides whether a page pattern is allowed.
- The canonical guide owns shared-infrastructure, i18n, sort, reference, hierarchy, and business-code contracts.
- `vben-expert` routes references only after those contracts have been checked.
- Do not copy `#/api/*`, `requestClient`, or generic request wrappers from demos or playgrounds.
- Prefer generated `RequestSchema` and `ResponseSchema` first, then page-level patches.
- Use pattern docs to shape code, not to bypass guide-level constraints.

## Completion Gate

Before marking a frontend task complete:

1. Apply `references/review-checklist.md`.
2. Re-check the failure modes in `{project-root}/_bmad/apihug/rules/apihug-impl-front-vben-guide.md`.
3. Confirm the implementation still follows the canonical guide.
