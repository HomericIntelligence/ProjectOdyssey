#!/usr/bin/env python3
"""Training Dashboard Server.

Flask-based web dashboard for monitoring ML Odyssey training runs.
Reads CSV metrics from logs directory and provides real-time visualization.

Usage:
    python scripts/dashboard/server.py [--port PORT] [--logs-dir DIR]

Example:
    python scripts/dashboard/server.py --port 5000 --logs-dir logs/
"""

import argparse
import csv
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any

try:
    from flask import Flask, jsonify, render_template, request
except ImportError:
    print("Flask not installed. Install with: pip install flask")
    sys.exit(1)

# Add project root to path
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

app = Flask(__name__, template_folder="templates")

# Default logs directory
DEFAULT_LOGS_DIR = PROJECT_ROOT / "logs"


def get_logs_dir() -> Path:
    """Get the logs directory from app config or default."""
    return Path(app.config.get("LOGS_DIR", DEFAULT_LOGS_DIR))


def discover_runs() -> List[Dict[str, Any]]:
    """Discover all training runs in the logs directory.

    Returns:
        List of run metadata dictionaries with keys:
        - id: Run directory name
        - path: Full path to run directory
        - metrics: List of available metric names
        - created: Directory creation timestamp
    """
    logs_dir = get_logs_dir()
    runs = []

    if not logs_dir.exists():
        return runs

    for run_dir in sorted(logs_dir.iterdir()):
        if not run_dir.is_dir():
            continue

        # Find CSV files in run directory
        csv_files = list(run_dir.glob("*.csv"))
        if not csv_files:
            continue

        metrics = [f.stem for f in csv_files]

        # Get creation time
        try:
            created = datetime.fromtimestamp(run_dir.stat().st_mtime)
        except OSError:
            created = datetime.now()

        runs.append(
            {
                "id": run_dir.name,
                "path": str(run_dir),
                "metrics": metrics,
                "created": created.isoformat(),
                "num_metrics": len(metrics),
            }
        )

    # Sort by creation time, newest first
    runs.sort(key=lambda x: x["created"], reverse=True)
    return runs


def read_metric_csv(run_id: str, metric_name: str) -> Optional[Dict[str, List]]:
    """Read a metric CSV file.

    Args:
        run_id: Training run identifier (directory name)
        metric_name: Name of metric (CSV file stem)

    Returns:
        Dictionary with 'steps' and 'values' lists, or None if not found
    """
    logs_dir = get_logs_dir()
    csv_path = logs_dir / run_id / f"{metric_name}.csv"

    if not csv_path.exists():
        return None

    steps = []
    values = []

    try:
        with open(csv_path, "r", newline="") as f:
            reader = csv.DictReader(f)
            for row in reader:
                try:
                    step = int(row.get("step", 0))
                    value = float(row.get("value", 0.0))
                    steps.append(step)
                    values.append(value)
                except (ValueError, TypeError):
                    continue
    except (OSError, csv.Error) as e:
        print(f"Error reading {csv_path}: {e}")
        return None

    return {"steps": steps, "values": values}


def read_all_metrics(run_id: str) -> Dict[str, Dict[str, List]]:
    """Read all metrics for a training run.

    Args:
        run_id: Training run identifier

    Returns:
        Dictionary mapping metric names to their data
    """
    logs_dir = get_logs_dir()
    run_dir = logs_dir / run_id

    if not run_dir.exists():
        return {}

    metrics = {}
    for csv_file in run_dir.glob("*.csv"):
        metric_name = csv_file.stem
        data = read_metric_csv(run_id, metric_name)
        if data:
            metrics[metric_name] = data

    return metrics


# Routes


@app.route("/")
def index():
    """Serve the main dashboard page."""
    return render_template("dashboard.html")


@app.route("/api/runs")
def api_runs():
    """Get list of all training runs.

    Returns:
        JSON array of run metadata
    """
    runs = discover_runs()
    return jsonify(runs)


@app.route("/api/run/<run_id>")
def api_run(run_id: str):
    """Get metadata for a specific run.

    Args:
        run_id: Training run identifier

    Returns:
        JSON object with run metadata
    """
    logs_dir = get_logs_dir()
    run_dir = logs_dir / run_id

    if not run_dir.exists():
        return jsonify({"error": "Run not found"}), 404

    csv_files = list(run_dir.glob("*.csv"))
    metrics = [f.stem for f in csv_files]

    try:
        created = datetime.fromtimestamp(run_dir.stat().st_mtime)
    except OSError:
        created = datetime.now()

    return jsonify(
        {
            "id": run_id,
            "path": str(run_dir),
            "metrics": metrics,
            "created": created.isoformat(),
        }
    )


@app.route("/api/run/<run_id>/metrics")
def api_run_metrics(run_id: str):
    """Get all metrics for a run.

    Args:
        run_id: Training run identifier

    Returns:
        JSON object mapping metric names to data
    """
    metrics = read_all_metrics(run_id)
    if not metrics:
        return jsonify({"error": "Run not found or no metrics"}), 404
    return jsonify(metrics)


@app.route("/api/run/<run_id>/metric/<metric_name>")
def api_run_metric(run_id: str, metric_name: str):
    """Get a specific metric for a run.

    Args:
        run_id: Training run identifier
        metric_name: Name of the metric

    Returns:
        JSON object with steps and values arrays
    """
    data = read_metric_csv(run_id, metric_name)
    if data is None:
        return jsonify({"error": "Metric not found"}), 404
    return jsonify(data)


@app.route("/api/compare")
def api_compare():
    """Compare metrics across multiple runs.

    Query params:
        runs: Comma-separated list of run IDs
        metric: Metric name to compare

    Returns:
        JSON object with comparison data
    """
    run_ids = request.args.get("runs", "").split(",")
    metric_name = request.args.get("metric", "train_loss")

    if not run_ids or run_ids == [""]:
        return jsonify({"error": "No runs specified"}), 400

    comparison = {}
    for run_id in run_ids:
        run_id = run_id.strip()
        if not run_id:
            continue
        data = read_metric_csv(run_id, metric_name)
        if data:
            comparison[run_id] = data

    return jsonify(comparison)


def main():
    """Run the dashboard server."""
    parser = argparse.ArgumentParser(description="ML Odyssey Training Dashboard Server")
    parser.add_argument(
        "--port",
        type=int,
        default=5000,
        help="Port to run server on (default: 5000)",
    )
    parser.add_argument(
        "--host",
        default="127.0.0.1",
        help="Host to bind to (default: 127.0.0.1)",
    )
    parser.add_argument(
        "--logs-dir",
        type=Path,
        default=DEFAULT_LOGS_DIR,
        help=f"Directory containing training logs (default: {DEFAULT_LOGS_DIR})",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Run in debug mode with auto-reload",
    )

    args = parser.parse_args()

    # Configure app
    app.config["LOGS_DIR"] = args.logs_dir

    print("ML Odyssey Training Dashboard")
    print("==============================")
    print(f"Logs directory: {args.logs_dir}")
    print(f"Server URL: http://{args.host}:{args.port}")
    print()

    # Discover runs
    runs = discover_runs()
    if runs:
        print(f"Found {len(runs)} training run(s):")
        for run in runs[:5]:
            print(f"  - {run['id']} ({run['num_metrics']} metrics)")
        if len(runs) > 5:
            print(f"  ... and {len(runs) - 5} more")
    else:
        print("No training runs found yet.")
        print(f"Training logs will appear at: {args.logs_dir}")

    print()
    print("Starting server...")

    app.run(host=args.host, port=args.port, debug=args.debug)


if __name__ == "__main__":
    main()
