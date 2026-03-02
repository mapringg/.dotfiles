# Idiomatic Audit — Subagent Prompts

Reference file for audit-idiomatic. Contains detailed prompts for each parallel subagent.

## Subagent 1: Language Idioms

````
Audit this codebase for non-idiomatic language usage.

Tech stack: [from Phase 1]

## PREFERRED CONSTRUCTS

Check that the codebase uses language-native constructs rather than verbose alternatives.

### Python
```python
# BAD - verbose loop to build list
result = []
for x in items:
    if x.active:
        result.append(x.name)

# GOOD - list comprehension
result = [x.name for x in items if x.active]

# BAD - manual key check
if key in d:
    val = d[key]
else:
    val = default

# GOOD - dict method
val = d.get(key, default)

# BAD - manual context management
f = open("file.txt")
try:
    data = f.read()
finally:
    f.close()

# GOOD - context manager
with open("file.txt") as f:
    data = f.read()

# BAD - type checking with isinstance alternative
if type(x) == int:

# GOOD
if isinstance(x, int):
```

### JavaScript/TypeScript
```typescript
// BAD - verbose null checks
const name = user !== null && user !== undefined ? user.name : undefined;

// GOOD - optional chaining
const name = user?.name;

// BAD - manual default
const port = config.port !== undefined ? config.port : 3000;

// GOOD - nullish coalescing
const port = config.port ?? 3000;

// BAD - var usage
var count = 0;

// GOOD - const/let
const count = 0;

// BAD - callback-based async
function fetchData(callback) {
  fetch(url).then(res => callback(null, res)).catch(err => callback(err));
}

// GOOD - async/await
async function fetchData() {
  return await fetch(url);
}

// BAD - manual array check
if (arr.indexOf(item) !== -1)

// GOOD
if (arr.includes(item))
```

### Go
```go
// BAD - unnecessary else after return
if err != nil {
    return err
}  else {
    doWork()
}

// GOOD - early return
if err != nil {
    return err
}
doWork()

// BAD - ignoring errors
result, _ := riskyOperation()

// GOOD - handle every error
result, err := riskyOperation()
if err != nil {
    return fmt.Errorf("riskyOperation: %w", err)
}

// BAD - init then assign
var s []string
s = make([]string, 0, 10)

// GOOD - short declaration
s := make([]string, 0, 10)
```

### Rust
```rust
// BAD - manual match on Option
match opt {
    Some(val) => do_something(val),
    None => (),
}

// GOOD - if let
if let Some(val) = opt {
    do_something(val);
}

// BAD - unwrap in non-test code
let value = result.unwrap();

// GOOD - propagate with ?
let value = result?;

// BAD - manual string building
let s = String::from("hello") + " " + &world;

// GOOD - format macro
let s = format!("hello {world}");
```

## ERROR HANDLING PATTERNS

Flag code that doesn't follow the language's error handling idioms:

| Language | Idiomatic Pattern | Anti-Pattern |
|----------|------------------|--------------|
| Go | Explicit `if err != nil` checks | Ignoring errors with `_` |
| Rust | `Result<T, E>` with `?` propagation | `.unwrap()` outside tests |
| Python | Specific exception types | Bare `except:` or `except Exception:` |
| Java | Specific checked exceptions | `catch (Exception e)` everywhere |
| TypeScript | Typed error handling | Untyped `catch (e)` |

## TYPE USAGE AND ANNOTATIONS

Flag weak or missing type usage:

```typescript
// BAD - any type
function process(data: any): any { }

// GOOD - specific types
function process(data: UserInput): ProcessedResult { }
```

```python
# BAD - no type hints in public API
def calculate(x, y):
    return x + y

# GOOD - annotated
def calculate(x: float, y: float) -> float:
    return x + y
```

## SEARCH STRATEGY

