"""Simple local server for the AI Chatbot - Windows compatible"""
import os
import sys
from pathlib import Path
import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import logging

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent))

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static file routes (MUST come before API routes to take precedence)
@app.get("/", response_class=FileResponse)
async def read_root():
    return FileResponse("index.html", media_type="text/html")

@app.get("/index.html", response_class=FileResponse)
async def read_index():
    return FileResponse("index.html", media_type="text/html")

@app.get("/styles.css", response_class=FileResponse)
async def serve_css():
    return FileResponse("styles.css", media_type="text/css")

@app.get("/script.js", response_class=FileResponse)
async def serve_js():
    return FileResponse("script.js", media_type="application/javascript")

# Mount the API routes from the original app (comes AFTER static routes)
try:
    from api.index import app as original_app
    # Add API routes (but skip the root "/" route to avoid conflicts)
    for route in original_app.routes:
        # Skip the root route from API to let our HTML serve
        if hasattr(route, 'path') and route.path != "/":
            app.routes.append(route)
    print("API routes loaded successfully")
except Exception as e:
    print(f"Warning: Could not load API routes: {e}")
    print("Server will run with static files only")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    print("="*60)
    print(f"Starting AI Chatbot Server on http://localhost:{port}")
    print("="*60)
    print(f"\nOpen your browser and go to: http://localhost:{port}")
    print("\nPress CTRL+C to stop the server")
    print("="*60)
    uvicorn.run(app, host="0.0.0.0", port=port, log_level="info")
