<!--
Sync Impact Report:
Version: 1.0.0 → 2.0.0
Type: MAJOR (Architectural pivot from console-first to web-first deployment)

Modified Principles:
- Principle I: "Agent-First Architecture" → "Modular Architecture" (relaxed MCP requirement)
- Principle II: "OpenAI Technology Stack" → "AI-Powered Web Stack" (FastAPI + OpenAI API)
- Principle III: "Console-First, API-Ready" → "Web-First, API-Ready" (primary interface changed)
- Principle IV: "Multimodal & Multilingual Intelligence" → Goals preserved, phased implementation allowed
- Principle V: "Intent-Driven Todo Management" → Preserved, agent requirement relaxed
- Principle VI: "MCP-Based Tool & Resource Communication" → "RESTful API Communication" (MCP optional)
- Principle IX: "Test-Driven Agent Development" → "Test-Driven Development" (tests phased with project maturity)

Added Sections:
- Web deployment technologies (FastAPI, CORS, serverless platforms)
- Serverless deployment strategy (Vercel, Railway)
- Phased implementation approach for features

Removed Sections:
- Strict MCP SDK requirements
- OpenAI ChatKit mandate
- OpenAI Agents SDK mandate
- Console-only deployment constraint

Templates Requiring Updates:
⚠ plan-template.md - Update Constitution Check to reflect web-first principles
⚠ spec-template.md - Update to allow web UI requirements
⚠ tasks-template.md - Update to reflect web implementation patterns

Follow-up TODOs:
- Update plan.md for feature 001-multimodal-todo-chatbot to align with web architecture
- Update spec.md to formally specify web UI requirements
- Update tasks.md to reflect completed web implementation and remaining phased features
- Create ADR documenting architectural pivot from console to web
-->

# AI-Powered Todo Chatbot Constitution

## Core Principles

### I. Modular Architecture

All functionality SHOULD be designed as modular, composable components. Each component is a focused unit with:

- Single, well-defined responsibility
- Clear input/output contracts (RESTful APIs, function interfaces, or MCP protocol)
- Ability to call other components through well-defined interfaces
- Independent testability and observability

**Rationale**: Modular design ensures scalability, maintainability, and reusability across different interfaces (web, console, mobile, API). This principle prevents monolithic design and enables incremental feature development.

### II. AI-Powered Web Stack

The following technologies are recommended for AI-powered web deployment:

- **Web Framework**: FastAPI, Flask, or similar Python web framework for REST APIs
- **AI Engine**: OpenAI API (GPT models for intent classification, language detection, translation)
- **Frontend**: Modern web technologies (HTML/CSS/JavaScript, React, Vue, or vanilla JS)
- **Communication**: RESTful APIs with JSON payloads; MCP SDK optional for advanced agent coordination

**Rationale**: Web-first deployment maximizes accessibility and user reach. FastAPI provides high-performance async capabilities ideal for AI API calls. OpenAI API ensures cutting-edge language understanding without complex agent orchestration overhead.

### III. Web-First, API-Ready

The application MUST:

- Provide a web-based user interface as the primary interaction model
- Expose all core functionality through a well-defined REST API
- Support future extension to console CLI, mobile apps, or other interfaces without core logic changes
- Use responsive design for cross-device compatibility

**Rationale**: Web-first development maximizes user accessibility and reach. The API-ready constraint prevents tight coupling to the web UI and enables future interface flexibility (CLI, mobile, integrations).

### IV. Multimodal & Multilingual Intelligence (Phased Implementation)

The system SHOULD progressively support:

- **Text input** (P0 - MVP): Natural language commands via web text input
- **Voice input** (P1): Speech-to-text conversion using Web Speech API or OpenAI Whisper API
- **Voice output** (P2): Text-to-speech for audible responses (optional per user preference)
- **Language Detection** (P1): Automatic detection of input language
- **Translation** (P1): Bidirectional translation to support multilingual users

**Implementation Approach**:
- Phase 0 (MVP): English text-based interaction only
- Phase 1: Add language detection and translation services
- Phase 2: Add voice input/output capabilities
- Each phase delivers independently valuable functionality

