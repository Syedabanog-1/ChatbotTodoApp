"""Main entry point for the chatbot CLI application."""

import sys
from pathlib import Path

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from src.lib.config import config
from src.lib.logging_config import setup_logging, get_logger
from src.services.task_repository import TaskRepository
from src.models.user_preferences import UserPreferences


def initialize_application():
    """Initialize application components."""
    # Setup logging
    logger = setup_logging(config.log_level, config.log_file)
    logger.info("Starting AI-Powered Multilingual Voice-Enabled Todo Chatbot")

    # Validate configuration
    is_valid, errors = config.validate()
    if not is_valid:
        logger.error("Configuration validation failed:")
        for error in errors:
            logger.error(f"  - {error}")
        print("\n❌ Configuration Error:")
        for error in errors:
            print(f"  - {error}")
        print("\nPlease check your .env file and ensure OPENAI_API_KEY is set.")
        sys.exit(1)

    # Initialize database
    logger.info(f"Initializing database at {config.database_path}")
    task_repo = TaskRepository(config.database_path)

    # Load or create user preferences
    logger.info(f"Loading user preferences from {config.preferences_path}")
    user_prefs = UserPreferences.load_from_file(config.preferences_path)

    # Save default preferences if file doesn't exist
    user_prefs.save_to_file(config.preferences_path)

    logger.info("Application initialized successfully")
    return task_repo, user_prefs, logger


def print_welcome():
    """Print welcome message."""
    print("\n" + "="*60)
    print("🤖 AI-Powered Multilingual Voice-Enabled Todo Chatbot v1.0")
    print("="*60)
    print("\nWelcome! I can help you manage your tasks in multiple languages.")
    print("Type your command or '/help' for assistance.\n")


def print_help():
    """Print help message."""
    print("\n📚 Available Commands:")
    print("  /help           - Show this help message")
    print("  /voice on       - Enable voice input/output")
    print("  /voice off      - Disable voice mode")
    print("  /language <code> - Set preferred language (e.g., /language es)")
    print("  /clear          - Clear conversation context")
    print("  /settings       - View/modify user preferences")
    print("  /exit           - Quit the chatbot")
    print("\n💡 Example Commands:")
    print("  - Add a task to buy groceries")
    print("  - Show my tasks")
    print("  - Mark task 1 as completed")
    print("  - Delete task 2")
    print("  - Añadir tarea comprar leche (Spanish)")
    print()


def main():
    """Main application loop."""
    try:
        # Initialize application
        task_repo, user_prefs, logger = initialize_application()

        # Print welcome message
        print_welcome()
        print(f"✅ Database initialized at {config.database_path}")
        print(f"✅ Preferences loaded from {config.preferences_path}")
        print()

        # Main interaction loop
        while True:
            try:
                user_input = input("You: ").strip()

                if not user_input:
                    continue

                # Handle special commands
                if user_input == '/help':
                    print_help()
                    continue

                if user_input == '/exit':
                    print("\n👋 Goodbye! Have a great day!")
                    logger.info("User exited application")
                    break

                if user_input == '/settings':
                    print(f"\n⚙️ Current Settings:")
                    print(f"  Language: {user_prefs.preferred_language or 'Auto-detect'}")
                    print(f"  Voice Input: {'Enabled' if user_prefs.voice_input_enabled else 'Disabled'}")
                    print(f"  Voice Output: {'Enabled' if user_prefs.voice_output_enabled else 'Disabled'}")
                    print(f"  Display Format: {user_prefs.display_format}")
                    print(f"  TTS Voice: {user_prefs.tts_voice}")
                    print()
                    continue

                if user_input.startswith('/voice '):
                    mode = user_input[7:].lower()
                    if mode == 'on':
                        user_prefs.voice_input_enabled = True
                        user_prefs.voice_output_enabled = True
                        user_prefs.save_to_file(config.preferences_path)
                        print("Chatbot: 🎤 Voice mode enabled.")
                    elif mode == 'off':
                        user_prefs.voice_input_enabled = False
                        user_prefs.voice_output_enabled = False
                        user_prefs.save_to_file(config.preferences_path)
                        print("Chatbot: 🔇 Voice mode disabled.")
                    else:
                        print("Chatbot: Invalid voice command. Use '/voice on' or '/voice off'.")
                    continue

                if user_input.startswith('/language '):
                    lang_code = user_input[10:].strip().lower()
                    user_prefs.preferred_language = lang_code
                    user_prefs.save_to_file(config.preferences_path)
                    print(f"Chatbot: 🌍 Language set to {lang_code}")
                    continue

                if user_input == '/clear':
                    print("Chatbot: 🧹 Conversation context cleared.")
                    continue

                # TODO: Process user input with agents
                # For now, placeholder response
                logger.info(f"User input: {user_input}")
                print("Chatbot: I'm still being developed. Full agent integration coming soon!")
                print("         For now, you can use /help to see available commands.")

            except KeyboardInterrupt:
                print("\n\n👋 Goodbye! Have a great day!")
                logger.info("User interrupted application")
                break

            except Exception as e:
                logger.error(f"Error processing input: {e}", exc_info=True)
                print(f"Chatbot: ❌ An error occurred: {str(e)}")
                print("         Please try again or type /help for assistance.")

    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        if 'logger' in locals():
            logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
