---
id: 0001
title: Define AI Todo Chatbot Constitution
stage: constitution
date: 2025-12-13
surface: agent
model: claude-sonnet-4-5
feature: none
branch: master
user: ThinK Pad
command: /sp.constitution
labels: ["constitution", "agent-architecture", "openai-stack", "multimodal", "multilingual"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .specify/memory/constitution.md
tests:
  - none
---

## Prompt

/sp.constitution

You are an expert AI software architect and product engineer.

Your task is to define the constitutional foundation for an AI-Powered
Console-Based Todo Application with a Multimodal & Multilingual AI Chatbot.

CORE VISION:
Build a conversational AI Todo system that allows users to manage their
tasks (Create, Read, Update, Patch, Delete) using:
• Natural language text input
• Natural language voice input
• Any spoken or written language (auto-detect & translate)

NON-NEGOTIABLE REQUIREMENTS:
1. Use OpenAI ChatKit for conversational interface
2. Use OpenAI Agents SDK for agent orchestration
3. Use Official MCP SDK for tool & resource communication
4. Operate in a console-based environment (CLI)
5. Support multilingual input/output (text + voice)
6. Support speech-to-text (STT) and text-to-speech (TTS)
7. Todo management must be fully AI-driven via intent understanding

INTELLIGENCE DESIGN:
• Create reusable AI intelligence units:
  - Core Todo Agent
  - Language Detection & Translation Agent
  - Voice Processing Agent
  - Intent Classification Agent
  - Task Operation Sub-Agents (Add, Update, Patch, Delete, Read)
• Agents must be reusable, composable, and skill-based

BEHAVIOR RULES:
• The chatbot must always respond politely and clearly
• If user speaks, convert voice → text automatically
• If user types, process directly
• Detect language automatically
• Translate internally to system language (English)
• Execute task operation
• Respond back in the user's original language
• Optionally respond via voice output

ARCHITECTURE PRINCIPLES:
• Agent-first design
• Tool-calling via MCP
• Clean separation of concerns
• Extensible for future UI (Web / Mobile)
• Console-first but API-ready

ERROR HANDLING:
• Graceful handling of unclear intent
• Ask follow-up questions if task info is missing
• Never crash the application

You must strictly follow this constitution while generating
specifications and plans.

## Response snapshot

Created comprehensive project constitution (v1.0.0) defining 9 core principles:

1. Agent-First Architecture (NON-NEGOTIABLE)
2. OpenAI Technology Stack (NON-NEGOTIABLE)
3. Console-First, API-Ready
4. Multimodal & Multilingual Intelligence (NON-NEGOTIABLE)
5. Intent-Driven Todo Management (NON-NEGOTIABLE)
6. MCP-Based Tool & Resource Communication
7. Polite, Clear, and Helpful Behavior
8. Graceful Error Handling
9. Test-Driven Agent Development

Added Technology Stack Requirements section specifying Python 3.11+, OpenAI Agents SDK, ChatKit, MCP SDK, Whisper/TTS for voice, and pytest for testing.

Added Development Workflow section covering agent development lifecycle, code review requirements, complexity management, and deployment strategy.

Added Governance section with amendment procedure, versioning policy, compliance review requirements, and violation justification process.

All placeholders from template resolved. Constitution file written to .specify/memory/constitution.md with Sync Impact Report prepended.

## Outcome

- ✅ Impact: Initial constitution ratified, establishes architectural foundation for AI-powered todo chatbot
- 🧪 Tests: No tests required (documentation)
- 📁 Files: .specify/memory/constitution.md created/updated
- 🔁 Next prompts: /sp.specify <feature-description> to create first feature specification
- 🧠 Reflection: Constitution provides clear architectural guardrails with 4 NON-NEGOTIABLE principles ensuring OpenAI stack consistency and agent-first design

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): N/A (constitution establishment)
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Validate constitution compliance during first feature specification creation
