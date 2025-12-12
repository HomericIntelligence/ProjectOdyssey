"""Utility functions for reduction operations.

This module provides helper functions used by reduction operations (sum, mean, max, min).
These utilities handle common tasks like coordinate/stride computation and index conversion.

Functions:
    compute_strides: Compute memory strides from tensor shape.
    linear_to_coords: Convert linear index to multi-dimensional coordinates.
    coords_to_linear: Convert multi-dimensional coordinates to linear index.
    map_result_to_input_coords: Map output coordinates to input coordinates accounting for reduction axis.
    create_result_coords: Create and initialize coordinate list.

Example:
    ```mojo
    from shared.core.reduction_utils import compute_strides, linear_to_coords, coords_to_linear

    var shape : List[Int] = [3, 4, 5]
    var strides = compute_strides(shape)  # [20, 5, 1]
    var coords = linear_to_coords(27, shape)  # [1, 2, 2]
    var linear = coords_to_linear(coords, strides)  # 27
    ```
"""

from collections import List


fn compute_strides(shape: List[Int]) -> List[Int]:
    """Compute memory strides from tensor shape.

    Strides represent the number of elements to skip to move one position along each axis.
    This is computed in row-major (C-contiguous) order.

    Args:
        shape: Tensor shape (list of dimension sizes).

    Returns:
        List of strides for each dimension.

    Examples:
        ```mojo
        var shape : List[Int] = [3, 4, 5]
        var strides = compute_strides(shape)  # [20, 5, 1]
        # Moving 1 position along axis 0 skips 20 elements
        # Moving 1 position along axis 1 skips 5 elements
        # Moving 1 position along axis 2 skips 1 element.
        ```
    """
    var ndim = len(shape)
    var strides = List[Int]()
    for _ in range(ndim):
        strides.append(0)

    var stride = 1
    for i in range(ndim - 1, -1, -1):
        strides[i] = stride
        stride *= shape[i]

    return strides^


fn linear_to_coords(linear_idx: Int, shape: List[Int]) -> List[Int]:
    """Convert linear index to multi-dimensional coordinates.

    Given a flat index into a row-major (C-contiguous) tensor, computes the
    corresponding multi-dimensional coordinates.

    Args:
        linear_idx: Flat index into tensor.
        shape: Tensor shape.

    Returns:
        Coordinates in each dimension.

    Examples:
        ```mojo
        var shape : List[Int] = [3, 4, 5]
        var coords = linear_to_coords(27, shape)  # [1, 2, 2]
        # Index 27 corresponds to position [1, 2, 2]
        ```
    """
    var ndim = len(shape)
    var coords = List[Int]()
    for _ in range(ndim):
        coords.append(0)

    var temp_idx = linear_idx
    for i in range(ndim - 1, -1, -1):
        coords[i] = temp_idx % shape[i]
        temp_idx //= shape[i]

    return coords^


fn coords_to_linear(coords: List[Int], strides: List[Int]) -> Int:
    """Convert multi-dimensional coordinates to linear index.

    Converts multi-dimensional coordinates to a flat index using pre-computed strides.

    Args:
        coords: Multi-dimensional coordinates.
        strides: Strides for each dimension.

    Returns:
        Linear index.

    Examples:
        ```mojo
        var coords : List[Int] = [1, 2, 2]
        var strides : List[Int] = [20, 5, 1]
        var linear = coords_to_linear(coords, strides)  # 27
        ```
    """
    var linear_idx = 0
    for i in range(len(coords)):
        linear_idx += coords[i] * strides[i]
    return linear_idx


fn map_result_to_input_coords(
    result_coords: List[Int], axis: Int, ndim: Int
) -> List[Int]:
    """Map output coordinates to input coordinates accounting for reduction axis.

    When reducing along an axis, the output tensor has fewer dimensions than the input.
    This function maps coordinates in the output space to coordinates in the input space
    by inserting the reduction axis dimension (which will be iterated over separately).

    Args:
        result_coords: Coordinates in the output (reduced) tensor.
        axis: The axis along which reduction occurred.
        ndim: Number of dimensions in the original input tensor.

    Returns:
        Coordinates in the input tensor (with axis dimension set to 0).

    Examples:
        ```mojo
        var result_coords : List[Int] = [1, 2]  # Output from reducing along axis 1
        var input_coords = map_result_to_input_coords(result_coords, 1, 3)
        # Returns [1, 0, 2] - axis 1 is inserted with value 0.
        ```
    """
    var input_coords = List[Int]()
    for _ in range(ndim):
        input_coords.append(0)

    var result_coord_idx = 0
    for i in range(ndim):
        if i != axis:
            input_coords[i] = result_coords[result_coord_idx]
            result_coord_idx += 1
        else:
            input_coords[i] = 0  # Will iterate over this axis
    return input_coords^


