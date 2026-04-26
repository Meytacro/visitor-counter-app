from flask import Flask, jsonify, render_template
import redis
import os

app = Flask(__name__)

redis_host = os.getenv("REDIS_HOST", "localhost")
redis_port = int(os.getenv("REDIS_PORT", 6379))
redis_ssl = os.getenv("REDIS_SSL", "false").lower() == "true"

redis_client = redis.Redis(
    host=redis_host,
    port=redis_port,
    ssl=redis_ssl,
    decode_responses=True
)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/visits")
def increment_visits():
    visits = redis_client.incr("visits")
    return jsonify({"visits": visits})

@app.route("/visits/current")
def current_visits():
    visits = redis_client.get("visits")

    if visits is None:
        visits = 0
    else:
        visits = int(visits)

    return jsonify({"visits": visits})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)