---
name: mojo-type-safety
description: Validate type safety in Mojo code including parametric types, trait constraints, and compile-time checks. Use during code review or when type errors occur.
---

# Type Safety Validation Skill

Validate Mojo code follows type safety principles.

## When to Use

- Type errors during compilation
- Code review for type safety
- Designing generic functions
- Working with traits

## Type Safety Principles

### 1. Use Type Parameters

```mojo
# ✅ Generic function
fn add[dtype: DType](a: Scalar[dtype], b: Scalar[dtype]) -> Scalar[dtype]:
    return a + b

# ❌ Untyped (Python-style)
def add_untyped(a, b):
    return a + b
```text

### 2. Trait Constraints

```mojo
# Ensure type supports required operations
fn process[T: Copyable](data: T):
    let copy = data  # OK: T is Copyable
```text

### 3. Compile-Time Checks

```mojo
@parameter
fn validate[size: Int]():
    constrained[size > 0, "Size must be positive"]()

fn create_array[size: Int]():
    validate[size]()  # Compile-time check
    # Create array
```text

## Common Issues

### 1. Missing Type Annotations

```mojo
# ❌ Missing types
fn process(data):
    return data

# ✅ Explicit types
fn process(data: Tensor[DType.float32]) -> Tensor[DType.float32]:
    return data
```text

### 2. Incorrect Parameter Constraints

```mojo
# ❌ No constraint
fn sort[T](data: List[T]):
    # Assumes T is comparable

# ✅ With constraint
fn sort[T: Comparable](data: List[T]):
    # T guaranteed comparable
```text

### 3. Type Mismatches

```mojo
# ❌ Type mismatch
let a: Float32 = 1.0
let b: Float64 = 2.0
let c = a + b  # Error: different types!

# ✅ Explicit conversion
let c = a + Float32(b)
```text

## Checklist

- [ ] All functions have type signatures
- [ ] Generic functions use type parameters
- [ ] Trait constraints where needed
- [ ] No implicit type conversions
- [ ] Compile-time validation where possible

See Mojo type system documentation.