1. Sample 10-15 representative source files across the codebase
2. For each file, check constructs against the idiom checklist for the detected language
3. Look for patterns of verbose code where concise idioms exist
4. Check error handling in every function that can fail
5. Verify type annotations on public APIs and function signatures

Report each finding with:

- file:line reference
- The non-idiomatic pattern found
- The idiomatic alternative with example
- Severity (Critical if it causes bugs, High if it hurts maintainability, Medium otherwise)

````

## Subagent 2: Framework Conventions

````
Audit this codebase for framework convention violations.

Tech stack: [from Phase 1]

## DIRECTORY STRUCTURE

Check that the project follows the framework's expected layout:

### Next.js / React
```
Expected:
  app/ or pages/        → route components
  components/           → reusable UI
  lib/ or utils/        → shared logic
  hooks/                → custom React hooks
  types/                → TypeScript types/interfaces

Flag:
  - Route components outside app/ or pages/
  - Hooks not prefixed with "use"
  - Components in lib/ or utils/
  - Business logic inside components (should be in hooks/lib)
```

### Laravel
```
Expected:
  app/Models/           → Eloquent models
  app/Http/Controllers/ → controllers
  app/Services/         → business logic
  database/migrations/  → migrations
  resources/views/      → templates

Flag:
  - Business logic in controllers (fat controllers)
  - Raw SQL instead of Eloquent/Query Builder
  - Missing model relationships
```

### Django
```
Expected:
  <app>/models.py       → models
  <app>/views.py        → views
  <app>/urls.py         → URL patterns
  <app>/admin.py        → admin config
  <app>/serializers.py  → DRF serializers

Flag:
  - Logic in views that belongs in models/managers
  - Missing migrations for model changes
  - Raw SQL instead of ORM
```

### Rails
```
Expected:
  app/models/           → ActiveRecord models
  app/controllers/      → controllers
  app/services/         → service objects
  app/views/            → templates

Flag:
  - Fat controllers (logic belongs in models/services)
  - N+1 queries (missing includes/eager loading)
  - Callbacks for complex logic (use service objects)
```

## COMPONENT/CLASS PATTERNS

### React
```typescript
// BAD - class component (legacy pattern)
class MyComponent extends React.Component {
  render() { return <div />; }
}

// GOOD - function component with hooks
function MyComponent() {
  return <div />;
}

// BAD - prop drilling through many layers
<GrandParent data={data}>
  <Parent data={data}>
    <Child data={data} />

// GOOD - context or state management
const DataContext = createContext<Data>(defaultData);

// BAD - useEffect for derived state
const [fullName, setFullName] = useState('');
useEffect(() => {
  setFullName(`${first} ${last}`);
}, [first, last]);

// GOOD - computed during render
const fullName = `${first} ${last}`;
```

### Express / Node.js
```typescript
// BAD - all logic in route handler
app.post('/users', async (req, res) => {
  // 100 lines of validation, DB queries, email sending...
});

// GOOD - middleware + service layer
app.post('/users', validate(schema), async (req, res) => {
  const user = await userService.create(req.body);
  res.json(user);
});
```

## ROUTING CONVENTIONS

Flag violations of framework routing patterns:
- Next.js: file-based routing — logic shouldn't manually define routes
- Express: RESTful resource naming (`/users/:id` not `/getUser`)
- Rails: resourceful routes (`resources :users` not manual `get/post`)
- Django: URL patterns with named routes

## ORM / DATABASE PATTERNS

Flag raw SQL when ORM methods exist:
```python
# BAD (Django)
cursor.execute("SELECT * FROM users WHERE active = 1")

# GOOD
User.objects.filter(active=True)
```

Flag missing eager loading / N+1 patterns:
```ruby
# BAD (Rails) - N+1 query
users.each { |u| puts u.posts.count }

# GOOD
users.includes(:posts).each { |u| puts u.posts.count }
```

## SEARCH STRATEGY

