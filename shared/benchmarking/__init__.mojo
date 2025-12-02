"""Benchmarking Framework for ML Odyssey.

Provides utilities for measuring and reporting performance characteristics
of ML operations including latency, throughput, and statistical analysis.

Modules:
    `runner`: Benchmarking runner with statistical analysis

Example:
    from shared.benchmarking import benchmark_function, print_benchmark_report

    fn forward_pass():
        var output = model.forward(input_batch)
        return output

    var result = benchmark_function(forward_pass, warmup_iters=10, measure_iters=100)
    print_benchmark_report(result, "Forward Pass")
"""

# Package version
alias VERSION = "0.1.0"

# ============================================================================
# Exports - Implemented modules
# ============================================================================

from .runner import (
    BenchmarkResult,  # Benchmark results container
    benchmark_function,  # Main benchmarking function
    print_benchmark_report,  # Print formatted results
    BenchmarkConfig,  # Configuration for benchmarking
    create_benchmark_config,  # Create default config
)
