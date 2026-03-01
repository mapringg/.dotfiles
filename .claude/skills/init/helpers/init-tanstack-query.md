# Initialize TanStack Query Best Practices

Add TanStack Query best practices. **Follow `~/.claude/skills/init/conventions.md` for standard file handling.**

## Target File

`.claude/rules/tanstack-query.md`

## Path Pattern

`**/*.{ts,tsx}`

## Content

<!-- RULES_START -->
---
paths: "**/*.{ts,tsx}"
---

# TanStack Query Rules

### Unstable Dependencies in useEffect

TanStack Query mutations and refetch functions create new references on every render. Including them in useEffect dependency arrays causes effects to re-run repeatedly, leading to bugs like duplicate event listeners.

**Problem — mutation in deps causes infinite re-runs:**

```tsx
const mutation = useMutation(...);

useEffect(() => {
  const unlisten = listen("event", () => mutation.mutate(...));
  return () => { unlisten.then(f => f()); };
}, [mutation]); // mutation changes every render = duplicate listeners
```

**Solution — use refs for unstable values:**

```tsx
const mutation = useMutation(...);
const mutationRef = useRef(mutation);
mutationRef.current = mutation;

useEffect(() => {
  const unlisten = listen("event", () => mutationRef.current.mutate(...));
  return () => { unlisten.then(f => f()); };
}, []); // Effect runs once, ref always has latest mutation
```

### Stability Reference

| Category | Examples | Safe in deps? |
|----------|----------|---------------|
| **Stable** | `useQueryClient()`, Zustand selectors, primitive values | Yes |
| **Unstable** | `useMutation()`, `useQuery().refetch`, callback props, arrays from `useQueries` | No — use refs |

### setQueryData vs invalidateQueries

For high-frequency updates (e.g., stats polling every 2 seconds), prefer `setQueryData` over `invalidateQueries`:

```tsx
// Bad — triggers re-render cascade for all subscribers
queryClient.invalidateQueries({ queryKey: ['processes', projectId] });

// Good — updates cache in place, only components reading changed data re-render
const freshData = await fetchProcesses(projectId);
queryClient.setQueryData(['processes', projectId], freshData);
```

**Why:** `invalidateQueries` marks queries as stale and triggers refetches, causing all subscribers to re-render during the loading state. `setQueryData` updates the cache directly without intermediate states.

### useQueries Returns Unstable Arrays

Even with `combine`, `useQueries` returns new array references on every render:

```tsx
// Problem — results array changes every render even if data unchanged
const results = useQueries({
  queries: items.map(item => ({ queryKey: ['item', item.id], queryFn: () => fetch(item.id) })),
  combine: (results) => results.map(r => r.data),  // Still new array each render!
});

// Solution — stabilize with serialization-based memoization
const prevRef = useRef<string>("");
const prevData = useRef<Data[]>([]);
const serialized = JSON.stringify(results);
if (serialized !== prevRef.current) {
  prevRef.current = serialized;
  prevData.current = results;
}
const stableResults = prevData.current;
```

### Common Mistakes

- Putting `mutation` in useEffect deps array — causes re-runs every render
- Putting `refetch` in useEffect deps array — same problem
- Forgetting to update ref on each render (`mutationRef.current = mutation`)
- Using stale closure instead of ref (captures old mutation instance)
- Using `invalidateQueries` for high-frequency updates — causes re-render cascade, use `setQueryData`
- Assuming `useQueries` with `combine` returns stable arrays — it doesn't, use serialization-based memoization
<!-- RULES_END -->
