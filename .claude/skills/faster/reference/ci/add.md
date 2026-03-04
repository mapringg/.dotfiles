# GitHub Actions — Add New Workflow

Set up a new GitHub Actions workflow for the project.

## Phase 1: Understand the Project

1. **Detect the project stack**:
   - Check for `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Gemfile`, etc.
   - Identify the package manager (npm, pnpm, yarn, bun, etc.)
   - Identify the test runner, linter, and build tool from scripts/config

2. **Check for existing workflows**:

    ```bash
    ls .github/workflows/ 2>/dev/null
    ```

   - If workflows already exist, read them to understand existing CI setup
   - Avoid duplicating steps that are already covered

3. **Ask the user what the workflow should do**:
   - **Options**:
     1. **CI** — "Lint, test, and build on pull requests"
     2. **Release** — "Publish/deploy on push to main"
     3. **Custom** — "Describe what you need"

## Phase 2: Generate the Workflow

1. **Create the workflow file** at `.github/workflows/<name>.yml`

2. **Follow these conventions**:
   - Use the latest stable versions of official actions (`actions/checkout@v4`, `actions/setup-node@v4`, etc.)
   - Pin action versions to major tags (e.g., `@v4`), not `@main` or `@latest`
   - Use the project's lock file for dependency installation (`npm ci`, `pnpm install --frozen-lockfile`, etc.)
   - Cache dependencies using the built-in cache support in setup actions (e.g., `actions/setup-node@v4` with `cache: 'pnpm'`)
   - Set minimal `permissions` block — only request what's needed
   - Use `concurrency` to cancel redundant runs on the same branch

3. **For CI workflows**, include:
   - Trigger on `pull_request` and `push` to main/master
   - Install dependencies
   - Run linter (if configured)
   - Run tests (if configured)
   - Run build (if configured)
   - Run type checking (if configured)

4. **For Release workflows**, include:
   - Trigger on `push` to main/master (or tags)
   - Build step
   - Deploy/publish step (ask user for target: npm, Docker, cloud provider, etc.)

## Phase 3: Verify

1. **Show the generated workflow to the user** and explain each step

2. **Commit and push** (only after user confirms):

    ```bash
    mkdir -p .github/workflows
    git add .github/workflows/<name>.yml
    git commit -m "ci: add <description> workflow"
    git push -u origin HEAD
    ```

3. **Watch the first run**:

    ```bash
    gh run watch
    ```

4. **If the run fails**, switch to the Fix CI workflow to diagnose and fix

## Notes

- Keep workflows simple — one job is preferred unless there's a reason to split (e.g., matrix builds, separate deploy step)
- Don't add steps the project doesn't need (e.g., no lint step if there's no linter configured)
- If the project has a monorepo structure, consider path filters to avoid running CI on unrelated changes
