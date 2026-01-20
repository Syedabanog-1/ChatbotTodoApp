"""Services for the AI-Powered Multilingual Voice-Enabled Todo Chatbot."""

from .task_repository import TaskRepository

# MCP server is optional - only needed for local development
try:
    from .task_mcp_server import TaskMCPServer, create_task_mcp_server
    __all__ = ['TaskRepository', 'TaskMCPServer', 'create_task_mcp_server']
except ImportError:
    # MCP not installed - production deployment mode
    __all__ = ['TaskRepository']
