# Frontend Review Checklist

Use this checklist before marking any frontend task complete in `apihug-dev-story`.

This checklist is for final verification. The canonical rules still live in `{project-root}/_bmad/apihug/rules/apihug-impl-front-vben-guide.md`.

## Global Checks

- The implementation still follows `{project-root}/_bmad/apihug/rules/apihug-impl-front-vben-guide.md`.
- The selected page pattern still matches the actual page shape.
- Generated services are used instead of `requestClient`, `axios`, or handwritten API wrappers.
- `RequestSchema` still drives forms and search forms where applicable.
- `ResponseSchema` still drives table columns where applicable.
- Route metadata still follows the `defineOptions({ name, meta })` contract.
- No hard-coded user-visible text exists outside static `defineOptions().meta.title`.
- No `tFallback(...)` or equivalent fallback helper appears in new page code.
- Every selected schema key used by the page resolves in every supported locale.
- No borrowed Vben example or playground pattern introduced API or paging conventions that conflict with the canonical guide.

## `LIST_GRID` And `TREE_WORKBENCH`

- Search lives in `formOptions`, not `gridOptions.formConfig`.
- Paging converts with `page.currentPage - 1` exactly once.
- Sortable headers appear only for verified backend-sortable fields.
- Pageable sortable grids pass `PageRequest.sort`.
- Non-pageable or tree endpoints do not expose fake sortable UI.
- Tree maintenance uses a non-pageable tree or list SDK call.
- Hierarchy-preserving row actions such as create-child or append are present when required.
- Action columns do not clip required actions.

## `FORM_SCHEMA`

- Field rules, defaults, dependencies, and `valueFormat` are intentional.
- Form schema patches happen in page code, not by editing generated schema files.
- Backend-managed business-code fields are not editable in normal create/edit forms.
- Reference fields use selectors, tree selectors, or lookup modals instead of typed IDs.
- Parent selection uses a hierarchy-aware selector when required.

## `MODAL_FLOW` And `DRAWER_FLOW`

- `connectedComponent`, `setData`, `getData`, and open lifecycle usage are consistent.
- Submit lifecycle uses `lock()` and `unlock()` when async confirmation or async submit is involved.
- Modal or drawer choice matches the actual complexity of the interaction.

## `DETAIL_PRESENTATION` And `LOOKUP_MODAL`

- Read-only presentation is intentional and not a hidden editable form.
- Long-text handling improves readability instead of hiding critical data.
- Lookup modal behavior remains read-only and in-place.
- Any embedded raw `Table` remains read-only with no pagination, actions, search, or mutation.

## `UPLOAD_IMPORT`, `DIAGNOSTIC_PANEL`, `RESULT_STATE`, And `STEPPED_FLOW`

- Upload surfaces use `Upload` plus approved follow-up grid behavior.
- Diagnostic panels use `useVbenForm` unless a justified complex-control exception exists.
- Loading, empty, alert, result, and fallback states use approved primitives instead of custom CSS panels.
- Stepped workflows use `Steps` only when the interaction is genuinely staged.

## `ACCESS_CONTROL`

- Access control stays in UI visibility or interaction points only.
- Backend authorization logic is not duplicated in frontend code.

## `THEME_ICON`

- Theme and icon changes stay within the established product language.
- Styling remains local and does not introduce page-level deep overrides or custom CSS control of component internals.

## Final Stop Check

Reject the implementation if any canonical failure mode is present, especially:

- page-local style blocks or deep overrides
- page-level `proxyConfig.response` overrides
- raw typed-ID reference fields
- hierarchy maintenance implemented as a flat pageable table
- continuing after detecting missing lookup/tree/i18n/business-code contracts