fn create_result_coords(result_idx: Int, shape: List[Int]) -> List[Int]:
    """Create and initialize coordinates from linear index using shape.

    Args:
        result_idx: Linear index.
        shape: Shape to use for coordinate conversion.

    Returns:
        Coordinates corresponding to result_idx.
    """
    var ndim = len(shape)
    var coords = List[Int]()
    for _ in range(ndim):
        coords.append(0)

    var temp_idx = result_idx
    for i in range(ndim - 1, -1, -1):
        coords[i] = temp_idx % shape[i]
        temp_idx //= shape[i]

    return coords^


fn build_reduced_shape(
    input_shape: List[Int], axis: Int, keepdims: Bool
) -> List[Int]:
    """Build output shape for axis reduction.

    Removes the specified axis from the shape, or keeps it as size 1 if keepdims=True.

    Args:
        input_shape: Shape of the input tensor.
        axis: Axis to reduce.
        keepdims: Whether to keep the reduced dimension as size 1.

    Returns:
        Shape of the output tensor after reduction.

    Examples:
        ```mojo
        var shape: List[Int] = [3, 4, 5]
        var reduced = build_reduced_shape(shape, 1, False)  # [3, 5]
        var kept = build_reduced_shape(shape, 1, True)  # [3, 1, 5]
        ```
    """
    var result_shape = List[Int]()
    for i in range(len(input_shape)):
        if i != axis:
            result_shape.append(input_shape[i])
        elif keepdims:
            result_shape.append(1)
    return result_shape^


@fieldwise_init
struct AxisReductionIterator(Copyable, Movable):
    """Iterator for accessing elements along a reduction axis.

    This struct encapsulates the common coordinate transformation logic used by
    all axis-reduction operations (sum, mean, max, min). It provides efficient
    iteration over elements along the reduction axis for each output position.

    Usage:
        ```mojo
        var iter = AxisReductionIterator(input_shape, axis)
        for result_idx in range(result.numel()):
            # Get first element along axis
            var first_idx = iter.get_input_idx(result_idx, 0)
            # Iterate remaining elements
            for k in range(1, iter.axis_size):
                var idx = iter.get_input_idx(result_idx, k)
        ```
    """

    var input_strides: List[Int]
    var result_shape: List[Int]
    var axis: Int
    var axis_size: Int
    var ndim: Int

    fn __init__(
        out self, input_shape: List[Int], axis: Int, keepdims: Bool = False
    ):
        """Initialize the axis reduction iterator.

        Args:
            input_shape: Shape of the input tensor.
            axis: Axis along which to reduce.
            keepdims: Whether to keep the reduced dimension (for result shape).
        """
        self.input_strides = compute_strides(input_shape)
        self.result_shape = build_reduced_shape(input_shape, axis, keepdims)
        self.axis = axis
        self.axis_size = input_shape[axis]
        self.ndim = len(input_shape)

    fn get_input_idx(self, result_idx: Int, k: Int) -> Int:
        """Get input tensor linear index for a given result position and axis offset.

        Args:
            result_idx: Linear index in the result (reduced) tensor.
            k: Offset along the reduction axis (0 to axis_size-1).

        Returns:
            Linear index into the input tensor.
        """
        # Convert result index to result coordinates
        var result_coords = create_result_coords(result_idx, self.result_shape)

        # Map to input coordinates (insert axis position with value k)
        var input_coords = List[Int]()
        for _ in range(self.ndim):
            input_coords.append(0)

        var result_coord_idx = 0
        for i in range(self.ndim):
            if i != self.axis:
                input_coords[i] = result_coords[result_coord_idx]
                result_coord_idx += 1
            else:
                input_coords[i] = k

        return coords_to_linear(input_coords, self.input_strides)
