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
    const readTasksBtn = document.getElementById('read-tasks-btn');
    const clearCompletedBtn = document.getElementById('clear-completed-btn');

    // Configuration - Auto-detect environment (FR-021)
    const BACKEND_URL = (function() {
        // If on localhost, use local backend
        if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
            return 'http://localhost:8000';
        }
        // Otherwise use Hugging Face Spaces production URL
        return 'https://chatbot-todo-app.hf.space'; // Updated Hugging Face Space URL
    })();

    console.log(`🌐 Backend URL: ${BACKEND_URL}`);

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
    let usedVoiceInput = false;  // Track if user used voice for last request

    // Text-to-Speech Setup
    let speechSynthesis = window.speechSynthesis;
    let isSpeaking = false;

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

            // Mark that voice input was used
            usedVoiceInput = true;

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
                    errorMessage = 'Network error. Check your internet connection and try again.';
                    console.warn('⚠️ Voice recognition network error. Possible causes:\n- No internet connection\n- Google Speech API unreachable\n- Firewall/proxy blocking access');
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

    // Voice Button Click Handler (Enhanced with connection check)
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
            // Check internet connection before starting voice input
            if (!navigator.onLine) {
                voiceStatus.textContent = '❌ No internet connection. Voice input requires internet.';
                voiceStatus.style.color = '#ef4444';
                alert('⚠️ Voice Input Requires Internet\n\nVoice recognition needs an active internet connection to work.\n\nPlease check your connection and try again.');
                return;
            }

            // Start listening
            try {
                const lang = LANGUAGE_CODES[languageSelect.value] || 'en-US';
                recognition.lang = lang;
                recognition.start();
                console.log(`🎤 Starting recognition in ${lang}`);
            } catch (error) {
                console.error('Error starting recognition:', error);
                voiceStatus.textContent = '❌ Failed to start voice input';
                voiceStatus.style.color = '#ef4444';
            }
        }
    });

    // Text-to-Speech Function
    function speakText(text, lang = 'en') {
        if (!speechSynthesis) {
            console.warn('Speech synthesis not supported');
            return;
        }

        // Stop any ongoing speech
        if (isSpeaking) {
            speechSynthesis.cancel();
        }

        const utterance = new SpeechSynthesisUtterance(text);

        // Map language codes to speech synthesis voices
        const langMap = {
            'en': 'en-US',
            'ur': 'ur-PK',
            'hi': 'hi-IN',
            'es': 'es-ES',
            'fr': 'fr-FR',
            'ar': 'ar-SA'
        };

        utterance.lang = langMap[lang] || 'en-US';
        utterance.rate = 0.9;  // Slightly slower for better clarity
        utterance.pitch = 1;
        utterance.volume = 1;

        utterance.onstart = function() {
            isSpeaking = true;
            voiceStatus.textContent = '🔊 Speaking...';
            voiceStatus.style.color = '#3b82f6';
        };

        utterance.onend = function() {
            isSpeaking = false;
            voiceStatus.textContent = '✓ Done speaking';
            voiceStatus.style.color = '#10b981';
            setTimeout(() => { voiceStatus.textContent = ''; }, 2000);
        };

        utterance.onerror = function(event) {
            isSpeaking = false;
            console.error('Speech synthesis error:', event);
        };

        speechSynthesis.speak(utterance);
    }

    // Utility Functions
    function getCurrentTime() {
        const now = new Date();
        return now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    }

    function addMessage(text, isUser) {
        const messageDiv = document.createElement('div');
        messageDiv.className = 'flex items-start gap-3 animate-fade-in';

        const avatar = document.createElement('div');
        if (isUser) {
            avatar.className = 'w-8 h-8 bg-gradient-to-br from-blue-500 to-cyan-600 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0 shadow-md';
            avatar.textContent = 'You';
            avatar.style.fontSize = '10px';
        } else {
            avatar.className = 'w-8 h-8 bg-gradient-to-br from-purple-500 to-indigo-600 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0 shadow-md';
            avatar.textContent = 'AI';
        }

        const contentDiv = document.createElement('div');
        contentDiv.className = 'flex-1';

        const headerDiv = document.createElement('div');
        headerDiv.className = 'flex items-center gap-2 mb-1';

        const sender = document.createElement('span');
        sender.className = 'text-sm font-semibold text-gray-800';
        sender.textContent = isUser ? 'You' : 'AI Assistant';

        const time = document.createElement('span');
        time.className = 'text-xs text-gray-500';
        time.textContent = getCurrentTime();

        headerDiv.appendChild(sender);
        headerDiv.appendChild(time);

        const textDiv = document.createElement('div');
        if (isUser) {
            textDiv.className = 'bg-gradient-to-r from-blue-500 to-cyan-600 text-white rounded-2xl rounded-tl-none p-4 shadow-md';
        } else {
            textDiv.className = 'bg-white rounded-2xl rounded-tl-none p-4 shadow-md';
        }

        const messageText = document.createElement('p');
        messageText.className = isUser ? 'text-sm leading-relaxed' : 'text-gray-700 text-sm leading-relaxed';
        messageText.textContent = text;
        textDiv.appendChild(messageText);

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
            } else {
                // Server error - keep existing UI as is (FR-022: read-only mode)
                console.warn(`Server returned ${response.status} - keeping existing tasks visible`);
            }
        } catch (error) {
            // Network error - keep existing UI as is (FR-022: read-only mode)
            console.error('Error fetching todos (keeping existing display):', error);
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
                li.className = 'bg-white rounded-xl p-4 shadow-md hover:shadow-lg transition-all duration-300 transform hover:scale-[1.02]';

                const container = document.createElement('div');
                container.className = 'flex items-center justify-between gap-3';

                const leftSection = document.createElement('div');
                leftSection.className = 'flex items-center gap-3 flex-1';

                // Checkbox/Status indicator
                const statusIcon = document.createElement('div');
                if (todo.completed) {
                    statusIcon.className = 'w-6 h-6 bg-gradient-to-br from-green-500 to-emerald-600 rounded-full flex items-center justify-center text-white text-sm flex-shrink-0 shadow-md';
                    statusIcon.textContent = '✓';
                } else {
                    statusIcon.className = 'w-6 h-6 border-2 border-gray-300 rounded-full flex-shrink-0 hover:border-purple-500 cursor-pointer transition-colors';
                    statusIcon.onclick = () => markComplete(todo.id, todo.title);
                }

                const taskText = document.createElement('span');
                if (todo.completed) {
                    taskText.className = 'text-gray-500 line-through text-sm font-medium';
                } else {
                    taskText.className = 'text-gray-800 text-sm font-medium';
                }
                taskText.textContent = todo.title;

                leftSection.appendChild(statusIcon);
                leftSection.appendChild(taskText);

                const actionDiv = document.createElement('div');
                actionDiv.className = 'flex items-center gap-2';

                // Update button
                const updateBtn = document.createElement('button');
                updateBtn.className = 'w-8 h-8 bg-blue-100 hover:bg-blue-200 text-blue-600 rounded-lg flex items-center justify-center transition-all duration-300 transform hover:scale-110';
                updateBtn.innerHTML = '✏️';
                updateBtn.title = 'Edit task';
                updateBtn.onclick = () => updateTask(todo.id, todo.title);
                actionDiv.appendChild(updateBtn);

                // Delete button
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'w-8 h-8 bg-red-100 hover:bg-red-200 text-red-600 rounded-lg flex items-center justify-center transition-all duration-300 transform hover:scale-110';
                deleteBtn.innerHTML = '🗑️';
                deleteBtn.title = 'Delete task';
                deleteBtn.onclick = () => deleteTask(todo.id, todo.title);
                actionDiv.appendChild(deleteBtn);

                container.appendChild(leftSection);
                container.appendChild(actionDiv);
                li.appendChild(container);
                todoItems.appendChild(li);
            });
        } else {
            const emptyState = document.createElement('li');
            emptyState.className = 'empty-state text-center py-12';
            emptyState.innerHTML = `
                <div class="text-6xl mb-4 animate-bounce-slow">📭</div>
                <p class="text-gray-600 font-semibold text-lg mb-2">No tasks yet</p>
                <p class="text-gray-500 text-sm">Add your first task to get started!</p>
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

                    // Auto-speak response if voice input was used (simplified)
                    if (usedVoiceInput) {
                        console.log('🔊 Voice input detected - speaking response:', data.response.substring(0, 50));
                        speakText(data.response, selectedLang);
                    }
                }

                // Update todo list
                if (data.todos) {
                    updateTodoList(data.todos);
                    updateTaskCount(data.todos.length);
                }

                // Reset voice input flag
                usedVoiceInput = false;
            } else {
                // Server responded but with error status (FR-022)
                const errorMsg = `❌ Server error (${response.status}). Please try again.`;
                addMessage(errorMsg, false);
                showRetryButton(message, selectedLang);
            }
        } catch (error) {
            // Network error - cannot reach server (FR-022)
            console.error('Error sending message:', error);
            const errorMsg = '❌ Could not connect to server. Please check your connection and try again.';
            addMessage(errorMsg, false);
            showRetryButton(message, selectedLang);
        }
    }

    // Retry Button for Failed Requests (FR-022)
    function showRetryButton(originalMessage, originalLang) {
        const retryDiv = document.createElement('div');
        retryDiv.className = 'retry-container';
        retryDiv.style.cssText = 'text-align: center; margin: 10px 0;';

        const retryBtn = document.createElement('button');
        retryBtn.textContent = '🔄 Retry';
        retryBtn.className = 'retry-btn';
        retryBtn.style.cssText = 'padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: 500;';

        retryBtn.onclick = function() {
            retryDiv.remove();
            // Retry the original message
            sendMessage(originalMessage, false);
        };

        retryDiv.appendChild(retryBtn);
        chatHistory.appendChild(retryDiv);
        chatHistory.scrollTop = chatHistory.scrollHeight;
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

    readTasksBtn.addEventListener('click', async function() {
        const taskTexts = document.querySelectorAll('.task-text');
        const selectedLang = languageSelect.value;

        if (taskTexts.length === 0 || (taskTexts.length === 1 && taskTexts[0].closest('.empty-state'))) {
            speakText('No tasks available', selectedLang);
            return;
        }

        // Build task list text for speaking
        let tasksToRead = `You have ${taskTexts.length} task${taskTexts.length !== 1 ? 's' : ''}. `;

        Array.from(taskTexts).forEach((taskText, index) => {
            if (!taskText.closest('.empty-state')) {
                const isCompleted = taskText.closest('li').classList.contains('completed');
                const statusText = isCompleted ? 'completed' : 'pending';
                tasksToRead += `Task ${index + 1}: ${taskText.textContent}, status ${statusText}. `;
            }
        });

        speakText(tasksToRead, selectedLang);
    });

    clearCompletedBtn.addEventListener('click', function() {
        if (confirm('Delete all completed tasks?')) {
            sendMessage('Delete all completed tasks');
        }
    });

    // Translation Function (Backend Batch Translation - FAST!)
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
            // Collect all task texts
            const taskElements = [];
            const originalTexts = [];

            for (let taskText of taskTexts) {
                if (taskText.closest('.empty-state')) continue;

                const originalText = taskText.getAttribute('data-original') || taskText.textContent;

                if (!taskText.getAttribute('data-original')) {
                    taskText.setAttribute('data-original', originalText);
                }

                taskElements.push(taskText);
                originalTexts.push(originalText);
            }

            console.log(`⚡ Batch translating ${originalTexts.length} tasks in ONE API call...`);
            const startTime = Date.now();

            // Call batch translation endpoint (ONE API call for ALL tasks)
            const response = await fetch(`${BACKEND_URL}/api/translate-batch`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    tasks: originalTexts,
                    target_language: targetLang
                })
            });

            if (response.ok) {
                const data = await response.json();
                const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);

                console.log(`✅ Batch translation completed in ${elapsed}s`);

                // Apply translations to UI
                if (data.translations && data.translations.length === taskElements.length) {
                    data.translations.forEach((translation, index) => {
                        taskElements[index].textContent = translation;
                    });

                    voiceStatus.textContent = `✓ Translated ${data.count} tasks in ${elapsed}s!`;
                    voiceStatus.style.color = '#10b981';
                    setTimeout(() => { voiceStatus.textContent = ''; }, 3000);
                } else {
                    throw new Error('Translation count mismatch');
                }
            } else {
                throw new Error('Batch translation request failed');
            }
        } catch (error) {
            console.error('Translation error:', error);
            voiceStatus.textContent = '❌ Translation failed';
            voiceStatus.style.color = '#ef4444';
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

    // Also handle Enter key with modern event listener
    userInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            if (userInput.value.trim() !== '') {
                sendMessage();
            }
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
