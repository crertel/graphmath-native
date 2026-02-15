defmodule Graphmath.Vec3 do
  @moduledoc """
  This is the 3D mathematics library for graphmath.

  This submodule handles 3D vectors using tuples of floats.
  """

  use Zig, otp_app: :graphmath_native, release_mode: :fast
  import Kernel, except: [length: 1]

  @type vec3 :: {float, float, float}

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

  pub fn create0_nif() beam.term {
      return beam.make(.{ 0.0, 0.0, 0.0 }, .{});
  }

  pub fn create3_nif(x: f64, y: f64, z: f64) beam.term {
      return beam.make(.{ x, y, z }, .{});
  }

  pub fn create1_nif(vec: beam.term) !beam.term {
      var list = vec.v;
      var head: e.ErlNifTerm = undefined;
      var x: f64 = undefined;
      var y: f64 = undefined;
      var z: f64 = undefined;

      if (e.enif_get_list_cell(beam.context.env, list, &head, &list) == 0) return error.ArgumentError;
      if (e.enif_get_double(beam.context.env, head, &x) == 0) {
          var ix: i64 = undefined;
          if (e.enif_get_int64(beam.context.env, head, &ix) == 0) return error.ArgumentError;
          x = @as(f64, @floatFromInt(ix));
      }

      if (e.enif_get_list_cell(beam.context.env, list, &head, &list) == 0) return error.ArgumentError;
      if (e.enif_get_double(beam.context.env, head, &y) == 0) {
          var iy: i64 = undefined;
          if (e.enif_get_int64(beam.context.env, head, &iy) == 0) return error.ArgumentError;
          y = @as(f64, @floatFromInt(iy));
      }

      if (e.enif_get_list_cell(beam.context.env, list, &head, &list) == 0) return error.ArgumentError;
      if (e.enif_get_double(beam.context.env, head, &z) == 0) {
          var iz: i64 = undefined;
          if (e.enif_get_int64(beam.context.env, head, &iz) == 0) return error.ArgumentError;
          z = @as(f64, @floatFromInt(iz));
      }

      return beam.make(.{ x, y, z }, .{});
  }

  pub fn add_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      return beam.make(.{ a.@"0" + b.@"0", a.@"1" + b.@"1", a.@"2" + b.@"2" }, .{});
  }

  pub fn subtract_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      return beam.make(.{ a.@"0" - b.@"0", a.@"1" - b.@"1", a.@"2" - b.@"2" }, .{});
  }

  pub fn multiply_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      return beam.make(.{ a.@"0" * b.@"0", a.@"1" * b.@"1", a.@"2" * b.@"2" }, .{});
  }

  pub fn scale_nif(a_term: beam.term, s: f64) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"0" * s, a.@"1" * s, a.@"2" * s }, .{});
  }

  pub fn dot_nif(a_term: beam.term, b_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      return a.@"0" * b.@"0" + a.@"1" * b.@"1" + a.@"2" * b.@"2";
  }

  pub fn cross_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"1" * b.@"2" - a.@"2" * b.@"1",
          a.@"2" * b.@"0" - a.@"0" * b.@"2",
          a.@"0" * b.@"1" - a.@"1" * b.@"0",
      }, .{});
  }

  pub fn length_nif(a_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      return std.math.sqrt(a.@"0" * a.@"0" + a.@"1" * a.@"1" + a.@"2" * a.@"2");
  }

  pub fn length_squared_nif(a_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      return a.@"0" * a.@"0" + a.@"1" * a.@"1" + a.@"2" * a.@"2";
  }

  pub fn length_manhattan_nif(a_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      return a.@"0" + a.@"1" + a.@"2";
  }

  pub fn normalize_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const invmag = 1.0 / std.math.sqrt(a.@"0" * a.@"0" + a.@"1" * a.@"1" + a.@"2" * a.@"2");
      return beam.make(.{ a.@"0" * invmag, a.@"1" * invmag, a.@"2" * invmag }, .{});
  }

  pub fn lerp_nif(a_term: beam.term, b_term: beam.term, t: f64) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      return beam.make(.{
          t * b.@"0" + (1.0 - t) * a.@"0",
          t * b.@"1" + (1.0 - t) * a.@"1",
          t * b.@"2" + (1.0 - t) * a.@"2",
      }, .{});
  }

  pub fn near_nif(a_term: beam.term, b_term: beam.term, distance: f64) !bool {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      const dx = a.@"0" - b.@"0";
      const dy = a.@"1" - b.@"1";
      const dz = a.@"2" - b.@"2";
      return distance > std.math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  pub fn equal_nif(a_term: beam.term, b_term: beam.term) !bool {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      return a.@"0" == b.@"0" and a.@"1" == b.@"1" and a.@"2" == b.@"2";
  }

  pub fn equal_eps_nif(a_term: beam.term, b_term: beam.term, eps: f64) !bool {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      return @abs(a.@"0" - b.@"0") <= eps and @abs(a.@"1" - b.@"1") <= eps and @abs(a.@"2" - b.@"2") <= eps;
  }

  pub fn negate_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      return beam.make(.{ -a.@"0", -a.@"1", -a.@"2" }, .{});
  }

  pub fn weighted_sum_nif(a: f64, v1_term: beam.term, b: f64, v2_term: beam.term) !beam.term {
      const v1 = try get_tuple(struct { f64, f64, f64 }, v1_term);
      const v2 = try get_tuple(struct { f64, f64, f64 }, v2_term);
      return beam.make(.{ a * v1.@"0" + b * v2.@"0", a * v1.@"1" + b * v2.@"1", a * v1.@"2" + b * v2.@"2" }, .{});
  }

  pub fn scalar_triple_nif(a_term: beam.term, b_term: beam.term, c_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      const c = try get_tuple(struct { f64, f64, f64 }, c_term);
      return a.@"0" * (b.@"1" * c.@"2" - b.@"2" * c.@"1") +
          a.@"1" * (b.@"2" * c.@"0" - b.@"0" * c.@"2") +
          a.@"2" * (b.@"0" * c.@"1" - b.@"1" * c.@"0");
  }

  pub fn minkowski_distance_nif(a_term: beam.term, b_term: beam.term, order: f64) !f64 {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      const adx = @abs(b.@"0" - a.@"0");
      const ady = @abs(b.@"1" - a.@"1");
      const adz = @abs(b.@"2" - a.@"2");
      const temp = std.math.pow(f64, adx, order) + std.math.pow(f64, ady, order) + std.math.pow(f64, adz, order);
      return std.math.pow(f64, temp, 1.0 / order);
  }

  pub fn chebyshev_distance_nif(a_term: beam.term, b_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64 }, b_term);
      const adx = @abs(b.@"0" - a.@"0");
      const ady = @abs(b.@"1" - a.@"1");
      const adz = @abs(b.@"2" - a.@"2");
      return @max(adx, @max(ady, adz));
  }

  pub fn p_norm_nif(a_term: beam.term, order: f64) !f64 {
      const a = try get_tuple(struct { f64, f64, f64 }, a_term);
      const ax = @abs(a.@"0");
      const ay = @abs(a.@"1");
      const az = @abs(a.@"2");
      const temp = std.math.pow(f64, ax, order) + std.math.pow(f64, ay, order) + std.math.pow(f64, az, order);
      return std.math.pow(f64, temp, 1.0 / order);
  }
  """

  @doc """
  `create()` creates a zeroed `vec3`.

  It takes no arguments.

  It returns a `vec3` of the form `{ 0.0, 0.0, 0.0 }`.
  """
  @spec create() :: vec3
  def create(), do: create0_nif()

  @doc """
  `create(x,y,z)` creates a `vec3` of value (x,y,z).

  `x` is the first element of the `vec3` to be created.

  `y` is the second element of the `vec3` to be created.

  `z` is the third element of the `vec3` to be created.

  It returns a `vec3` of the form `{x,y,z}`.
  """
  @spec create(float, float, float) :: vec3
  def create(x, y, z), do: create3_nif(1.0 * x, 1.0 * y, 1.0 * z)

  @doc """
  `create(vec)` creates a `vec3` from a list of 3 or more floats.

  `vec` is a list of 3 or more floats.

  It returns a `vec3` of the form `{x,y,z}`, where `x`, `y`, and `z` are the first three elements in `vec`.
  """
  @spec create([float]) :: vec3
  def create(vec), do: create1_nif(vec)

  @doc """
  `add( a, b)` adds two `vec3`s.

  `a` is the first `vec3`.

  `b` is the second `vec3`.

  It returns a `vec3` of the form { a<sub>x</sub> + b<sub>x</sub>, a<sub>y</sub> + b<sub>y</sub>, a<sub>z</sub> + b<sub>z</sub> }.
  """
  @spec add(vec3, vec3) :: vec3
  def add({ax, ay, az}, {bx, by, bz})
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz),
      do: add_nif({ax, ay, az}, {bx, by, bz})

  def add(a, b), do: add(to_float(a), to_float(b))

  @doc """
  `subtract(a, b)` subtracts one `vec3` from another `vec3`.

  `a` is the `vec3` minuend.

  `b` is the `vec3` subtrahend.

  It returns a `vec3` of the form { a<sub>x</sub> - b<sub>x</sub>, a<sub>y</sub> - b<sub>y</sub>, a<sub>z</sub> - b<sub>z</sub> }.

  (the terminology was found [here](http://mathforum.org/library/drmath/view/58801.html)).
  """
  @spec subtract(vec3, vec3) :: vec3
  def subtract({ax, ay, az}, {bx, by, bz})
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz),
      do: subtract_nif({ax, ay, az}, {bx, by, bz})

  def subtract(a, b), do: subtract(to_float(a), to_float(b))

  @doc """
  `multiply( a, b)` multiplies element-wise a `vec3` by another `vec3`.

  `a` is the `vec3` multiplicand.

  `b` is the `vec3` multiplier.

  It returns a `vec3` of the form { a<sub>x</sub>b<sub>x</sub>, a<sub>y</sub>b<sub>y</sub>, a<sub>z</sub>b<sub>z</sub> }.
  """
  @spec multiply(vec3, vec3) :: vec3
  def multiply({ax, ay, az}, {bx, by, bz})
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz),
      do: multiply_nif({ax, ay, az}, {bx, by, bz})

  def multiply(a, b), do: multiply(to_float(a), to_float(b))

  @doc """
  `scale( a, scale)` uniformly scales a `vec3`.

  `a` is the `vec3` to be scaled.

  `scale` is the float to scale each element of `a` by.

  It returns a tuple of the form { a<sub>x</sub>scale, a<sub>y</sub>scale, a<sub>z</sub>scale }.
  """
  @spec scale(vec3, float) :: vec3
  def scale({ax, ay, az}, s) when is_float(ax) and is_float(ay) and is_float(az) and is_float(s),
    do: scale_nif({ax, ay, az}, s)

  def scale(a, s), do: scale(to_float(a), 1.0 * s)

  @doc """
  `dot( a, b)` finds the dot (inner) product of one `vec3` with another `vec3`.

  `a` is the first `vec3`.

  `b` is the second `vec3`.

  It returns a float of the value (a<sub>x</sub>b<sub>x</sub> + a<sub>y</sub>b<sub>y</sub> + a<sub>z</sub>b<sub>z</sub>).
  """
  @spec dot(vec3, vec3) :: float
  def dot({ax, ay, az}, {bx, by, bz})
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz),
      do: dot_nif({ax, ay, az}, {bx, by, bz})

  def dot(a, b), do: dot(to_float(a), to_float(b))

  @doc """
  `cross( a, b)` finds the cross productof one `vec3` with another `vec3`.

  `a` is the first `vec3`.

  `b` is the second `vec3`.

  It returns a float of the value ( a<sub>y</sub>b<sub>z</sub> - a<sub>z</sub>b<sub>y</sub>, a<sub>z</sub>b<sub>x</sub> - a<sub>x</sub>b<sub>z</sub>, a<sub>x</sub>b<sub>y</sub> - a<sub>y</sub>b<sub>x</sub>).

  The cross product of two vectors is a vector perpendicular to the two source vectors.
  Its magnitude will be the area of the parallelogram made by the two souce vectors.

  """
  @spec cross(vec3, vec3) :: vec3
  def cross({ax, ay, az}, {bx, by, bz})
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz),
      do: cross_nif({ax, ay, az}, {bx, by, bz})

  def cross(a, b), do: cross(to_float(a), to_float(b))

  @doc """
  `length(a)` finds the length (Eucldiean or L2 norm) of a `vec3`.

  `a` is the `vec3` to find the length of.

  It returns a float of the value (sqrt( a<sub>x</sub><sup>2</sup> + a<sub>y</sub><sup>2</sup> + a<sub>z</sub><sup>2</sup>)).
  """
  @spec length(vec3) :: float
  def length({ax, ay, az}) when is_float(ax) and is_float(ay) and is_float(az),
    do: length_nif({ax, ay, az})

  def length(a), do: length(to_float(a))

  @doc """
  `length_squared(a)` finds the square of the length of a `vec3`.

  `a` is the `vec3` to find the length squared of.

  It returns a float of the value a<sub>x</sub><sup>2</sup> + a<sub>y</sub><sup>2</sup> + a<sub>z</sub><sup>2</sup>.

  In many cases, this is sufficient for comparisons and avoids a square root.
  """
  @spec length_squared(vec3) :: float
  def length_squared({ax, ay, az}) when is_float(ax) and is_float(ay) and is_float(az),
    do: length_squared_nif({ax, ay, az})

  def length_squared(a), do: length_squared(to_float(a))

  @doc """
  `length_manhattan(a)` finds the Manhattan (L1 norm) length of a `vec3`.

  `a` is the `vec3` to find the Manhattan length of.

  It returns a float of the value (a<sub>x</sub> + a<sub>y</sub> + a<sub>z</sub>).

  The Manhattan length is the sum of the components.
  """
  @spec length_manhattan(vec3) :: float
  def length_manhattan({ax, ay, az}) when is_float(ax) and is_float(ay) and is_float(az),
    do: length_manhattan_nif({ax, ay, az})

  def length_manhattan(a), do: length_manhattan(to_float(a))

  @doc """
  `normalize(a)` finds the unit vector with the same direction as a `vec3`.

  `a` is the `vec3` to be normalized.

  It returns a `vec3` of the form `{normx, normy, normz}`.

  This is done by dividing each component by the vector's magnitude.
  """
  @spec normalize(vec3) :: vec3
  def normalize({ax, ay, az}) when is_float(ax) and is_float(ay) and is_float(az),
    do: normalize_nif({ax, ay, az})

  def normalize(a), do: normalize(to_float(a))

  @doc """
  `lerp(a,b,t)` linearly interpolates between one `vec3` and another `vec3` along an interpolant.

  `a` is the starting `vec3`.

  `b` is the ending `vec3`.

  `t` is the interpolant float, on the domain [0,1].

  It returns a `vec3` of the form (1-t)**a** - (t)**b**.

  The interpolant `t` is on the domain [0,1]. Behavior outside of that is undefined.
  """
  @spec lerp(vec3, vec3, float) :: vec3
  def lerp({ax, ay, az}, {bx, by, bz}, t)
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz) and is_float(t),
      do: lerp_nif({ax, ay, az}, {bx, by, bz}, t)

  def lerp(a, b, t), do: lerp(to_float(a), to_float(b), 1.0 * t)

  @doc """
  `near(a,b, distance)` checks whether two `vec3`s are within a certain distance of each other.

  `a` is the first `vec3`.

  `b` is the second `vec3`.

  `distance` is the distance between them as a float.
  """
  @spec near(vec3, vec3, float) :: boolean
  def near({ax, ay, az}, {bx, by, bz}, d)
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz) and is_float(d),
      do: near_nif({ax, ay, az}, {bx, by, bz}, d)

  def near(a, b, d), do: near(to_float(a), to_float(b), 1.0 * d)

  @doc """
  `rotate( v, k, theta)` rotates a vector (v) about a unit vector (k) by theta radians.

  `v` is the `vec3` to be rotated.

  `k` is the `vec3` axis of rotation. *It must be of unit length*.

  `theta` is the angle in radians to rotate as a float.

  This uses the [Formula of Rodriguez](http://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula):

  **V**<sub>rot</sub> = **V**cos(theta) + (**K** x **V**)sin(theta) + **K**(**K** dot **V**)(1-cos(theta))
  """
  @spec rotate(vec3, vec3, float) :: vec3
  def rotate(v, k, theta) do
    {vx, vy, vz} = to_float(v)
    {kx, ky, kz} = to_float(k)
    ct = :math.cos(theta)
    st = :math.sin(theta)
    k_dot_v = vx * kx + vy * ky + vz * kz
    coeff = (1.0 - ct) * k_dot_v

    v
    |> scale(ct)
    |> add(scale(cross(k, v), st))
    |> add(scale(k, coeff))
  end

  @doc """
  `equal(a, b)` checks to see if two vec3s a and b are equivalent.

  `a` is the `vec3`.

  `b` is the `vec3`.

  It returns true if the vectors have equal elements.

  Note that due to precision issues, you may want to use `equal/3` instead.
  """
  @spec equal(vec3, vec3) :: boolean
  def equal({ax, ay, az}, {bx, by, bz})
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz),
      do: equal_nif({ax, ay, az}, {bx, by, bz})

  def equal(a, b), do: equal(to_float(a), to_float(b))

  @doc """
  `equal(a, b, eps)` checks to see if two vec3s a and b are equivalent within some tolerance.

  `a` is the `vec3`.

  `b` is the `vec3`.

  `eps` is the tolerance, a float.

  It returns true if the vectors have equal elements within some tolerance.
  """
  @spec equal(vec3, vec3, float) :: boolean
  def equal({ax, ay, az}, {bx, by, bz}, eps)
      when is_float(ax) and is_float(ay) and is_float(az) and is_float(bx) and is_float(by) and
             is_float(bz) and is_float(eps),
      do: equal_eps_nif({ax, ay, az}, {bx, by, bz}, eps)

  def equal(a, b, eps), do: equal_eps_nif(to_float(a), to_float(b), 1.0 * eps)

  @doc """
  `random_sphere()` gives a point at or within unit distance of the origin, using [this](http://extremelearning.com.au/how-to-generate-uniformly-random-points-on-n-spheres-and-n-balls/) polar method.
  Another really nice exploration of this is [here](http://mathworld.wolfram.com/SpherePointPicking.html).

  It returns a vec3 within at most unit distance of the origin.
  """
  @spec random_sphere() :: vec3
  def random_sphere() do
    u = 2.0 * :rand.uniform() - 1
    phi = 2.0 * :math.pi() * :rand.uniform()
    x = :math.cos(phi) * :math.sqrt(1 - u * u)
    y = :math.sin(phi) * :math.sqrt(1 - u * u)
    z = u
    {x, y, z}
  end

  @doc """
  `random_ball()` gives a point at or within unit distance of the origin, using [the last algo here](https://karthikkaranth.me/blog/generating-random-points-in-a-sphere/).

  It returns a vec3 within at most unit distance of the origin.
  """
  @spec random_ball() :: vec3
  def random_ball() do
    u = :rand.uniform()
    v = :rand.uniform()
    theta = 2.0 * u * :math.pi()
    phi = :math.acos(2.0 * v - 1.0)
    # basically cube root
    r = :math.pow(:rand.uniform(), 1 / 3)
    sin_theta = :math.sin(theta)
    cos_theta = :math.cos(theta)
    sin_phi = :math.sin(phi)
    cos_phi = :math.cos(phi)
    x = r * sin_phi * cos_theta
    y = r * sin_phi * sin_theta
    z = r * cos_phi
    {x, y, z}
  end

  @doc """
  `random_box()` gives a point on or in the unit box [0,1]x[0,1]x[0,1].

  It returns a vec3.
  """
  @spec random_box() :: vec3
  def random_box(), do: {:rand.uniform(), :rand.uniform(), :rand.uniform()}

  @doc """
  `negate(v)` creates a vector whose elements are opposite in sign to `v`.
  """
  @spec negate(vec3) :: vec3
  def negate({ax, ay, az}) when is_float(ax) and is_float(ay) and is_float(az),
    do: negate_nif({ax, ay, az})

  def negate(v), do: negate(to_float(v))

  @doc """
  `weighted_sum(a, v1, b, v2)` returns the sum of vectors `v1` and `v2` having been scaled by `a` and `b`, respectively.
  """
  @spec weighted_sum(number, vec3, number, vec3) :: vec3
  def weighted_sum(a, {x, y, z}, b, {u, v, w})
      when is_float(a) and is_float(x) and is_float(y) and is_float(z) and
             is_float(b) and is_float(u) and is_float(v) and is_float(w),
      do: weighted_sum_nif(a, {x, y, z}, b, {u, v, w})

  def weighted_sum(a, v1, b, v2),
    do: weighted_sum_nif(1.0 * a, to_float(v1), 1.0 * b, to_float(v2))

  @doc """
  `scalar_triple(a,b,c)` returns the [scalar triple product](https://en.wikipedia.org/wiki/Triple_product#Scalar_triple_product) of three vectors.

  We're using the `a*(b x c)` form.
  """
  @spec scalar_triple(vec3, vec3, vec3) :: float
  def scalar_triple({ax, ay, az}, {bx, by, bz}, {cx, cy, cz})
      when is_float(ax) and is_float(ay) and is_float(az) and
             is_float(bx) and is_float(by) and is_float(bz) and
             is_float(cx) and is_float(cy) and is_float(cz),
      do: scalar_triple_nif({ax, ay, az}, {bx, by, bz}, {cx, cy, cz})

  def scalar_triple(a, b, c), do: scalar_triple_nif(to_float(a), to_float(b), to_float(c))

  @doc """
  `minkowski_distance(a,b,order)` returns the [Minkowski distance](https://en.wikipedia.org/wiki/Minkowski_distance) between two points `a` and b` of order `order`.

  `order` needs to be greater than or equal to 1 to define a [metric space](https://en.wikipedia.org/wiki/Metric_space).

  `order` 1 is equivalent to manhattan distance, 2 to Euclidean distance, otherwise all bets are off.
  """
  @spec minkowski_distance(vec3, vec3, number) :: number
  def minkowski_distance({x1, y1, z1}, {x2, y2, z2}, order)
      when is_float(x1) and is_float(y1) and is_float(z1) and
             is_float(x2) and is_float(y2) and is_float(z2) and is_float(order),
      do: minkowski_distance_nif({x1, y1, z1}, {x2, y2, z2}, order)

  def minkowski_distance(a, b, order),
    do: minkowski_distance_nif(to_float(a), to_float(b), 1.0 * order)

  @doc """
  `chebyshev_distance(a,b)` returns the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance) between two points `a` and b`.
  """
  @spec chebyshev_distance(vec3, vec3) :: number
  def chebyshev_distance({x1, y1, z1}, {x2, y2, z2})
      when is_float(x1) and is_float(y1) and is_float(z1) and
             is_float(x2) and is_float(y2) and is_float(z2),
      do: chebyshev_distance_nif({x1, y1, z1}, {x2, y2, z2})

  def chebyshev_distance(a, b), do: chebyshev_distance_nif(to_float(a), to_float(b))

  @doc """
  `p_norm(v,order)` returns the [P-norm](https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions) of vector `v` of order `order`.

  `order` needs to be greater than or equal to 1 to define a [metric space](https://en.wikipedia.org/wiki/Metric_space).

  `order` 1 is equivalent to manhattan distance, 2 to Euclidean distance, otherwise all bets are off.
  """
  @spec p_norm(vec3, number) :: number
  def p_norm({x, y, z}, order) when is_float(x) and is_float(y) and is_float(z) and is_float(order),
    do: p_norm_nif({x, y, z}, order)

  def p_norm(v, order), do: p_norm_nif(to_float(v), 1.0 * order)

  defp to_float({x, y, z}), do: {1.0 * x, 1.0 * y, 1.0 * z}
end
