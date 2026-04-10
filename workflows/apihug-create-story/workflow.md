# ApiHug Create Story Workflow

**Goal:** Create a comprehensive story file with all the context the dev agent needs for flawless ApiHug implementation.

**Your Role:** Story context engine that prevents LLM developer mistakes, omissions, or disasters.
- Communicate all responses in {communication_language} and generate all documents in {document_output_language}
- Your purpose is NOT to copy from epics - it's to create a comprehensive, optimized story file that gives the DEV agent EVERYTHING needed for flawless implementation
- COMMON LLM MISTAKES TO PREVENT: reinventing wheels, wrong libraries, wrong file locations, breaking regressions, ignoring UX, vague implementations, lying about completion, not learning from past work
- EXHAUSTIVE ANALYSIS REQUIRED: You must thoroughly analyze ALL artifacts to extract critical context - do NOT be lazy or skim!
- UTILIZE SUBPROCESSES AND SUBAGENTS: Use research subagents, subprocesses or parallel processing if available to thoroughly analyze different artifacts simultaneously
- SAVE QUESTIONS: If you think of questions or clarifications during analysis, save them for the end after the complete story is written
- ZERO USER INTERVENTION: Process should be fully automated except for initial epic/story selection or missing documents

---

## INITIALIZATION

### Configuration Loading

Load config from `{project-root}/_bmad/bmm/config.yaml` and resolve:

- `project_name`, `user_name`
- `communication_language`, `document_output_language`
- `user_skill_level`
- `planning_artifacts`, `implementation_artifacts`
- `date` as system-generated current datetime

### Paths

- `sprint_status` = `{implementation_artifacts}/sprint-status.yaml`
- `epics_file` = `{planning_artifacts}/epics.md`
- `prd_file` = `{planning_artifacts}/prd.md`
- `architecture_file` = `{planning_artifacts}/architecture.md`
- `ux_file` = `{planning_artifacts}/*ux*.md`
- `story_title` = `` (will be elicited if not derivable)
- `project_context` = `**/project-context.md` (load if exists)
- `default_output_file` = `{implementation_artifacts}/{{story_key}}.md`

### Rules (reference-only, loaded in Step 5)

- `rules` = `{project-root}/_bmad/rules/rules.csv`
- `rules_path` = `{project-root}/_bmad/rules`
- `apihug_proto_api_extension_guide` = `{rules_path}/apihug-proto-api-extension-guide.md`
- `apihug_proto_database_modeling_guide` = `{rules_path}/apihug-proto-database-modeling-guide.md`
- `apihug_proto_enum_error_extension_guide` = `{rules_path}/apihug-proto-enum-error-extension-guide.md`
- `apihug_impl_golden_rule` = `{rules_path}/apihug-impl-golden-rule.md`
- `apihug_impl_front_vben_guide` = `{rules_path}/apihug-impl-front-vben-guide.md`

### Input Files

| Input | Description | Path Pattern(s) | Load Strategy |
|-------|-------------|------------------|---------------|
| prd | PRD (fallback - epics file should have most content) | whole: `{planning_artifacts}/*prd*.md`, sharded: `{planning_artifacts}/*prd*/*.md` | SELECTIVE_LOAD |
| architecture | Architecture (fallback) | whole: `{planning_artifacts}/*architecture*.md`, sharded: `{planning_artifacts}/*architecture*/*.md` | SELECTIVE_LOAD |
| ux | UX design (fallback) | whole: `{planning_artifacts}/*ux*.md`, sharded: `{planning_artifacts}/*ux*/*.md` | SELECTIVE_LOAD |
| epics | Enhanced epics+stories file | whole: `{planning_artifacts}/*epic*.md`, sharded: `{planning_artifacts}/*epic*/*.md` | SELECTIVE_LOAD |

---

## EXECUTION

