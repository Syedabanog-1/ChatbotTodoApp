<!--
Sync Impact Report:
Version: 0.0.0 → 1.0.0
Type: MAJOR (Initial ratification of project constitution)

Modified Principles:
- All principles newly defined (previously placeholder template)

Added Sections:
- Core Principles (9 principles defined)
- Technology Stack Requirements
- Development Workflow
- Governance

Removed Sections:
- None (template placeholders replaced)

Templates Requiring Updates:
✅ plan-template.md - Constitution Check section aligns with principles
✅ spec-template.md - Requirements structure compatible with constitution
✅ tasks-template.md - Task categorization aligns with testing and architecture principles

Follow-up TODOs:
- None - all placeholders resolved
-->

# AI-Powered Todo Chatbot Constitution

## Core Principles

### I. Agent-First Architecture (NON-NEGOTIABLE)

All functionality MUST be designed as modular, composable AI agents. Each agent is a reusable intelligence unit with:

- Single, well-defined responsibility
- Clear input/output contracts via MCP protocol
- Ability to call other agents or tools through MCP
- Independent testability and observability

**Rationale**: Agent-first design ensures scalability, maintainability, and reusability across different interfaces (console, web, mobile). This principle prevents monolithic design and enables incremental feature development.

### II. OpenAI Technology Stack (NON-NEGOTIABLE)

The following technologies are mandated and MUST be used:

- **OpenAI ChatKit**: For conversational UI and user interaction management
- **OpenAI Agents SDK**: For agent orchestration, lifecycle management, and coordination
- **Official MCP SDK**: For all tool-calling, resource access, and inter-agent communication

**Rationale**: Standardization on OpenAI's official tooling ensures long-term support, community alignment, and best practices for AI-powered applications.

### III. Console-First, API-Ready

The application MUST:

- Operate fully in a command-line interface (CLI) environment
- Expose all core functionality through a well-defined internal API
- Support future extension to web or mobile UIs without core logic changes
- Use text-based I/O as the primary interaction model

**Rationale**: Console-first development ensures focus on core functionality and agent design. The API-ready constraint prevents tight coupling to the CLI and enables future UI flexibility.

### IV. Multimodal & Multilingual Intelligence (NON-NEGOTIABLE)

The system MUST support:

- **Text input**: Natural language commands typed by the user
- **Voice input**: Speech-to-text (STT) conversion for spoken commands
- **Voice output**: Text-to-speech (TTS) for audible responses (optional per user preference)
- **Language Detection**: Automatic detection of input language (spoken or written)
- **Translation**: Internal processing in English; responses in user's original language

**Agents Required**:
- Language Detection Agent
- Translation Agent (bidirectional)
- Voice Processing Agent (STT/TTS integration)

**Rationale**: True conversational AI must be accessible across modalities and languages. This ensures global usability and natural interaction patterns.

### V. Intent-Driven Todo Management (NON-NEGOTIABLE)

All todo operations (Create, Read, Update, Patch, Delete) MUST be executed through AI intent understanding. The system MUST:

- Parse natural language input to extract user intent
- Map intent to specific todo operations
- Handle ambiguous or incomplete requests gracefully
- Ask clarifying questions when necessary (never crash or fail silently)

**Agents Required**:
- Intent Classification Agent
- Task Operation Sub-Agents: Add, Update, Patch, Delete, Read

**Rationale**: Users interact naturally, not through rigid commands. Intent-driven design enables conversational task management and reduces cognitive load.

### VI. MCP-Based Tool & Resource Communication

All agent-to-agent communication, tool invocation, and resource access MUST use the official MCP (Model Context Protocol) SDK. This includes:

- Todo data persistence (via MCP resources)
- Language translation services (via MCP tools)
- Voice processing (STT/TTS via MCP tools)
- Inter-agent messaging and coordination

**Rationale**: MCP provides a standardized, versioned protocol for AI agents to communicate. This ensures interoperability, debuggability, and future extensibility.

### VII. Polite, Clear, and Helpful Behavior

The chatbot MUST:

- Respond politely and clearly to all user input
- Provide confirmation messages for successful operations
- Explain what went wrong when errors occur
- Offer suggestions when user intent is unclear
- Never use technical jargon in user-facing messages unless the user demonstrates technical expertise

**Rationale**: User experience is paramount. Clear, polite communication builds trust and ensures users of all technical levels can use the system effectively.

### VIII. Graceful Error Handling

