# Proto Design Verification Checklist

## Pre-Design

- [ ] Domain configuration loaded (hope-wire.json exists)
- [ ] Package name confirmed
- [ ] Proto module meta index loaded (apihug.idx.csv)
- [ ] Existing components overview obtained from meta index (CSV format: type, class, name, description, proto, details)
- [ ] Three spec documents accessible (constant/domain/swagger, mock embedded in swagger)

## Requirements Clarification

### API Design
- [ ] API name defined
- [ ] Business description clear (1-2 sentences)
- [ ] HTTP method specified (GET/POST/PUT/DELETE/PATCH)
- [ ] API path defined
- [ ] Input parameters documented (fields, types, validations)
- [ ] Output fields documented
- [ ] Error scenarios identified
- [ ] Permissions/roles specified
- [ ] Pagination requirement clarified

### Entity Design
- [ ] Entity name defined
- [ ] Table structure documented
- [ ] Field constraints specified (nullable, unique, length)
- [ ] Primary key defined with generation strategy
- [ ] Built-in wires selected (AUDITABLE/DELETABLE/TENANT_ISOLATE)
- [ ] Views designed (LIST/DETAIL/AGGREGATE)
- [ ] Indexes defined

### Enum/Error Design
- [ ] Enum/Error name defined
- [ ] All values documented with codes
- [ ] English messages provided
- [ ] Chinese messages (message2) provided
- [ ] Error code range assigned (no conflicts)
- [ ] HTTP status codes mapped (for errors)
- [ ] Category specified (BUSINESS/SYSTEM for errors)
- [ ] Severity set (ERROR/WARN/INFO for errors)

### Mock Configuration
- [ ] Fields requiring mock data identified
- [ ] Mock rules embedded in swagger field/schema options
- [ ] Nature specified (STRING/NUMBER/BOOLEAN/DATE/EMAIL/URL/IMAGE)
- [ ] Rules configured (min/max, patterns, candidates)
- [ ] Special rules applied (chinese_rule, china_address_rule, etc.)

## Proto File Generation

### Constant Proto
- [ ] File locations correct (one or more proto files under `infra/**`, e.g. `infra/settings/example/constant.proto`, `infra/settings/example/error.proto`, or other infra subpackages)
- [ ] Package name matches hope-wire.json
- [ ] Import `apihug/protobuf/extend/constant.proto`
- [ ] Enum values use `(hope.constant.field)` option
- [ ] Error codes use `(hope.constant.error)` option
- [ ] All required fields present (code, message, message2)

### Domain Proto
- [ ] File location correct (`domain/entities/*.proto`)
- [ ] Package name matches hope-wire.json
- [ ] Imports correct (persistence.proto, view.proto, annotations.proto)
- [ ] Table option `(hope.persistence.table)` configured
- [ ] Table name defined (uppercase convention)
- [ ] Description provided
- [ ] Wires applied correctly
- [ ] Column options `(hope.persistence.column)` configured
- [ ] Primary key marked with `id: TRUE`
- [ ] Generation strategy set (AUTO_INC/UUID)
- [ ] Constraints specified (nullable, unique, length)
- [ ] Views defined with `(hope.persistence.view)` option
- [ ] View type set (LIST/DETAIL/AGGREGATE)

### API Proto
- [ ] File location correct (`api/*/api.proto`)
- [ ] Package name matches hope-wire.json
- [ ] Imports correct (swagger annotations, domain entities)
- [ ] Service option `(hope.swagger.svc)` configured
- [ ] Service path, description, tag set
- [ ] RPC methods defined
- [ ] Operation option `(hope.swagger.operation)` configured
- [ ] HTTP method and path set (get/post/put/delete/patch)
- [ ] Title and description provided
- [ ] Priority set (CRITICAL/HIGH/MEDIUM/LOW)
- [ ] Authorization configured (roles/permissions)
- [ ] Pagination flag set if needed
- [ ] Mock enabled (when needed)
- [ ] Request/Response messages defined
- [ ] Field schema options `(hope.swagger.schema)` or `(hope.swagger.field)` configured
- [ ] Field descriptions provided
- [ ] Validations set (required, min_length, max_length, pattern, format)

### Mock Configuration
- [ ] Mock configuration is embedded in field/message swagger options (not standalone)
- [ ] Nature set appropriately (STRING/NUMBER/BOOLEAN/DATE/EMAIL/URL/IMAGE)
- [ ] String rules configured (min, max, pool, candidates)
- [ ] Number rules configured (min, max, fractions)
- [ ] Date rules configured (birth_day, time_gap, dir)
- [ ] Special natures used when needed (EMAIL, URL, IMAGE)
- [ ] Chinese rules configured when needed (chinese_rule, china_address_rule, etc.)

## Compilation

- [ ] Run `./gradlew {module}:wire` successfully
- [ ] Compilation successful (no syntax errors)
- [ ] No import resolution errors
- [ ] No option validation errors
- [ ] Wire plugin logs clean (no warnings)
- [ ] Generated code in `src/generated/main/wire/` (Wire DTOs)
- [ ] Generated code in `src/generated/main/api/` (API interfaces)
- [ ] Generated code in `src/generated/main/domain/` (Domain entities)
- [ ] Expected Java classes present

## Validation

### Error Code Validation
- [ ] All error codes unique (no duplicates)
- [ ] Error codes within assigned range
- [ ] Error codes follow module convention (e.g., order: 40xxxx)

### Package Validation
- [ ] Proto package names consistent
- [ ] Package names match hope-wire.json `packageName`
- [ ] Import paths correct

### Generated Code Validation
- [ ] Enum classes generated
- [ ] Error code constants present
- [ ] Entity classes generated
- [ ] DTO classes generated (Request/Response)
- [ ] Service interfaces generated
- [ ] Class names match proto definitions

## Design Quality

- [ ] API paths follow RESTful conventions
- [ ] Entity names use singular form (User, not Users)
- [ ] Field names use snake_case (e.g., user_name)
- [ ] Enum values use UPPER_CASE
- [ ] Table names use UPPER_CASE
- [ ] Column names use UPPER_CASE
- [ ] Descriptions are meaningful and clear
- [ ] Error messages are user-friendly
- [ ] Mock rules produce realistic data

## Documentation

- [ ] Design summary generated
- [ ] Business requirements documented
- [ ] Proto file list complete
- [ ] Key design decisions recorded
- [ ] Error code assignments documented
- [ ] Next steps provided

## Next Steps Preparation

- [ ] Application run command documented: `./gradlew {module}:bootRun` (auto-triggers wire)
- [ ] Verification endpoints listed
- [ ] Reference links included

## Common Issues Checklist

- [ ] No duplicate error codes
- [ ] No conflicting API paths
- [ ] No missing imports
- [ ] No package name mismatches
- [ ] No missing required options
- [ ] No invalid option values
- [ ] No syntax errors
- [ ] No wire plugin errors

---

## Notes

Use this checklist to ensure comprehensive proto design quality. Each section corresponds to a phase in the workflow.
