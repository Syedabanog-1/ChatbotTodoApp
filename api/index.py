"""
Vercel Serverless Deployment - FastAPI AI Todo Chatbot
Clean, fixed & production-ready with SQLite persistence
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import Optional, List
from pathlib import Path
from datetime import datetime
import os
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.models.task import Task
from src.services.task_repository import TaskRepository

# =========================
# App Initialization
# =========================
app = FastAPI(
    title="AI Todo Chatbot API",
    version="2.0.0",
    description="Serverless AI-powered Todo Chatbot with SQLite Persistence"
)

# =========================
# CORS
# =========================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # change in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# Database Initialization
# =========================
# Initialize TaskRepository with SQLite database
db_path = Path(__file__).parent.parent / "data" / "tasks.db"
task_repo = TaskRepository(str(db_path))

# =========================
# Models
# =========================
class ChatRequest(BaseModel):
    message: str
    language: Optional[str] = "en"

# =========================
# OpenAI helper
# =========================
def ask_openai(message: str) -> str:
    try:
        from openai import OpenAI

        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            return "⚠️ OPENAI_API_KEY missing in environment variables."

        client = OpenAI(api_key=api_key)

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful AI Todo assistant."},
                {"role": "user", "content": message}
            ],
            max_tokens=120,
            temperature=0.6
        )

        return response.choices[0].message.content

    except Exception as e:
        return f"❌ OpenAI Error: {e}"

# =========================
# Helper: Convert Task to dict
# =========================
def task_to_dict(task: Task) -> dict:
    """Convert Task object to frontend-compatible dict."""
    return {
        "id": task.id,
        "title": task.description,
        "completed": task.status == "completed"
    }

# =========================
# Todo Logic with SQLite
# =========================
def handle_message(message: str):
    msg = message.lower()

    # ADD
    if "add" in msg and "task" in msg:
        title = message.split(":", 1)[-1].strip()
        if not title or title.lower() in ["add task", "task"]:
            # Extract from natural language
            parts = message.split("add", 1)
            if len(parts) > 1:
                title = parts[1].replace("task", "").replace(":", "").strip()

        new_task = Task(
            description=title,
            status="pending",
            created_at=datetime.now(),
            updated_at=datetime.now()
        )
        task_repo.create(new_task)
        return f"✅ Task added: {title}"

    # LIST
    if "list" in msg or "show" in msg:
        tasks = task_repo.get_all()
        if not tasks:
            return "📝 No tasks available."
        return "\n".join(
            [f"{'✓' if t.status == 'completed' else '○'} {t.id}. {t.description}"
             for t in tasks]
        )

    # COMPLETE
    if "complete" in msg or "done" in msg:
        tasks = task_repo.get_all()
        for t in tasks:
            if str(t.id) in msg or t.description.lower() in msg:
                t.status = "completed"
                task_repo.update(t)
                return f"✅ Completed: {t.description}"
        return "❌ Task not found."

    # DELETE
    if "delete" in msg or "remove" in msg:
        tasks = task_repo.get_all()
        for t in tasks:
            if str(t.id) in msg or t.description.lower() in msg:
                task_repo.delete(t.id)
                return f"🗑️ Deleted: {t.description}"
        return "❌ Task not found."

    # AI fallback
    return ask_openai(message)

# =========================
# API ROUTES
# =========================

@app.get("/api")
async def api_root():
    task_count = len(task_repo.get_all())
    return {
        "status": "ok",
        "service": "AI Todo Chatbot with SQLite",
        "version": "2.0.0",
        "todos": task_count,
        "database": "SQLite (persistent)"
    }

@app.get("/api/todos")
async def get_todos():
    tasks = task_repo.get_all()
    return [task_to_dict(t) for t in tasks]

@app.post("/api/chat")
async def chat(req: ChatRequest):
    reply = handle_message(req.message)
    tasks = task_repo.get_all()
    return {
        "response": reply,
        "todos": [task_to_dict(t) for t in tasks]
    }

# =========================
# Frontend Serving
# =========================
@app.get("/")
async def serve_frontend():
    index_file = Path(__file__).parent.parent / "index.html"
    if index_file.exists():
        return FileResponse(index_file)
    return {"message": "Frontend not found. API is running."}

# =========================
# Static files
# =========================
@app.get("/{file_path:path}")
async def static_files(file_path: str):
    file = Path(__file__).parent.parent / file_path
    if file.exists():
        return FileResponse(file)
    return {"error": "File not found"}

# =========================
# Vercel export
# =========================
__all__ = ["app"]
