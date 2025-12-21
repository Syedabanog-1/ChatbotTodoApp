/**
 * Professional AI Voice Chatbot
 * Enhanced voice recognition & modern UI interactions
 */

document.addEventListener('DOMContentLoaded', function() {
    // DOM Elements
    const chatHistory = document.getElementById('chat-history');
    const userInput = document.getElementById('user-input');
    const sendBtn = document.getElementById('send-btn');
    const voiceBtn = document.getElementById('voice-btn');
    const voiceVisualizer = document.getElementById('voice-visualizer');
    const voiceStatus = document.getElementById('voice-status');
    const todoItems = document.getElementById('todo-items');
    const taskCount = document.getElementById('task-count');
    const languageSelect = document.getElementById('language-select');
    const translateBtn = document.getElementById('translate-btn');

    // Quick action buttons
    const addTaskBtn = document.getElementById('add-task-btn');
    const showTasksBtn = document.getElementById('show-tasks-btn');
    const clearCompletedBtn = document.getElementById('clear-completed-btn');

    // Configuration
    const BACKEND_URL = window.location.origin;
    const LANGUAGE_CODES = {
        'en': 'en-US',
        'ur': 'ur-PK',
        'hi': 'hi-IN',
        'es': 'es-ES',
        'fr': 'fr-FR',
        'ar': 'ar-SA'
    };

    // Voice Recognition Setup
    let recognition = null;
    let isListening = false;

    // Initialize Speech Recognition
    if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        recognition = new SpeechRecognition();
        recognition.continuous = false;
        recognition.interimResults = false;
        recognition.maxAlternatives = 1;

        recognition.onstart = function() {
            isListening = true;
            voiceBtn.classList.add('listening');
            voiceVisualizer.classList.remove('hidden');
            voiceStatus.textContent = '🎤 Listening to your voice...';
            voiceStatus.style.color = '#ef4444';
            console.log('🎤 Voice recognition started');
        };

        recognition.onresult = function(event) {
            const transcript = event.results[0][0].transcript;
            const confidence = event.results[0][0].confidence;

            console.log('✅ Recognized:', transcript, 'Confidence:', confidence);

            userInput.value = transcript;
            voiceStatus.textContent = `✓ Heard: "${transcript}"`;
            voiceStatus.style.color = '#10b981';

            // Auto-send after 1 second
            setTimeout(() => {
                sendMessage();
            }, 1000);
        };

        recognition.onerror = function(event) {
            console.error('❌ Voice error:', event.error);
            let errorMessage = 'Voice recognition error';

            switch(event.error) {
                case 'no-speech':
                    errorMessage = 'No speech detected. Please try again.';
                    break;
                case 'audio-capture':
                    errorMessage = 'Microphone not found or not allowed.';
                    break;
                case 'not-allowed':
                    errorMessage = 'Microphone permission denied.';
                    break;
                case 'network':
                    errorMessage = 'Network error occurred.';
                    break;
                default:
                    errorMessage = `Error: ${event.error}`;
            }

            voiceStatus.textContent = `❌ ${errorMessage}`;
            voiceStatus.style.color = '#ef4444';
            voiceBtn.classList.remove('listening');
            voiceVisualizer.classList.add('hidden');
            isListening = false;
        };

        recognition.onend = function() {
            console.log('🛑 Voice recognition ended');
            voiceBtn.classList.remove('listening');
            voiceVisualizer.classList.add('hidden');
            isListening = false;

            // Clear status after 3 seconds
            setTimeout(() => {
                if (voiceStatus.textContent.includes('Listening')) {
                    voiceStatus.textContent = '';
                }
            }, 3000);
        };
    } else {
        // Voice not supported
        voiceBtn.disabled = true;
        voiceBtn.style.opacity = '0.5';
        voiceBtn.title = 'Voice input not supported in this browser. Use Chrome, Edge, or Safari.';
        console.warn('⚠️ Web Speech API not supported in this browser');
    }

    // Voice Button Click Handler
    voiceBtn.addEventListener('click', function() {
        if (!recognition) {
            alert('⚠️ Voice recognition is not supported in your browser.\n\nPlease use:\n- Google Chrome\n- Microsoft Edge\n- Safari');
            return;
        }

        if (isListening) {
            // Stop listening
            recognition.stop();
            voiceStatus.textContent = 'Voice input cancelled';
            voiceStatus.style.color = '#6b7280';
        } else {
            // Start listening
            try {
                const lang = LANGUAGE_CODES[languageSelect.value] || 'en-US';
                recognition.lang = lang;
                recognition.start();
                console.log(`🎤 Starting recognition in ${lang}`);
            } catch (error) {
                console.error('Error starting recognition:', error);
                voiceStatus.textContent = 'Failed to start voice input';
                voiceStatus.style.color = '#ef4444';
            }
        }
    });

    // Utility Functions
    function getCurrentTime() {
        const now = new Date();
        return now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    }

    function addMessage(text, isUser) {
        const messageDiv = document.createElement('div');
        messageDiv.classList.add('message');
        messageDiv.classList.add(isUser ? 'user-message' : 'bot-message');

        const avatar = document.createElement('div');
        avatar.classList.add('message-avatar');
        avatar.textContent = isUser ? '👤' : '🤖';

        const contentDiv = document.createElement('div');
        contentDiv.classList.add('message-content');

        const headerDiv = document.createElement('div');
        headerDiv.classList.add('message-header');

        const sender = document.createElement('span');
        sender.classList.add('message-sender');
        sender.textContent = isUser ? 'You' : 'AI Assistant';

        const time = document.createElement('span');
        time.classList.add('message-time');
        time.textContent = getCurrentTime();

        headerDiv.appendChild(sender);
        headerDiv.appendChild(time);

        const textDiv = document.createElement('div');
        textDiv.classList.add('message-text');
        textDiv.textContent = text;

        contentDiv.appendChild(headerDiv);
        contentDiv.appendChild(textDiv);

        messageDiv.appendChild(avatar);
        messageDiv.appendChild(contentDiv);

        chatHistory.appendChild(messageDiv);
        chatHistory.scrollTop = chatHistory.scrollHeight;
    }

    // Get Todos from Backend
    async function getTodos() {
        try {
            const response = await fetch(`${BACKEND_URL}/api/todos`);
            if (response.ok) {
                const todos = await response.json();
                updateTodoList(todos);
                updateTaskCount(todos.length);
            }
        } catch (error) {
            console.error('Error fetching todos:', error);
        }
    }

    function updateTaskCount(count) {
        taskCount.textContent = count;
    }

    // Update Todo List with Action Buttons
    function updateTodoList(todos) {
        todoItems.innerHTML = '';

        if (Array.isArray(todos) && todos.length > 0) {
            todos.forEach(todo => {
                const li = document.createElement('li');
                if (todo.completed) {
                    li.classList.add('completed');
                }

                const taskText = document.createElement('span');
                taskText.className = 'task-text';
                taskText.textContent = todo.title;

                const actionDiv = document.createElement('div');
                actionDiv.className = 'task-actions';

                // Complete button (only for incomplete tasks)
                if (!todo.completed) {
                    const completeBtn = document.createElement('button');
                    completeBtn.textContent = '✓';
                    completeBtn.className = 'task-btn complete-btn';
                    completeBtn.title = 'Mark as complete';
                    completeBtn.onclick = () => markComplete(todo.id, todo.title);
                    actionDiv.appendChild(completeBtn);
                }

                // Update button
                const updateBtn = document.createElement('button');
                updateBtn.textContent = '✏️';
                updateBtn.className = 'task-btn update-btn';
                updateBtn.title = 'Edit task';
                updateBtn.onclick = () => updateTask(todo.id, todo.title);
                actionDiv.appendChild(updateBtn);

                // Delete button
                const deleteBtn = document.createElement('button');
                deleteBtn.textContent = '🗑️';
                deleteBtn.className = 'task-btn delete-btn';
                deleteBtn.title = 'Delete task';
                deleteBtn.onclick = () => deleteTask(todo.id, todo.title);
                actionDiv.appendChild(deleteBtn);

                li.appendChild(taskText);
                li.appendChild(actionDiv);
                todoItems.appendChild(li);
            });
        } else {
            const emptyState = document.createElement('li');
            emptyState.className = 'empty-state';
            emptyState.innerHTML = `
                <div class="empty-icon">📭</div>
                <p>No tasks yet</p>
                <small>Add your first task to get started!</small>
            `;
            todoItems.appendChild(emptyState);
        }
    }

    // Task Actions
    async function markComplete(taskId, taskTitle) {
        await sendMessage(`Mark "${taskTitle}" as complete`, false);
    }

    async function updateTask(taskId, taskTitle) {
        const newTitle = prompt('Update task to:', taskTitle);
        if (newTitle && newTitle.trim() && newTitle !== taskTitle) {
            await sendMessage(`Update task "${taskTitle}" to "${newTitle}"`, false);
        }
    }

    async function deleteTask(taskId, taskTitle) {
        if (confirm(`Delete task: "${taskTitle}"?`)) {
            await sendMessage(`Delete task "${taskTitle}"`, false);
        }
    }

    // Send Message to Backend
    async function sendMessage(messageText = null, showInChat = true) {
        const message = messageText || userInput.value.trim();
        if (!message) return;

        // Show user message in chat
        if (showInChat) {
            addMessage(message, true);
        }

        if (!messageText) {
            userInput.value = '';
        }

        const selectedLang = languageSelect.value;

        try {
            const response = await fetch(`${BACKEND_URL}/api/chat`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: message,
                    language: selectedLang
                })
            });

            if (response.ok) {
                const data = await response.json();

                // Show bot response
                if (data.response) {
                    addMessage(data.response, false);
                }

                // Update todo list
                if (data.todos) {
                    updateTodoList(data.todos);
                    updateTaskCount(data.todos.length);
                }
            } else {
                addMessage('Sorry, there was an error processing your request.', false);
            }
        } catch (error) {
            console.error('Error sending message:', error);
            addMessage('Sorry, could not connect to the server. Please check your connection.', false);
        }
    }

    // Quick Actions
    addTaskBtn.addEventListener('click', function() {
        const task = prompt('📝 Enter new task:');
        if (task && task.trim()) {
            sendMessage(`Add task: ${task}`);
        }
    });

    showTasksBtn.addEventListener('click', function() {
        sendMessage('Show all my tasks');
    });

    clearCompletedBtn.addEventListener('click', function() {
        if (confirm('Delete all completed tasks?')) {
            sendMessage('Delete all completed tasks');
        }
    });

    // Translation Function
    translateBtn.addEventListener('click', async function() {
        const targetLang = languageSelect.value;
        if (targetLang === 'en') {
            alert('Already in English. Select another language to translate.');
            return;
        }

        const taskTexts = document.querySelectorAll('.task-text');
        if (taskTexts.length === 0 || (taskTexts.length === 1 && taskTexts[0].closest('.empty-state'))) {
            alert('No tasks to translate!');
            return;
        }

        translateBtn.disabled = true;
        translateBtn.innerHTML = '<span class="btn-icon">⏳</span><span class="btn-text">Translating...</span>';

        try {
            for (let taskText of taskTexts) {
                if (taskText.closest('.empty-state')) continue;

                const originalText = taskText.getAttribute('data-original') || taskText.textContent;

                if (!taskText.getAttribute('data-original')) {
                    taskText.setAttribute('data-original', originalText);
                }

                const response = await fetch(`${BACKEND_URL}/api/chat`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        message: `Translate to ${getLanguageName(targetLang)}: ${originalText}`,
                        language: targetLang
                    })
                });

                if (response.ok) {
                    const data = await response.json();
                    if (data.response) {
                        taskText.textContent = data.response.replace(/^(Translated:|Translation:)/i, '').trim();
                    }
                }
            }

            voiceStatus.textContent = '✓ Translation completed!';
            voiceStatus.style.color = '#10b981';
            setTimeout(() => { voiceStatus.textContent = ''; }, 3000);
        } catch (error) {
            console.error('Translation error:', error);
            alert('Translation failed. Please try again.');
        } finally {
            translateBtn.disabled = false;
            translateBtn.innerHTML = '<span class="btn-icon">🔄</span><span class="btn-text">Translate</span>';
        }
    });

    function getLanguageName(code) {
        const names = {
            'en': 'English',
            'ur': 'Urdu',
            'hi': 'Hindi',
            'es': 'Spanish',
            'fr': 'French',
            'ar': 'Arabic'
        };
        return names[code] || 'English';
    }

    // Event Listeners
    sendBtn.addEventListener('click', () => sendMessage());

    userInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // Focus input on load
    userInput.focus();

    // Initialize
    getTodos();

    // Auto-refresh todos every 5 seconds
    setInterval(getTodos, 5000);

    console.log('✅ AI Voice Chatbot initialized successfully!');
});
