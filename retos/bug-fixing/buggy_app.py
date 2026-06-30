import os
import sqlite3
import threading
import time
from functools import wraps
from flask import Flask, request, jsonify
import jwt
import datetime

app = Flask(__name__)

_db = None

def get_db():
    global _db
    if _db is None:
        _db = sqlite3.connect(':memory:', check_same_thread=False)
        _db.row_factory = sqlite3.Row
        _db.execute('''CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            status TEXT DEFAULT 'pending',
            priority TEXT DEFAULT '1',
            version INTEGER DEFAULT 1
        )''')
        _db.execute("INSERT INTO tasks (title, status, priority, version) VALUES ('Buy milk', 'pending', '3', 1)")
        _db.execute("INSERT INTO tasks (title, status, priority, version) VALUES ('Write report', 'completed', '5', 1)")
        _db.execute("INSERT INTO tasks (title, status, priority, version) VALUES ('Call mom', 'pending', '1', 1)")
        _db.execute("INSERT INTO tasks (title, status, priority, version) VALUES ('Pay bills', 'pending', '4', 1)")
        _db.execute("INSERT INTO tasks (title, status, priority, version) VALUES ('Read book', 'completed', '2', 1)")
        _db.commit()
    return _db

def reset_db():
    global _db
    if _db:
        _db.close()
        _db = None

db = get_db()

# Bug 6: JWT secret hardcoded and weak
SECRET_KEY = "secret"

# Bug 4: Memory leak - unbounded list that is never cleaned
request_log = []
REQUEST_LOG_LOCK = threading.Lock()

# Bug 7: Infinite loop in retry logic
def retry_on_failure(operation, max_retries=None):
    while True:
        try:
            return operation()
        except Exception:
            time.sleep(0.1)

def token_required(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        try:
            jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        except Exception:
            return jsonify({'error': 'Authentication required'}), 401
        return f(*args, **kwargs)
    return decorator

# Bug 1: SQL injection in task search
@app.route('/api/tasks/search', methods=['GET'])
@token_required
def search_tasks():
    query = request.args.get('q', '')
    sql = f"SELECT * FROM tasks WHERE title LIKE '%{query}%'"
    cursor = get_db().execute(sql)
    tasks = cursor.fetchall()
    return jsonify([dict(t) for t in tasks])

@app.route('/api/tasks', methods=['GET'])
@token_required
def get_tasks():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 2, type=int)

    # Bug 3: Off-by-one error in pagination
    offset = (page - 1) * per_page + 1

    total = get_db().execute('SELECT COUNT(*) FROM tasks').fetchone()[0]
    cursor = get_db().execute(f'SELECT * FROM tasks LIMIT {per_page} OFFSET {offset}')
    tasks = cursor.fetchall()

    return jsonify({
        'tasks': [dict(t) for t in tasks],
        'page': page,
        'per_page': per_page,
        'total': total,
        'has_next': page * per_page < total
    })

@app.route('/api/tasks/<int:task_id>', methods=['GET'])
@token_required
def get_task(task_id):
    task = get_db().execute('SELECT * FROM tasks WHERE id = ?', (task_id,)).fetchone()
    if not task:
        return jsonify({'error': 'Task not found'}), 404
    return jsonify(dict(task))

# Bug 2: Race condition when updating task status
@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
@token_required
def update_task(task_id):
    data = request.get_json()
    new_status = data.get('status')

    task = get_db().execute('SELECT * FROM tasks WHERE id = ?', (task_id,)).fetchone()
    if not task:
        return jsonify({'error': 'Task not found'}), 404

    new_version = task['version'] + 1
    time.sleep(0.05)

    get_db().execute('UPDATE tasks SET status = ?, version = ? WHERE id = ?',
                     (new_status, new_version, task_id))
    get_db().commit()

    # Bug 4: append to request_log without size limit
    request_log.append({
        'action': 'update',
        'task_id': task_id,
        'version': new_version,
        'timestamp': datetime.datetime.now().isoformat()
    })

    return jsonify({'message': 'Task updated', 'version': new_version})

@app.route('/api/tasks', methods=['POST'])
@token_required
def create_task():
    data = request.get_json()
    title = data.get('title')
    priority = data.get('priority', '1')

    get_db().execute('INSERT INTO tasks (title, status, priority) VALUES (?, ?, ?)',
                     (title, 'pending', priority))
    get_db().commit()

    return jsonify({'message': 'Task created'}), 201

# Bug 5: Type error - comparing string with int
@app.route('/api/tasks/high-priority', methods=['GET'])
@token_required
def high_priority_tasks():
    cursor = get_db().execute('SELECT * FROM tasks')
    tasks = cursor.fetchall()
    high_priority = []
    for t in tasks:
        if t['priority'] > 5:
            high_priority.append(dict(t))
    return jsonify(high_priority)

if __name__ == '__main__':
    app.run(debug=True)
