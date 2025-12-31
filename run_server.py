"""
Production server entry point for Railway deployment.
Uses uvicorn to run the FastAPI app.
"""
import os
import sys

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

if __name__ == "__main__":
    import uvicorn
    from api.index import app

    port = int(os.environ.get("PORT", 8000))

    print(f"Starting AI Chatbot Server on port {port}...")
    print("API Documentation: /docs")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