**Rationale**: True conversational AI should be accessible across modalities and languages, but phased implementation enables faster MVP delivery and iterative validation of each capability.

### V. Intent-Driven Todo Management

All todo operations (Create, Read, Update, Patch, Delete) SHOULD be executed through AI intent understanding. The system MUST:

- Parse natural language input to extract user intent
- Map intent to specific todo operations
- Handle ambiguous or incomplete requests gracefully
- Ask clarifying questions when necessary (never crash or fail silently)

**Implementation Options**:
- **Simple**: Keyword matching + GPT-4 fallback for complex cases
- **Advanced**: Dedicated intent classification with structured output parsing
- **Agent-based**: Intent Classifier Agent + Task Operation Sub-Agents (if using agent architecture)

**Rationale**: Users interact naturally, not through rigid commands. Intent-driven design enables conversational task management and reduces cognitive load.

### VI. RESTful API Communication

All client-server communication MUST use RESTful API principles:

- **HTTP methods**: GET (read), POST (create), PUT (update), PATCH (partial update), DELETE (delete)
- **JSON payloads**: Structured request/response data
- **Stateless design**: Each request contains all necessary information (or uses session tokens)
- **Error handling**: Standard HTTP status codes + descriptive error messages

**Advanced Option**: MCP (Model Context Protocol) SDK MAY be used for complex agent-to-agent communication in microservice architectures, but is NOT required for basic deployments.

**Rationale**: RESTful APIs are industry-standard, well-understood, and supported by all web technologies. This ensures interoperability, ease of integration, and straightforward debugging.

### VII. Polite, Clear, and Helpful Behavior

The chatbot MUST:

- Respond politely and clearly to all user input
- Provide confirmation messages for successful operations
- Explain what went wrong when errors occur
- Offer suggestions when user intent is unclear
- Never expose technical jargon or error stack traces to end users

**Rationale**: User experience is paramount. Clear, polite communication builds trust and ensures users of all technical levels can use the system effectively.

### VIII. Graceful Error Handling

The system MUST NEVER crash or fail silently. When errors occur:

- Log detailed error information for debugging (internal only, server-side)
- Present user-friendly error messages (external, client-facing)
- Offer recovery options or next steps
- Ask clarifying questions if user input was ambiguous
- Maintain session state across error recovery where possible

**Edge cases that MUST be handled**:
- Unclear or ambiguous user intent
- Missing required information (e.g., "delete the task" without specifying which)
- Language detection failures
- Voice input quality issues (if voice enabled)
- Network/service unavailability for external APIs (OpenAI, translation services)

**Rationale**: Robustness and reliability are critical for user trust. Graceful error handling transforms failures into learning opportunities and maintains user engagement.

### IX. Test-Driven Development (Phased)

Production-ready features SHOULD be developed following test-driven principles:

- **API contract tests**: Verify REST endpoints conform to specifications
- **Integration tests**: Validate end-to-end workflows (user input → AI processing → task operations)
- **Unit tests**: Test individual business logic components
- **User scenario tests**: Validate user journeys (Given/When/Then format)

**Testing workflow**:
1. Write tests FIRST for critical user paths (tests must fail initially)
2. Implement feature logic
3. Verify tests pass
4. Refactor if needed (tests still pass)

**Phased Approach**:
- **Prototype/MVP**: Tests optional; prioritize rapid iteration and user validation
- **Production**: Tests REQUIRED for all critical user flows and edge cases
- **Scale**: Comprehensive test coverage (contract, integration, unit, E2E)

**Rationale**: Tests provide a safety net for modifications and ensure consistent behavior across updates. Phased testing balances speed-to-market with quality assurance.

## Technology Stack Requirements

### Required Technologies

- **Language**: Python 3.11+ (for OpenAI API compatibility and async capabilities)
- **Web Framework**: FastAPI (high-performance async REST API framework)
- **AI Engine**: OpenAI API (GPT-4 for intent classification, language understanding, translation)
- **Data Persistence**: SQLite (local), PostgreSQL (production), or serverless database (Vercel Postgres, PlanetScale)
- **Frontend**: HTML5/CSS3/JavaScript (vanilla or framework: React, Vue, Svelte)
- **CORS**: Middleware for cross-origin resource sharing (web security)
- **Testing**: pytest (API tests, integration tests, unit tests)

