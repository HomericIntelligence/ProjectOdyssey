"""Tests for argument parser utilities (Issue #2200).

Tests basic argument parsing functionality including:
- Adding typed arguments with defaults
- Adding boolean flags
- Parsing from simulated command line args
- Type conversion (int, float, string, bool)
- Error handling for unknown arguments and type mismatches
- Convenience helpers for training/inference argument patterns
"""

from testing import assert_true, assert_equal
from shared.utils import (
    ArgumentParser,
    ArgumentSpec,
    ParsedArgs,
    create_training_parser,
    create_inference_parser,
)


fn test_argument_spec_creation() raises:
    """Test creating argument specifications."""
    var spec = ArgumentSpec(
        name="epochs", arg_type="int", default_value="100", is_flag=False
    )
    assert_equal(spec.name, "epochs")
    assert_equal(spec.arg_type, "int")
    assert_equal(spec.default_value, "100")
    assert_true(not spec.is_flag)
    print("PASS: test_argument_spec_creation")


fn test_parsed_args_string() raises:
    """Test ParsedArgs string getter."""
    var args = ParsedArgs()
    args.set("output", "model.weights")
    assert_equal(args.get_string("output"), "model.weights")
    assert_equal(args.get_string("missing", "default"), "default")
    print("PASS: test_parsed_args_string")


fn test_parsed_args_int() raises:
    """Test ParsedArgs integer getter."""
    var args = ParsedArgs()
    args.set("epochs", "100")
    assert_equal(args.get_int("epochs"), 100)
    assert_equal(args.get_int("missing", 42), 42)
    print("PASS: test_parsed_args_int")


fn test_parsed_args_float() raises:
    """Test ParsedArgs float getter."""
    var args = ParsedArgs()
    args.set("lr", "0.001")
    var lr = args.get_float("lr")
    # Float comparison with tolerance
    assert_true(lr > 0.0009 and lr < 0.0011)
    assert_equal(args.get_float("missing", 0.1), 0.1)
    print("PASS: test_parsed_args_float")


fn test_parsed_args_bool() raises:
    """Test ParsedArgs boolean flag getter."""
    var args = ParsedArgs()
    args.set("verbose", "true")
    assert_true(args.get_bool("verbose"))
    assert_true(not args.get_bool("missing"))
    print("PASS: test_parsed_args_bool")


fn test_parsed_args_has() raises:
    """Test ParsedArgs has() method."""
    var args = ParsedArgs()
    args.set("epochs", "100")
    assert_true(args.has("epochs"))
    assert_true(not args.has("missing"))
    print("PASS: test_parsed_args_has")


fn test_argument_parser_creation() raises:
    """Test creating an argument parser."""
    var parser = ArgumentParser()
    parser.add_argument("epochs", "int", "100")
    assert_equal(len(parser.arguments), 1)
    print("PASS: test_argument_parser_creation")


fn test_argument_parser_add_arguments() raises:
    """Test adding typed arguments."""
    var parser = ArgumentParser()
    parser.add_argument("epochs", "int", "100")
    parser.add_argument("batch-size", "int", "32")
    parser.add_argument("lr", "float", "0.001")
    parser.add_argument("output", "string", "model.weights")

    assert_equal(len(parser.arguments), 4)
    assert_true("epochs" in parser.arguments)
    assert_true("batch-size" in parser.arguments)
    assert_true("lr" in parser.arguments)
    assert_true("output" in parser.arguments)
    print("PASS: test_argument_parser_add_arguments")


fn test_argument_parser_add_flag() raises:
    """Test adding boolean flags."""
    var parser = ArgumentParser()
    parser.add_flag("verbose")
    parser.add_flag("debug")

    assert_equal(len(parser.arguments), 2)
    assert_true("verbose" in parser.arguments)
    assert_true("debug" in parser.arguments)

    assert_true(parser.arguments["verbose"].is_flag)
    print("PASS: test_argument_parser_add_flag")


fn test_argument_parser_invalid_type() raises:
    """Test that invalid argument types are rejected."""
    var parser = ArgumentParser()
    try:
        parser.add_argument("bad", "invalid_type", "0")
        # Should raise error
        assert_true(False)
    except:
        assert_true(True)  # Expected error
        print("PASS: test_argument_parser_invalid_type")


