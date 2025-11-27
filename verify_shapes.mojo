from shared.core.extensor import ExTensor, zeros

fn main() raises:
    var batch = 2
    var m = 3
    var k = 4
    var n = 2

    # Create input A with shape (batch*m, k) = (6, 4)
    var shape_a = List[Int]()
    shape_a.append(batch * m)
    shape_a.append(k)
    var a = zeros(shape_a, DType.float32)

    # Create input B with shape (k, n) = (4, 2)
    var shape_b = List[Int]()
    shape_b.append(k)
    shape_b.append(n)
    var b = zeros(shape_b, DType.float32)

    print("A ndim:", len(a.shape()))
    print("A shape:", a.shape()[0], "x", a.shape()[1])
    print("B ndim:", len(b.shape()))
    print("B shape:", b.shape()[0], "x", b.shape()[1])
