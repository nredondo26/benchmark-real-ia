import os
import json
import redis
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = int(os.getenv("REDIS_PORT", 6379))

r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)


@app.get("/health")
def health():
    try:
        r.ping()
        redis_ok = True
    except Exception:
        redis_ok = False
    return {"status": "ok", "redis": redis_ok}


@app.get("/api/data")
def get_data():
    cached = r.get("cached_data")
    if cached:
        data = json.loads(cached)
        data["source"] = "cache"
        return data
    data = {
        "message": "Hello from FastAPI + Redis!",
        "source": "backend",
        "timestamp": os.getenv("HOSTNAME", "unknown"),
    }
    r.setex("cached_data", 30, json.dumps(data))
    return data
