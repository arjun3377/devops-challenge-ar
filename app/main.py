"""Skybyte greeting service."""
import os
import time
from flask import Flask, request, Response, jsonify
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP Requests",
    ["method", "path", "status"]
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "Request latency",
    ["method", "path"]
)

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    duration = time.time() - request.start_time

    REQUEST_COUNT.labels(
        request.method,
        request.path,
        str(response.status_code)
    ).inc()

    REQUEST_LATENCY.labels(
        request.method,
        request.path
    ).observe(duration)

    return response

VERSION = "1.0.0"
API_TOKEN = os.environ.get("API_TOKEN", "")

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {
        "Content-Type": "text/plain"
    }

@app.route("/")
def hello():
    return jsonify({"message": "Hello, Candidate", "version": VERSION})


@app.route("/healthz")
def healthz():
    # TODO: actually check something useful
    return "ok", 200


if __name__ == "__main__":
    # Bind to 0.0.0.0 so the container can be reached from outside.
    app.run(host="0.0.0.0", port=80)

