"""Model checkpoint management for training state persistence.

Provides comprehensive checkpoint lifecycle management with support for:
- Saving/loading complete training state (model + optimizer + metadata)
- Automatic checkpoint rotation (keep last N checkpoints)
- Best model tracking by monitored metric
- Training resume support

Checkpoint Directory Structure:
    checkpoint_dir/
    ├── checkpoint_epoch_10/
    │   ├── model/
    │   │   ├── index.txt           # List of tensor keys
    │   │   └── *.weights           # Model parameter tensors
    │   ├── optimizer/
    │   │   ├── index.txt
    │   │   └── *.weights           # Optimizer state tensors
    │   └── metadata.txt            # Epoch, metrics, version
    ├── checkpoint_epoch_20/
    └── best/ -> checkpoint_epoch_15/  (copy of best checkpoint)

Usage Example:
    ```mojo
    var manager = CheckpointManager(
        checkpoint_dir="./checkpoints",
        keep_last_n=5,
        best_metric="val_loss",
        best_mode="min"
    )

    # Save checkpoint at each epoch
    var model_state = model.state_dict()
    var optimizer_state = optimizer.state_dict()
    var metrics = Dict[String, Float64]()
    metrics["val_loss"] = 0.42
    metrics["val_acc"] = 0.95

    manager.save_checkpoint(epoch, model_state, optimizer_state, metrics)

    # Resume from latest checkpoint
    var (model_state, optimizer_state, metrics, start_epoch) = manager.load_latest()
    model.load_state_dict(model_state)
    optimizer.load_state_dict(optimizer_state)
    ```
"""

from shared.core.extensor import ExTensor
from shared.utils.serialization import save_tensor, load_tensor
from collections import Dict, List


# ============================================================================
# Checkpoint Manager
# ============================================================================