1. Verify directory structure matches framework expectations
2. Sample route/controller files for fat-controller anti-pattern
3. Check component files for deprecated patterns (class components, mixins)
4. Search for raw SQL alongside ORM usage
5. Check for framework-provided utilities being reimplemented

Report each finding with:

- file:line reference
- The convention violation
- What the framework recommends instead
- Link to relevant framework documentation section (if well-known)

````

## Subagent 3: Anti-Patterns

````
Audit this codebase for common anti-patterns specific to the detected stack.

Tech stack: [from Phase 1]

## REINVENTING FRAMEWORK FUNCTIONALITY

Search for hand-rolled implementations of things the framework provides:

### Common Reimplementations
```typescript
// BAD - manual debounce when lodash/framework provides one
function debounce(fn, delay) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

// BAD - manual deep clone
function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}
// GOOD - structuredClone (modern JS) or library utility

// BAD - manual request retry logic when axios-retry / fetch-retry exists
async function fetchWithRetry(url, retries = 3) { ... }

// BAD - manual form validation when framework has it
function validateForm(data) {
  const errors = {};
  if (!data.email) errors.email = 'Required';
  if (!data.email.includes('@')) errors.email = 'Invalid';
  ...
}
// GOOD - use framework validation (Zod, Yup, class-validator, etc.)
```

### React-Specific
```typescript
// BAD - manual state sync (use the framework)
useEffect(() => {
  setFilteredItems(items.filter(i => i.match(search)));
}, [items, search]);

// GOOD - useMemo or compute inline
const filteredItems = useMemo(
  () => items.filter(i => i.match(search)),
  [items, search]
);

// BAD - manual previous value tracking
const [prev, setPrev] = useState(value);
if (value !== prev) { setPrev(value); doSomething(); }

// GOOD - useRef for previous, or restructure logic
```

### Python-Specific
```python
# BAD - manual CSV parsing
with open('data.csv') as f:
    for line in f:
        fields = line.strip().split(',')

# GOOD - csv module or pandas
import csv
with open('data.csv') as f:
    reader = csv.DictReader(f)

# BAD - manual path joining
path = dir + '/' + filename

# GOOD - pathlib
path = Path(dir) / filename
```

## LEGACY PATTERNS

Flag patterns that have modern replacements:

| Legacy Pattern | Modern Alternative | Language |
|---------------|--------------------|----------|
| `var` declarations | `const` / `let` | JavaScript |
| `.then()` chains | `async` / `await` | JavaScript |
| Class components | Function components + hooks | React |
| `unittest.TestCase` | `pytest` functions | Python |
| `fmt.Sprintf` for errors | `fmt.Errorf` with `%w` | Go |
| `interface{}` | `any` (Go 1.18+) | Go |
| jQuery DOM manipulation | Native DOM API or framework | JavaScript |
| Moment.js | date-fns or dayjs | JavaScript |
| `require()` | `import` (ESM) | Node.js |
| String concatenation | Template literals / f-strings | JS / Python |
| Manual HTTP clients | Framework-provided (e.g., `HttpClient`) | Various |

## IGNORED CONVENTIONS

Look for patterns where the developer ignores framework conventions without clear reason:

- Middleware/interceptor bypass (doing auth checks inline)
- Not using framework's config system (hardcoded values)
- Skipping framework lifecycle methods (manual init instead of framework hooks)
- Not using framework's testing utilities
- Ignoring framework's logging/error reporting

## SEARCH STRATEGY

1. Check `package.json` / manifest for available utilities — then search for hand-rolled versions
2. Search for common DIY patterns: manual debounce, deep clone, retry logic, validation
3. Look for legacy API usage that has modern replacements
4. Check if framework middleware/plugins exist but aren't used
5. Search for `// TODO: use [framework feature]` or similar comments indicating known debt

Report each finding with:

- file:line reference
- The anti-pattern found
- The framework/language feature that should be used instead
- Effort estimate (trivial / moderate / significant refactor)

````

## Subagent 4: Performance Idioms

