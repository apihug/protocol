
## keep track in two repository:

1. https://github.com/apihug/skills.git
2. https://gitee.com/apihug/skills.git


Used by the `REPL` `hope.common.repl.spec.core.Installer`:

```java
 /** Git sources for skills repository - round-robin fallback */
  private static final String[] SKILLS_GIT_SOURCES = {
    "https://github.com/apihug/skills.git", "https://gitee.com/apihug/skills.git"
  };
```
