# Boundaries Audit — Subagent Prompts

These are the subagent prompt templates for the boundaries audit. Each is launched in parallel using `Agent` with `subagent_type=Explore`.

---

## Subagent 1: Presentation → Data Violations

```
Audit this codebase for presentation layer directly accessing data layer.

Tech stack: [from Phase 1]
Architecture: [from Phase 1]

## UI IMPORTING DATABASE LAYER (Critical)
Find imports where presentation code accesses persistence:

Rule:
```

FROM: (controllers|views|components|pages|handlers|routes)
TO:   (repositories|persistence|db|dao|prisma|sequelize|typeorm|mongoose)

```

Examples of VIOLATIONS:
```typescript
// In: components/UserList.tsx
import { prisma } from '../db/client';  // VIOLATION: component → db

// In: pages/orders.tsx
import { OrderRepository } from '../repositories/order';  // VIOLATION

// In: controllers/UserController.ts
import { Pool } from 'pg';  // VIOLATION: controller → raw db
```

## CONTROLLERS WITH DATABASE QUERIES (High)

Find controllers/handlers containing:

- SQL strings: SELECT, INSERT, UPDATE, DELETE
- ORM method calls: .find(), .save(), .create(), .query()
- Raw database client usage

```typescript
// VIOLATION: SQL in controller
class UserController {
  async getUser(id: string) {
    const result = await this.pool.query(
      'SELECT * FROM users WHERE id = $1', [id]  // SQL in controller!
    );
    return result.rows[0];
  }
}
```

## WHAT TO ALLOW

Don't flag:

- Controllers calling services/use-cases (proper layering)
- Controllers using DTOs from shared types
- Test files mocking database
- Configuration/bootstrap files

Report each finding with:

- file:line reference
- The violating import or query
- Source layer → target layer
- Suggested fix: introduce service layer, use repository pattern

```

---

## Subagent 2: Domain → Infrastructure Violations

```

Audit this codebase for domain layer depending on infrastructure.

Tech stack: [from Phase 1]
Architecture: [from Phase 1]

## DOMAIN DEPENDING ON INFRASTRUCTURE (Critical)

Core business logic should have NO external dependencies:

Rule:

```
FROM: (domain|entities|core|aggregates|valueobjects)
TO:   (infrastructure|db|external|http|api|aws|gcp|azure|redis|kafka)
```

Examples of VIOLATIONS:

```typescript
// In: domain/entities/Order.ts
import axios from 'axios';  // VIOLATION: domain → http client

// In: domain/services/PricingService.ts
import { redisClient } from '../infrastructure/cache';  // VIOLATION

// In: core/models/User.ts
import { S3 } from 'aws-sdk';  // VIOLATION: domain → cloud service
```

## DOMAIN SHOULD NOT KNOW ABOUT

- HTTP clients (axios, fetch, got)
- Database clients (pg, mysql, prisma, sequelize)
- Message queues (kafka, rabbitmq, sqs)
- Cache systems (redis, memcached)
- Cloud SDKs (aws-sdk, @google-cloud/*)
- File system operations (fs, path for data storage)
- External API clients

## PROPER PATTERN

Domain defines interfaces (ports), infrastructure implements:

```typescript
// GOOD: domain/ports/PaymentGateway.ts (interface only)
export interface PaymentGateway {
  charge(amount: Money): Promise<PaymentResult>;
}

// GOOD: infrastructure/StripePaymentGateway.ts (implementation)
import Stripe from 'stripe';
export class StripePaymentGateway implements PaymentGateway {
  charge(amount: Money): Promise<PaymentResult> { ... }
}
```

Report each finding with:

- file:line reference
- The domain file with infrastructure import
- What infrastructure it depends on
- Suggested fix: define interface in domain, implement in infrastructure

```

---

## Subagent 3: Business Logic in Controllers

