import os
os.environ['JWT_SECRET'] = 'test-secret-opencode-challenge-2025'

import sys
import json
import threading
import time
import pytest
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from buggy_app import app, reset_db, request_log, retry_on_failure
import jwt


@pytest.fixture
def client():
    reset_db()
    request_log.clear()
    app.config['TESTING'] = True
    with app.test_client() as c:
        yield c


def get_token():
    return jwt.encode(
        {'user': 'test', 'exp': 9999999999},
        os.environ['JWT_SECRET'],
        algorithm='HS256'
    )


class TestBugs:

    def test_bug1_sql_injection(self, client):
        token = get_token()
        headers = {'Authorization': f'Bearer {token}'}

        resp = client.get("/api/tasks/search?q=' OR 1=1--", headers=headers)
        data = resp.get_json()

        assert isinstance(data, list)
        assert len(data) == 0, (
            f"SQL injection returned {len(data)} tasks, expected 0"
        )

    def test_bug2_race_condition(self, client):
        token = get_token()
        barrier = threading.Barrier(5)

        def update():
            barrier.wait()
            client.put(
                '/api/tasks/1',
                json={'status': 'completed'},
                headers={'Authorization': f'Bearer {token}'}
            )

        threads = [threading.Thread(target=update) for _ in range(5)]
        for t in threads:
            t.start()
        for t in threads:
            t.join(timeout=5)

        resp = client.get(
            '/api/tasks/1',
            headers={'Authorization': f'Bearer {token}'}
        )
        task = resp.get_json()
        assert task['version'] == 6, (
            f"Race condition caused lost updates: version={task['version']}, expected 6"
        )

    def test_bug3_off_by_one_pagination(self, client):
        token = get_token()
        headers = {'Authorization': f'Bearer {token}'}

        resp = client.get('/api/tasks?page=1&per_page=2', headers=headers)
        data = resp.get_json()

        task_ids = [t['id'] for t in data['tasks']]
        assert 1 in task_ids, (
            f"Off-by-one: task 1 missing from page 1, got ids {task_ids}"
        )

    def test_bug4_memory_leak(self, client):
        token = get_token()
        headers = {'Authorization': f'Bearer {token}'}

        for i in range(200):
            status = 'completed' if i % 2 == 0 else 'pending'
            client.put(
                '/api/tasks/1',
                json={'status': status},
                headers=headers
            )

        assert len(request_log) < 200, (
            f"Memory leak: request_log has {len(request_log)} entries"
        )

    def test_bug5_type_error(self, client):
        token = get_token()
        headers = {'Authorization': f'Bearer {token}'}

        resp = client.get('/api/tasks/high-priority', headers=headers)
        data = resp.get_json()

        for task in data:
            assert int(task['priority']) > 5, (
                f"Task {task['id']} has priority {task['priority']} but was returned"
            )

    def test_bug6_authentication(self, client):
        weak_token = jwt.encode(
            {'user': 'hacker'},
            'secret',
            algorithm='HS256'
        )
        resp = client.get(
            '/api/tasks',
            headers={'Authorization': f'Bearer {weak_token}'}
        )
        assert resp.status_code == 401, "Weak JWT secret was accepted"

        proper_token = get_token()
        resp = client.get(
            '/api/tasks',
            headers={'Authorization': f'Bearer {proper_token}'}
        )
        assert resp.status_code == 200, "Proper token was rejected"

    def test_bug7_infinite_loop(self):
        call_count = [0]

        def failing():
            call_count[0] += 1
            raise ValueError("Operation failed")

        result = []

        def run():
            try:
                retry_on_failure(failing, max_retries=3)
            except ValueError as e:
                result.append(e)

        t = threading.Thread(target=run)
        t.start()
        t.join(timeout=3)

        assert not t.is_alive(), "retry_on_failure looped infinitely"
        assert len(result) == 1, "Did not raise ValueError"
        assert call_count[0] == 3, (
            f"Expected 3 calls, got {call_count[0]}"
        )
