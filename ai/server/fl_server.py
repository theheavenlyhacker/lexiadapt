#!/usr/bin/env python3
"""
Federated Learning server for LexiAdapt.
Aggregates model weight deltas from devices without receiving raw audio.

Usage:
  pip install flwr fastapi uvicorn
  python fl_server.py
"""
import json
from datetime import datetime

try:
    import flwr as fl
    from flwr.server.strategy import FedAvg
    HAS_FLOWER = True
except ImportError:
    HAS_FLOWER = False

try:
    from fastapi import FastAPI, HTTPException
    from fastapi.responses import JSONResponse
    import uvicorn
    HAS_FASTAPI = True
except ImportError:
    HAS_FASTAPI = False

from config import (
    FL_SERVER_HOST, FL_SERVER_PORT,
    FL_MIN_FIT_CLIENTS, FL_MIN_AVAILABLE_CLIENTS, FL_NUM_ROUNDS,
)

# --- FastAPI REST endpoints for Lazy Sync ---

if HAS_FASTAPI:
    app = FastAPI(title="LexiAdapt FL Server")
    weight_store: list = []

    @app.get("/health")
    async def health():
        return {"status": "ok", "timestamp": datetime.utcnow().isoformat()}

    @app.post("/submit_deltas")
    async def submit_deltas(payload: dict):
        if "deltas" not in payload:
            raise HTTPException(400, "Missing 'deltas' field")
        weight_store.append({
            "deltas": payload["deltas"],
            "device_id": payload.get("device_id", "unknown"),
            "timestamp": datetime.utcnow().isoformat(),
        })
        return {"accepted": True, "queue_size": len(weight_store)}

    @app.get("/global_weights")
    async def global_weights():
        return JSONResponse({"weights": [], "version": 0, "note": "Aggregation pending"})


def start_flower_server():
    if not HAS_FLOWER:
        print("Flower not installed. Run: pip install flwr")
        return

    strategy = FedAvg(
        min_fit_clients=FL_MIN_FIT_CLIENTS,
        min_available_clients=FL_MIN_AVAILABLE_CLIENTS,
    )

    print(f"Starting Flower FL server on {FL_SERVER_HOST}:{FL_SERVER_PORT + 1}")
    fl.server.start_server(
        server_address=f"{FL_SERVER_HOST}:{FL_SERVER_PORT + 1}",
        config=fl.server.ServerConfig(num_rounds=FL_NUM_ROUNDS),
        strategy=strategy,
    )


def main():
    import argparse
    parser = argparse.ArgumentParser(description="LexiAdapt FL Server")
    parser.add_argument("--mode", choices=["rest", "flower", "both"], default="rest")
    args = parser.parse_args()

    if args.mode in ("rest", "both"):
        if not HAS_FASTAPI:
            print("FastAPI not installed. Run: pip install fastapi uvicorn")
            return
        print(f"Starting REST API on {FL_SERVER_HOST}:{FL_SERVER_PORT}")
        if args.mode == "both":
            import threading
            threading.Thread(target=start_flower_server, daemon=True).start()
        uvicorn.run(app, host=FL_SERVER_HOST, port=FL_SERVER_PORT)
    elif args.mode == "flower":
        start_flower_server()


if __name__ == "__main__":
    main()
