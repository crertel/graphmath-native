defmodule Graphmath.Vec2 do
  @moduledoc """
  This is the 2D mathematics.

  This submodule handles vectors stored as tuples of floats ex: `{1.0, 2.0}`.
  """

  use Zig, otp_app: :graphmath_native, release_mode: :fast
  import Kernel, except: [length: 1]

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

  pub fn create0_nif() beam.term {
      return beam.make(.{ 0.0, 0.0 }, .{});
  }

  pub fn create2_nif(x: f64, y: f64) beam.term {
      return beam.make(.{ x, y }, .{});
  }

  pub fn create1_nif(vec: beam.term) !beam.term {
      var list = vec.v;
      var head: e.ErlNifTerm = undefined;
      var x: f64 = undefined;
      var y: f64 = undefined;

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

      return beam.make(.{ x, y }, .{});
  }

  pub fn add_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      return beam.make(.{ a.@"0" + b.@"0", a.@"1" + b.@"1" }, .{});
  }

  pub fn subtract_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      return beam.make(.{ a.@"0" - b.@"0", a.@"1" - b.@"1" }, .{});
  }

  pub fn multiply_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      return beam.make(.{ a.@"0" * b.@"0", a.@"1" * b.@"1" }, .{});
  }

  pub fn scale_nif(a_term: beam.term, s: f64) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      return beam.make(.{ a.@"0" * s, a.@"1" * s }, .{});
  }

  pub fn dot_nif(a_term: beam.term, b_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      return a.@"0" * b.@"0" + a.@"1" * b.@"1";
  }

  pub fn perp_prod_nif(a_term: beam.term, b_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      return a.@"0" * b.@"1" - b.@"0" * a.@"1";
  }

  pub fn length_nif(a_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      return std.math.sqrt(a.@"0" * a.@"0" + a.@"1" * a.@"1");
  }

  pub fn length_squared_nif(a_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      return a.@"0" * a.@"0" + a.@"1" * a.@"1";
  }

  pub fn length_manhattan_nif(a_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      return a.@"0" + a.@"1";
  }

  pub fn normalize_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const invmag = 1.0 / std.math.sqrt(a.@"0" * a.@"0" + a.@"1" * a.@"1");
      return beam.make(.{ a.@"0" * invmag, a.@"1" * invmag }, .{});
  }

  pub fn lerp_nif(a_term: beam.term, b_term: beam.term, t: f64) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      return beam.make(.{ t * b.@"0" + (1.0 - t) * a.@"0", t * b.@"1" + (1.0 - t) * a.@"1" }, .{});
  }

  pub fn rotate_nif(a_term: beam.term, theta: f64) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const ct = std.math.cos(theta);
      const st = std.math.sin(theta);
      return beam.make(.{ a.@"0" * ct - a.@"1" * st, a.@"0" * st + a.@"1" * ct }, .{});
  }

  pub fn near_nif(a_term: beam.term, b_term: beam.term, distance: f64) !bool {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      const dx = a.@"0" - b.@"0";
      const dy = a.@"1" - b.@"1";
      return distance > std.math.sqrt(dx * dx + dy * dy);
  }

  pub fn project_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      const coeff = (a.@"0" * b.@"0" + a.@"1" * b.@"1") / (b.@"0" * b.@"0" + b.@"1" * b.@"1");
      return beam.make(.{ b.@"0" * coeff, b.@"1" * coeff }, .{});
  }

  pub fn perp_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      return beam.make(.{ -a.@"1", a.@"0" }, .{});
  }

  pub fn equal_nif(a_term: beam.term, b_term: beam.term) !bool {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      return a.@"0" == b.@"0" and a.@"1" == b.@"1";
  }

  pub fn equal_eps_nif(a_term: beam.term, b_term: beam.term, eps: f64) !bool {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      return @abs(a.@"0" - b.@"0") <= eps and @abs(a.@"1" - b.@"1") <= eps;
  }

  pub fn negate_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      return beam.make(.{ -a.@"0", -a.@"1" }, .{});
  }

  pub fn weighted_sum_nif(a: f64, v1_term: beam.term, b: f64, v2_term: beam.term) !beam.term {
      const v1 = try get_tuple(struct { f64, f64 }, v1_term);
      const v2 = try get_tuple(struct { f64, f64 }, v2_term);
      return beam.make(.{ a * v1.@"0" + b * v2.@"0", a * v1.@"1" + b * v2.@"1" }, .{});
  }

  pub fn minkowski_distance_nif(a_term: beam.term, b_term: beam.term, order: f64) !f64 {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      const adx = @abs(b.@"0" - a.@"0");
      const ady = @abs(b.@"1" - a.@"1");
      const temp = std.math.pow(f64, adx, order) + std.math.pow(f64, ady, order);
      return std.math.pow(f64, temp, 1.0 / order);
  }

  pub fn chebyshev_distance_nif(a_term: beam.term, b_term: beam.term) !f64 {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64 }, b_term);
      const adx = @abs(b.@"0" - a.@"0");
      const ady = @abs(b.@"1" - a.@"1");
      return @max(adx, ady);
  }

  pub fn p_norm_nif(a_term: beam.term, order: f64) !f64 {
      const a = try get_tuple(struct { f64, f64 }, a_term);
      const ax = @abs(a.@"0");
      const ay = @abs(a.@"1");
      const temp = std.math.pow(f64, ax, order) + std.math.pow(f64, ay, order);
      return std.math.pow(f64, temp, 1.0 / order);
  }
  """

  @doc """
  `create()` creates a zero vec2.

  It will return a tuple of the form {0.0,0.0}.
  `create()` creates a zeroed `vec2`.

  It takes no arguments.

  It returns a `vec2` of the form `{ 0.0, 0.0 }`.
  """
  @spec create() :: vec2
  def create(), do: create0_nif()

  @doc """
  `create(x,y)` creates a `vec2` of value (x,y).

  `x` is the first element of the `vec3` to be created.

  `y` is the second element of the `vec3` to be created.

  It returns a `vec2` of the form `{x,y}`.
  """
  @spec create(float, float) :: vec2
  def create(x, y), do: create2_nif(1.0 * x, 1.0 * y)

  @doc """
  `create(vec)` creates a `vec2` from a list of 2 or more floats.

  `vec` is a list of 2 or more floats.

  It returns a `vec2` of the form `{x,y}`, where `x` and `y` are the first three elements in `vec`.
  """
  @spec create([float]) :: vec2
  def create(vec), do: create1_nif(vec)

  @doc """
  `add( a, b)` adds a vec2 (a) to a vec2 (b).

  It returns a tuple of the form { ax + bx, ay + by }.

  `add( a, b )` adds two `vec2`s.

  `a` is the first `vec2`.

  `b` is the second `vec2`.

  It returns a `vec2` of the form { a<sub>x</sub> + b<sub>x</sub>, a<sub>y</sub> + b<sub>y</sub> }.
  """
  @spec add(vec2, vec2) :: vec2
  def add({ax, ay}, {bx, by}) when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by),
    do: add_nif({ax, ay}, {bx, by})

  def add(a, b), do: add(to_float(a), to_float(b))

  @doc """
  `subtract(a, b )` subtracts one `vec2` from another `vec2`.

  `a` is the `vec2` minuend.

  `b` is the `vec2` subtrahend.

  It returns a `vec2` of the form { a<sub>x</sub> - b<sub>x</sub>, a<sub>y</sub> - b<sub>y</sub> }.

  (the terminology was found [here](http://mathforum.org/library/drmath/view/58801.html)).
  """
  @spec subtract(vec2, vec2) :: vec2
  def subtract({ax, ay}, {bx, by})
      when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by),
      do: subtract_nif({ax, ay}, {bx, by})

  def subtract(a, b), do: subtract(to_float(a), to_float(b))

  @doc """
  `multiply( a, b)` mulitplies element-wise a vec2 (a) by a vec2 (b).

  It returns a tuple of the form `{ ax*bx, ay*by }`.

  `multiply( a, b )` multiplies element-wise a `vec2` by another `vec2`.

  `a` is the `vec2` multiplicand.

  `b` is the `vec2` multiplier.

  It returns a `vec2` of the form { a<sub>x</sub>b<sub>x</sub>, a<sub>y</sub>b<sub>y</sub> }.
  """
  @spec multiply(vec2, vec2) :: vec2
  def multiply({ax, ay}, {bx, by})
      when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by),
      do: multiply_nif({ax, ay}, {bx, by})

  def multiply(a, b), do: multiply(to_float(a), to_float(b))

  @doc """
  `scale( a, scale )` uniformly scales a `vec2`.

  `a` is the `vec2` to be scaled.

  `scale` is the float to scale each element of `a` by.

  It returns a tuple of the form { a<sub>x</sub>scale, a<sub>y</sub>scale }.
  """
  @spec scale(vec2, float) :: vec2
  def scale({ax, ay}, s) when is_float(ax) and is_float(ay) and is_float(s),
    do: scale_nif({ax, ay}, s)

  def scale(a, s), do: scale(to_float(a), 1.0 * s)

  @doc """
  `dot( a, b )` finds the dot (inner) product of one `vec2` with another `vec2`.

  `a` is the first `vec2`.

  `b` is the second `vec2`.

  It returns a float of the value (a<sub>x</sub>b<sub>x</sub> + a<sub>y</sub>b<sub>y</sub> ).
  """
  @spec dot(vec2, vec2) :: float
  def dot({ax, ay}, {bx, by}) when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by),
    do: dot_nif({ax, ay}, {bx, by})

  def dot(a, b), do: dot(to_float(a), to_float(b))

  @doc """
  `perp_prod( a, b )` finds the perpindicular product of one `vec2` with another `vec2`.

  `a` is the first `vec2`.

  `b` is the second `vec2`.

  The perpindicular product is the magnitude of the cross-product between the two vectors.

  It returns a float of the value (a<sub>x</sub>b<sub>y</sub> - b<sub>x</sub>a<sub>y</sub>).
  """
  @spec perp_prod(vec2, vec2) :: float
  def perp_prod({ax, ay}, {bx, by})
      when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by),
      do: perp_prod_nif({ax, ay}, {bx, by})

  def perp_prod(a, b), do: perp_prod(to_float(a), to_float(b))

  @doc """
  `length(a)` finds the length (Eucldiean or L2 norm) of a `vec2`.

  `a` is the `vec2` to find the length of.

  It returns a float of the value (sqrt( a<sub>x</sub><sup>2</sup> + a<sub>y</sub><sup>2</sup>)).
  """
  @spec length(vec2) :: float
  def length({ax, ay}) when is_float(ax) and is_float(ay), do: length_nif({ax, ay})
  def length(a), do: length(to_float(a))

  @doc """
  `length_squared(a)` finds the square of the length of a vec2 (a).

  In many cases, this is sufficient for comparisions and avaoids a sqrt.

  It returns a float of the value (ax*ax + ay*ay).
  `length_squared(a)` finds the square of the length of a `vec2`.

  `a` is the `vec2` to find the length squared of.

  It returns a float of the value a<sub>x</sub><sup>2</sup> + a<sub>y</sub><sup>2</sup>.

  In many cases, this is sufficient for comparisons and avoids a square root.
  """
  @spec length_squared(vec2) :: float
  def length_squared({ax, ay}) when is_float(ax) and is_float(ay), do: length_squared_nif({ax, ay})
  def length_squared(a), do: length_squared(to_float(a))

  @doc """
  `length_manhattan(a)` finds the Manhattan (L1 norm) length of a `vec2`.

  `a` is the `vec2` to find the Manhattan length of.

  It returns a float of the value (a<sub>x</sub> + a<sub>y</sub>).

  The Manhattan length is the sum of the components.
  """
  @spec length_manhattan(vec2) :: float
  def length_manhattan({ax, ay}) when is_float(ax) and is_float(ay),
    do: length_manhattan_nif({ax, ay})

  def length_manhattan(a), do: length_manhattan(to_float(a))

  @doc """
  `normalize(a)` finds the unit vector with the same direction as a `vec2`.

  `a` is the `vec2` to be normalized.

  It returns a `vec2` of the form `{normx, normy}`.

  This is done by dividing each component by the vector's magnitude.
  """
  @spec normalize(vec2) :: vec2
  def normalize({ax, ay}) when is_float(ax) and is_float(ay), do: normalize_nif({ax, ay})
  def normalize(a), do: normalize(to_float(a))

  @doc """
  `lerp(a,b,t)` is used to linearly interpolate between two given vectors a and b along an interpolant t.

  The interpolant `t`  is on the domain [0,1]. Behavior outside of that is undefined.
  `lerp(a,b,t)` linearly interpolates between one `vec2` and another `vec2` along an interpolant.

  `a` is the starting `vec2`.

  `b` is the ending `vec2`.

  `t` is the interpolant float, on the domain [0,1].

  It returns a `vec2` of the form (1-t)**a** - (t)**b**.

  The interpolant `t` is on the domain [0,1]. Behavior outside of that is undefined.
  """
  @spec lerp(vec2, vec2, float) :: vec2
  def lerp({ax, ay}, {bx, by}, t)
      when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by) and is_float(t),
      do: lerp_nif({ax, ay}, {bx, by}, t)

  def lerp(a, b, t), do: lerp(to_float(a), to_float(b), 1.0 * t)

  @doc """
  `rotate(a,theta)` rotates a `vec2` CCW about the +Z axis.

  `a` is the `vec2` to rotate.

  `theta` is the number of radians to rotate by as a float.

  This returns a `vec2`.
  """
  @spec rotate(vec2, float) :: vec2
  def rotate({ax, ay}, theta) when is_float(ax) and is_float(ay) and is_float(theta),
    do: rotate_nif({ax, ay}, theta)

  def rotate(a, theta), do: rotate(to_float(a), 1.0 * theta)

  @doc """
  `near(a,b, distance)` checks whether two `vec2`s are within a certain distance of each other.

  `a` is the first `vec2`.

  `b` is the second `vec2`.

  `distance` is the distance between them as a float.
  """
  @spec near(vec2, vec2, float) :: boolean
  def near({ax, ay}, {bx, by}, d)
      when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by) and is_float(d),
      do: near_nif({ax, ay}, {bx, by}, d)

  def near(a, b, d), do: near(to_float(a), to_float(b), 1.0 * d)

  @doc """
  `project(a,b)` projects one `vec2` onto another `vec2`.

  `a` is the first `vec2`.

  `b` is the second `vec2`.

  This returns a `vec2` representing the image of `a` in the direction of `b`.
  """
  @spec project(vec2, vec2) :: vec2
  def project({ax, ay}, {bx, by})
      when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by),
      do: project_nif({ax, ay}, {bx, by})

  def project(a, b), do: project(to_float(a), to_float(b))

  @doc """
  `perp(a)` creates a vector perpendicular to another vector `a`.

  `a` is the `vec2` to be perpindicular to.

  This returns a `vec2` perpindicular to `a`, to the right of the original `a`.
  """
  @spec perp(vec2) :: vec2
  def perp({ax, ay}) when is_float(ax) and is_float(ay), do: perp_nif({ax, ay})
  def perp(a), do: perp(to_float(a))

  @doc """
  `equal(a, b)` checks to see if two vec2s a and b are equivalent.

  `a` is the `vec2`.

  `b` is the `vec2`.

  It returns true if the vectors have equal elements.

  Note that due to precision issues, you may want to use `equal/3` instead.
  """
  @spec equal(vec2, vec2) :: boolean
  def equal({ax, ay}, {bx, by}) when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by),
    do: equal_nif({ax, ay}, {bx, by})

  def equal(a, b), do: equal(to_float(a), to_float(b))

  @doc """
  `equal(a, b, eps)` checks to see if two vec2s a and b are equivalent within some tolerance.

  `a` is the `vec2`.

  `b` is the `vec2`.

  `eps` is the tolerance, a float.

  It returns true if the vectors have equal elements within some tolerance.
  """
  @spec equal(vec2, vec2, float) :: boolean
  def equal({ax, ay}, {bx, by}, eps)
      when is_float(ax) and is_float(ay) and is_float(bx) and is_float(by) and is_float(eps),
      do: equal_eps_nif({ax, ay}, {bx, by}, eps)

  def equal(a, b, eps), do: equal_eps_nif(to_float(a), to_float(b), 1.0 * eps)

  @doc """
  `random_circle()` generates a point on the unit circle.

  It returns a vec2 with distance 1 from the origin.
  """
  @spec random_circle() :: vec2
  def random_circle() do
    pi = :math.pi()
    theta = :rand.uniform()
    {:math.cos(2.0 * pi * theta), :math.sin(2.0 * pi * theta)}
  end

  @doc """
  `random_disc()` generates a point on or inside the unit circle using the method [here](http://mathworld.wolfram.com/DiskPointPicking.html).

  It returns a vec2 with distance 1 from the origin.
  """
  @spec random_disc() :: vec2
  def random_disc() do
    pi = :math.pi()
    theta = :rand.uniform()
    rho = :math.sqrt(:rand.uniform())
    {rho * :math.cos(2.0 * pi * theta), rho * :math.sin(2.0 * pi * theta)}
  end

  @doc """
  `random_box()` generates a point on or inside the unit box [0,1]x[0,1].
  """
  @spec random_box() :: vec2
  def random_box(), do: {:rand.uniform(), :rand.uniform()}

  @doc """
  `negate(v)` creates a vector whose elements are opposite in sign to `v`.
  """
  @spec negate(vec2) :: vec2
  def negate({ax, ay}) when is_float(ax) and is_float(ay), do: negate_nif({ax, ay})
  def negate(a), do: negate(to_float(a))

  @doc """
  `weighted_sum(a, v1, b, v2)` returns the sum of vectors `v1` and `v2` having been scaled by `a` and `b`, respectively.
  """
  @spec weighted_sum(number, vec2, number, vec2) :: vec2
  def weighted_sum(a, {x, y}, b, {u, v})
      when is_float(a) and is_float(x) and is_float(y) and
             is_float(b) and is_float(u) and is_float(v),
      do: weighted_sum_nif(a, {x, y}, b, {u, v})

  def weighted_sum(a, v1, b, v2),
    do: weighted_sum_nif(1.0 * a, to_float(v1), 1.0 * b, to_float(v2))

  @doc """
  `minkowski_distance(a,b,order)` returns the [Minkowski distance](https://en.wikipedia.org/wiki/Minkowski_distance) between two points `a` and `b` of order `order`.

  Order 1 is equivalent to manhattan distance, 2 to Euclidean distance, otherwise all bets are off.
  """
  @spec minkowski_distance(vec2, vec2, number) :: number
  def minkowski_distance({x1, y1}, {x2, y2}, order)
      when is_float(x1) and is_float(y1) and is_float(x2) and is_float(y2) and is_float(order),
      do: minkowski_distance_nif({x1, y1}, {x2, y2}, order)

  def minkowski_distance(a, b, order),
    do: minkowski_distance_nif(to_float(a), to_float(b), 1.0 * order)

  @doc """
  `chebyshev_distance(a,b)` returns the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance) between two points `a` and `b`.
  """
  @spec chebyshev_distance(vec2, vec2) :: number
  def chebyshev_distance({x1, y1}, {x2, y2})
      when is_float(x1) and is_float(y1) and is_float(x2) and is_float(y2),
      do: chebyshev_distance_nif({x1, y1}, {x2, y2})

  def chebyshev_distance(a, b), do: chebyshev_distance_nif(to_float(a), to_float(b))

  @doc """
  `p_norm(v,order)` returns the [P-norm](https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions) of vector `v` of order `order`.

  `order` needs to be greater than or equal to 1 to define a [metric space](https://en.wikipedia.org/wiki/Metric_space).

  `order` 1 is equivalent to manhattan distance, 2 to Euclidean distance, otherwise all bets are off.
  """
  @spec p_norm(vec2, number) :: number
  def p_norm({x, y}, order) when is_float(x) and is_float(y) and is_float(order),
    do: p_norm_nif({x, y}, order)

  def p_norm(v, order), do: p_norm_nif(to_float(v), 1.0 * order)

  defp to_float({x, y}), do: {1.0 * x, 1.0 * y}
end
