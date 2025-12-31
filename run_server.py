"""
Production server entry point for Railway deployment.
Uses uvicorn to run the FastAPI app.
"""
import os
import sys
import traceback

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

if __name__ == "__main__":
    try:
        import uvicorn

        print("=" * 50)
        print("STARTING AI CHATBOT SERVER")
        print("=" * 50)
        print(f"Python version: {sys.version}")
        print(f"Working directory: {os.getcwd()}")
        print(f"PORT environment variable: {os.environ.get('PORT', 'NOT SET')}")

        port = int(os.environ.get("PORT", 8000))
        print(f"Will bind to port: {port}")

        print("\nImporting FastAPI app...")
        from api.index import app
        print("✓ FastAPI app imported successfully")

        print(f"\nStarting uvicorn server on 0.0.0.0:{port}...")
        print("=" * 50)

        uvicorn.run(
            app,
            host="0.0.0.0",
            port=port,
            log_level="info",
            access_log=True
        )
    except Exception as e:
        print("\n" + "=" * 50)
        print("FATAL ERROR DURING STARTUP")
        print("=" * 50)
        print(f"Error: {e}")
        print("\nFull traceback:")
        traceback.print_exc()
        print("=" * 50)
        sys.exit(1)