````
Audit this codebase for missing performance idioms specific to the detected stack.

Tech stack: [from Phase 1]

## FRAMEWORK-SPECIFIC OPTIMIZATIONS

### React
```typescript
// BAD - creating objects/arrays in render (causes unnecessary re-renders)
function Component() {
  return <Child style={{ color: 'red' }} items={[1, 2, 3]} />;
}

// GOOD - stable references
const style = { color: 'red' };
const items = [1, 2, 3];
function Component() {
  return <Child style={style} items={items} />;
}

// BAD - missing key in lists (or using index as key for dynamic lists)
items.map((item, index) => <Item key={index} {...item} />);

// GOOD - stable unique key
items.map(item => <Item key={item.id} {...item} />);

// BAD - expensive computation every render
function Component({ items }) {
  const sorted = items.sort((a, b) => a.score - b.score); // runs every render
}

// GOOD - memoized
function Component({ items }) {
  const sorted = useMemo(() =>
    [...items].sort((a, b) => a.score - b.score),
    [items]
  );
}
```

### Python
```python
# BAD - string concatenation in loop
result = ""
for s in strings:
    result += s  # O(n²) for strings

# GOOD
result = "".join(strings)  # O(n)

# BAD - repeated dict/attribute access in loop
for item in items:
    process(config.settings.threshold, item)

# GOOD - hoist out of loop
threshold = config.settings.threshold
for item in items:
    process(threshold, item)

# BAD - loading entire file into memory
data = open("huge.csv").read().split("\n")

# GOOD - iterate lazily
with open("huge.csv") as f:
    for line in f:
        process(line)
```

### Go
```go
// BAD - string concatenation in loop
var s string
for _, item := range items {
    s += item.Name + ", "
}

// GOOD - strings.Builder
var b strings.Builder
for _, item := range items {
    b.WriteString(item.Name)
    b.WriteString(", ")
}

// BAD - not pre-allocating slices when size is known
var results []Result
for _, item := range items {
    results = append(results, process(item))
}

// GOOD - pre-allocate
results := make([]Result, 0, len(items))
for _, item := range items {
    results = append(results, process(item))
}

// BAD - defer in loop (deferred calls accumulate)
for _, file := range files {
    f, _ := os.Open(file)
    defer f.Close()  // won't close until function returns!
}
```

### SQL / ORM
```
Flag these patterns:
- SELECT * when only specific columns needed
- N+1 queries (loop with individual queries)
- Missing indexes on frequently queried columns
- Unbounded queries without LIMIT
- Loading entire tables into memory
```

## MEMORY AND RESOURCE MANAGEMENT

Flag resource leaks and inefficient memory usage:

```typescript
// BAD - event listener leak
useEffect(() => {
  window.addEventListener('resize', handleResize);
  // Missing cleanup!
});

// GOOD
useEffect(() => {
  window.addEventListener('resize', handleResize);
  return () => window.removeEventListener('resize', handleResize);
}, []);
```

```go
// BAD - unclosed HTTP response body
resp, err := http.Get(url)
// using resp without closing body

// GOOD
resp, err := http.Get(url)
if err != nil {
    return err
}
defer resp.Body.Close()
```

```python
# BAD - unclosed database connection
conn = psycopg2.connect(dsn)
cursor = conn.cursor()
cursor.execute(query)

# GOOD
with psycopg2.connect(dsn) as conn:
    with conn.cursor() as cursor:
        cursor.execute(query)
```

## ASYNC / CONCURRENCY PATTERNS

```typescript
// BAD - sequential async when parallel is possible
const users = await fetchUsers();
const posts = await fetchPosts();
const comments = await fetchComments();

// GOOD - parallel execution
const [users, posts, comments] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
  fetchComments(),
]);

// BAD - await in loop
for (const id of ids) {
  const result = await fetch(`/api/${id}`);
  results.push(result);
}

// GOOD - parallel with concurrency control
const results = await Promise.all(ids.map(id => fetch(`/api/${id}`)));
```

