# ApiHug Dev Story Workflow

**Goal:** Execute ApiHug story implementation (backend + optional frontend) following a BMAD story spec file with Contract-First proto design.

**Your Role:** Developer implementing the story.
- Communicate all responses in {communication_language} and language MUST be tailored to {user_skill_level}
- Generate all documents in {document_output_language}
- Only modify the story file in these areas: Tasks/Subtasks checkboxes, Dev Agent Record (Debug Log, Completion Notes), File List, Change Log, and Status
- Execute ALL steps in exact order; do NOT skip steps
- Absolutely DO NOT stop because of "milestones", "significant progress", or "session boundaries". Continue in a single execution until the story is COMPLETE (all ACs satisfied and all tasks/subtasks checked) UNLESS a HALT condition is triggered or the USER gives other instruction.
- Do NOT schedule a "next session" or request review pauses unless a HALT condition applies.
- User skill level ({user_skill_level}) affects conversation style ONLY, not code updates.

---

## WORKFLOW ARCHITECTURE

This uses **step-file architecture** for focused execution:

- Each phase loads fresh to combat "lost in the middle"
- State persists via INITIALIZATION variables below
- Sequential progression: Discover → Backend → Frontend (optional) → Complete

---

## INITIALIZATION

### Configuration Loading

Load config from `{project-root}/_bmad/bmm/config.yaml` and resolve:

- `project_name`, `user_name`
- `communication_language`, `document_output_language`
- `user_skill_level`
- `implementation_artifacts`
- `planning_artifacts`
- `date` as system-generated current datetime

### Paths

- `story_file` = `` (explicit story path; auto-discovered if empty)
- `sprint_status` = `{implementation_artifacts}/sprint-status.yaml`

### Context

- `project_context` = `**/project-context.md` (load if exists)

### Domain Selection (Backend)

> This yaml contains the project's module structure, dependencies and relationships

- `project_structures` = `{project-root}/docs/project.yaml`
- `domains_all` = `{project_structures}:domains`
- `domain` = `{context.domain || auto_select_or_prompt(domains_all)}`
- `architecture` = `{planning_artifacts}/architecture.md`

#### Module (unified architecture: proto + generated + handwritten)

- `domain_module` = `{project_structures}:details:{domain}`
- `module_path` = `{domain_module}:path`
- `module_gradle_module` = `{domain_module}:gradleModuleName`

### Frontend Configuration (Phase 2)

- `frontend_enabled` = `{domain_module}:hasFront`
- `frontend_ui_module` = `{domain_module}:ui_module`
- `frontend_target_ui_module_apps` = `{project_structures}:details:{frontend_ui_module}:{appDirs}`
- `frontend_app` = `{domain_module}:frontend_app` (if absent, prompt choice from `{frontend_target_ui_module_apps}`)

### Wire Configuration

- `hope_wire` = `{module_path}/src/main/resources/hope-wire.json`
- `package_name` = `{hope_wire}:packageName`
- `package_path` = `convert_dots_to_slashes({package_name})`
- `java_path` = `{module_path}/src/main/java/{package_path}`
- `module_name` = `{hope_wire}:name`
- `domain_name` = `{hope_wire}:domain`
- `application_name` = `{hope_wire}:application`
- `apiRoot` = `{hope_wire}:apiRoot`

### Backend Paths

- `meta_index` = `{module_path}/src/main/resources/apihug.idx.csv`
- `rules` = `{project-root}/_bmad/rules/rules.csv`
- `rules_path` = `{project-root}/_bmad/rules`

#### Proto Paths

- `proto_output_root` = `{module_path}/src/main/proto/{package_path}`
- `proto_api_path` = `{proto_output_root}/api`
- `proto_domain_path` = `{proto_output_root}/domain`
- `proto_infra_path` = `{proto_output_root}/infra`

#### Implementation Paths

- `impl_path` = `{module_path}/src/main/java`
- `trait_path` = `{module_path}/src/main/trait/t`
- `test_path` = `{module_path}/src/test/java`

### Frontend Paths (Phase 2, loaded when `frontend_enabled=true`)

- `ui_path` = `{project-root}/{frontend_ui_module}`
- `ui_config` = `{ui_path}/ui.yml`
- `app_path` = `{ui_path}/apps/{frontend_app}`

#### API Dependencies

- `app_apis_config` = `{app_path}/apis.yml`
- `primary_api` = `{app_apis_config}:[0]`
- `domain_service_root` = `{ui_path}/{primary_api}:path`
- `domain_sdk_module` = `{primary_api}:module`

#### Key Index Files

- `apihug_index` = `{domain_service_root}/apihug.idx.csv`

#### App Source Paths (writable)

- `views_dir` = `{app_path}/src/views`
- `components_dir` = `{app_path}/src/components`
- `stores_dir` = `{app_path}/src/store`

#### Generated Code (read-only)

- `router_dir` = `{app_path}/src/router/routes/modules`
- `menus_dir` = `{app_path}/src/menus`

### Rules (reference-only, loaded conditionally during execution)

- `apihug_proto_api_extension_guide` = `{rules_path}/apihug-proto-api-extension-guide.md`
- `apihug_proto_database_modeling_guide` = `{rules_path}/apihug-proto-database-modeling-guide.md`
- `apihug_proto_enum_error_extension_guide` = `{rules_path}/apihug-proto-enum-error-extension-guide.md`
- `apihug_impl_golden_rule` = `{rules_path}/apihug-impl-golden-rule.md`
- `apihug_impl_front_vben_guide` = `{rules_path}/apihug-impl-front-vben-guide.md`

---

## EXECUTION

Read fully and follow: `./steps/phase-discover.md` to begin the workflow.
