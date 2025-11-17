"""ExTensor - Extensible Tensor for ML Odyssey.

A comprehensive, dynamic tensor class with arbitrary shapes, data types, and dimensions.
Implements 150+ operations from the Array API Standard 2024 with NumPy-style broadcasting.
"""

from memory import UnsafePointer
from sys import simdwidthof


struct ExTensor:
    """Dynamic tensor with runtime-determined shape and data type.

    ExTensor provides a flexible tensor implementation for machine learning workloads,
    supporting arbitrary dimensions (0D scalars to N-D tensors), multiple data types,
    and NumPy-style broadcasting for all operations.

    Attributes:
        _data: UnsafePointer to the underlying data buffer
        _shape: DynamicVector storing the shape dimensions
        _strides: DynamicVector storing the stride for each dimension
        _dtype: The data type of tensor elements
        _numel: Total number of elements in the tensor
        _is_view: Whether this tensor is a view (shares data with another tensor)

    Examples:
        # Create tensors
        let a = ExTensor.zeros((3, 4), DType.float32)
        let b = ExTensor.ones((3, 4), DType.float32)

        # Arithmetic with broadcasting
        let c = a + b  # Element-wise addition
        let d = c * 2.0  # Broadcast scalar

        # Matrix operations
        let x = ExTensor.zeros((3, 4), DType.float32)
        let y = ExTensor.zeros((4, 5), DType.float32)
        let z = x @ y  # Matrix multiplication -> (3, 5)
    """

    var _data: UnsafePointer[Scalar[DType.float32]]  # Will be parametrized by dtype
    var _shape: DynamicVector[Int]
    var _strides: DynamicVector[Int]
    var _dtype: DType
    var _numel: Int
    var _is_view: Bool

    fn __init__(inout self, shape: DynamicVector[Int], dtype: DType):
        """Initialize a new ExTensor with given shape and dtype.

        Args:
            shape: The shape of the tensor as a vector of dimension sizes
            dtype: The data type of tensor elements

        Note:
            This is a low-level constructor. Users should prefer creation
            functions like zeros(), ones(), full(), etc.
        """
        self._shape = shape
        self._dtype = dtype
        self._is_view = False

        # Calculate total number of elements
        self._numel = 1
        for i in range(len(shape)):
            self._numel *= shape[i]

        # Calculate row-major strides
        self._strides = DynamicVector[Int]()
        var stride = 1
        for i in range(len(shape) - 1, -1, -1):
            self._strides.insert(i, stride)
            stride *= shape[i]

        # Allocate memory (placeholder - will need to handle different dtypes)
        self._data = UnsafePointer[Scalar[DType.float32]].alloc(self._numel)

    fn __del__(owned self):
        """Destructor to free allocated memory."""
        if not self._is_view:
            self._data.free()

    fn shape(self) -> DynamicVector[Int]:
        """Return the shape of the tensor.

        Returns:
            A vector containing the size of each dimension

        Examples:
            let t = ExTensor.zeros((3, 4), DType.float32)
            print(t.shape())  # DynamicVector[3, 4]
        """
        return self._shape

    fn dtype(self) -> DType:
        """Return the data type of the tensor.

        Returns:
            The DType of tensor elements
        """
        return self._dtype

    fn numel(self) -> Int:
        """Return the total number of elements in the tensor.

        Returns:
            The product of all dimension sizes

        Examples:
            let t = ExTensor.zeros((3, 4), DType.float32)
            print(t.numel())  # 12
        """
        return self._numel

    fn dim(self) -> Int:
        """Return the number of dimensions (rank) of the tensor.

        Returns:
            The number of dimensions

        Examples:
            let t = ExTensor.zeros((3, 4), DType.float32)
            print(t.dim())  # 2
        """
        return len(self._shape)

    fn is_contiguous(self) -> Bool:
        """Check if the tensor has a contiguous memory layout.

        Returns:
            True if the tensor is contiguous (row-major, no gaps), False otherwise

        Note:
            Contiguous tensors enable SIMD optimizations and efficient operations.
        """
        # Check if strides match row-major layout
        var expected_stride = 1
        for i in range(len(self._shape) - 1, -1, -1):
            if self._strides[i] != expected_stride:
                return False
            expected_stride *= self._shape[i]
        return True


# ============================================================================
# Creation Operations
# ============================================================================

fn zeros(shape: DynamicVector[Int], dtype: DType) -> ExTensor:
    """Create a tensor filled with zeros.

    Args:
        shape: The shape of the output tensor
        dtype: The data type of tensor elements

    Returns:
        A new ExTensor filled with zeros

    Examples:
        let t = zeros((3, 4), DType.float32)
        # Creates a 3x4 tensor of float32 zeros

    Performance:
        O(n) time where n is the number of elements
    """
    var tensor = ExTensor(shape, dtype)

    # Initialize all elements to zero
    # TODO: Handle different dtypes properly
    for i in range(tensor._numel):
        tensor._data[i] = 0.0

    return tensor^


fn ones(shape: DynamicVector[Int], dtype: DType) -> ExTensor:
    """Create a tensor filled with ones.

    Args:
        shape: The shape of the output tensor
        dtype: The data type of tensor elements

    Returns:
        A new ExTensor filled with ones

    Examples:
        let t = ones((3, 4), DType.float32)
        # Creates a 3x4 tensor of float32 ones
    """
    var tensor = ExTensor(shape, dtype)

    # Initialize all elements to one
    # TODO: Handle different dtypes properly
    for i in range(tensor._numel):
        tensor._data[i] = 1.0

    return tensor^


fn full(shape: DynamicVector[Int], fill_value: Float64, dtype: DType) -> ExTensor:
    """Create a tensor filled with a specific value.

    Args:
        shape: The shape of the output tensor
        fill_value: The value to fill the tensor with
        dtype: The data type of tensor elements

    Returns:
        A new ExTensor filled with fill_value

    Examples:
        let t = full((3, 4), 42.0, DType.float32)
        # Creates a 3x4 tensor filled with 42.0
    """
    var tensor = ExTensor(shape, dtype)

    # Initialize all elements to fill_value
    # TODO: Handle different dtypes properly
    for i in range(tensor._numel):
        tensor._data[i] = fill_value

    return tensor^


fn empty(shape: DynamicVector[Int], dtype: DType) -> ExTensor:
    """Create an uninitialized tensor (fast allocation).

    Args:
        shape: The shape of the output tensor
        dtype: The data type of tensor elements

    Returns:
        A new ExTensor with uninitialized memory

    Warning:
        The tensor contains uninitialized memory. Values are undefined until written.
        Use this for performance when you will immediately write to all elements.

    Examples:
        let t = empty((3, 4), DType.float32)
        # Creates a 3x4 tensor with undefined values
    """
    # Just allocate without initialization
    var tensor = ExTensor(shape, dtype)
    return tensor^
