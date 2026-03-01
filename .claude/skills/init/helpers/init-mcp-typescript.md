# Initialize MCP TypeScript Best Practices

Add MCP TypeScript best practices. **Follow `~/.claude/skills/init/conventions.md` for standard file handling.**

## Target File

`.claude/rules/mcp-typescript.md`

## Path Pattern

`**/*.ts`

## Content

<!-- RULES_START -->
---
paths: "**/*.{ts,json}"
---

# MCP TypeScript Rules

MCP (Model Context Protocol) is the universal standard for connecting AI systems to external data and tools. These rules apply to MCP server development using the official TypeScript SDK.

### Quick Reference

| Primitive | Control | Purpose | Registration |
|-----------|---------|---------|--------------|
| **Tools** | Model-controlled | Executable functions | `server.registerTool()` |
| **Resources** | App-controlled | Read-only data (URIs) | `server.registerResource()` |
| **Prompts** | User-controlled | Reusable templates | `server.registerPrompt()` |

### Server Setup

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "my-mcp-server",
  version: "1.0.0"
});

// Register primitives BEFORE connecting
server.registerTool(/*...*/);

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Tool Implementation

```typescript
server.registerTool(
  "calculate-bmi",
  {
    title: "BMI Calculator",
    description: "Calculate Body Mass Index",  // LLM uses this to select tools
    inputSchema: {
      weightKg: z.number().positive(),
      heightM: z.number().positive()
    },
    outputSchema: {  // Optional structured output
      bmi: z.number(),
      category: z.string()
    }
  },
  async ({ weightKg, heightM }) => {
    const bmi = weightKg / (heightM * heightM);
    return {
      content: [{ type: "text", text: `BMI: ${bmi.toFixed(1)}` }],
      structuredContent: { bmi, category: getBmiCategory(bmi) }
    };
  }
);
```

### Error Handling Pattern

```typescript
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";

async ({ dividend, divisor }) => {
  // Protocol errors: throw McpError
  if (!isValidUri(uri)) {
    throw new McpError(ErrorCode.InvalidParams, "Invalid resource URI format");
  }

  // Execution errors: return isError
  if (divisor === 0) {
    return {
      isError: true,
      content: [{ type: "text", text: "Cannot divide by zero" }]
    };
  }

  return {
    content: [{ type: "text", text: String(dividend / divisor) }]
  };
}
```

| Code | Name | When to use |
|------|------|-------------|
| -32700 | ParseError | Malformed JSON |
| -32600 | InvalidRequest | Missing JSON-RPC fields |
| -32601 | MethodNotFound | Unknown method |
| -32602 | InvalidParams | Schema validation failed |
| -32603 | InternalError | Unexpected server failure |
| -32002 | ResourceNotFound | MCP resource URI not found |

### Resources (Read-Only Data)

```typescript
import { ResourceTemplate } from "@modelcontextprotocol/sdk/server/mcp.js";

// Static resource
server.registerResource(
  "config",
  "config://app/settings",
  { title: "App Configuration", mimeType: "application/json" },
  async (uri) => ({
    contents: [{ uri: uri.href, text: JSON.stringify(await loadConfig()) }]
  })
);

// Dynamic resource with URI template (RFC 6570)
server.registerResource(
  "user-profile",
  new ResourceTemplate("users://{userId}/profile", { list: undefined }),
  { title: "User Profile" },
  async (uri, { userId }) => ({
    contents: [{ uri: uri.href, text: JSON.stringify(await getUser(userId)) }]
  })
);
```

### Prompts (User Templates)

```typescript
server.registerPrompt(
  "code-review",
  {
    title: "Code Review",
    description: "Review code for issues and best practices",
    argsSchema: {
      code: z.string(),
      focus: z.enum(["security", "performance", "style"]).optional()
    }
  },
  ({ code, focus }) => ({
    messages: [{
      role: "user",
      content: {
        type: "text",
        text: `Review this code${focus ? ` focusing on ${focus}` : ""}:\n\n${code}`
      }
    }]
  })
);
```

### Security Checklist

