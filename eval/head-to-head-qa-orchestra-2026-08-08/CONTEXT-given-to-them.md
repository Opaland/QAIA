# Project Context — ExpenseFlow

## Application Under Test

- **Name**: ExpenseFlow
- **Type**: Expense report submission and approval workflow (finance / HR)
- **Backend**: Node.js, plain HTTP server, in-memory store
- **API layer**: REST — base URL: `http://localhost:4500/api`
- **Frontend URL (local)**: `http://localhost:4500`
- **Roles**: employee, manager, finance, director (fixed hierarchy manager < finance < director)
- **Seed accounts**: `employee@demo`, `manager@demo`, `finance@demo`, `director@demo` — password `demo1234`

## Environment Setup

- **Start the app**: `cd app && node server.js`
- **Reset state**: `POST /api/reset`
- **Health check URL**: `http://localhost:4500/`

## AC format

Acceptance criteria are numbered `1.`…`8.` in the ticket. Reference them as `AC-1`…`AC-8`.

## Priority definitions

- **Must Test**: core functionality, direct AC mapping, high risk
- **Should Test**: important but lower risk, boundary cases for critical fields
- **Could Test**: unlikely edge cases, cosmetic validation

## Existing coverage

None. This is the first test design pass on this feature.

## Test framework

Playwright, JavaScript, Page Object Model.
