# Initialize TanStack Query Best Practices

Add TanStack Query best practices. **Follow `~/.claude/skills/faster/reference/init/conventions.md` for standard file handling.**

## Detection

- `package.json` with `@tanstack/react-query`
- Files importing from `@tanstack/react-query` (`useQuery`, `useMutation`)

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

### QueryClient Configuration

```typescript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,       // 1 min before data is considered stale
      gcTime: 1000 * 60 * 5,      // 5 min before inactive cache is garbage collected
      retry: 2,                    // Retry failed queries twice
      refetchOnWindowFocus: false, // Disable if polling or WebSocket used
    },
    mutations: {
      retry: false,                // Don't retry mutations by default
    },
  },
})

// Wrap app
<QueryClientProvider client={queryClient}>
  <App />
</QueryClientProvider>
```

### queryOptions Helper

Define query options outside components for reuse in loaders, prefetching, and components:

```typescript
import { queryOptions } from '@tanstack/react-query'

export const postsQueryOptions = (page: number) => queryOptions({
  queryKey: ['posts', page],
  queryFn: () => fetchPosts(page),
  staleTime: 1000 * 60 * 5,
})

// Use anywhere
const { data } = useQuery(postsQueryOptions(1))
const { data } = useSuspenseQuery(postsQueryOptions(1))
await queryClient.prefetchQuery(postsQueryOptions(1))
await queryClient.ensureQueryData(postsQueryOptions(1))
```

### Query Key Conventions

```typescript
// Hierarchical keys enable targeted invalidation
['posts']                          // All posts
['posts', 'list', { page, sort }]  // Filtered list
['posts', 'detail', postId]        // Single post

// Invalidate all posts (lists + details)
queryClient.invalidateQueries({ queryKey: ['posts'] })

// Invalidate only lists
queryClient.invalidateQueries({ queryKey: ['posts', 'list'] })
```

### useSuspenseQuery

Preferred over `useQuery` when used with `<Suspense>` boundaries — eliminates loading state checks:

```typescript
// With useQuery — must handle loading/error
const { data, isLoading, error } = useQuery(postsQueryOptions(page))
if (isLoading) return <Skeleton />
if (error) return <Error />
// data may still be undefined here

// With useSuspenseQuery — data is always defined
function Posts({ page }: { page: number }) {
  const { data } = useSuspenseQuery(postsQueryOptions(page))
  return <PostList posts={data} />  // data is guaranteed
}

// Parent handles loading + error
<ErrorBoundary fallback={<Error />}>
  <Suspense fallback={<Skeleton />}>
    <Posts page={1} />
  </Suspense>
</ErrorBoundary>
```

### Dependent Queries

```typescript
// Sequential — second query waits for first
const { data: user } = useQuery({ queryKey: ['user', id], queryFn: () => fetchUser(id) })
const { data: projects } = useQuery({
  queryKey: ['projects', user?.orgId],
  queryFn: () => fetchProjects(user!.orgId),
  enabled: !!user?.orgId,  // Only runs when user is loaded
})
```

### Infinite Queries

```typescript
const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteQuery({
  queryKey: ['posts', 'infinite'],
  queryFn: ({ pageParam }) => fetchPosts({ cursor: pageParam, limit: 20 }),
  initialPageParam: 0,
  getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
})

// Flatten pages for rendering
const allPosts = data?.pages.flatMap(page => page.items) ?? []
```

### Mutations

```typescript
const mutation = useMutation({
  mutationFn: (newPost: CreatePostInput) => createPost(newPost),
  onSuccess: () => {
    // Invalidate and refetch related queries
    queryClient.invalidateQueries({ queryKey: ['posts'] })
  },
})

mutation.mutate({ title: 'New Post', body: '...' })
```

### Optimistic Updates

```typescript
const mutation = useMutation({
  mutationFn: updatePost,
  onMutate: async (updatedPost) => {
    // Cancel outgoing refetches
    await queryClient.cancelQueries({ queryKey: ['posts', updatedPost.id] })

    // Snapshot previous value
    const previous = queryClient.getQueryData(['posts', updatedPost.id])

    // Optimistically update cache
    queryClient.setQueryData(['posts', updatedPost.id], updatedPost)

    return { previous }  // Context for rollback
  },
  onError: (_err, _vars, context) => {
    // Rollback on error
    if (context?.previous) {
      queryClient.setQueryData(['posts', context.previous.id], context.previous)
    }
  },
  onSettled: () => {
    // Always refetch after error or success to ensure server state
    queryClient.invalidateQueries({ queryKey: ['posts'] })
  },
})
```