## SEARCH STRATEGY

1. Check for string concatenation in loops (all languages)
2. Look for N+1 query patterns near ORM usage
3. Search for `useEffect` / event listeners missing cleanup
4. Find sequential awaits that could be parallelized
5. Check for resource handles (files, connections) without proper closing
6. Look for `SELECT *` in SQL queries

Report each finding with:

- file:line reference
- The performance issue
- Expected impact (minor / moderate / significant)
- The idiomatic optimization with example

````

## Subagent 5: Consistency

````
Audit this codebase for internal consistency issues — places where the codebase contradicts its own established patterns.

Tech stack: [from Phase 1]

## INCONSISTENT STYLE WITHIN CODEBASE

This subagent does NOT check against external standards — it checks that the codebase is consistent with ITSELF.

### Step 1: Detect Dominant Patterns

Sample 10-20 source files and identify the codebase's own conventions:

```
Track these dimensions:
- Import style: named vs default, relative vs absolute paths
- Export style: named exports vs default exports
- String quotes: single vs double
- Semicolons: present vs absent (JS/TS)
- Trailing commas: used vs not used
- Function style: arrow functions vs function declarations
- Component style: function declarations vs const arrows (React)
- File naming: kebab-case vs camelCase vs PascalCase
- Error handling approach: try/catch vs .catch() vs Result types
- Logging: console.log vs logger instance vs framework logger
- Comment style: JSDoc vs inline vs none
```

### Step 2: Flag Deviations

Once dominant patterns are established, flag files/sections that deviate:

```typescript
// If codebase predominantly uses named exports:
// INCONSISTENT
export default function UserService() { }

// CONSISTENT with codebase
export function UserService() { }

// If codebase predominantly uses arrow functions:
// INCONSISTENT
function handleClick() { }

// CONSISTENT with codebase
const handleClick = () => { }
```

## MIXED PARADIGMS

Flag when multiple approaches coexist without clear reason:

### State Management
```
Flag if codebase mixes:
- Redux AND Context API AND Zustand (pick one)
- MobX AND Redux (pick one)
- Multiple HTTP clients (axios AND fetch AND got)
- Multiple validation libraries (Zod AND Yup AND Joi)
```

### Data Fetching
```
Flag if codebase mixes:
- REST AND GraphQL for similar resources (without clear separation)
- Callbacks AND Promises AND async/await (should be unified)
- Multiple caching strategies without clear layering
```

### Styling (Frontend)
```
Flag if codebase mixes:
- CSS Modules AND styled-components AND Tailwind
- Inline styles AND CSS classes for similar purposes
- Multiple CSS methodologies (BEM, SMACSS, etc.)
```

## STRUCTURAL INCONSISTENCY

### File Organization
```
Flag if:
- Some features use flat structure, others use nested folders
- Some modules export from index files, others don't
- Test files sometimes co-located, sometimes in separate tree
- Some files use barrel exports, others use direct imports
```

### API Patterns
```
Flag if:
- Some endpoints return { data, error }, others return raw data
- Error response format varies between endpoints
- Pagination style differs (cursor vs offset vs page)
- Authentication approach differs between modules
```

### Error Handling
```
Flag if:
- Some functions throw, others return null, others return Result
- Some async code uses try/catch, others use .catch()
- Error types/classes used in some modules but not others
- Some errors logged, others silently swallowed
```

## SEARCH STRATEGY

1. Sample files from different areas of the codebase (not just one directory)
2. Build a tally of each pattern dimension across sampled files
3. Identify the dominant approach for each dimension (>60% usage)
4. Rescan for deviations from dominant patterns
5. Group deviations by type — a single file with many deviations may indicate a different author or legacy code

Report each finding with:

- file:line reference
- The inconsistent pattern found
- What the codebase's dominant convention is (with file count / percentage)
- Whether the inconsistency appears isolated or systemic

````
