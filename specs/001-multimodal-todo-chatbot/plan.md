# Implementation Plan: AI-Powered Multilingual Voice-Enabled Todo Chatbot

**Branch**: `001-multimodal-todo-chatbot` | **Date**: 2025-12-13 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-multimodal-todo-chatbot/spec.md`

**Note**: This plan follows the Spec-Driven Development (SDD) workflow and will be executed through `/sp.plan` (Phases 0-1) and `/sp.tasks` (Phase 2).

## Summary

Build a console-based AI-powered todo chatbot that accepts natural language commands in both text and voice formats, automatically detects and translates between 7+ languages, and uses a modular agent architecture for intent classification, task management, and multimodal interaction. The system will be built using OpenAI Agents SDK, MCP for inter-agent communication, and ChatKit for conversational UI.

**Technical Approach**: Agent-first architecture where each capability (language detection, translation, STT, TTS, intent classification, CRUD operations) is implemented as an independent, composable agent. All agents communicate via MCP protocol, with a Master Chat Agent orchestrating workflows. Console interface built with OpenAI ChatKit, voice processing via Whisper API (STT) and OpenAI TTS API.

## Technical Context

**Language/Version**: Python 3.11+ (required for OpenAI Agents SDK and MCP compatibility)

**Primary Dependencies**:
- OpenAI Agents SDK (agent orchestration)
- OpenAI ChatKit (console conversational UI)
- Official MCP SDK (inter-agent communication, tool-calling)
- OpenAI Whisper API (speech-to-text)
- OpenAI TTS API (text-to-speech)
- OpenAI GPT-4 API (language detection, translation, intent classification)

**Storage**: SQLite (local file-based database) exposed as MCP resource for task persistence

**Testing**: pytest (contract tests, integration tests, unit tests, user scenario tests)

**Target Platform**: Cross-platform console (Windows, macOS, Linux) via terminal/command-line

**Project Type**: Single Python project with modular agent architecture

**Performance Goals**:
- Text command response: <2 seconds end-to-end
- Voice command response: <4 seconds (including transcription)
- Intent classification accuracy: >95%
- Language detection accuracy: >90%
- Voice transcription accuracy: >85% (clean audio)

**Constraints**:
- Console-only interface (no GUI)
- Local-first (no cloud sync, single-user)
- Internet required for voice/translation services (graceful degradation to English text-only when offline)
- Max 1000 tasks optimized (personal use scale)
- Conversation context: last 5 exchanges only

**Scale/Scope**:
- Personal productivity tool (single user)
- 7+ languages supported (English, Spanish, French, Mandarin, Arabic, Hindi, German)
- 10+ agents (Master Chat, Intent Classifier, Language Detector, Translator, Voice Processor, 5 Todo Operation Agents)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Principle I - Agent-First Architecture**: ✅ PASS
- Each capability (intent classification, language detection, translation, STT, TTS, CRUD operations) designed as independent agent
- Agents communicate via MCP protocol
- Single responsibility per agent (e.g., Intent Classifier only classifies, Task Add Agent only adds tasks)
- Master Chat Agent orchestrates multi-agent workflows

**Principle II - OpenAI Technology Stack**: ✅ PASS
- OpenAI ChatKit for conversational UI
- OpenAI Agents SDK for agent lifecycle and orchestration
- Official MCP SDK for all tool-calling and inter-agent communication
- No third-party AI frameworks (Langchain, LlamaIndex) used

**Principle III - Console-First, API-Ready**: ✅ PASS
- Primary interface is command-line via ChatKit
- Core agents expose MCP tools/resources (API contract via JSON Schema)
- Future UI extension possible by swapping ChatKit for web/mobile UI while keeping agent layer unchanged

**Principle IV - Multimodal & Multilingual Intelligence**: ✅ PASS
- Text input via ChatKit console
- Voice input via Whisper API (STT)
- Voice output via TTS API (user-controlled preference)
- Language Detection Agent (auto-detect from text/transcribed speech)
- Translation Agent (bidirectional: user language ↔ English)

**Principle V - Intent-Driven Todo Management**: ✅ PASS
- Intent Classification Agent parses natural language to extract operation (Create/Read/Update/Patch/Delete)
- Graceful handling of ambiguous input (clarifying questions)
- Sub-agents for each operation: TaskAddAgent, TaskReadAgent, TaskUpdateAgent, TaskPatchAgent, TaskDeleteAgent

**Principle VI - MCP-Based Communication**: ✅ PASS
- All agent-to-agent calls via MCP tools
- Task persistence via MCP resource (SQLite database exposed as resource)
- External services (Whisper, TTS, translation) wrapped as MCP tools

**Principle VII - Polite, Clear, Helpful Behavior**: ✅ PASS
- Natural language responses (no error codes exposed to users)
- Confirmation messages for all operations
- Clarifying questions when intent unclear
- User-friendly error messages

**Principle VIII - Graceful Error Handling**: ✅ PASS
- Never crash or fail silently
- Internal error logging (detailed) + user-facing messages (friendly)
- Fallback to text-only English mode when services unavailable
- Conversation context maintained across error recovery

**Principle IX - Test-Driven Agent Development**: ✅ PASS
- Contract tests for all MCP tool/resource schemas
- Integration tests for multi-agent workflows (e.g., voice input → translation → task add)
- Unit tests for individual agent logic
- User scenario tests (Given/When/Then) for all acceptance scenarios in spec

**GATE STATUS**: ✅ ALL CHECKS PASS - Proceed to Phase 0 research

## Project Structure

### Documentation (this feature)

```text
specs/001-multimodal-todo-chatbot/
├── plan.md              # This file (/sp.plan command output)
├── research.md          # Phase 0 output - technology decisions and unknowns resolved
├── data-model.md        # Phase 1 output - Task, ConversationContext, UserPreferences schemas
├── quickstart.md        # Phase 1 output - setup, run, test instructions
├── contracts/           # Phase 1 output - MCP tool/resource JSON schemas
│   ├── master-chat-agent.json
│   ├── intent-classifier-agent.json
│   ├── language-detector-agent.json
│   ├── translator-agent.json
│   ├── voice-processor-agent.json
│   ├── task-add-agent.json
│   ├── task-read-agent.json
│   ├── task-update-agent.json
│   ├── task-patch-agent.json
│   ├── task-delete-agent.json
│   └── task-resource.json
└── tasks.md             # Phase 2 output (/sp.tasks command - NOT created by /sp.plan)
```

### Source Code (repository root)

```text
src/
├── agents/
│   ├── master_chat_agent.py       # Orchestrates workflow, manages conversation context
│   ├── intent_classifier_agent.py # Classifies user intent (Create/Read/Update/Patch/Delete)
│   ├── language_detector_agent.py # Detects input language (7+ languages)
│   ├── translator_agent.py        # Bidirectional translation (user language ↔ English)
│   ├── voice_processor_agent.py   # STT (Whisper) and TTS coordination
│   └── task_agents/
│       ├── task_add_agent.py      # Create new task
│       ├── task_read_agent.py     # List/search/filter tasks
│       ├── task_update_agent.py   # Replace entire task
│       ├── task_patch_agent.py    # Modify specific task fields
│       └── task_delete_agent.py   # Delete task (with confirmation)
│
├── models/
│   ├── task.py                    # Task entity (ID, description, due_date, priority, status, tags, timestamps)
│   ├── conversation_context.py   # ConversationContext (recent exchanges, referenced tasks, language, preferences)
│   └── user_preferences.py        # UserPreferences (language, voice settings, display format)
│
├── services/
│   ├── task_repository.py         # MCP resource wrapper for SQLite task persistence
│   ├── whisper_service.py         # MCP tool wrapper for OpenAI Whisper API (STT)
│   ├── tts_service.py             # MCP tool wrapper for OpenAI TTS API
│   └── translation_service.py     # MCP tool wrapper for GPT-4 translation
│
├── cli/
│   └── chatbot_cli.py             # ChatKit console interface entry point
│
└── lib/
    ├── mcp_helpers.py             # MCP SDK utilities (tool registration, resource exposure)
    └── logging_config.py          # Internal logging setup (error tracking, debugging)

