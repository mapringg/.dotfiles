# AGENTS.md

## Concise responses
In all interactions, plans, and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Plans
For multi-step plans, divide them into multiple phases with different headings. That way I can describe which phases to implement at a time so we don't have to implement everything at once.

## Libraries
If you're ever unsure how a library works, use the Context7 MCP server to research it rather than crawling around node modules or other build files.

## Tech preferences

### JavaScript / TypeScript
Use pnpm as the preferred package manager. If my current project uses a different package manager, use that instead.

Prefer `type` to `interface` when writing TS types

Ensure JS Docs are consise. Follow the Hemingway Test as a guide.

### Next.js
Don't call build commands unless you really need to, they break my dev environment. You can run typechecks all you want.

Minimize usage of useEffect, derive all state where possible, and skip useMemo and useCallback as well. React Compiler will handle it.

Always format using default Prettier rules. Always use TypeScript. Avoid return types unless necessary (lean on inference). 