```

Audit this codebase for fat controllers with business logic.

Tech stack: [from Phase 1]
Architecture: [from Phase 1]

## FAT CONTROLLER HEURISTICS

A controller is doing too much if:
>
- >50 lines of code (excluding imports/decorators)
- Imports BOTH ORM AND domain entities
- Contains SQL or complex query strings
- Has >4 injected dependencies
- Contains loops processing business data
- Has conditional business rules (not just routing)

## BUSINESS LOGIC INDICATORS

Flag controllers containing:

1. **Data transformation logic**:

```typescript
// Business logic in controller - BAD
const total = items.reduce((sum, item) =>
  sum + item.price * item.quantity * (1 - item.discount), 0
);
```

1. **Business rule conditionals**:

```typescript
// Business rules in controller - BAD
if (user.role === 'admin' || (user.role === 'manager' && user.department === order.department)) {
  // allow action
}
```

1. **Multiple repository calls orchestrated**:

```typescript
// Orchestration in controller - BAD
const user = await userRepo.find(userId);
const orders = await orderRepo.findByUser(userId);
const payments = await paymentRepo.findByOrders(orders.map(o => o.id));
// ... more orchestration
```

## PROPER CONTROLLER

Controller should only:

- Parse request (params, body, query)
- Call single service/use-case method
- Format response
- Handle HTTP-specific concerns (status codes, headers)

```typescript
// GOOD: thin controller
class OrderController {
  async createOrder(req: Request, res: Response) {
    const dto = OrderDto.fromRequest(req.body);
    const result = await this.orderService.createOrder(dto);
    res.status(201).json(result);
  }
}
```

Report each finding with:

- file:line reference
- Controller name
- Lines of code
- Number of dependencies
- Business logic indicators found
- Suggested extraction to service layer

```

---

## Subagent 4: ORM & Database Access Violations

```

Audit this codebase for database queries outside repository/data layer.

Tech stack: [from Phase 1]
Architecture: [from Phase 1]

## ORM OUTSIDE REPOSITORY (High)

Database access should be encapsulated in repository/data layer:

Rule:

```
FROM: NOT (repository|persistence|dao|data|db)
TO:   (typeorm|sequelize|prisma|mongoose|pg|mysql|knex|drizzle)
```

Flag when files outside data layer:

- Import ORM/database packages
- Contain query builder calls
- Have raw SQL strings
- Use database transactions

Examples:

```typescript
// VIOLATION: service using Prisma directly
// In: services/OrderService.ts
import { prisma } from '../db';

class OrderService {
  async getOrders() {
    return prisma.order.findMany({  // Should go through repository
      where: { status: 'active' }
    });
  }
}
```

## RAW SQL DETECTION

Find SQL strings outside data layer:

```regex
/(SELECT|INSERT|UPDATE|DELETE|CREATE|DROP|ALTER)\s+/i
```

In files not matching: `/repository|persistence|dao|migration|seed/`

## TRANSACTION LEAKAGE

Transactions should be managed in service/use-case layer, not scattered:

```typescript
// BAD: transaction in random service
async function updateUserAndOrders() {
  await prisma.$transaction([
    prisma.user.update(...),
    prisma.order.updateMany(...)
  ]);
}
```

Should be in a dedicated use-case or through repository with unit of work.

Report each finding with:

- file:line reference
- The non-repository file
- What database access it contains
- Suggested refactor to repository pattern

```

---

## Subagent 5: Configuration & Environment Violations

```

Audit this codebase for scattered environment variable access.

Tech stack: [from Phase 1]
Architecture: [from Phase 1]

## ENVIRONMENT VARIABLES OUTSIDE CONFIG (Medium)

All env var access should be centralized in config module:

Rule:

```
FROM: NOT (config|configuration|settings|env)
TO:   process.env | os.environ | getenv | Environment. | $_ENV | $_SERVER
```

Examples of VIOLATIONS:

```typescript
// VIOLATION: env var in service
// In: services/EmailService.ts
const apiKey = process.env.SENDGRID_API_KEY;  // Should come from config

// VIOLATION: env var in component
// In: components/App.tsx
const apiUrl = process.env.REACT_APP_API_URL;  // Should come from config
```

## PROPER PATTERN

Centralized config with typed exports:

```typescript
// GOOD: config/index.ts
export const config = {
  email: {
    apiKey: process.env.SENDGRID_API_KEY || '',
    from: process.env.EMAIL_FROM || 'noreply@example.com',
  },
  api: {
    url: process.env.API_URL || 'http://localhost:3000',
  },
} as const;

// GOOD: services/EmailService.ts
import { config } from '../config';
const apiKey = config.email.apiKey;  // Typed, centralized
```

## CROSS-MODULE CONFIG LEAKAGE

Flag when:

- Module A reads env vars that Module B also reads
- Same env var accessed in multiple files
- No config validation at startup

Report each finding with:

- file:line reference
- The env var access
- Where it should be defined (config module)
- Suggested config structure