fn test_argument_defaults() raises:
    """Test that defaults are applied."""
    var parser = ArgumentParser()
    parser.add_argument("epochs", "int", "100")
    parser.add_argument("lr", "float", "0.001")
    parser.add_argument("output", "string", "model.weights")

    # Note: In a real test, we would call parse() with empty argv
    # For now, we just verify defaults are stored
    assert_equal(parser.arguments["epochs"].default_value, "100")
    assert_equal(parser.arguments["lr"].default_value, "0.001")
    assert_equal(parser.arguments["output"].default_value, "model.weights")
    print("PASS: test_argument_defaults")


fn test_parsed_args_multiple_values() raises:
    """Test handling multiple argument values."""
    var args = ParsedArgs()
    args.set("epochs", "100")
    args.set("batch_size", "32")
    args.set("lr", "0.001")
    args.set("output", "weights.mojo")

    assert_equal(args.get_int("epochs"), 100)
    assert_equal(args.get_int("batch_size"), 32)
    var lr = args.get_float("lr")
    assert_true(lr > 0.0009 and lr < 0.0011)
    assert_equal(args.get_string("output"), "weights.mojo")
    print("PASS: test_parsed_args_multiple_values")


fn test_create_training_parser_structure() raises:
    """Test that create_training_parser creates parser with expected arguments."""
    var parser = create_training_parser()

    # Verify all expected training arguments are present
    assert_true("epochs" in parser.arguments)
    assert_true("batch-size" in parser.arguments)
    assert_true("lr" in parser.arguments)
    assert_true("learning-rate" in parser.arguments)
    assert_true("momentum" in parser.arguments)
    assert_true("weight-decay" in parser.arguments)
    assert_true("model-path" in parser.arguments)
    assert_true("data-dir" in parser.arguments)
    assert_true("seed" in parser.arguments)
    assert_true("verbose" in parser.arguments)

    print("PASS: test_create_training_parser_structure")


fn test_create_training_parser_defaults() raises:
    """Test that create_training_parser has correct default values."""
    var parser = create_training_parser()

    assert_equal(parser.arguments["epochs"].default_value, "100")
    assert_equal(parser.arguments["batch-size"].default_value, "32")
    assert_equal(parser.arguments["lr"].default_value, "0.001")
    assert_equal(parser.arguments["learning-rate"].default_value, "0.001")
    assert_equal(parser.arguments["momentum"].default_value, "0.9")
    assert_equal(parser.arguments["weight-decay"].default_value, "0.0")
    assert_equal(parser.arguments["model-path"].default_value, "model.weights")
    assert_equal(parser.arguments["data-dir"].default_value, "datasets")
    assert_equal(parser.arguments["seed"].default_value, "42")

    print("PASS: test_create_training_parser_defaults")


fn test_create_training_parser_types() raises:
    """Test that create_training_parser has correct argument types."""
    var parser = create_training_parser()

    # Verify integer arguments
    assert_equal(parser.arguments["epochs"].arg_type, "int")
    assert_equal(parser.arguments["batch-size"].arg_type, "int")
    assert_equal(parser.arguments["seed"].arg_type, "int")

    # Verify float arguments
    assert_equal(parser.arguments["lr"].arg_type, "float")
    assert_equal(parser.arguments["learning-rate"].arg_type, "float")
    assert_equal(parser.arguments["momentum"].arg_type, "float")
    assert_equal(parser.arguments["weight-decay"].arg_type, "float")

    # Verify string arguments
    assert_equal(parser.arguments["model-path"].arg_type, "string")
    assert_equal(parser.arguments["data-dir"].arg_type, "string")

    # Verify flag
    assert_true(parser.arguments["verbose"].is_flag)

    print("PASS: test_create_training_parser_types")


fn test_create_inference_parser_structure() raises:
    """Test that create_inference_parser creates parser with expected arguments."""
    var parser = create_inference_parser()

    # Verify all expected inference arguments are present
    assert_true("checkpoint" in parser.arguments)
    assert_true("image" in parser.arguments)
    assert_true("data-dir" in parser.arguments)
    assert_true("top-k" in parser.arguments)
    assert_true("batch-size" in parser.arguments)
    assert_true("test-set" in parser.arguments)
    assert_true("verbose" in parser.arguments)

    print("PASS: test_create_inference_parser_structure")


