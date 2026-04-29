from flask import Flask, jsonify, render_template
import os
import socket
import redis

app = Flask(__name__)

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
REDIS_SSL = os.getenv("REDIS_SSL", "false").lower() == "true"

redis_client = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    ssl=REDIS_SSL,
    decode_responses=True,
    socket_connect_timeout=5,
    socket_timeout=5,
)


def instance_info():
    hostname = socket.gethostname()

    try:
        ip = socket.gethostbyname(hostname)
    except socket.gaierror:
        ip = "unknown"

    return {
        "hostname": hostname,
        "ip": ip,
    }


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/health")
def health():
    try:
        redis_client.ping()
        redis_status = "ok"
    except redis.RedisError:
        redis_status = "error"

    return jsonify({
        "status": "ok",
        "redis": redis_status,
        **instance_info(),
    })


@app.route("/visits")
def increment_visits():
    visits = redis_client.incr("visits")

    return jsonify({
        "visits": visits,
        **instance_info(),
    })


@app.route("/visits/current")
def current_visits():
    visits = redis_client.get("visits")

    return jsonify({
        "visits": int(visits) if visits else 0,
        **instance_info(),
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)