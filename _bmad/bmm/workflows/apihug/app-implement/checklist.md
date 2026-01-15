# ApiHug App Implementation Checklist

## Pre-implementation

- [ ] Proto module compiled successfully
- [ ] `hope-wire.json` configured correctly
- [ ] Meta index (apihug.idx.csv) accessible

## Code Generation

- [ ] Run `./gradlew {module}:wire` successfully
- [ ] Controllers generated in `src/generated/main/api/`
- [ ] Service interfaces generated in `src/generated/main/api/`
- [ ] DTOs generated in `src/generated/main/wire/`
- [ ] Entities generated in `src/generated/main/domain/`
- [ ] Repository templates generated in `src/main/trait/`
- [ ] Dependencies complete in `build.gradle`

## Service Implementation

- [ ] All service interfaces implemented
- [ ] Constructor injection used (no `@Autowired`)
- [ ] `@Transactional` applied to data modifications
- [ ] Business validations in place
- [ ] Domain exceptions from proto definitions used
- [ ] Return types match interface definitions

## Repository Extension

- [ ] Custom SQL in `_DerivedSQL` interface only
- [ ] `@Query` annotations used for complex queries
- [ ] Semantic method names

## Configuration

- [ ] Application configuration complete
- [ ] `@ConfigurationProperties` used for type safety
- [ ] Profile-specific settings configured
- [ ] No Spring Security configuration (not needed)

## Testing

- [ ] Service tests written (`@SpringBootTest`)
- [ ] Repository tests written (`@DataJdbcTest`)
- [ ] Business logic validation covered
- [ ] Custom query validation covered
- [ ] Test coverage > 80%
- [ ] All tests pass

## Application Verification

- [ ] Application starts successfully
- [ ] OAS documentation accessible
- [ ] API endpoints respond correctly
- [ ] Error codes properly exposed
- [ ] Actuator endpoints available
- [ ] Authority definitions accessible

## Code Quality

- [ ] No modifications to `src/generated/main/{api,domain,wire,mcp,cloud}`
- [ ] All custom code in `src/main/java/` or `src/main/trait/`
- [ ] Constructor injection used throughout
- [ ] No JPA annotations used
- [ ] Code follows naming conventions
- [ ] Exception handling in service layer

## Documentation

- [ ] Implementation summary generated
- [ ] Custom repository methods documented
- [ ] Configuration changes documented
- [ ] Test coverage report available