<workflow>
  <critical>Communicate all responses in {communication_language} and generate all documents in {document_output_language}</critical>
  <critical>Your purpose is NOT to copy from epics - create comprehensive story context for the DEV agent</critical>
  <critical>COMMON LLM MISTAKES TO PREVENT: reinventing wheels, wrong libraries, wrong file locations, breaking regressions</critical>
  <critical>EXHAUSTIVE ANALYSIS REQUIRED: thoroughly analyze ALL artifacts - do NOT be lazy or skim!</critical>
  <critical>SAVE QUESTIONS: Save for the end after the complete story is written</critical>
  <critical>ZERO USER INTERVENTION: Fully automated except initial epic/story selection or missing documents</critical>

  <!-- ============================================ -->
  <!-- L1: ApiHug Inline Critical Constraints       -->
  <!-- These are embedded in story Dev Notes        -->
  <!-- ============================================ -->

  <!-- Immutable Constraints (ZERO TOLERANCE) -->
  <critical>Source Set: NEVER modify src/generated/ — comments are wire markers</critical>
  <critical>Lombok: FORBIDDEN — write explicit getters/setters/constructors</critical>
  <critical>Onion Architecture: Adapter (ServiceImpl) → Domain (DomainService) → Infrastructure (Repository)</critical>
  <critical>Security: ZERO RBAC code in ServiceImpl/DomainService — proto authorization only</critical>
  <critical>Proto DSL: snake_case for fields; API MUST NOT import domain entities</critical>
  <critical>Request Message Design: 0 params → Empty; 1-2 params → Empty+parameters{}; 3+ params → Message</critical>

  <!-- API Extension Core Constraints -->
  <critical>PROTO: NEVER add `page`, `size`, `sort` to Request Message — use `pageable: true`</critical>
  <critical>PROTO: NEVER wrap response in `PageableXxx` — framework wraps Result&lt;Pageable&lt;T&gt;&gt;</critical>
  <critical>PROTO: NEVER use `string` for enum values — use `EnumType` with full package path</critical>
  <critical>PROTO: NEVER add file-level options (`java_package`, `go_package`) — build system injects</critical>
  <critical>PROTO: NEVER import `domain/` entities in `api/` layer</critical>
  <critical>PROTO: NEVER use SQL reserved words as column names — use prefixes: `user_name`, `order_no`</critical>
  <critical>PROTO: NEVER use relative type references — always use full package path</critical>
  <critical>PROTO: NEVER create Request Message with only 1-2 fields — use `google.protobuf.Empty` + `parameters{}`</critical>
  <critical>PROTO: NEVER create proto message with single repeated field — use `input_repeated`/`output_repeated`</critical>
  <critical>PROTO: NEVER use `DTO` in message names — MUST have real business meaning</critical>
  <critical>PROTO: NEVER put all code in root `api/`, `domain/`, `infra/` — each feature gets sub dir</critical>
  <critical>PROTO: NEVER define INNER message type — all messages at file level</critical>
  <critical>PROTO: NEVER add redundant "ENUM" suffix</critical>

  <!-- Database Modeling Core Constraints -->
  <critical>PROTO: NEVER modify `_full.xml` migration file — auto-generated by wire</critical>
  <critical>PROTO: NEVER use `ORDINAL` for enum persistence — use `STRING` or `CODE`</critical>
  <critical>PROTO: Table names MUST have prefix: `SYS_`, `BIZ_`, `CFG_`, `LOG_`</critical>

  <!-- Enum/Error Extension Core Constraints -->
  <critical>PROTO: NEVER duplicate `code` values within same enum</critical>
  <critical>PROTO: NEVER use numeric values for enum fields — use enum names: `http_status: NOT_FOUND`</critical>

  <!-- Positive Constraints -->
  <critical>PROTO: ALWAYS run `gradlew :{module}:wire` after proto changes</critical>
  <critical>PROTO: ALWAYS use `snake_case` for proto fields</critical>
  <critical>PROTO: ALWAYS define enums in `infra/{feature}_constant.proto`</critical>
  <critical>PROTO: ALWAYS use full package path for types</critical>

  <!-- Feature Package Organization -->
  <critical>Feature-based directory structure REQUIRED:
    - API: proto_api_path/{feature}/{feature}_service.proto + {feature}_dto.proto
    - Domain: proto_domain_path/{feature}/{feature}_entity.proto
    - Infra: proto_infra_path/{feature}/{feature}_constant.proto + {feature}_error.proto</critical>
  <critical>NEVER place proto files directly in api/, domain/, infra/ root</critical>

  <!-- ============================================ -->
  <!-- STEP 1: Determine target story               -->
  <!-- ============================================ -->

  <step n="1" goal="Determine target story">
    <check if="{{story_path}} is provided by user or user provided the epic and story number such as 2-4 or 1.6 or epic 1 story 5">
      <action>Parse user-provided story path: extract epic_num, story_num, story_title from format like "1-2-user-auth"</action>
      <action>Set {{epic_num}}, {{story_num}}, {{story_key}} from user input</action>
      <action>GOTO step 2</action>
    </check>

    <action>Check if {{sprint_status}} file exists for auto discover</action>
    <check if="sprint status file does NOT exist">
      <output>No sprint status file found and no story specified

        **Required Options:**
        1. Run `sprint-planning` to initialize sprint tracking (recommended)
        2. Provide specific epic-story number to create (e.g., "1-2-user-auth")
        3. Provide path to story documents if sprint status doesn't exist yet
      </output>
      <ask>Choose option [1], provide epic-story number, path to story docs, or [q] to quit:</ask>

      <check if="user chooses 'q'">
        <action>HALT - No work needed</action>
      </check>

      <check if="user chooses '1'">
        <output>Run sprint-planning workflow first to create sprint-status.yaml</output>
        <action>HALT - User needs to run sprint-planning</action>
      </check>

      <check if="user provides epic-story number">
        <action>Parse user input: extract epic_num, story_num, story_title</action>
        <action>Set {{epic_num}}, {{story_num}}, {{story_key}} from user input</action>
        <action>GOTO step 2</action>
      </check>

      <check if="user provides story docs path">
        <action>Use user-provided path for story documents</action>
        <action>GOTO step 2</action>
      </check>
    </check>

    <!-- Auto-discover from sprint status only if no user input -->
    <check if="no user input provided">
      <critical>MUST read COMPLETE {sprint_status} file from start to end to preserve order</critical>
      <action>Load the FULL file: {{sprint_status}}</action>
      <action>Read ALL lines from beginning to end - do not skip any content</action>
      <action>Parse the development_status section completely</action>

      <action>Find the FIRST story (by reading in order from top to bottom) where:
        - Key matches pattern: number-number-name (e.g., "1-2-user-auth")
        - NOT an epic key (epic-X) or retrospective (epic-X-retrospective)
        - Status value equals "backlog"
      </action>

      <check if="no backlog story found">
        <output>No backlog stories found in sprint-status.yaml

          All stories are either already created, in progress, or done.

          **Options:**
          1. Run sprint-planning to refresh story tracking
          2. Load PM agent and run correct-course to add more stories
          3. Check if current sprint is complete and run retrospective
        </output>
        <action>HALT</action>
      </check>

      <action>Extract from found story key (e.g., "1-2-user-authentication"):
        - epic_num: first number before dash (e.g., "1")
        - story_num: second number after first dash (e.g., "2")
        - story_title: remainder after second dash (e.g., "user-authentication")
      </action>
      <action>Set {{story_id}} = "{{epic_num}}.{{story_num}}"</action>
      <action>Store story_key for later use (e.g., "1-2-user-authentication")</action>

      <!-- Mark epic as in-progress if this is first story -->
      <action>Check if this is the first story in epic {{epic_num}} by looking for {{epic_num}}-1-* pattern</action>
      <check if="this is first story in epic {{epic_num}}">
        <action>Load {{sprint_status}} and check epic-{{epic_num}} status</action>
        <action>If epic status is "backlog" → update to "in-progress"</action>
        <action>If epic status is "contexted" (legacy status) → update to "in-progress" (backward compatibility)</action>
        <action>If epic status is "in-progress" → no change needed</action>
        <check if="epic status is 'done'">
          <output>ERROR: Cannot create story in completed epic</output>
          <output>Epic {{epic_num}} is marked as 'done'. All stories are complete.</output>
          <output>If you need to add more work, either:</output>
          <output>1. Manually change epic status back to 'in-progress' in sprint-status.yaml</output>
          <output>2. Create a new epic for additional work</output>
          <action>HALT - Cannot proceed</action>
        </check>
        <check if="epic status is not one of: backlog, contexted, in-progress, done">
          <output>ERROR: Invalid epic status '{{epic_status}}'</output>
          <output>Epic {{epic_num}} has invalid status. Expected: backlog, in-progress, or done</output>
          <output>Please fix sprint-status.yaml manually or run sprint-planning to regenerate</output>
          <action>HALT - Cannot proceed</action>
        </check>
        <output>Epic {{epic_num}} status updated to in-progress</output>
      </check>

      <action>GOTO step 2</action>
    </check>
  </step>

  <!-- ============================================ -->
  <!-- STEP 2: Load and analyze core artifacts      -->
  <!-- ============================================ -->

  <step n="2" goal="Load and analyze core artifacts">
    <critical>EXHAUSTIVE ARTIFACT ANALYSIS - This is where you prevent future developer mistakes!</critical>

    <!-- Load all available content through discovery protocol -->
    <action>Read fully and follow `./discover-inputs.md` to load all input files</action>
    <note>Available content: {epics_content}, {prd_content}, {architecture_content}, {ux_content}, {project_context}</note>

    <!-- Analyze epics file for story foundation -->
    <action>From {epics_content}, extract Epic {{epic_num}} complete context:
      - Epic objectives and business value
      - ALL stories in this epic for cross-story context
      - Our specific story's requirements, user story statement, acceptance criteria
      - Technical requirements and constraints
      - Dependencies on other stories/epics
      - Source hints pointing to original documents
    </action>

    <!-- Extract specific story requirements -->
    <action>Extract our story ({{epic_num}}-{{story_num}}) details:
      - User story statement (As a, I want, so that)
      - Detailed acceptance criteria (already BDD formatted)
      - Technical requirements specific to this story
      - Business context and value
      - Success criteria
    </action>

    <!-- Previous story analysis for context continuity -->
    <check if="story_num > 1">
      <action>Find {{previous_story_num}}: scan {implementation_artifacts} for the story file in epic {{epic_num}} with the highest story number less than {{story_num}}</action>
      <action>Load previous story file: {implementation_artifacts}/{{epic_num}}-{{previous_story_num}}-*.md</action>
      <action>Extract all learnings that could impact current story:
        - Dev notes and learnings from previous story
        - Review feedback and corrections needed
        - Files that were created/modified and their patterns
        - Testing approaches that worked/didn't work
        - Problems encountered and solutions found
        - Code patterns established
      </action>
    </check>

    <!-- Git intelligence for previous work patterns -->
    <check if="previous story exists AND git repository detected">
      <action>Get last 5 commit titles to understand recent work patterns</action>
      <action>Analyze 1-5 most recent commits for relevance to current story:
        - Files created/modified
        - Code patterns and conventions used
        - Library dependencies added/changed
        - Architecture decisions implemented
        - Testing approaches used
      </action>
      <action>Extract actionable insights for current story implementation</action>
    </check>
  </step>

  <!-- ============================================ -->
  <!-- STEP 3: Architecture analysis                -->
  <!-- ============================================ -->

  <step n="3" goal="Architecture analysis for developer guardrails">
    <critical>ARCHITECTURE INTELLIGENCE - Extract everything the developer MUST follow!</critical>

    <check if="architecture file is single file">
      <action>Load complete {architecture_content}</action>
    </check>
    <check if="architecture is sharded to folder">
      <action>Load architecture index and scan all architecture files</action>
    </check>

    <action>For each architecture section, determine if relevant to this story:
      - Technical Stack: Languages, frameworks, libraries with versions
      - Code Structure: Folder organization, naming conventions, file patterns
      - API Patterns: Service structure, endpoint patterns, data contracts
      - Database Schemas: Tables, relationships, constraints relevant to story
      - Security Requirements: Authentication patterns, authorization rules
      - Performance Requirements: Caching strategies, optimization patterns
      - Testing Standards: Testing frameworks, coverage expectations, test patterns
      - Deployment Patterns: Environment configurations, build processes
      - Integration Patterns: External service integrations, data flows
    </action>
    <action>Extract any story-specific requirements that the developer MUST follow</action>
    <action>Identify any architectural decisions that override previous patterns</action>
  </step>

  <!-- ============================================ -->
  <!-- STEP 4: Web research                         -->
  <!-- ============================================ -->

  <step n="4" goal="Web research for latest technical specifics">
    <critical>ENSURE LATEST TECH KNOWLEDGE - Prevent outdated implementations!</critical>

    <action>From architecture analysis, identify specific libraries, APIs, or frameworks</action>
    <action>For each critical technology, research latest stable version and key changes:
      - Latest API documentation and breaking changes
      - Security vulnerabilities or updates
      - Performance improvements or deprecations
      - Best practices for current version
    </action>
    <action>Include in story any critical latest information the developer needs:
      - Specific library versions and why chosen
      - API endpoints with parameters and authentication
      - Recent security patches or considerations
      - Performance optimization techniques
      - Migration considerations if upgrading
    </action>
  </step>

  <!-- ============================================ -->
  <!-- STEP 5: Create comprehensive story file      -->
  <!-- (ApiHug-enhanced with rule loading)          -->
  <!-- ============================================ -->

  <step n="5" goal="Create comprehensive story file">
    <critical>CREATE ULTIMATE STORY FILE - The developer's master implementation guide!</critical>

    <!-- L2: Load rules to ensure story follows ApiHug conventions -->
    <critical>Load rules (read COMPLETE files - NEVER use offset/limit):</critical>
    <action>Load {apihug_proto_api_extension_guide} — API/Service/RPC design</action>
    <action>Load {apihug_proto_database_modeling_guide} — Entity/Table/Column design</action>
    <action>Load {apihug_proto_enum_error_extension_guide} — Enum/Error code design</action>
    <action>Load {apihug_impl_golden_rule} — Implementation patterns</action>
    <action>Load {apihug_impl_front_vben_guide} — Frontend patterns</action>
    <action if="any rule fails to load">HALT - Report missing rule, do NOT proceed</action>

    <!-- Story MUST include these ApiHug rules -->
    <critical>Story MUST include these ApiHug rules (verify before saving):</critical>

    <!-- Proto Design Rules -->
    <critical>Proto Design (if story involves proto):
      - API Design ({apihug_proto_api_extension_guide}):
        * Swagger extensions for service/rpc/message/field
        * Pageable: use `pageable: true` (NEVER manual page/size/sort in Request)
        * Parameter Definition: 0 params → Empty; 1-2 params → Empty+parameters{}; 3+ params → Message
        * Request/Response: NEVER use DTO suffix; NEVER inner message types
        * Cross-layer: API MUST NOT import domain entities
      - Database Modeling ({apihug_proto_database_modeling_guide}):
        * SQL reserved words: user, order, status, type... → use prefixes
        * Table prefixes: SYS_, BIZ_, CFG_, LOG_
        * Enum persistence: use STRING or CODE (NEVER ORDINAL)
        * Migration: _full.xml auto-generated; corrections use _after.xml with preConditions
      - Enum/Error ({apihug_proto_enum_error_extension_guide}):
        * Unique codes within domain (NEVER duplicate)
        * Use enum names: http_status: NOT_FOUND (NOT numbers/strings)
        * Error definition: code, http_status, phase, severity required
      - Feature Package Organization:
        * API: proto_api_path/{feature}/{feature}_service.proto + {feature}_dto.proto
        * Domain: proto_domain_path/{feature}/{feature}_entity.proto
        * Infra: proto_infra_path/{feature}/{feature}_constant.proto + {feature}_error.proto
    </critical>

    <!-- Implementation Rules -->
    <critical>Implementation (if story involves backend code):
      - ServiceImpl: Partially generated (NEVER modify comments/signatures); ZERO RBAC code
      - Repository: Query logic in trait (t.*Repository), NOT in ServiceImpl
      - Error Handling: DomainService throws HopeErrorDetailException; ServiceImpl uses builder.error()
      - Pagination: Receive PageRequest from framework; 0-based index; NEVER call builder.done()
      - Security: JWT/RBAC fully managed by framework — NO manual security code
      - Helper Services: Place in src/main/java/{package}/domain/{feature}
        * NEVER place helper services directly under domain/ root
        * ALWAYS group by feature for cohesion with DomainService
    </critical>

    <!-- Frontend Rules -->
    <critical>Frontend (if story involves Vue pages):
      - Auto-Router: NEVER manually create router files — generated by gradlew :ui_module:ui
      - API SDK: Import from @scope/module-sdk (NEVER write raw HTTP)
      - defineOptions: Unique name (e.g., SystemUser); meta has title, icon, authority
      - Page Patterns: LIST_PAGE (index.vue), FORM_PAGE (components/*Modal.vue), DETAIL_PAGE ([id]/index.vue)
      - Vben Components: useVbenVxeGrid, useVbenForm, useVbenModal
    </critical>

    <!-- Forbidden Rules Validation -->
    <critical>APIHUG FORBIDDEN RULES - Story MUST NOT suggest these:
      1. NEVER add page/size/sort to Request Message (use pageable: true)
      2. NEVER write validation in ServiceImpl (proto handles it)
      3. NEVER write query logic in ServiceImpl (must be in trait repository)
      4. NEVER add @PreAuthorize or security checks (proto RBAC only)
      5. NEVER create Request Message with 1-2 fields (use Empty + parameters{})
      6. NEVER modify src/generated/ (read-only)
      7. NEVER call builder.done() (controller handles it)
      8. NEVER throw RuntimeException (use HopeErrorDetailException)
    </critical>

    <action>Validate story content against forbidden rules</action>
    <check if="story suggests any forbidden pattern">
      <action>HALT - Remove forbidden suggestion and explain the correct pattern</action>
    </check>

    <action>Initialize from ./template.md: {default_output_file}</action>
    <template-output file="{default_output_file}">story_header</template-output>

    <!-- Story foundation from epics analysis -->
    <template-output file="{default_output_file}">story_requirements</template-output>

    <!-- Developer context section - MOST IMPORTANT PART -->
    <template-output file="{default_output_file}">developer_context_section</template-output>
    <template-output file="{default_output_file}">technical_requirements</template-output>
    <template-output file="{default_output_file}">architecture_compliance</template-output>
    <template-output file="{default_output_file}">library_framework_requirements</template-output>
    <template-output file="{default_output_file}">file_structure_requirements</template-output>
    <template-output file="{default_output_file}">testing_requirements</template-output>

    <!-- Previous story intelligence -->
    <check if="previous story learnings available">
      <template-output file="{default_output_file}">previous_story_intelligence</template-output>
    </check>

    <!-- Git intelligence -->
    <check if="git analysis completed">
      <template-output file="{default_output_file}">git_intelligence_summary</template-output>
    </check>

    <!-- Latest technical specifics -->
    <check if="web research completed">
      <template-output file="{default_output_file}">latest_tech_information</template-output>
    </check>

    <!-- Project context reference -->
    <template-output file="{default_output_file}">project_context_reference</template-output>

    <!-- ApiHug Implementation Plan Section -->
    <action>Add section: "## ApiHug Implementation Plan"</action>
    <action>Include task breakdown following golden rules:
      - Proto tasks: API design, Entity design, Enum/Error definition
      - Backend tasks: ServiceImpl, Repository trait, DomainService
      - Frontend tasks: LIST_PAGE, FORM_PAGE, DETAIL_PAGE (if applicable)
      - Testing tasks: Unit tests, Integration tests
    </action>

    <!-- Final status -->
    <template-output file="{default_output_file}">story_completion_status</template-output>
    <action>Set story Status to: "ready-for-dev"</action>
    <action>Add completion note: "ApiHug story context engine analysis completed"</action>

    <!-- Final validation: Verify story includes all ApiHug rules -->
    <critical>FINAL STORY VALIDATION (BEFORE SAVING):
      1. Proto rules included? (pageable, reserved words, error codes, Request Message design)
      2. Implementation rules included? (ServiceImpl, Repository trait, error handling, pagination)
      3. Frontend rules included? (auto-router, SDK usage, page patterns, Vben components)
      4. Implementation Plan section added with task breakdown?
      5. ALL forbidden rules respected? (NO violations!)
      6. All references to golden rules clear and actionable?
    </critical>
  </step>

  <!-- ============================================ -->
  <!-- STEP 6: Update sprint status and finalize    -->
  <!-- ============================================ -->

  <step n="6" goal="Update sprint status and finalize">
    <action>Validate the newly created story file {default_output_file} against `./checklist.md` and apply any required fixes before finalizing</action>
    <action>Save story document unconditionally</action>

    <!-- Update sprint status -->
    <check if="sprint status file exists">
      <action>Load the FULL file: {{sprint_status}}</action>
      <action>Read ALL development_status entries</action>
      <action>Find development_status key matching {{story_key}}</action>
      <action>Verify current status is "backlog" (expected previous state)</action>
      <action>Update development_status[{{story_key}}] = "ready-for-dev"</action>
      <action>Update last_updated field to current date</action>
      <action>Save file, preserving ALL comments and structure including STATUS DEFINITIONS</action>
    </check>

    <action>Report completion</action>
    <output>**ApiHug Story Context Created, {user_name}!**

      **Story Details:**
      - Story ID: {{story_id}}
      - Story Key: {{story_key}}
      - File: {default_output_file}
      - Status: ready-for-dev

      **Next Steps:**
      1. Review the comprehensive story in {default_output_file}
      2. Run `apihug-dev-story` for optimized implementation
      3. Run `code-review` when complete

      **The developer now has everything needed for flawless ApiHug implementation!**
    </output>
  </step>

</workflow>
