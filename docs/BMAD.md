# BMAD Method Integration with ApiHug

The BMAD Method (BMM) is a core module of the BMAD Ecosystem, designed to implement best practices in context engineering and planning. By providing clear, structured context, it enables AI agents to perform optimally throughout the development process.

ApiHug is a premier contract-first enterprise Java platform framework. During development, it leverages the BMAD methodology and seamlessly integrates its optimized workflows into the ApiHug development lifecycle.

## Entire Workflow

This optimized workflow guides you through a swift, professional development experience, combining the strengths of BMAD and ApiHug to accelerate your projects.
Since BMAD [6.0](https://docs.bmad-method.org/roadmap/) all move to skill Architecture

| Phase          | Workflow                              | Purpose                                                          | Produces                             |
|----------------|---------------------------------------|------------------------------------------------------------------|--------------------------------------|
| Analysis       | `bmad-create-product-brief`           | Capture strategic vision                                         | `product-brief.md`                   |
| Plan           | `bmad-create-prd`                     | Define requirements (FRs/NFRs)                                   | `PRD.md`                             |
| Solutioning    | `bmad-create-architecture`            | Make technical decisions explicit                                | `architecture.md` with ADRs          |
| Solutioning    | `bmad-create-epics-and-stories`       | Break requirements into implementable work                       | Epic files with stories              |
| Solutioning    | `bmad-check-implementation-readiness` | Gate check before implementation                                 | PASS/CONCERNS/FAIL decision          |
| Implementation | `bmad-sprint-planning`                | Initialize tracking (once per project to sequence the dev cycle) | `sprint-status.yaml`                 |
| Implementation | `apihug-create-story`                 | Prepare next story for implementation with **ApiHug** way        | `story-[slug].md`                    |
| Implementation | `apihug-dev-story`                    | Implement the story with **ApiHug** way                          | Working code + tests                 |
| Implementation | `apihug-proto-review`                 | Review existing proto files against ApiHug proto design rules    | Approved or proto changes requested  |
| Implementation | `apihug-impl-review`                  | Review implementation code against ApiHug golden rules           | Approved or implementation requested |
| Implementation | `bmad-code-review`                    | Validate implementation quality                                  | Approved or changes requested        |
| Implementation | `bmad-correct-course`                 | Handle significant mid-sprint changes                            | Updated plan or re-routing           |
| Implementation | `bmad-retrospective`                  | Review after epic completion                                     | Lessons learned                      |

BMAD [Workflow Map](https://docs.bmad-method.org/reference/workflow-map/)


## Project Context

The `project-context.md` file, located at `{project-root}/docs/project-context.md`, serves as your project's implementation guide for AI agents. Similar to a “constitution” in other development systems, it documents the rules, patterns, and preferences that ensure consistent code generation across all workflows (see [Project Context](https://docs.bmad-method.org/explanation/project-context/)). 

For existing projects, you can generate this file by running the `bmad-bmm-generate-project-context` workflow.
