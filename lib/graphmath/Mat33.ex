defmodule Graphmath.Mat33 do
  @moduledoc """
  This is the 3D mathematics library for graphmath.

  This submodule handles 3x3 matrices using tuples of floats.
  """

  use Zig, otp_app: :graphmath_native, release_mode: :fast

  @type mat33 :: {float, float, float, float, float, float, float, float, float}
  @type vec3 :: {float, float, float}
  @type vec2 :: {float, float}

  ~Z"""
  const beam = @import("beam");
  const e = @import("erl_nif");
  const std = @import("std");

  fn get_tuple(comptime T: type, term: beam.term) !T {
      const info = @typeInfo(T);
      const fields = info.Struct.fields;
      var arity: c_int = undefined;
      var ptr: [*c]const e.ErlNifTerm = undefined;
      if (e.enif_get_tuple(beam.context.env, term.v, &arity, &ptr) == 0) return error.ArgumentError;
      if (arity != fields.len) return error.ArgumentError;
      var result: T = undefined;
      inline for (fields, 0..) |field, i| {
          if (field.type == f64) {
              var val: f64 = undefined;
              if (e.enif_get_double(beam.context.env, ptr[i], &val) != 0) {
                  @field(result, field.name) = val;
              } else {
                  var ival: i64 = undefined;
                  if (e.enif_get_int64(beam.context.env, ptr[i], &ival) != 0) {
                      @field(result, field.name) = @as(f64, @floatFromInt(ival));
                  } else return error.ArgumentError;
              }
          } else {
              @field(result, field.name) = try beam.get(field.type, .{ .v = ptr[i] }, .{});
          }
      }
      return result;
  }

  pub fn identity_nif() beam.term {
      return beam.make(.{ 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 }, .{});
  }

  pub fn zero_nif() beam.term {
      return beam.make(.{ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }, .{});
  }

  pub fn add_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"0" + b.@"0", a.@"1" + b.@"1", a.@"2" + b.@"2",
          a.@"3" + b.@"3", a.@"4" + b.@"4", a.@"5" + b.@"5",
          a.@"6" + b.@"6", a.@"7" + b.@"7", a.@"8" + b.@"8",
      }, .{});
  }

  pub fn subtract_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"0" - b.@"0", a.@"1" - b.@"1", a.@"2" - b.@"2",
          a.@"3" - b.@"3", a.@"4" - b.@"4", a.@"5" - b.@"5",
          a.@"6" - b.@"6", a.@"7" - b.@"7", a.@"8" - b.@"8",
      }, .{});
  }

  pub fn scale_nif(a_term: beam.term, k: f64) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{
          a.@"0" * k, a.@"1" * k, a.@"2" * k,
          a.@"3" * k, a.@"4" * k, a.@"5" * k,
          a.@"6" * k, a.@"7" * k, a.@"8" * k,
      }, .{});
  }

  pub fn make_scale1_nif(k: f64) beam.term {
      return beam.make(.{ k, 0.0, 0.0, 0.0, k, 0.0, 0.0, 0.0, k }, .{});
  }

  pub fn make_scale3_nif(sx: f64, sy: f64, sz: f64) beam.term {
      return beam.make(.{ sx, 0.0, 0.0, 0.0, sy, 0.0, 0.0, 0.0, sz }, .{});
  }

  pub fn make_translate_nif(tx: f64, ty: f64) beam.term {
      return beam.make(.{ 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, tx, ty, 1.0 }, .{});
  }

  pub fn make_rotate_nif(theta: f64) beam.term {
      const st = std.math.sin(theta);
      const ct = std.math.cos(theta);
      return beam.make(.{ ct, st, 0.0, -st, ct, 0.0, 0.0, 0.0, 1.0 }, .{});
  }

  pub fn multiply_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"0" * b.@"0" + a.@"1" * b.@"3" + a.@"2" * b.@"6",
          a.@"0" * b.@"1" + a.@"1" * b.@"4" + a.@"2" * b.@"7",
          a.@"0" * b.@"2" + a.@"1" * b.@"5" + a.@"2" * b.@"8",
          a.@"3" * b.@"0" + a.@"4" * b.@"3" + a.@"5" * b.@"6",
          a.@"3" * b.@"1" + a.@"4" * b.@"4" + a.@"5" * b.@"7",
          a.@"3" * b.@"2" + a.@"4" * b.@"5" + a.@"5" * b.@"8",
          a.@"6" * b.@"0" + a.@"7" * b.@"3" + a.@"8" * b.@"6",
          a.@"6" * b.@"1" + a.@"7" * b.@"4" + a.@"8" * b.@"7",
          a.@"6" * b.@"2" + a.@"7" * b.@"5" + a.@"8" * b.@"8",
      }, .{});
  }

  pub fn multiply_transpose_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"0" * b.@"0" + a.@"1" * b.@"1" + a.@"2" * b.@"2",
          a.@"0" * b.@"3" + a.@"1" * b.@"4" + a.@"2" * b.@"5",
          a.@"0" * b.@"6" + a.@"1" * b.@"7" + a.@"2" * b.@"8",
          a.@"3" * b.@"0" + a.@"4" * b.@"1" + a.@"5" * b.@"2",
          a.@"3" * b.@"3" + a.@"4" * b.@"4" + a.@"5" * b.@"5",
          a.@"3" * b.@"6" + a.@"4" * b.@"7" + a.@"5" * b.@"8",
          a.@"6" * b.@"0" + a.@"7" * b.@"1" + a.@"8" * b.@"2",
          a.@"6" * b.@"3" + a.@"7" * b.@"4" + a.@"8" * b.@"5",
          a.@"6" * b.@"6" + a.@"7" * b.@"7" + a.@"8" * b.@"8",
      }, .{});
  }

  pub fn column0_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"0", a.@"3", a.@"6" }, .{});
  }

  pub fn column1_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"1", a.@"4", a.@"7" }, .{});
  }

  pub fn column2_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"2", a.@"5", a.@"8" }, .{});
  }

  pub fn row0_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"0", a.@"1", a.@"2" }, .{});
  }

  pub fn row1_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"3", a.@"4", a.@"5" }, .{});
  }

  pub fn row2_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"6", a.@"7", a.@"8" }, .{});
  }

  pub fn diag_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"0", a.@"4", a.@"8" }, .{});
  }

  pub fn apply_nif(a_term: beam.term, v_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const v = try get_tuple(struct { f64, f64, f64 }, v_term);
      return beam.make(.{
          a.@"0" * v.@"0" + a.@"1" * v.@"1" + a.@"2" * v.@"2",
          a.@"3" * v.@"0" + a.@"4" * v.@"1" + a.@"5" * v.@"2",
          a.@"6" * v.@"0" + a.@"7" * v.@"1" + a.@"8" * v.@"2",
      }, .{});
  }

  pub fn apply_transpose_nif(a_term: beam.term, v_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const v = try get_tuple(struct { f64, f64, f64 }, v_term);
      return beam.make(.{
          a.@"0" * v.@"0" + a.@"3" * v.@"1" + a.@"6" * v.@"2",
          a.@"1" * v.@"0" + a.@"4" * v.@"1" + a.@"7" * v.@"2",
          a.@"2" * v.@"0" + a.@"5" * v.@"1" + a.@"8" * v.@"2",
      }, .{});
  }

  pub fn transform_point_nif(a_term: beam.term, v_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const v = try get_tuple(struct { f64, f64 }, v_term);
      return beam.make(.{
          a.@"0" * v.@"0" + a.@"3" * v.@"1" + a.@"6",
          a.@"1" * v.@"0" + a.@"4" * v.@"1" + a.@"7",
      }, .{});
  }

  pub fn transform_vector_nif(a_term: beam.term, v_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const v = try get_tuple(struct { f64, f64 }, v_term);
      return beam.make(.{
          a.@"0" * v.@"0" + a.@"3" * v.@"1",
          a.@"1" * v.@"0" + a.@"4" * v.@"1",
      }, .{});
  }

  pub fn inverse_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const a00 = a.@"0"; const a01 = a.@"1"; const a02 = a.@"2";
      const a10 = a.@"3"; const a11 = a.@"4"; const a12 = a.@"5";
      const a20 = a.@"6"; const a21 = a.@"7"; const a22 = a.@"8";

      const v00 = a11 * a22 - a12 * a21;
      const v01 = a02 * a21 - a01 * a22;
      const v02 = a01 * a12 - a02 * a11;
      const v10 = a12 * a20 - a10 * a22;
      const v11 = a00 * a22 - a02 * a20;
      const v12 = a02 * a10 - a00 * a12;
      const v20 = a10 * a21 - a11 * a20;
      const v21 = a01 * a20 - a00 * a21;
      const v22 = a00 * a11 - a01 * a10;

      const f_det = a00 * v00 + a01 * v10 + a02 * v20;
      if (f_det == 0.0) return error.ArgumentError;

      const f_inv_det = 1.0 / f_det;

      return beam.make(.{
          v00 * f_inv_det, v01 * f_inv_det, v02 * f_inv_det,
          v10 * f_inv_det, v11 * f_inv_det, v12 * f_inv_det,
          v20 * f_inv_det, v21 * f_inv_det, v22 * f_inv_det,
      }, .{});
  }
  """

  @doc """
  `identity()` creates an identity `mat33`.

  This returns an identity `mat33`.
  """
  @spec identity() :: mat33
  def identity(), do: identity_nif()

  @doc """
  `zero()` creates a zeroed `mat33`.

  This returns a zeroed `mat33`.
  """
  @spec zero() :: mat33
  def zero(), do: zero_nif()

  @doc """
  `add(a,b)` adds one `mat33` to another `mat33`.

  `a` is the first `mat33`.

  `b` is the second `mat33`.

  This returns a `mat33` which is the element-wise sum of `a` and `b`.
  """
  @spec add(mat33, mat33) :: mat33
  def add(a, b), do: add_nif(to_float(a), to_float(b))

  @doc """
  `subtract(a,b)` subtracts one `mat33` from another `mat33`.

  `a` is the minuend.

  `b` is the subtraherd.

  This returns a `mat33` formed by the element-wise subtraction of `b` from `a`.
  """
  @spec subtract(mat33, mat33) :: mat33
  def subtract(a, b), do: subtract_nif(to_float(a), to_float(b))

  @doc """
  `scale( a, k )` scales every element in a `mat33` by a coefficient k.

  `a` is the `mat33` to scale.

  `k` is the float to scale by.

  This returns a `mat33` `a` scaled element-wise by `k`.
  """
  @spec scale(mat33, float) :: mat33
  def scale(a, k), do: scale_nif(to_float(a), 1.0 * k)

  @doc """
  `make_scale( k )` creates a `mat33` that uniformly scales.

  `k` is the float value to scale by.

  This returns a `mat33` whose diagonal is all `k`s.
  """
  @spec make_scale(float) :: mat33
  def make_scale(k), do: make_scale1_nif(1.0 * k)

  @doc """
  `make_scale( sx, sy, sz )` creates a `mat33` that scales each axis independently.

  `sx` is a float for scaling the x-axis.

  `sy` is a float for scaling the y-axis.

  `sz` is a float for scaling the z-axis.

  This returns a `mat33` whose diagonal is `{ sx, sy, sz }`.

  Note that, when used with `vec2`s via the *transform* methods, `sz` will have no effect.
  """
  @spec make_scale(float, float, float) :: mat33
  def make_scale(sx, sy, sz), do: make_scale3_nif(1.0 * sx, 1.0 * sy, 1.0 * sz)

  @doc """
  `make_translate( tx, ty )` creates a mat33 that translates a vec2 by (tx, ty).

  `tx` is a float for translating along the x-axis.

  `ty` is a float for translating along the y-axis.

  This returns a `mat33` which translates by a `vec2` `{ tx, ty }`.
  """
  @spec make_translate(float, float) :: mat33
  def make_translate(tx, ty), do: make_translate_nif(1.0 * tx, 1.0 * ty)

  @doc """
  `make_rotate( theta )` creates a mat33 that rotates a vec2 by `theta` radians about the +Z axis.

  `theta` is the float of the number of radians of rotation the matrix will provide.

  This returns a `mat33` which rotates by `theta` radians about the +Z axis.
  """
  @spec make_rotate(float) :: mat33
  def make_rotate(theta), do: make_rotate_nif(1.0 * theta)

  @doc """
  `round( a, sigfigs )` rounds every element of a `mat33` to some number of decimal places.

  `a` is the `mat33` to round.

  `sigfigs` is an integer on [0,15] of the number of decimal places to round to.

  This returns a `mat33` which is the result of rounding `a`.
  """
  @spec round(mat33, 0..15) :: mat33
  def round(a, sigfigs) do
    {a11, a12, a13, a21, a22, a23, a31, a32, a33} = to_float(a)

    {
      Float.round(a11, sigfigs),
      Float.round(a12, sigfigs),
      Float.round(a13, sigfigs),
      Float.round(a21, sigfigs),
      Float.round(a22, sigfigs),
      Float.round(a23, sigfigs),
      Float.round(a31, sigfigs),
      Float.round(a32, sigfigs),
      Float.round(a33, sigfigs)
    }
  end

  @doc """
  `multiply( a, b )` multiply two matrices a and b together.

  `a` is the `mat33` multiplicand.

  `b` is the `mat33` multiplier.

  This returns the `mat33` product of the `a` and `b`.
  """
  @spec multiply(mat33, mat33) :: mat33
  def multiply(a, b), do: multiply_nif(to_float(a), to_float(b))

  @doc """
  `multiply_transpose( a, b )` multiply two matrices a and b<sup>T</sup> together.

  `a` is the `mat33` multiplicand.

  `b` is the `mat33` multiplier.

  This returns the `mat33` product of the `a` and `b`<sup>T</sup>.
  """
  @spec multiply_transpose(mat33, mat33) :: mat33
  def multiply_transpose(a, b), do: multiply_transpose_nif(to_float(a), to_float(b))

  @doc """
  `column0( a )` selects the first column of a `mat33`.

  `a` is the `mat33` to take the first column of.

  This returns a `vec3` representing the first column of `a`.
  """
  @spec column0(mat33) :: vec3
  def column0(a), do: column0_nif(to_float(a))

  @doc """
  `column1( a )` selects the second column of a `mat33`.

  `a` is the `mat33` to take the second column of.

  This returns a `vec3` representing the second column of `a`.
  """
  @spec column1(mat33) :: vec3
  def column1(a), do: column1_nif(to_float(a))

  @doc """
  `column2( a )` selects the third column of a `mat33`.

  `a` is the `mat33` to take the third column of.

  This returns a `vec3` representing the third column of `a`.
  """
  @spec column2(mat33) :: vec3
  def column2(a), do: column2_nif(to_float(a))

  @doc """
  `row0( a )` selects the first row of a `mat33`.

  `a` is the `mat33` to take the first row of.

  This returns a `vec3` representing the first row of `a`.
  """
  @spec row0(mat33) :: vec3
  def row0(a), do: row0_nif(to_float(a))

  @doc """
  `row1( a )` selects the second row of a `mat33`.

  `a` is the `mat33` to take the second row of.

  This returns a `vec3` representing the second row of `a`.
  """
  @spec row1(mat33) :: vec3
  def row1(a), do: row1_nif(to_float(a))

  @doc """
  `row2( a )` selects the third row of a `mat33`.

  `a` is the `mat33` to take the third row of.

  This returns a `vec3` representing the third row of `a`.
  """
  @spec row2(mat33) :: vec3
  def row2(a), do: row2_nif(to_float(a))

  @doc """
  `diag( a )` selects the diagonal of a `mat33`.

  `a` is the `mat33` to take the diagonal of.

  This returns a `vec3` representing the diagonal of `a`.
  """
  @spec diag(mat33) :: vec3
  def diag(a), do: diag_nif(to_float(a))

  @doc """
  `at( a, i, j)` selects an element of a `mat33`.

  `a` is the `mat33` to index.

  `i` is the row integer index [0,2].

  `j` is the column integer index [0,2].

  This returns a float from the matrix at row `i` and column `j`.
  """
  @spec at(mat33, non_neg_integer, non_neg_integer) :: float
  def at(a, i, j), do: elem(a, 3 * i + j)

  @doc """
  `apply( a, v )` transforms a `vec3` by a `mat33`.

  `a` is the `mat33` to transform by.

  `v` is the `vec3` to be transformed.

  This returns a `vec3` representing **A****v**.

  This is the "full" application of a matrix, and uses all elements.
  """
  @spec apply(mat33, vec3) :: vec3
  def apply(a, v), do: apply_nif(to_float(a), to_float_v3(v))

  @doc """
  `apply_transpose( a, v )` transforms a `vec3` by a a transposed `mat33`.

  `a` is the `mat33` to transform by.

  `v` is the `vec3` to be transformed.

  This returns a `vec3` representing **A**<sup>T</sup>**v**.

  This is the "full" application of a matrix, and uses all elements.
  """
  @spec apply_transpose(mat33, vec3) :: vec3
  def apply_transpose(a, v), do: apply_transpose_nif(to_float(a), to_float_v3(v))

  @doc """
  `apply_left( v, a )` transforms a `vec3` by a `mat33`, applied on the left.

  `a` is the `mat33` to transform by.

  `v` is the `vec3` to be transformed.

  This returns a `vec3` representing **v****A**.

  This is the "full" application of a matrix, and uses all elements.
  """
  @spec apply_left(vec3, mat33) :: vec3
  def apply_left(v, a), do: apply_transpose_nif(to_float(a), to_float_v3(v))

  @doc """
  `apply_left_transpose( v, a )` transforms a `vec3` by a transposed `mat33`, applied on the left.

  `a` is the `mat33` to transform by.

  `v` is the `vec3` to be transformed.

  This returns a `vec3` representing **v****A**<sup>T</sup>.

  This is the "full" application of a matrix, and uses all elements.
  """
  @spec apply_left_transpose(vec3, mat33) :: vec3
  def apply_left_transpose(v, a), do: apply_nif(to_float(a), to_float_v3(v))

  @doc """
  `transform_point( a, v )` transforms a `vec2` point by a `mat33`.

  `a` is a `mat33` used to transform the point.

  `v` is a `vec2` to be transformed.

  This returns a `vec2` representing the application of `a` to `v`.

  The point `a` is internally treated as having a third coordinate equal to 1.0.

  Note that transforming a point will work for all transforms.
  """
  @spec transform_point(mat33, vec2) :: vec2
  def transform_point(a, v), do: transform_point_nif(to_float(a), to_float_v2(v))

  @doc """
  `transform_vector( a, v )` transforms a `vec2` vector by a `mat33`.

  `a` is a `mat33` used to transform the point.

  `v` is a `vec2` to be transformed.

  This returns a `vec2` representing the application of `a` to `v`.

  The point `a` is internally treated as having a third coordinate equal to 0.0.

  Note that transforming a vector will work for only rotations, scales, and shears.
  """
  @spec transform_vector(mat33, vec2) :: vec2
  def transform_vector(a, v), do: transform_vector_nif(to_float(a), to_float_v2(v))

  @doc """
  `inverse(a)` calculates the inverse matrix

  `a` is a `mat33` to be inverted

  Returs a `mat33` representing `a`<sup>-1</sup>

  Raises an error when you try to calculate inverse of a matrix whose determinant is `zero`
  """
  @spec inverse(mat33) :: mat33
  def inverse(a), do: inverse_nif(to_float(a))

  defp to_float({a, b, c, d, e, f, g, h, i}),
    do: {1.0 * a, 1.0 * b, 1.0 * c, 1.0 * d, 1.0 * e, 1.0 * f, 1.0 * g, 1.0 * h, 1.0 * i}

  defp to_float_v3({x, y, z}), do: {1.0 * x, 1.0 * y, 1.0 * z}
  defp to_float_v2({x, y}), do: {1.0 * x, 1.0 * y}
end
