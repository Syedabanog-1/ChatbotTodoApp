
import uvicorn
import os
import sys

# Ensure project root is in path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

if __name__ == "__main__":
    print("Starting AI Chatbot Server...")
    print("Documentation: http://localhost:8000/docs")

    # Run Uvicorn
    # using import string style to enable reload
    try:
        uvicorn.run("src.cli.chatbot_cli:app", host="127.0.0.1", port=8000, reload=False)
    except Exception as e:
        print(f"Failed to start server: {e}")
        input("Press Enter to exit...")