### Optional Technologies

- **Voice Processing**: OpenAI Whisper API (STT), OpenAI TTS API, or Web Speech API
- **Translation**: OpenAI GPT models, Google Translate API, or DeepL API
- **Agent Framework**: OpenAI Agents SDK + MCP SDK (if scaling to complex multi-agent architecture)
- **Deployment**: Vercel, Railway, Render, AWS Lambda, or traditional hosting

### Technology Constraints

- MUST use OpenAI API for core AI functionality (intent classification, language understanding)
- SHOULD prefer lightweight dependencies (avoid framework bloat)
- MUST NOT store API keys or secrets in code or version control (use environment variables)
- SHOULD use async/await patterns for I/O-bound operations (API calls, database queries)

## Development Workflow

### Feature Development Lifecycle

1. **Specification**: Define feature purpose, user stories, acceptance criteria
2. **API Contract**: Design REST endpoints (methods, paths, request/response schemas)
3. **Test Creation** (if production-ready): Write API tests, integration tests, scenario tests
4. **Implementation**: Develop backend logic (intent classification, task operations, AI integration)
5. **Frontend Integration**: Build UI components and connect to API endpoints
6. **Validation**: Verify functionality, test edge cases, review code
7. **Documentation**: Update API docs, user guides, and deployment instructions

### Code Review Requirements

All code changes SHOULD:

- Pass all existing tests (no regressions)
- Include new tests for new critical functionality
- Follow Python PEP 8 style guidelines (backend) and ESLint/Prettier (frontend)
- Include docstrings for all public functions and classes
- Update relevant documentation (API docs, README, quickstart guides)

### Complexity Management

- **Prefer composition over inheritance** for component design
- **Keep components small and focused** (single responsibility)
- **Avoid premature optimization** (clarity over performance initially)
- **Document all architectural decisions** in ADRs (Architecture Decision Records)

### Deployment Strategy

- **Serverless deployment** (recommended): Vercel, Railway, Render, AWS Lambda
  - Fast deployment, auto-scaling, minimal ops overhead
  - Environment variables for API keys and configuration
  - Static frontend hosting + serverless backend functions
- **Traditional hosting** (alternative): VPS, Docker containers, Heroku
  - Full control, persistent storage, custom infrastructure
- **Local development**: .env files for API keys, hot-reload for rapid iteration
- **Secrets handling**: NEVER commit API keys or secrets to repository
- **Versioning**: Follow semantic versioning (MAJOR.MINOR.PATCH)

## Governance

### Amendment Procedure

This constitution can be amended through the following process:

1. **Proposal**: Any team member can propose an amendment via pull request or discussion
2. **Discussion**: Team reviews impact on existing code and architecture
3. **Version Bump**: Determine MAJOR/MINOR/PATCH based on change type
4. **Documentation**: Update constitution version and Last Amended date
5. **Propagation**: Update all dependent templates (plan, spec, tasks)
6. **Approval**: Requires consensus or designated architect approval
7. **Migration**: Create migration plan if changes affect existing code

### Versioning Policy

- **MAJOR**: Backward-incompatible principle changes, removed principles, or redefined core architecture
- **MINOR**: New principles added or existing principles materially expanded
- **PATCH**: Clarifications, wording improvements, typo fixes (no semantic changes)

### Compliance Review

All specifications, plans, and task lists SHOULD include a "Constitution Check" section that verifies:

- Core principles are satisfied (or violations explicitly justified)
- Technology stack requirements are met
- Architecture design follows modular principles
- Testing approach aligns with project maturity phase
- Any violations are documented with rationale and mitigation plan

### Violation Justification

If a feature MUST violate a constitutional principle:

1. Document the violation explicitly in the plan's "Complexity Tracking" section
2. Explain why the violation is necessary
3. Describe what simpler alternatives were considered and rejected
4. Get explicit approval before implementation
5. Consider whether the constitution itself needs amendment

**Version**: 2.0.0 | **Ratified**: 2025-12-13 | **Last Amended**: 2025-12-21
