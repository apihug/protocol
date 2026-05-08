# Phase: Frontend Implementation

> Execute frontend tasks for the Vben Admin app following ApiHug UI patterns.

---

## Prerequisites

- `## Backend Phase Completed` marker MUST exist in Dev Agent Record
- If not present, HALT: "Backend must be completed before frontend phase"

---

<workflow>

  <critical>FOLLOW STORY FILE FRONTEND TASKS SEQUENCE EXACTLY</critical>
  <critical>Execute continuously without pausing until all frontend tasks are complete or explicit HALT condition</critical>

  <!-- ==================== -->
  <!-- STEP 11: CONTEXT     -->
  <!-- ==================== -->

  <step n="11" goal="Load frontend context">
    <action>Verify "## Backend Phase Completed" exists in Dev Agent Record; if not, HALT</action>
    <action>Load {ui_config} (ui.yml) and {app_apis_config} (apis.yml)</action>

    <!-- Determine frontend app -->
    <check if="{frontend_app} NOT specified">
      <action>Load available apps from {frontend_target_ui_module_apps}</action>
      <check if="apps_count == 0"><output>Configure frontend_app in project.yaml</output><action>HALT</action></check>
      <check if="apps_count == 1"><action>Auto-select single app</action></check>
      <check if="apps_count > 1"><ask>Select app number or name:</ask></check>
    </check>

    <action>Re-resolve paths: app_path, app_apis_config, views_dir, components_dir, stores_dir</action>
    <action>Scan existing code: views, components, stores</action>
    <output>Frontend Context: UI Module={{frontend_ui_module}}, App={{frontend_app}}, Domain SDK={{domain_sdk_module}}</output>
  </step>

  <!-- ==================== -->
  <!-- STEP 12: IMPLEMENT   -->
  <!-- ==================== -->

  <step n="12" goal="Implement frontend task">

    <action>Load COMPLETE rule file: {apihug_impl_front_vben_guide}</action>
    <critical>HALT if ANY MANDATORY rule violated - See rules file MANDATORY EXECUTION RULES section</critical>
    <critical>`vben-expert` MUST be invoked for ALL frontend tasks in this phase. Do not treat it as optional.</critical>
    <action>Invoke the `vben-expert` skill as the secondary router for Vben component behavior, UI composition, and reference selection</action>
    <critical>PRE-WRITE CHECK: LIST_PAGE? -> Check rules PAGE PATTERNS -> LIST_PAGE</critical>
    <critical>PRE-WRITE CHECK: FORM_PAGE? -> Check rules PAGE PATTERNS -> FORM_PAGE</critical>
    <critical>PRE-WRITE CHECK: DETAIL_PAGE? -> Check rules PAGE PATTERNS -> DETAIL_PAGE</critical>

    <action>Identify first incomplete FRONTEND task</action>
    <check if="no incomplete frontend tasks"><goto step="15">Frontend completion</goto></check>

    <action>Determine task type: "list page"/"query" -> LIST_PAGE; "form page"/"add/edit" -> FORM_PAGE; "detail page"/"view" -> DETAIL_PAGE; "component" -> COMPONENT</action>
    <action>Check story Dev Notes for explicit frontend sub-mode hints, per-task UI behavior notes, or Vben reference expectations for the current frontend task</action>
    <action if="explicit frontend sub-mode hints exist for the current task">Use those hints as the primary source for `frontend_sub_modes[]`</action>
    <action if="explicit frontend sub-mode hints do NOT exist for the current task">Determine one or more frontend sub-modes from the current task and intended UI behavior:
      - table/grid/search/columns/tree/custom cell/toolbar -> LIST_GRID
      - field/schema/rules/validation/dependencies/valueFormat -> FORM_SCHEMA
      - detail/read-only/description/overview/long text display -> DETAIL_PRESENTATION
      - modal/dialog/popup lifecycle -> MODAL_FLOW
      - drawer/side panel lifecycle -> DRAWER_FLOW
      - alert/confirm/prompt/lightweight confirmation -> ALERT_PROMPT
      - ellipsis/tooltip/expand/overflow text -> ELLIPSIS_TEXT
      - authority/access/permission/button visibility -> ACCESS_CONTROL
      - icon/theme/style/look and feel -> THEME_ICON
      - nearest example or analogous business module needed -> PLAYGROUND_ANALOG
    </action>
    <action>Store the result as `frontend_sub_modes[]` and allow multiple matches for the same task, such as `LIST_GRID + MODAL_FLOW + ACCESS_CONTROL`</action>
    <action>Use `vben-expert` to route the current frontend sub-modes to the minimal required references before writing code</action>
    <critical>Priority order for decisions: `apihug-impl-front-vben-guide` -> `vben-expert` -> selected reference docs, demos, and playground files</critical>
    <critical>Never inherit API, SDK, paging, or request-client conventions from generic Vben demos or playground source</critical>

    <check if="task type == LIST_PAGE">
      <action>Generate: List page with useVbenVxeGrid, proxyConfig.ajax.query, page index conversion (currentPage - 1)</action>
    </check>

    <check if="task type == FORM_PAGE">
      <action>Generate: Form modal or page with useVbenForm, and when modal is used include modalApi.lock()/unlock()</action>
    </check>

    <check if="task type == DETAIL_PAGE">
      <action>Generate: Detail view with hideInMenu: true, data loading in onMounted, and explicit handling for long-text/detail presentation when needed</action>
    </check>

    <check if="task type == COMPONENT">
      <action>Generate: {components_dir}/{{ComponentName}}.vue with Props/Events and sub-mode-specific Vben behavior across all matched frontend sub-modes</action>
    </check>
  </step>

  <!-- ==================== -->
  <!-- STEP 13: GENERATE    -->
  <!-- ==================== -->

  <step n="13" goal="Generate routes and menus">
    <action>Execute: gradlew :{frontend_ui_module}:ui</action>
    <action>Verify: {router_dir}/*.ts, {menus_dir}/*.ts generated</action>
  </step>

  <!-- ==================== -->
  <!-- STEP 14: VALIDATE    -->
  <!-- ==================== -->

  <step n="14" goal="Validate and mark frontend task complete">
    <action>Verify Vue files exist with correct defineOptions and generated Service imports</action>
    <action>Load and apply `vben-expert/references/review-checklist.md` for all current frontend sub-modes before marking task complete</action>
    <action>Verify current implementation still follows `apihug-impl-front-vben-guide` for generated services, schema mapping, paging contract, route metadata, and menu generation boundaries</action>
    <action if="task type == LIST_PAGE">Verify search form is in `formOptions`, not `gridOptions.formConfig`, and that grid behavior matches all selected Vben sub-modes</action>
    <action if="task type == FORM_PAGE">Verify field rules, dependencies, valueFormat, and submit lifecycle match all selected Vben sub-modes</action>
    <action if="frontend_sub_modes contains MODAL_FLOW OR frontend_sub_modes contains DRAWER_FLOW">Verify `setData/getData`, `onOpenChange`, and submit `lock/unlock` lifecycle are correct</action>
    <action if="frontend_sub_modes contains ALERT_PROMPT">Verify lightweight prompts are used only for lightweight confirmation/input, not as a hidden replacement for full modal forms</action>
    <action if="frontend_sub_modes contains ELLIPSIS_TEXT OR frontend_sub_modes contains DETAIL_PRESENTATION">Verify long text handling uses truncation, tooltip, or expand behavior intentionally and does not break table or detail readability</action>
    <action if="frontend_sub_modes contains ACCESS_CONTROL">Verify access behavior is implemented in UI visibility/control points only and does not drift into backend authorization logic</action>
    <action>Verify any borrowed playground or example pattern was used only for UI composition and did not copy generic API layer conventions into APIHug feature code</action>
    <action>Run: pnpm lint (if configured)</action>
    <action if="lint fails">STOP and fix</action>

    <action>Mark frontend task checkbox [x]; update File List; save story</action>
    <check if="more frontend tasks"><goto step="12">Next frontend task</goto></check>
  </step>

  <!-- ==================== -->
  <!-- STEP 15: PHASE DONE  -->
  <!-- ==================== -->

  <step n="15" goal="Frontend phase completion">
    <action>Verify ALL frontend tasks marked [x]</action>
    <action>Add to Dev Agent Record:
      ## Frontend Phase Completed
      **Date**: {{date}}
      **Vue Pages**: {{page_count}}
      **Components**: {{component_count}}
    </action>
    <action>Update story Status to "review"</action>
    <check if="{sprint_status} file exists AND {{current_sprint_status}} != 'no-sprint-tracking'">
      <action>Update sprint-status: development_status[{{story_key}}] = "review"</action>
    </check>
  </step>

</workflow>

---

## NEXT

Read fully and follow: `./phase-complete.md` for final completion.