### Prefetching

```typescript
// Prefetch on hover (non-blocking, populates cache)
<Link
  onMouseEnter={() => queryClient.prefetchQuery(postQueryOptions(postId))}
  to={`/posts/${postId}`}
>
  View Post
</Link>

// Prefetch in route loader (TanStack Router integration)
loader: ({ context: { queryClient }, params }) => {
  queryClient.prefetchQuery(postQueryOptions(params.postId))
}

// ensureQueryData — blocks until data is available (for SSR/loaders)
loader: async ({ context: { queryClient }, params }) => {
  await queryClient.ensureQueryData(postQueryOptions(params.postId))
}
```

### Error and Retry Configuration

```typescript
useQuery({
  queryKey: ['data'],
  queryFn: fetchData,
  retry: (failureCount, error) => {
    if (error.status === 404) return false  // Don't retry 404s
    return failureCount < 3
  },
  retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
})
```

### Devtools

```typescript
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

// Add inside QueryClientProvider — auto-removed in production builds
<QueryClientProvider client={queryClient}>
  <App />
  <ReactQueryDevtools initialIsOpen={false} />
</QueryClientProvider>
```

### Unstable Dependencies in useEffect

TanStack Query mutations and refetch functions create new references on every render. Including them in useEffect dependency arrays causes effects to re-run repeatedly.

**Problem — mutation in deps causes infinite re-runs:**

```tsx
const mutation = useMutation(...)

useEffect(() => {
  const unlisten = listen("event", () => mutation.mutate(...));
  return () => { unlisten.then(f => f()); };
}, [mutation]); // mutation changes every render = duplicate listeners
```

**Solution — use refs for unstable values:**

```tsx
const mutation = useMutation(...)
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
queryClient.invalidateQueries({ queryKey: ['processes', projectId] })

// Good — updates cache in place, only components reading changed data re-render
const freshData = await fetchProcesses(projectId)
queryClient.setQueryData(['processes', projectId], freshData)
```

**Why:** `invalidateQueries` marks queries as stale and triggers refetches, causing all subscribers to re-render during the loading state. `setQueryData` updates the cache directly without intermediate states.

### useQueries Returns Unstable Arrays

Even with `combine`, `useQueries` returns new array references on every render:

```tsx
// Problem — results array changes every render even if data unchanged
const results = useQueries({
  queries: items.map(item => ({ queryKey: ['item', item.id], queryFn: () => fetch(item.id) })),
  combine: (results) => results.map(r => r.data),  // Still new array each render!
})

// Solution — stabilize with serialization-based memoization
const prevRef = useRef<string>("")
const prevData = useRef<Data[]>([])
const serialized = JSON.stringify(results)
if (serialized !== prevRef.current) {
  prevRef.current = serialized
  prevData.current = results
}
const stableResults = prevData.current
```

### Common Mistakes

| Mistake | Fix |
|---------|-----|
| No `queryOptions` helper | Define once, reuse in components, loaders, prefetch |
| `useQuery` with inline loading checks | Use `useSuspenseQuery` + `<Suspense>` boundaries |
| Mutation in useEffect deps | Use refs for unstable mutation/refetch references |
| `invalidateQueries` for high-frequency updates | Use `setQueryData` to avoid re-render cascade |
| Not prefetching on hover/route load | Use `prefetchQuery` for instant navigations |
| Missing `gcTime` tuning | Set based on data freshness needs — default 5 min may be too short |
| Flat query keys | Use hierarchical keys for targeted invalidation |
| Missing error boundaries with `useSuspenseQuery` | Always wrap in `<ErrorBoundary>` |
| Optimistic update without rollback | Always return snapshot in `onMutate`, restore in `onError` |
| Forgetting `onSettled` invalidation | Always refetch after mutation to sync with server |
<!-- RULES_END -->
