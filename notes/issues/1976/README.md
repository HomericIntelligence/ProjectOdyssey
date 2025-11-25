# Issue #1976: Add missing var declarations in core test files

## Objective

Fix "use of unknown declaration" errors in core test files by adding missing `var` keyword before variable declarations.

## Deliverables

All four test files now have proper `var` declarations:

1. **tests/shared/core/test_edge_cases.mojo** - 36 var declarations added
2. **tests/shared/core/test_utilities.mojo** - 2 var declarations added
3. **tests/shared/core/test_utility.mojo** - 30+ var declarations added
4. **tests/shared/core/test_integration.mojo** - 35+ var declarations added

## Changes Made

### test_edge_cases.mojo

Fixed variable declarations in functions including:
- `test_empty_tensor_creation()`: `t` (line 35)
- `test_empty_tensor_operations()`: `a`, `b`, `c` (lines 45-47)
- `test_scalar_tensor_operations()`: `a`, `b`, `c` (lines 80-82)
- `test_scalar_to_vector_broadcast()`: `a`, `b`, `c` (lines 95-97)
- `test_comparison_with_zero()`: `positive`, `negative`, `zero`, `pos_gt_zero`, `neg_gt_zero`, `neg_lt_zero` (lines 519-532)
- `test_comparison_equal_values()`: `a`, `b`, `c` (lines 539-541)
- `test_comparison_very_close_values()`: `a`, `b`, `eq`, `ne` (lines 551-556)
- Division and modulo test functions: `val` variable declarations in loops
- Power and floor_divide test functions: Variable declarations for operands

### test_utilities.mojo

Fixed variable declarations in:
- `test_ones_like_values()`: `val` (line 54)
- `test_full_like_custom_value()`: `fill_value` (line 119), `val` (line 125), `diff` (line 126)

### test_utility.mojo

Fixed extensive variable declarations in property and utility operation tests:
- `test_numel_total_elements()`: `t` (line 62)
- `test_dim_num_dimensions()`: `t1` (line 71), `t3` (line 78)
- `test_shape_property()`: `t` (line 87), `s` (line 89)
- `test_dtype_property()`: `t32` (line 100), `t64` (line 103)
- `test_stride_row_major()`: `t` (line 117), `strides` (line 120)
- `test_is_contiguous_true()`: `t` (line 135), `contig` (line 139)
- `test_is_contiguous_after_transpose()`: `a` (line 149)
- `test_contiguous_on_noncontiguous()`: `a` (line 167)
- `test_item_single_element()`: `t` (line 184)
- `test_item_requires_single_element()`: `t` (line 195)
- `test_tolist_1d()`: `t` (line 208)
- `test_tolist_nested()`: `t` (line 221)
- `test_len_first_dim()`: `t` (line 240)
- `test_len_1d()`: `t` (line 251)
- `test_bool_single_element()`: `t_zero` (line 265), `t_nonzero` (line 266)
- `test_bool_requires_single_element()`: `t` (line 279)
- `test_int_conversion()`: `t` (line 295)
- `test_float_conversion()`: `t` (line 305)
- `test_str_readable()`: `t` (line 320)
- `test_repr_complete()`: `t` (line 332)
- `test_hash_immutable()`: `a` (line 347), `b` (line 348)
- `test_diff_1d()`: `t` (line 363)
- `test_diff_higher_order()`: `t` (line 374)

### test_integration.mojo

Fixed variable declarations in integration tests:
- `test_chained_add_operations()`: `a`, `b`, `c`, `result` (lines 29-33)
- `test_mixed_arithmetic_operations()`: `a`, `b`, `c`, `sum_ab`, `result` (lines 42-48)
- `test_arithmetic_with_operator_overloading()`: `a`, `b`, `c`, `result` (lines 57-62)
- `test_complex_expression()`: `a`, `b`, `c`, `d`, `result` (lines 72-78)
- `test_identity_matrix_operations()`: `I`, `A`, `B`, `result` (lines 89-97)
- `test_arange_arithmetic()`: `a`, `b`, `result` (lines 111-116)
- `test_linspace_operations()`: `a`, `b`, `result` (lines 125-128)
- `test_same_dtype_consistency()`: `a32`, `b32`, `result32`, `a64`, `b64`, `result64` (lines 144-152)
- `test_int_dtype_operations()`: `a`, `b`, `result` (lines 160-162)
- `test_2d_elementwise_operations()`: `a`, `b`, `result` (lines 177-180)
- `test_3d_operations()`: `a`, `b`, `result` (lines 192-195)
- `test_linear_transformation_pattern()`: `W`, `x`, `b`, `Wx`, `result` (lines 211-217)
- `test_gradient_descent_update_pattern()`: `w`, `grad`, `lr`, `lr_grad`, `new_w` (lines 227-233)
- `test_batch_normalization_pattern()`: `x`, `mean`, `scale`, `centered`, `result` (lines 243-249)
- `test_additive_identity()`: `a`, `zero`, `result` (lines 263-266)
- `test_multiplicative_identity()`: `a`, `one`, `result` (lines 276-279)
- `test_multiplicative_zero()`: `a`, `zero`, `result` (lines 289-292)
- `test_scalar_operations()`: `a`, `b`, `result` (lines 304-307)
- `test_large_tensor_operations()`: `a`, `b`, `result` (lines 321-324)

## Success Criteria

- [x] All missing `var` declarations have been added to test_edge_cases.mojo
- [x] All missing `var` declarations have been added to test_utilities.mojo
- [x] All missing `var` declarations have been added to test_utility.mojo
- [x] All missing `var` declarations have been added to test_integration.mojo
- [x] Files now compile without "use of unknown declaration" errors
- [x] All variable assignments properly use `var` keyword

## Notes

- Fixed pattern: Changed `varname = value` to `var name = value` (accidental concatenation)
- Fixed pattern: Added `var` before variables that were missing the keyword
- All changes follow Mojo syntax requirements for variable declarations
- No functional changes, purely syntactic fixes
- Total of 100+ variable declarations fixed across 4 files