The system MUST NEVER crash or fail silently. When errors occur:

- Log detailed error information for debugging (internal only)
- Present user-friendly error messages (external)
- Offer recovery options or next steps
- Ask clarifying questions if user input was ambiguous
- Maintain conversational context across error recovery

**Edge cases that MUST be handled**:
- Unclear or ambiguous user intent
- Missing required information (e.g., "delete the task" without specifying which)
- Language detection failures
- Voice input quality issues
- Network/service unavailability for external tools

**Rationale**: Robustness and reliability are critical for user trust. Graceful error handling transforms failures into learning opportunities and maintains user engagement.

### IX. Test-Driven Agent Development

All agents MUST be developed following test-driven principles:

- **Contract tests**: Verify agent inputs/outputs conform to MCP contracts
- **Integration tests**: Validate agent orchestration and multi-agent workflows
- **Unit tests**: Test individual agent logic components
- **User scenario tests**: Validate end-to-end user journeys (Given/When/Then format)

**Testing workflow**:
1. Write tests FIRST (tests must fail initially)
2. Implement agent logic
3. Verify tests pass
4. Refactor if needed (tests still pass)

**Rationale**: AI agent behavior can be unprompted and complex. Tests provide a safety net for agent modifications and ensure consistent behavior across updates.

## Technology Stack Requirements

### Required Technologies

- **Language**: Python 3.11+ (for OpenAI SDK compatibility and MCP support)
- **AI Framework**: OpenAI Agents SDK (agent orchestration)
- **Conversational UI**: OpenAI ChatKit (console-based conversational interface)
- **Communication Protocol**: Official MCP SDK (tool-calling and resource access)
- **Voice Processing**: OpenAI Whisper (STT) and TTS API (text-to-speech)
- **Translation**: OpenAI GPT models or dedicated translation tools via MCP
- **Data Persistence**: File-based storage or lightweight database (SQLite) exposed as MCP resource
- **Testing**: pytest (unit, integration, contract testing)

### Technology Constraints

- MUST use official OpenAI libraries (no third-party wrappers for core agent functionality)
- MUST NOT introduce additional AI frameworks (Langchain, LlamaIndex, etc.)
- MUST use MCP for all tool/resource communication (no direct API calls outside MCP)
- SHOULD prefer lightweight dependencies (avoid framework bloat)

## Development Workflow

### Agent Development Lifecycle

1. **Specification**: Define agent purpose, inputs, outputs, and MCP contract
2. **Contract Definition**: Write MCP tool/resource schema (JSON Schema)
3. **Test Creation**: Write contract tests, integration tests, and user scenario tests
4. **Implementation**: Develop agent logic using OpenAI Agents SDK
5. **Validation**: Verify all tests pass and agent behavior matches specification
6. **Documentation**: Update agent registry and usage examples

### Code Review Requirements

All code changes MUST:

- Pass all existing tests (no regressions)
- Include new tests for new functionality
- Follow Python PEP 8 style guidelines
- Include docstrings for all public functions and classes
- Update relevant documentation (agent registry, quickstart guides)

### Complexity Management

- **Prefer composition over inheritance** for agent design
- **Keep agents small and focused** (single responsibility)
- **Avoid premature optimization** (clarity over performance initially)
- **Document all architectural decisions** in ADRs (Architecture Decision Records)

### Deployment Strategy

- **Console deployment**: Package as executable CLI application
- **Environment management**: Use .env files for API keys and configuration
- **Secrets handling**: NEVER commit API keys or secrets to repository
- **Versioning**: Follow semantic versioning (MAJOR.MINOR.PATCH)

## Governance

### Amendment Procedure

This constitution can be amended through the following process:

1. **Proposal**: Any team member can propose an amendment via pull request
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

All specifications, plans, and task lists MUST include a "Constitution Check" section that verifies:

- All NON-NEGOTIABLE principles are satisfied
- Technology stack requirements are met
- Agent design follows core principles
- Testing requirements are included
- Any violations are explicitly justified with documented rationale

### Violation Justification

If a feature MUST violate a constitutional principle:

1. Document the violation explicitly in the plan's "Complexity Tracking" section
2. Explain why the violation is necessary
3. Describe what simpler alternatives were considered and rejected
4. Get explicit approval before implementation
5. Consider whether the constitution itself needs amendment

**Version**: 1.0.0 | **Ratified**: 2025-12-13 | **Last Amended**: 2025-12-13