tests/
├── contract/
│   ├── test_mcp_schemas.py        # Validate all MCP tool/resource contracts against JSON Schema
│   └── test_agent_interfaces.py  # Verify agent input/output conform to contracts
│
├── integration/
│   ├── test_text_workflow.py      # End-to-end text-based task management (P1)
│   ├── test_multilingual_workflow.py # Multi-language text interaction (P2)
│   ├── test_voice_workflow.py     # Voice input/output workflow (P3)
│   ├── test_partial_update_workflow.py # Partial task updates (P4)
│   └── test_context_awareness_workflow.py # Conversation context (P5)
│
└── unit/
    ├── test_intent_classifier.py  # Unit tests for intent classification logic
    ├── test_language_detector.py  # Unit tests for language detection
    ├── test_translator.py         # Unit tests for translation logic
    └── test_task_agents.py        # Unit tests for each CRUD agent

config/
└── .env.example                   # Template for API keys (OPENAI_API_KEY, etc.)

data/
└── tasks.db                       # SQLite database (auto-created on first run)

docs/
├── agent-registry.md              # Documentation of all agents, their MCP contracts, usage
└── architecture.md                # System architecture diagram and flow explanations
```

**Structure Decision**: Single Python project structure chosen because:
- Console-only application (no separate frontend/backend)
- All agents run in same process (no distributed services)
- Modular agent design via `src/agents/` directory keeps concerns separated
- Testing organized by type (contract/integration/unit) for TDD workflow

## Complexity Tracking

> **No violations detected. Table intentionally left empty.**

All constitutional principles satisfied with no justified exceptions.

---

## Phase 0: Research & Unknown Resolution

**NEXT STEPS**: The `/sp.plan` command will now proceed to Phase 0 research to resolve the following unknowns and create `research.md`:

### Research Tasks

1. **OpenAI Agents SDK Integration**
   - Investigate: How to structure agent lifecycle with OpenAI Agents SDK
   - Investigate: Agent orchestration patterns (Master agent calling sub-agents)
   - Investigate: Error handling and timeout configuration in agent workflows

2. **MCP SDK Implementation**
   - Investigate: MCP tool registration patterns for external APIs (Whisper, TTS)
   - Investigate: MCP resource patterns for SQLite database access
   - Investigate: Inter-agent communication via MCP (agent-to-agent tool calling)

3. **OpenAI ChatKit Console UI**
   - Investigate: ChatKit setup for terminal-based conversational interface
   - Investigate: User input handling (text vs. voice mode toggle)
   - Investigate: Conversation history management in ChatKit

4. **Voice Processing Best Practices**
   - Investigate: Whisper API latency optimization techniques
   - Investigate: Audio input handling in console environment (microphone access via Python)
   - Investigate: TTS output delivery (play audio in terminal or save to file)

5. **Language Detection & Translation**
   - Investigate: GPT-4 prompt engineering for reliable language detection
   - Investigate: Translation accuracy strategies (bidirectional consistency checks)
   - Investigate: Supported language set (confirm 7+ languages feasible)

6. **SQLite as MCP Resource**
   - Investigate: Best practices for exposing SQLite via MCP resource protocol
   - Investigate: Schema migration strategy for future updates
   - Investigate: Concurrent access handling (if needed for multi-agent scenarios)

7. **Testing Strategy for AI Agents**
   - Investigate: Contract testing frameworks for MCP schemas (JSON Schema validation)
   - Investigate: Integration testing patterns for multi-agent workflows
   - Investigate: Mocking strategies for OpenAI API calls (avoid costs in tests)

**Output**: `research.md` will document decisions, rationale, and alternatives for each research task above.

---

## Phase 1: Design & Contracts

**Prerequisites**: `research.md` complete

### Deliverables

1. **data-model.md**: Entity schemas
   - Task: ID, description, due_date, priority, status, tags, created_at, updated_at
   - ConversationContext: exchanges, referenced_tasks, language, voice_preferences
   - UserPreferences: language, voice_input_enabled, voice_output_enabled, display_format

2. **contracts/**: MCP tool/resource JSON schemas
   - All agent tool contracts (input/output schemas)
   - Task resource contract (SQLite access via MCP)

3. **quickstart.md**: Setup and run instructions
   - Environment setup (Python 3.11+, dependencies)
   - API key configuration (.env file)
   - First run and sample commands

4. **Agent context update**: Run `.specify/scripts/bash/update-agent-context.sh claude` to update agent-specific context file with new technologies from this plan

**STOP POINT**: Phase 1 design artifacts completed. Phase 2 (tasks.md generation via `/sp.tasks`) will be executed separately.

---

## Key Architectural Decisions (Summary)

**To be detailed in research.md after Phase 0:**

1. **Agent Orchestration**: Master Chat Agent coordinates all sub-agents via MCP tool calls
2. **Language Processing Flow**: User Input → Language Detector → Translator (if needed) → Intent Classifier → Task Agent → Translator (response) → Output
3. **Voice Processing Flow**: Audio Input → Whisper STT → [same as text flow] → TTS (if enabled) → Audio Output
4. **State Management**: Conversation context maintained by Master Chat Agent, task data in SQLite via MCP resource
5. **Error Handling**: Layered approach (agent-level errors → Master Chat → user-friendly messages + recovery options)
6. **Testing Strategy**: Contract-first (MCP schemas validated), integration tests for workflows, unit tests for agent logic

---

**COMPLETION STATUS**: Plan structure complete. Ready for Phase 0 research execution.
