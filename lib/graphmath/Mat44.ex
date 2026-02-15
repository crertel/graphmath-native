defmodule Graphmath.Mat44 do
  @moduledoc """
  This is the 3D mathematics library for graphmath.

  This submodule handles 4x4 matrices using tuples of floats.
  """

  use Zig, otp_app: :graphmath_native, release_mode: :fast

  @type mat44 ::
          {float, float, float, float, float, float, float, float, float, float, float, float,
           float, float, float, float}
  @type vec4 :: {float, float, float, float}
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

  pub fn identity_nif() beam.term {
      return beam.make(.{
          1.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          0.0, 0.0, 0.0, 1.0,
      }, .{});
  }

  pub fn zero_nif() beam.term {
      return beam.make(.{
          0.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 0.0,
      }, .{});
  }

  pub fn add_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"0" + b.@"0", a.@"1" + b.@"1", a.@"2" + b.@"2", a.@"3" + b.@"3",
          a.@"4" + b.@"4", a.@"5" + b.@"5", a.@"6" + b.@"6", a.@"7" + b.@"7",
          a.@"8" + b.@"8", a.@"9" + b.@"9", a.@"10" + b.@"10", a.@"11" + b.@"11",
          a.@"12" + b.@"12", a.@"13" + b.@"13", a.@"14" + b.@"14", a.@"15" + b.@"15",
      }, .{});
  }

  pub fn subtract_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"0" - b.@"0", a.@"1" - b.@"1", a.@"2" - b.@"2", a.@"3" - b.@"3",
          a.@"4" - b.@"4", a.@"5" - b.@"5", a.@"6" - b.@"6", a.@"7" - b.@"7",
          a.@"8" - b.@"8", a.@"9" - b.@"9", a.@"10" - b.@"10", a.@"11" - b.@"11",
          a.@"12" - b.@"12", a.@"13" - b.@"13", a.@"14" - b.@"14", a.@"15" - b.@"15",
      }, .{});
  }

  pub fn scale_nif(a_term: beam.term, k: f64) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{
          a.@"0" * k, a.@"1" * k, a.@"2" * k, a.@"3" * k,
          a.@"4" * k, a.@"5" * k, a.@"6" * k, a.@"7" * k,
          a.@"8" * k, a.@"9" * k, a.@"10" * k, a.@"11" * k,
          a.@"12" * k, a.@"13" * k, a.@"14" * k, a.@"15" * k,
      }, .{});
  }

  pub fn make_scale1_nif(k: f64) beam.term {
      return beam.make(.{
          k, 0.0, 0.0, 0.0,
          0.0, k, 0.0, 0.0,
          0.0, 0.0, k, 0.0,
          0.0, 0.0, 0.0, k,
      }, .{});
  }

  pub fn make_scale4_nif(sx: f64, sy: f64, sz: f64, sw: f64) beam.term {
      return beam.make(.{
          sx, 0.0, 0.0, 0.0,
          0.0, sy, 0.0, 0.0,
          0.0, 0.0, sz, 0.0,
          0.0, 0.0, 0.0, sw,
      }, .{});
  }

  pub fn make_translate_nif(tx: f64, ty: f64, tz: f64) beam.term {
      return beam.make(.{
          1.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          tx, ty, tz, 1.0,
      }, .{});
  }

  pub fn make_rotate_x_nif(theta: f64) beam.term {
      const st = std.math.sin(theta);
      const ct = std.math.cos(theta);
      return beam.make(.{
          1.0, 0.0, 0.0, 0.0,
          0.0, ct, st, 0.0,
          0.0, -st, ct, 0.0,
          0.0, 0.0, 0.0, 1.0,
      }, .{});
  }

  pub fn make_rotate_y_nif(theta: f64) beam.term {
      const st = std.math.sin(theta);
      const ct = std.math.cos(theta);
      return beam.make(.{
          ct, 0.0, st, 0.0,
          0.0, 1.0, 0.0, 0.0,
          -st, 0.0, ct, 0.0,
          0.0, 0.0, 0.0, 1.0,
      }, .{});
  }

  pub fn make_rotate_z_nif(theta: f64) beam.term {
      const st = std.math.sin(theta);
      const ct = std.math.cos(theta);
      return beam.make(.{
          ct, st, 0.0, 0.0,
          -st, ct, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          0.0, 0.0, 0.0, 1.0,
      }, .{});
  }

  pub fn multiply_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"0" * b.@"0" + a.@"1" * b.@"4" + a.@"2" * b.@"8" + a.@"3" * b.@"12",
          a.@"0" * b.@"1" + a.@"1" * b.@"5" + a.@"2" * b.@"9" + a.@"3" * b.@"13",
          a.@"0" * b.@"2" + a.@"1" * b.@"6" + a.@"2" * b.@"10" + a.@"3" * b.@"14",
          a.@"0" * b.@"3" + a.@"1" * b.@"7" + a.@"2" * b.@"11" + a.@"3" * b.@"15",
          a.@"4" * b.@"0" + a.@"5" * b.@"4" + a.@"6" * b.@"8" + a.@"7" * b.@"12",
          a.@"4" * b.@"1" + a.@"5" * b.@"5" + a.@"6" * b.@"9" + a.@"7" * b.@"13",
          a.@"4" * b.@"2" + a.@"5" * b.@"6" + a.@"6" * b.@"10" + a.@"7" * b.@"14",
          a.@"4" * b.@"3" + a.@"5" * b.@"7" + a.@"6" * b.@"11" + a.@"7" * b.@"15",
          a.@"8" * b.@"0" + a.@"9" * b.@"4" + a.@"10" * b.@"8" + a.@"11" * b.@"12",
          a.@"8" * b.@"1" + a.@"9" * b.@"5" + a.@"10" * b.@"9" + a.@"11" * b.@"13",
          a.@"8" * b.@"2" + a.@"9" * b.@"6" + a.@"10" * b.@"10" + a.@"11" * b.@"14",
          a.@"8" * b.@"3" + a.@"9" * b.@"7" + a.@"10" * b.@"11" + a.@"11" * b.@"15",
          a.@"12" * b.@"0" + a.@"13" * b.@"4" + a.@"14" * b.@"8" + a.@"15" * b.@"12",
          a.@"12" * b.@"1" + a.@"13" * b.@"5" + a.@"14" * b.@"9" + a.@"15" * b.@"13",
          a.@"12" * b.@"2" + a.@"13" * b.@"6" + a.@"14" * b.@"10" + a.@"15" * b.@"14",
          a.@"12" * b.@"3" + a.@"13" * b.@"7" + a.@"14" * b.@"11" + a.@"15" * b.@"15",
      }, .{});
  }

  pub fn multiply_transpose_nif(a_term: beam.term, b_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const b = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, b_term);
      return beam.make(.{
          a.@"0" * b.@"0" + a.@"1" * b.@"1" + a.@"2" * b.@"2" + a.@"3" * b.@"3",
          a.@"0" * b.@"4" + a.@"1" * b.@"5" + a.@"2" * b.@"6" + a.@"3" * b.@"7",
          a.@"0" * b.@"8" + a.@"1" * b.@"9" + a.@"2" * b.@"10" + a.@"3" * b.@"11",
          a.@"0" * b.@"12" + a.@"1" * b.@"13" + a.@"2" * b.@"14" + a.@"3" * b.@"15",
          a.@"4" * b.@"0" + a.@"5" * b.@"1" + a.@"6" * b.@"2" + a.@"7" * b.@"3",
          a.@"4" * b.@"4" + a.@"5" * b.@"5" + a.@"6" * b.@"6" + a.@"7" * b.@"7",
          a.@"4" * b.@"8" + a.@"5" * b.@"9" + a.@"6" * b.@"10" + a.@"7" * b.@"11",
          a.@"4" * b.@"12" + a.@"5" * b.@"13" + a.@"6" * b.@"14" + a.@"7" * b.@"15",
          a.@"8" * b.@"0" + a.@"9" * b.@"1" + a.@"10" * b.@"2" + a.@"11" * b.@"3",
          a.@"8" * b.@"4" + a.@"9" * b.@"5" + a.@"10" * b.@"6" + a.@"11" * b.@"7",
          a.@"8" * b.@"8" + a.@"9" * b.@"9" + a.@"10" * b.@"10" + a.@"11" * b.@"11",
          a.@"8" * b.@"12" + a.@"9" * b.@"13" + a.@"10" * b.@"14" + a.@"11" * b.@"15",
          a.@"12" * b.@"0" + a.@"13" * b.@"1" + a.@"14" * b.@"2" + a.@"15" * b.@"3",
          a.@"12" * b.@"4" + a.@"13" * b.@"5" + a.@"14" * b.@"6" + a.@"15" * b.@"7",
          a.@"12" * b.@"8" + a.@"13" * b.@"9" + a.@"14" * b.@"10" + a.@"15" * b.@"11",
          a.@"12" * b.@"12" + a.@"13" * b.@"13" + a.@"14" * b.@"14" + a.@"15" * b.@"15",
      }, .{});
  }

  pub fn column0_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"0", a.@"4", a.@"8", a.@"12" }, .{});
  }

  pub fn column1_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"1", a.@"5", a.@"9", a.@"13" }, .{});
  }

  pub fn column2_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"2", a.@"6", a.@"10", a.@"14" }, .{});
  }

  pub fn column3_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"3", a.@"7", a.@"11", a.@"15" }, .{});
  }

  pub fn row0_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"0", a.@"1", a.@"2", a.@"3" }, .{});
  }

  pub fn row1_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"4", a.@"5", a.@"6", a.@"7" }, .{});
  }

  pub fn row2_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"8", a.@"9", a.@"10", a.@"11" }, .{});
  }

  pub fn row3_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"12", a.@"13", a.@"14", a.@"15" }, .{});
  }

  pub fn diag_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      return beam.make(.{ a.@"0", a.@"5", a.@"10", a.@"15" }, .{});
  }

  pub fn apply_nif(a_term: beam.term, v_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const v = try get_tuple(struct { f64, f64, f64, f64 }, v_term);
      return beam.make(.{
          a.@"0" * v.@"0" + a.@"1" * v.@"1" + a.@"2" * v.@"2" + a.@"3" * v.@"3",
          a.@"4" * v.@"0" + a.@"5" * v.@"1" + a.@"6" * v.@"2" + a.@"7" * v.@"3",
          a.@"8" * v.@"0" + a.@"9" * v.@"1" + a.@"10" * v.@"2" + a.@"11" * v.@"3",
          a.@"12" * v.@"0" + a.@"13" * v.@"1" + a.@"14" * v.@"2" + a.@"15" * v.@"3",
      }, .{});
  }

  pub fn apply_transpose_nif(a_term: beam.term, v_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const v = try get_tuple(struct { f64, f64, f64, f64 }, v_term);
      return beam.make(.{
          a.@"0" * v.@"0" + a.@"4" * v.@"1" + a.@"8" * v.@"2" + a.@"12" * v.@"3",
          a.@"1" * v.@"0" + a.@"5" * v.@"1" + a.@"9" * v.@"2" + a.@"13" * v.@"3",
          a.@"2" * v.@"0" + a.@"6" * v.@"1" + a.@"10" * v.@"2" + a.@"14" * v.@"3",
          a.@"3" * v.@"0" + a.@"7" * v.@"1" + a.@"11" * v.@"2" + a.@"15" * v.@"3",
      }, .{});
  }

  pub fn transform_point_nif(a_term: beam.term, v_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const v = try get_tuple(struct { f64, f64, f64 }, v_term);
      return beam.make(.{
          a.@"0" * v.@"0" + a.@"4" * v.@"1" + a.@"8" * v.@"2" + a.@"12",
          a.@"1" * v.@"0" + a.@"5" * v.@"1" + a.@"9" * v.@"2" + a.@"13",
          a.@"2" * v.@"0" + a.@"6" * v.@"1" + a.@"10" * v.@"2" + a.@"14",
      }, .{});
  }

  pub fn transform_vector_nif(a_term: beam.term, v_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const v = try get_tuple(struct { f64, f64, f64 }, v_term);
      return beam.make(.{
          a.@"0" * v.@"0" + a.@"4" * v.@"1" + a.@"8" * v.@"2",
          a.@"1" * v.@"0" + a.@"5" * v.@"1" + a.@"9" * v.@"2",
          a.@"2" * v.@"0" + a.@"6" * v.@"1" + a.@"10" * v.@"2",
      }, .{});
  }

  pub fn inverse_nif(a_term: beam.term) !beam.term {
      const a = try get_tuple(struct { f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64, f64 }, a_term);
      const m00 = a.@"0"; const m01 = a.@"1"; const m02 = a.@"2"; const m03 = a.@"3";
      const m10 = a.@"4"; const m11 = a.@"5"; const m12 = a.@"6"; const m13 = a.@"7";
      const m20 = a.@"8"; const m21 = a.@"9"; const m22 = a.@"10"; const m23 = a.@"11";
      const m30 = a.@"12"; const m31 = a.@"13"; const m32 = a.@"14"; const m33 = a.@"15";

      var v0 = m20 * m31 - m21 * m30;
      var v1 = m20 * m32 - m22 * m30;
      var v2 = m20 * m33 - m23 * m30;
      var v3 = m21 * m32 - m22 * m31;
      var v4 = m21 * m33 - m23 * m31;
      var v5 = m22 * m33 - m23 * m32;

      const t00 = (v5 * m11 - v4 * m12 + v3 * m13);
      const t10 = -(v5 * m10 - v2 * m12 + v1 * m13);
      const t20 = (v4 * m10 - v2 * m11 + v0 * m13);
      const t30 = -(v3 * m10 - v1 * m11 + v0 * m12);

      const f_det = t00 * m00 + t10 * m01 + t20 * m02 + t30 * m03;
      if (f_det == 0.0) return error.ArgumentError;

      const inv_det = 1.0 / f_det;

      const d00 = t00 * inv_det;
      const d10 = t10 * inv_det;
      const d20 = t20 * inv_det;
      const d30 = t30 * inv_det;

      const d01 = -(v5 * m01 - v4 * m02 + v3 * m03) * inv_det;
      const d11 = (v5 * m00 - v2 * m02 + v1 * m03) * inv_det;
      const d21 = -(v4 * m00 - v2 * m01 + v0 * m03) * inv_det;
      const d31 = (v3 * m00 - v1 * m01 + v0 * m02) * inv_det;

      v0 = m10 * m31 - m11 * m30;
      v1 = m10 * m32 - m12 * m30;
      v2 = m10 * m33 - m13 * m30;
      v3 = m11 * m32 - m12 * m31;
      v4 = m11 * m33 - m13 * m31;
      v5 = m12 * m33 - m13 * m32;

      const d02 = (v5 * m01 - v4 * m02 + v3 * m03) * inv_det;
      const d12 = -(v5 * m00 - v2 * m02 + v1 * m03) * inv_det;
      const d22 = (v4 * m00 - v2 * m01 + v0 * m03) * inv_det;
      const d32 = -(v3 * m00 - v1 * m01 + v0 * m02) * inv_det;

      v0 = m21 * m10 - m20 * m11;
      v1 = m22 * m10 - m20 * m12;
      v2 = m23 * m10 - m20 * m13;
      v3 = m22 * m11 - m21 * m12;
      v4 = m23 * m11 - m21 * m13;
      v5 = m23 * m12 - m22 * m13;

      const d03 = -(v5 * m01 - v4 * m02 + v3 * m03) * inv_det;
      const d13 = (v5 * m00 - v2 * m02 + v1 * m03) * inv_det;
      const d23 = -(v4 * m00 - v2 * m01 + v0 * m03) * inv_det;
      const d33 = (v3 * m00 - v1 * m01 + v0 * m02) * inv_det;

      return beam.make(.{d00, d01, d02, d03, d10, d11, d12, d13, d20, d21, d22, d23, d30, d31, d32, d33}, .{});
  }
  """

  @doc """
  `identity()` creates an identity `mat44`.

  This returns an identity `mat44`.
  """
  @spec identity() :: mat44
  def identity(), do: identity_nif()

  @doc """
  `zero()` creates a zeroed `mat44`.

  This returns a zeroed `mat44`.
  """
  @spec zero() :: mat44
  def zero(), do: zero_nif()

  @doc """
  `add(a,b)` adds one `mat44` to another `mat44`.

  `a` is the first `mat44`.

  `b` is the second `mat44`.

  This returns a `mat44` which is the element-wise sum of `a` and `b`.
  """
  @spec add(mat44, mat44) :: mat44
  def add(a, b), do: add_nif(to_float(a), to_float(b))

  @doc """
  `subtract(a,b)` subtracts one `mat44` from another `mat44`.

  `a` is the minuend.

  `b` is the subtraherd.

  This returns a `mat44` formed by the element-wise subtraction of `b` from `a`.
  """
  @spec subtract(mat44, mat44) :: mat44
  def subtract(a, b), do: subtract_nif(to_float(a), to_float(b))

  @doc """
  `scale( a, k )` scales every element in a `mat44` by a coefficient k.

  `a` is the `mat44` to scale.

  `k` is the float to scale by.

  This returns a `mat44` `a` scaled element-wise by `k`.
  """
  @spec scale(mat44, float) :: mat44
  def scale(a, k), do: scale_nif(to_float(a), 1.0 * k)

  @doc """
  `make_scale( k )` creates a `mat44` that uniformly scales.

  `k` is the float value to scale by.

  This returns a `mat44` whose diagonal is all `k`s.
  """
  @spec make_scale(float) :: mat44
  def make_scale(k), do: make_scale1_nif(1.0 * k)

  @doc """
  `make_scale( sx, sy, sz, sw )` creates a `mat44` that scales each axis independently.

  `sx` is a float for scaling the x-axis.

  `sy` is a float for scaling the y-axis.

  `sz` is a float for scaling the z-axis.

  `sw` is a float for scaling the w-axis.

  This returns a `mat44` whose diagonal is `{ sx, sy, sz, sw }`.

  Note that, when used with `vec3`s via the *transform* methods, `sw` will have no effect.
  """
  @spec make_scale(float, float, float, float) :: mat44
  def make_scale(sx, sy, sz, sw), do: make_scale4_nif(1.0 * sx, 1.0 * sy, 1.0 * sz, 1.0 * sw)

  @doc """
  `make_translate( tx, ty, tz )` creates a mat44 that translates a point by tx, ty, and tz.

  `make_translate( tx, ty, tz )` creates a mat44 that translates a vec3 by (tx, ty, tz).

  `tx` is a float for translating along the x-axis.

  `ty` is a float for translating along the y-axis.

  `tz` is a float for translating along the z-axis.

  This returns a `mat44` which translates by a `vec3` `{ tx, ty, tz }`.
  """
  @spec make_translate(float, float, float) :: mat44
  def make_translate(tx, ty, tz), do: make_translate_nif(1.0 * tx, 1.0 * ty, 1.0 * tz)

  @doc """
  `make_rotate_x( theta )` creates a `mat44` that rotates a `vec3` by `theta` radians about the +X axis.

  `theta` is the float of the number of radians of rotation the matrix will provide.

  This returns a `mat44` which rotates by `theta` radians about the +X axis.
  """
  @spec make_rotate_x(float) :: mat44
  def make_rotate_x(theta), do: make_rotate_x_nif(1.0 * theta)

  @doc """
  `make_rotate_y( theta )` creates a `mat44` that rotates a `vec3` by `theta` radians about the +Y axis.

  `theta` is the float of the number of radians of rotation the matrix will provide.

  This returns a `mat44` which rotates by `theta` radians about the +Y axis.
  """
  @spec make_rotate_y(float) :: mat44
  def make_rotate_y(theta), do: make_rotate_y_nif(1.0 * theta)

  @doc """
  `make_rotate_Z( theta )` creates a `mat44` that rotates a `vec3` by `theta` radians about the +Z axis.

  `theta` is the float of the number of radians of rotation the matrix will provide.

  This returns a `mat44` which rotates by `theta` radians about the +Z axis.
  """
  @spec make_rotate_z(float) :: mat44
  def make_rotate_z(theta), do: make_rotate_z_nif(1.0 * theta)

  @doc """
  `round( a, sigfigs )` rounds every element of a `mat44` to some number of decimal places.

  `a` is the `mat44` to round.

  `sigfigs` is an integer on [0,15] of the number of decimal places to round to.

  This returns a `mat44` which is the result of rounding `a`.
  """
  @spec round(mat44, 0..15) :: mat44
  def round(a, sigfigs) do
    {a11, a12, a13, a14, a21, a22, a23, a24, a31, a32, a33, a34, a41, a42, a43, a44} = to_float(a)

    {
      Float.round(1.0 * a11, sigfigs),
      Float.round(1.0 * a12, sigfigs),
      Float.round(1.0 * a13, sigfigs),
      Float.round(1.0 * a14, sigfigs),
      Float.round(1.0 * a21, sigfigs),
      Float.round(1.0 * a22, sigfigs),
      Float.round(1.0 * a23, sigfigs),
      Float.round(1.0 * a24, sigfigs),
      Float.round(1.0 * a31, sigfigs),
      Float.round(1.0 * a32, sigfigs),
      Float.round(1.0 * a33, sigfigs),
      Float.round(1.0 * a34, sigfigs),
      Float.round(1.0 * a41, sigfigs),
      Float.round(1.0 * a42, sigfigs),
      Float.round(1.0 * a43, sigfigs),
      Float.round(1.0 * a44, sigfigs)
    }
  end

  @doc """
  `multiply( a, b )` multiply two matrices a and b together.

  `a` is the `mat44` multiplicand.

  `b` is the `mat44` multiplier.

  This returns the `mat44` product of the `a` and `b`.
  """
  @spec multiply(mat44, mat44) :: mat44
  def multiply(a, b), do: multiply_nif(to_float(a), to_float(b))

  @doc """
  `multiply_transpose( a, b )` multiply two matrices a and b<sup>T</sup> together.

  `a` is the `mat44` multiplicand.

  `b` is the `mat44` multiplier.

  This returns the `mat44` product of the `a` and `b`<sup>T</sup>.
  """
  @spec multiply_transpose(mat44, mat44) :: mat44
  def multiply_transpose(a, b), do: multiply_transpose_nif(to_float(a), to_float(b))

  @doc """
  `column0( a )` selects the first column of a `mat44`.

  `a` is the `mat44` to take the first column of.

  This returns a `vec4` representing the first column of `a`.
  """
  @spec column0(mat44) :: vec4
  def column0(a), do: column0_nif(to_float(a))

  @doc """
  `column1( a )` selects the second column of a `mat44`.

  `a` is the `mat44` to take the second column of.

  This returns a `vec4` representing the second column of `a`.
  """
  @spec column1(mat44) :: vec4
  def column1(a), do: column1_nif(to_float(a))

  @doc """
  `column2( a )` selects the third column of a `mat44`.

  `a` is the `mat44` to take the third column of.

  This returns a `vec4` representing the third column of `a`.
  """
  @spec column2(mat44) :: vec4
  def column2(a), do: column2_nif(to_float(a))

  @doc """
  `column3( a )` selects the fourth column of a `mat44`.

  `a` is the `mat44` to take the fourth column of.

  This returns a `vec4` representing the fourth column of `a`.
  """
  @spec column3(mat44) :: vec4
  def column3(a), do: column3_nif(to_float(a))

  @doc """
  `row0( a )` selects the first row of a `mat44`.

  `a` is the `mat44` to take the first row of.

  This returns a `vec4` representing the first row of `a`.
  """
  @spec row0(mat44) :: vec4
  def row0(a), do: row0_nif(to_float(a))

  @doc """
  `row1( a )` selects the second row of a `mat44`.

  `a` is the `mat44` to take the second row of.

  This returns a `vec4` representing the second row of `a`.
  """
  @spec row1(mat44) :: vec4
  def row1(a), do: row1_nif(to_float(a))

  @doc """
  `row2( a )` selects the third row of a `mat44`.

  `a` is the `mat44` to take the third row of.

  This returns a `vec4` representing the third row of `a`.
  """
  @spec row2(mat44) :: vec4
  def row2(a), do: row2_nif(to_float(a))

  @doc """
  `row3( a )` selects the fourth row of a `mat44`.

  `a` is the `mat44` to take the fourth row of.

  This returns a `vec4` representing the fourth row of `a`.
  """
  @spec row3(mat44) :: vec4
  def row3(a), do: row3_nif(to_float(a))

  @doc """
  `diag( a )` selects the diagonal of a `mat44`.

  `a` is the `mat44` to take the diagonal of.

  This returns a `vec4` representing the diagonal of `a`.
  """
  @spec diag(mat44) :: vec4
  def diag(a), do: diag_nif(to_float(a))

  @doc """
  `at( a, i, j)` selects an element of a `mat44`.

  `a` is the `mat44` to index.

  `i` is the row integer index [0,3].

  `j` is the column integer index [0,3].

  This returns a float from the matrix at row `i` and column `j`.
  """
  @spec at(mat44, non_neg_integer, non_neg_integer) :: float
  def at(a, i, j), do: elem(a, 4 * i + j)

  @doc """
  `apply( a, v )` transforms a `vec4` by a `mat44`.

  `a` is the `mat44` to transform by.

  `v` is the `vec4` to be transformed.

  This returns a `vec4` representing **A****v**.

  This is the "full" application of a matrix, and uses all elements.
  """
  @spec apply(mat44, vec4) :: vec4
  def apply(a, v), do: apply_nif(to_float(a), to_float_v4(v))

  @doc """
  `apply_transpose( a, v )` transforms a `vec4` by a a transposed `mat44`.

  `a` is the `mat44` to transform by.

  `v` is the `vec4` to be transformed.

  This returns a `vec4` representing **A**<sup>T</sup>**v**.

  This is the "full" application of a matrix, and uses all elements.
  """
  @spec apply_transpose(mat44, vec4) :: vec4
  def apply_transpose(a, v), do: apply_transpose_nif(to_float(a), to_float_v4(v))

  @doc """
  `apply_left( v, a )` transforms a `vec4` by a `mat44`, applied on the left.

  `a` is the `mat44` to transform by.

  `v` is the `vec4` to be transformed.

  This returns a `vec4` representing **v****A**.

  This is the "full" application of a matrix, and uses all elements.
  """
  @spec apply_left(vec4, mat44) :: vec4
  def apply_left(v, a), do: apply_transpose_nif(to_float(a), to_float_v4(v))

  @doc """
  `apply_left_transpose( v, a )` transforms a `vec3` by a transposed `mat33`, applied on the left.

  `a` is the `mat44` to transform by.

  `v` is the `vec4` to be transformed.

  This returns a `vec4` representing **v****A**<sup>T</sup>.

  This is the "full" application of a matrix, and uses all elements.
  """
  @spec apply_left_transpose(vec4, mat44) :: vec4
  def apply_left_transpose(v, a), do: apply_nif(to_float(a), to_float_v4(v))

  @doc """
  `transform_point( a, v )` transforms a `vec3` point by a `mat44`.

  `a` is a `mat44` used to transform the point.

  `v` is a `vec3` to be transformed.

  This returns a `vec3` representing the application of `a` to `v`.

  The point `a` is internally treated as having a fourth coordinate equal to 1.0.

  Note that transforming a point will work for all transforms.
  """
  @spec transform_point(mat44, vec3) :: vec3
  def transform_point(a, v), do: transform_point_nif(to_float(a), to_float_v3(v))

  @doc """
  `transform_vector( a, v )` transforms a `vec3` vector by a `mat44`.

  `a` is a `mat44` used to transform the point.

  `v` is a `vec3` to be transformed.

  This returns a `vec3` representing the application of `a` to `v`.

  The point `a` is internally treated as having a fourth coordinate equal to 0.0.

  Note that transforming a vector will work for only rotations, scales, and shears.
  """
  @spec transform_vector(mat44, vec3) :: vec3
  def transform_vector(a, v), do: transform_vector_nif(to_float(a), to_float_v3(v))

  @doc """
  `inverse(a)` calculates the inverse matrix

  `a` is a `mat44` to be inverted

  Returs a `mat44` representing `a`<sup>-1</sup>

  Raises an error when you try to calculate inverse of a matrix whose determinant is `zero`
  """
  @spec inverse(mat44) :: mat44
  def inverse(a) do
    try do
      inverse_nif(to_float(a))
    rescue
      _ -> raise "Matrices with determinant equal to zero does not have inverse"
    end
  end

  defp to_float({a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16}),
    do:
      {1.0 * a1, 1.0 * a2, 1.0 * a3, 1.0 * a4, 1.0 * a5, 1.0 * a6, 1.0 * a7, 1.0 * a8, 1.0 * a9,
       1.0 * a10, 1.0 * a11, 1.0 * a12, 1.0 * a13, 1.0 * a14, 1.0 * a15, 1.0 * a16}

  defp to_float_v4({x, y, z, w}), do: {1.0 * x, 1.0 * y, 1.0 * z, 1.0 * w}
  defp to_float_v3({x, y, z}), do: {1.0 * x, 1.0 * y, 1.0 * z}
end