struct CheckpointManager:
    """Manage model checkpoint lifecycle.

    Handles saving, loading, and rotation of checkpoints with support for
    tracking best checkpoints by a monitored metric.
    """

    var checkpoint_dir: String
    """Root directory for all checkpoints."""
    var keep_last_n: Int
    """Number of recent checkpoints to keep (older ones deleted)."""
    var best_metric: String
    """Metric name to monitor for best checkpoint (e.g., 'val_loss')."""
    var best_mode: String
    """Mode for best metric: 'min' or 'max'."""
    var best_value: Float64
    """Best value of monitored metric so far."""
    var best_epoch: Int
    """Epoch number of best checkpoint."""
    var saved_epochs: List[Int]
    """List of saved checkpoint epoch numbers (for rotation)."""

    fn __init__(
        out self,
        checkpoint_dir: String,
        keep_last_n: Int = 5,
        best_metric: String = "val_loss",
        best_mode: String = "min",
    ):
        """Initialize CheckpointManager.

        Args:
            checkpoint_dir: Directory to store all checkpoints.
            keep_last_n: Number of recent checkpoints to keep (default: 5).
            best_metric: Metric name to monitor for best checkpoint (default: "val_loss").
            best_mode: "min" if lower is better, "max" if higher is better (default: "min").

        Example:
            ```mojo
            var manager = CheckpointManager("./checkpoints", keep_last_n=3)
            ```
        """
        self.checkpoint_dir = checkpoint_dir
        self.keep_last_n = keep_last_n
        self.best_metric = best_metric
        self.best_mode = best_mode
        self.saved_epochs = List[Int]()

        # Initialize best value based on mode
        if best_mode == "max":
            self.best_value = Float64(-1e9)
        else:
            self.best_value = Float64(1e9)
        self.best_epoch = -1

    fn save_checkpoint(
        mut self,
        epoch: Int,
        model_state: Dict[String, ExTensor],
        optimizer_state: Dict[String, ExTensor],
        metrics: Dict[String, Float64],
    ) raises:
        """Save complete training checkpoint.

        Creates checkpoint directory structure and saves all state:
        - Model parameters
        - Optimizer state (momentum buffers, step counter, etc.)
        - Training metadata (epoch, metrics)

        Args:
            epoch: Training epoch number.
            model_state: Model state dict from model.state_dict().
            optimizer_state: Optimizer state dict from optimizer.state_dict().
            metrics: Dictionary of metric values (e.g., {"val_loss": 0.42}).

        Raises:
            Error: If checkpoint creation or file writing fails.

        Example:
            ```mojo
            var model_state = model.state_dict()
            var opt_state = optimizer.state_dict()
            var metrics = Dict[String, Float64]()
            metrics["val_loss"] = 0.42

            manager.save_checkpoint(epoch=5, model_state, opt_state, metrics)
            ```
        """
        # Create checkpoint directory
        var ckpt_path = self.checkpoint_dir + "/checkpoint_epoch_" + String(epoch)
        from shared.utils.io import create_directory

        if not create_directory(ckpt_path):
            raise Error("Failed to create checkpoint directory: " + ckpt_path)

        # Save model state with index file
        var model_path = ckpt_path + "/model"
        if not create_directory(model_path):
            raise Error("Failed to create model directory: " + model_path)

        self._save_state_dict(model_state, model_path)

        # Save optimizer state with index file
        var optimizer_path = ckpt_path + "/optimizer"
        if not create_directory(optimizer_path):
            raise Error("Failed to create optimizer directory: " + optimizer_path)

        self._save_state_dict(optimizer_state, optimizer_path)

        # Save metadata
        var metadata = self._build_metadata(epoch, metrics)
        var meta_path = ckpt_path + "/metadata.txt"
        with open(meta_path, "w") as f:
            _ = f.write(metadata)

        # Track saved epochs
        self.saved_epochs.append(epoch)

        # Update best checkpoint if this is better
        self._update_best(epoch, metrics)

        # Rotate old checkpoints
        self._cleanup_old_checkpoints()

        print("[CheckpointManager] Saved checkpoint epoch " + String(epoch))

    fn load_checkpoint(
        self, epoch: Int
    ) raises -> Tuple[
        Dict[String, ExTensor], Dict[String, ExTensor], Dict[String, Float64]
    ]:
        """Load checkpoint by epoch number.

        Args:
            epoch: Epoch number of checkpoint to load.

        Returns:
            Tuple of (model_state, optimizer_state, metrics).

        Raises:
            Error: If checkpoint doesn't exist or files are corrupted.

        Example:
            ```mojo
            var (model_state, opt_state, metrics) = manager.load_checkpoint(10)
            model.load_state_dict(model_state)
            optimizer.load_state_dict(opt_state)
            ```
        """
        var ckpt_path = self.checkpoint_dir + "/checkpoint_epoch_" + String(epoch)

        from shared.utils.io import directory_exists

        if not directory_exists(ckpt_path):
            raise Error("Checkpoint not found: " + ckpt_path)

        # Load model state
        var model_state = self._load_state_dict(ckpt_path + "/model")

        # Load optimizer state
        var optimizer_state = self._load_state_dict(ckpt_path + "/optimizer")

        # Load metadata
        var metrics = self._load_metadata(ckpt_path + "/metadata.txt")

        return (model_state^, optimizer_state^, metrics^)

    fn load_latest(
        self
    ) raises -> Tuple[
        Dict[String, ExTensor],
        Dict[String, ExTensor],
        Dict[String, Float64],
        Int,
    ]:
        """Load most recent checkpoint.

        Returns:
            Tuple of (model_state, optimizer_state, metrics, epoch).

        Raises:
            Error: If no checkpoints found.

        Example:
            ```mojo
            var (model_state, opt_state, metrics, start_epoch) = manager.load_latest()
            model.load_state_dict(model_state)
            optimizer.load_state_dict(opt_state)
            for epoch in range(start_epoch, num_epochs):
                # Resume training...
            ```
        """
        var available = self._get_available_epochs()
        if len(available) == 0:
            raise Error("No checkpoints found in: " + self.checkpoint_dir)

        # Find max epoch
        var latest_epoch = available[0]
        for i in range(1, len(available)):
            if available[i] > latest_epoch:
                latest_epoch = available[i]

        var (model_state, optimizer_state, metrics) = self.load_checkpoint(
            latest_epoch
        )
        return (model_state^, optimizer_state^, metrics^, latest_epoch)

    fn load_best(
        self
    ) raises -> Tuple[
        Dict[String, ExTensor],
        Dict[String, ExTensor],
        Dict[String, Float64],
        Int,
    ]:
        """Load best checkpoint (by monitored metric).

        Returns:
            Tuple of (model_state, optimizer_state, metrics, epoch).

        Raises:
            Error: If no best checkpoint found.

        Example:
            ```mojo
            var (model_state, opt_state, metrics, best_epoch) = manager.load_best()
            ```
        """
        # Read epoch from best metadata
        from shared.utils.io import directory_exists

        var best_path = self.checkpoint_dir + "/best"
        if not directory_exists(best_path):
            raise Error("No best checkpoint found")

        var meta_path = best_path + "/metadata.txt"
        var metadata = self._read_file(meta_path)
        var epoch = self._parse_epoch_from_metadata(metadata)

        var (model_state, optimizer_state, metrics) = self.load_checkpoint(epoch)
        return (model_state^, optimizer_state^, metrics^, epoch)

    # =========================================================================
    # Private Methods
    # =========================================================================

    fn _save_state_dict(
        self, state: Dict[String, ExTensor], dirpath: String
    ) raises:
        """Save state dict with index file."""
        # Build key list
        var keys = List[String]()
        for key_ref in state.keys():
            keys.append(String(key_ref))

        # Write index file
        var index_path = dirpath + "/index.txt"
        var index_content = "VERSION=1\n"
        for i in range(len(keys)):
            index_content += keys[i] + "\n"

        with open(index_path, "w") as f:
            _ = f.write(index_content)

        # Save each tensor
        for i in range(len(keys)):
            var key = keys[i]
            var filepath = dirpath + "/" + key + ".weights"
            save_tensor(state[key], filepath, key)

    fn _load_state_dict(self, dirpath: String) raises -> Dict[String, ExTensor]:
        """Load state dict from directory with index file."""
        var state = Dict[String, ExTensor]()

        # Read index file
        var index_path = dirpath + "/index.txt"
        var index_content = self._read_file(index_path)

        var lines = index_content.split("\n")

        # Parse version and keys (skip VERSION line)
        var start_line = 0
        if len(lines) > 0 and lines[0].startswith("VERSION="):
            start_line = 1

        # Load each tensor
        for i in range(start_line, len(lines)):
            var line = String(lines[i])
            line = line.strip()
            if len(line) == 0:
                continue

            var filepath = dirpath + "/" + line + ".weights"
            var tensor = load_tensor(filepath)
            state[line] = tensor

        return state^

    fn _build_metadata(
        self, epoch: Int, metrics: Dict[String, Float64]
    ) -> String:
        """Build metadata string from epoch and metrics."""
        var content = "VERSION=1\n"
        content += "EPOCH=" + String(epoch) + "\n"

        for key_ref in metrics.keys():
            var key = String(key_ref)
            content += key + "=" + String(metrics[key]) + "\n"

        return content

    fn _load_metadata(self, filepath: String) raises -> Dict[String, Float64]:
        """Load metadata from file."""
        var content = self._read_file(filepath)
        var metrics = Dict[String, Float64]()
        var lines = content.split("\n")

        for i in range(len(lines)):
            var line = String(lines[i]).strip()
            if len(line) == 0:
                continue

            var eq_pos = line.find("=")
            if eq_pos == -1:
                continue

            var key = String(line[:eq_pos])
            var value = String(line[eq_pos + 1 :])

            if key == "VERSION" or key == "EPOCH":
                continue

            metrics[key] = Float64(atof(value))

        return metrics^

    fn _parse_epoch_from_metadata(self, metadata: String) raises -> Int:
        """Extract epoch number from metadata."""
        var lines = metadata.split("\n")
        for i in range(len(lines)):
            var line = String(lines[i]).strip()
            if line.startswith("EPOCH="):
                return atol(String(line[6:]))
        raise Error("EPOCH not found in metadata")

    fn _update_best(
        mut self, epoch: Int, metrics: Dict[String, Float64]
    ) raises:
        """Update best checkpoint tracking."""
        if self.best_metric not in metrics:
            return

        var current = metrics[self.best_metric]
        var is_better: Bool

        if self.best_mode == "max":
            is_better = current > self.best_value
        else:
            is_better = current < self.best_value

        if is_better:
            self.best_value = current
            self.best_epoch = epoch

            # Copy to best/ directory
            var src = self.checkpoint_dir + "/checkpoint_epoch_" + String(epoch)
            var dst = self.checkpoint_dir + "/best"

            from python import Python

            try:
                var shutil = Python.import_module("shutil")
                var os = Python.import_module("os")
                if os.path.exists(dst):
                    shutil.rmtree(dst)
                shutil.copytree(src, dst)
                print("[CheckpointManager] Updated best checkpoint (epoch " +
                      String(epoch) + ")")
            except:
                print("[CheckpointManager] Warning: Failed to update best checkpoint")

    fn _cleanup_old_checkpoints(mut self) raises:
        """Remove old checkpoints beyond keep_last_n (preserve best)."""
        if len(self.saved_epochs) <= self.keep_last_n:
            return

        # Sort epochs
        for i in range(len(self.saved_epochs)):
            for j in range(i + 1, len(self.saved_epochs)):
                if self.saved_epochs[j] < self.saved_epochs[i]:
                    var tmp = self.saved_epochs[i]
                    self.saved_epochs[i] = self.saved_epochs[j]
                    self.saved_epochs[j] = tmp

        # Remove oldest checkpoints
        while len(self.saved_epochs) > self.keep_last_n:
            var oldest = self.saved_epochs[0]

            # Don't remove best checkpoint
            if oldest == self.best_epoch:
                _ = self.saved_epochs.pop(0)
                continue

            var ckpt_path = (
                self.checkpoint_dir + "/checkpoint_epoch_" + String(oldest)
            )

            from python import Python

            try:
                var shutil = Python.import_module("shutil")
                shutil.rmtree(ckpt_path)
                print("[CheckpointManager] Removed checkpoint epoch " +
                      String(oldest))
            except:
                pass

            _ = self.saved_epochs.pop(0)

    fn _get_available_epochs(self) -> List[Int]:
        """Get list of available checkpoint epochs."""
        var result = List[Int]()

        from python import Python

        try:
            var pathlib = Python.import_module("pathlib")
            var p = pathlib.Path(self.checkpoint_dir)
            var dirs = p.glob("checkpoint_epoch_*")

            for d in dirs:
                var name = String(d.name)
                var parts = name.split("_")
                if len(parts) >= 3:
                    var epoch_str = String(parts[2])
                    result.append(Int(epoch_str))
        except:
            pass

        return result^

    fn _read_file(self, filepath: String) raises -> String:
        """Read entire file contents."""
        var content: String
        with open(filepath, "r") as f:
            content = f.read()
        return content