- **Input validation**: Zod schemas validate automatically; sanitize for injection
- **Path traversal**: Resolve paths and check they stay within allowed directories
- **Authentication**: OAuth 2.1 for HTTP; environment variables for stdio
- **Transport**: HTTPS in production; bind local servers to `127.0.0.1` only
- **Sessions**: Use `crypto.randomUUID()` for session IDs
- **Rate limiting**: Implement to prevent abuse

```typescript
function validateFilePath(filePath: string, rootDir: string): string {
  const resolved = path.resolve(rootDir, path.normalize(filePath));
  if (!resolved.startsWith(rootDir)) {
    throw new McpError(ErrorCode.InvalidParams, "Path traversal detected");
  }
  const forbidden = ['.git', '.env', 'node_modules'];
  if (forbidden.some(p => resolved.includes(p))) {
    throw new McpError(ErrorCode.InvalidParams, "Access denied");
  }
  return resolved;
}
```

### Testing with In-Memory Transport

```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";

describe("Calculator Server", () => {
  it("should add numbers correctly", async () => {
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();

    await server.connect(serverTransport);
    const client = new Client({ name: "test", version: "1.0.0" });
    await client.connect(clientTransport);

    const result = await client.callTool({ name: "add", arguments: { a: 2, b: 3 } });
    expect(result.content[0].text).toBe("5");
  });
});
```

### Debugging

```bash
# MCP Inspector - interactive debugging
npx @modelcontextprotocol/inspector node path/to/server.js

# CLI mode
npx @modelcontextprotocol/inspector --cli node build/index.js --method tools/list

# Claude Desktop logs (macOS)
tail -f ~/Library/Logs/Claude/mcp*.log
```

### Graceful Shutdown

```typescript
const transport = new StdioServerTransport();
await server.connect(transport);

process.on("SIGINT", async () => {
  console.error("Shutting down...");  // stderr for logs, stdout for JSON-RPC
  await transport.close();
  process.exit(0);
});
```

### Common Mistakes

| Don't | Do |
|----------|-------|
| Log to stdout | Log to stderr (stdout = JSON-RPC) |
| Register after connect | Register primitives before `server.connect()` |
| Throw for execution errors | Return `{ isError: true, content: [...] }` |
| Use relative paths in config | Use absolute paths |
| Hardcode secrets | Use environment variables |
| Skip input validation | Use Zod schemas on all inputs |
| Bind to 0.0.0.0 locally | Bind to 127.0.0.1 |

### Complete Server Template

```typescript
import { McpServer, ResourceTemplate } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "production-mcp-server",
  version: "1.0.0"
});

// Tools
server.registerTool("analyze", {
  description: "Analyze data and return insights",
  inputSchema: { data: z.string(), format: z.enum(["json", "text"]).default("text") }
}, async ({ data, format }) => {
  const result = await performAnalysis(data);
  return { content: [{ type: "text", text: formatResult(result, format) }] };
});

// Resources
server.registerResource(
  "data",
  new ResourceTemplate("data://{id}", { list: undefined }),
  { title: "Data Records", mimeType: "application/json" },
  async (uri, { id }) => ({
    contents: [{ uri: uri.href, text: JSON.stringify(await fetchData(id)) }]
  })
);

// Prompts
server.registerPrompt("summarize", {
  description: "Summarize content",
  argsSchema: { content: z.string(), length: z.enum(["brief", "detailed"]).default("brief") }
}, ({ content, length }) => ({
  messages: [{ role: "user", content: { type: "text", text: `Summarize (${length}): ${content}` } }]
}));

// Connect and handle shutdown
const transport = new StdioServerTransport();
await server.connect(transport);

process.on("SIGINT", async () => {
  console.error("Shutting down...");
  await transport.close();
  process.exit(0);
});
```

### Reference Servers

Study the official implementations at `modelcontextprotocol/servers`:

- **Everything**: Comprehensive test server with all primitives
- **Filesystem**: Secure file operations
- **GitHub**: Repository management
- **Memory**: Knowledge graph persistence
- **Sequential Thinking**: Dynamic problem-solving
<!-- RULES_END -->