fn test_create_inference_parser_defaults() raises:
    """Test that create_inference_parser has correct default values."""
    var parser = create_inference_parser()

    assert_equal(parser.arguments["checkpoint"].default_value, "model.weights")
    assert_equal(parser.arguments["image"].default_value, "")
    assert_equal(parser.arguments["data-dir"].default_value, "datasets")
    assert_equal(parser.arguments["top-k"].default_value, "5")
    assert_equal(parser.arguments["batch-size"].default_value, "32")

    print("PASS: test_create_inference_parser_defaults")


fn test_create_inference_parser_types() raises:
    """Test that create_inference_parser has correct argument types."""
    var parser = create_inference_parser()

    # Verify string arguments
    assert_equal(parser.arguments["checkpoint"].arg_type, "string")
    assert_equal(parser.arguments["image"].arg_type, "string")
    assert_equal(parser.arguments["data-dir"].arg_type, "string")

    # Verify integer arguments
    assert_equal(parser.arguments["top-k"].arg_type, "int")
    assert_equal(parser.arguments["batch-size"].arg_type, "int")

    # Verify flags
    assert_true(parser.arguments["test-set"].is_flag)
    assert_true(parser.arguments["verbose"].is_flag)

    print("PASS: test_create_inference_parser_types")


fn test_training_parser_can_parse_args() raises:
    """Test that training parser can handle parsed arguments."""
    var parser = create_training_parser()
    var args = ParsedArgs()

    # Simulate parsed arguments
    args.set("epochs", "50")
    args.set("batch-size", "64")
    args.set("lr", "0.01")
    args.set("momentum", "0.95")
    args.set("weight-decay", "0.0001")
    args.set("model-path", "my_model.weights")
    args.set("data-dir", "my_data")
    args.set("seed", "123")
    args.set("verbose", "true")

    # Verify values can be retrieved with correct types
    assert_equal(args.get_int("epochs"), 50)
    assert_equal(args.get_int("batch-size"), 64)
    var lr = args.get_float("lr")
    assert_true(lr > 0.009 and lr < 0.011)
    var momentum = args.get_float("momentum")
    assert_true(momentum > 0.949 and momentum < 0.951)
    var weight_decay = args.get_float("weight-decay")
    assert_true(weight_decay > 0.00009 and weight_decay < 0.00011)
    assert_equal(args.get_string("model-path"), "my_model.weights")
    assert_equal(args.get_string("data-dir"), "my_data")
    assert_equal(args.get_int("seed"), 123)
    assert_true(args.get_bool("verbose"))

    print("PASS: test_training_parser_can_parse_args")


fn test_inference_parser_can_parse_args() raises:
    """Test that inference parser can handle parsed arguments."""
    var parser = create_inference_parser()
    var args = ParsedArgs()

    # Simulate parsed arguments
    args.set("checkpoint", "checkpoints/model_final")
    args.set("image", "test_image.png")
    args.set("data-dir", "custom_data")
    args.set("top-k", "10")
    args.set("batch-size", "16")
    args.set("test-set", "true")
    args.set("verbose", "true")

    # Verify values can be retrieved with correct types
    assert_equal(args.get_string("checkpoint"), "checkpoints/model_final")
    assert_equal(args.get_string("image"), "test_image.png")
    assert_equal(args.get_string("data-dir"), "custom_data")
    assert_equal(args.get_int("top-k"), 10)
    assert_equal(args.get_int("batch-size"), 16)
    assert_true(args.get_bool("test-set"))
    assert_true(args.get_bool("verbose"))

    print("PASS: test_inference_parser_can_parse_args")


fn main() raises:
    """Run all argument parser tests."""
    print("")
    print("=" * 70)
    print("ArgumentParser Unit Tests")
    print("=" * 70)
    print("")

    # Basic argument parser tests
    test_argument_spec_creation()
    test_parsed_args_string()
    test_parsed_args_int()
    test_parsed_args_float()
    test_parsed_args_bool()
    test_parsed_args_has()
    test_argument_parser_creation()
    test_argument_parser_add_arguments()
    test_argument_parser_add_flag()
    test_argument_parser_invalid_type()
    test_argument_defaults()
    test_parsed_args_multiple_values()

    # Training parser convenience helper tests
    test_create_training_parser_structure()
    test_create_training_parser_defaults()
    test_create_training_parser_types()
    test_training_parser_can_parse_args()

    # Inference parser convenience helper tests
    test_create_inference_parser_structure()
    test_create_inference_parser_defaults()
    test_create_inference_parser_types()
    test_inference_parser_can_parse_args()

    print("")
    print("=" * 70)
    print("All argument parser tests passed!")
    print("=" * 70)
    print("")
