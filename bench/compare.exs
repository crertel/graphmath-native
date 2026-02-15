# This script benchmarks all functions from graphmath-native against the original graphmath.

defmodule OriginalLoader do
  def load() do
    path = "deps/graphmath/lib/graphmath"
    files_to_load = ["Vec2.ex", "Vec3.ex", "Mat33.ex", "Mat44.ex", "Quatern.ex"]

    for file <- files_to_load do
      content = File.read!(Path.join(path, file))
      new_content = Regex.replace(~r/(?<!Original)Graphmath\./, content, "OriginalGraphmath.")
      Code.compile_string(new_content)
    end
  end
end

OriginalLoader.load()

defmodule BenchHelper do
  def get_inputs(module, func, arity) do
    case {module, func, arity} do
      # Vec2
      {m, :create, 0} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> []
      {m, :create, 1} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [[1.0, 2.0]]
      {m, :create, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [1.0, 2.0]
      {m, :add, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {3.0, 4.0}]
      {m, :subtract, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {3.0, 4.0}]
      {m, :multiply, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {3.0, 4.0}]
      {m, :scale, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, 2.5]
      {m, :dot, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {3.0, 4.0}]
      {m, :perp_prod, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {3.0, 4.0}]
      {m, :length, 1} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{3.0, 4.0}]
      {m, :length_squared, 1} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{3.0, 4.0}]
      {m, :length_manhattan, 1} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{3.0, 4.0}]
      {m, :normalize, 1} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{3.0, 4.0}]
      {m, :lerp, 3} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {3.0, 4.0}, 0.5]
      {m, :rotate, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 0.0}, 1.57]
      {m, :near, 3} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {1.000001, 2.0}, 0.1]
      {m, :project, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {1.0, 0.0}]
      {m, :perp, 1} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}]
      {m, :equal, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {1.0, 2.0}]
      {m, :equal, 3} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {1.000001, 2.0}, 0.1]
      {m, :random_circle, 0} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> []
      {m, :random_disc, 0} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> []
      {m, :random_box, 0} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> []
      {m, :negate, 1} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, -2.0}]
      {m, :weighted_sum, 4} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [2.0, {1.0, 2.0}, 3.0, {3.0, 4.0}]
      {m, :minkowski_distance, 3} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {3.0, 4.0}, 3.0]
      {m, :chebyshev_distance, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, {3.0, 4.0}]
      {m, :p_norm, 2} when m in [Graphmath.Vec2, OriginalGraphmath.Vec2] -> [{1.0, 2.0}, 3.0]

      # Vec3
      {m, :create, 0} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> []
      {m, :create, 1} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [[1.0, 2.0, 3.0]]
      {m, :create, 3} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [1.0, 2.0, 3.0]
      {m, :add, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}]
      {m, :subtract, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}]
      {m, :multiply, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}]
      {m, :scale, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, 2.5]
      {m, :dot, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}]
      {m, :cross, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}]
      {m, :length, 1} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}]
      {m, :length_squared, 1} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}]
      {m, :length_manhattan, 1} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}]
      {m, :normalize, 1} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}]
      {m, :lerp, 3} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}, 0.5]
      {m, :near, 3} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {1.0, 2.0, 3.1}, 0.2]
      {m, :rotate, 3} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 0.0, 0.0}, {0.0, 0.0, 1.0}, 1.57]
      {m, :equal, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {1.0, 2.0, 3.0}]
      {m, :equal, 3} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {1.0, 2.0, 3.1}, 0.2]
      {m, :random_sphere, 0} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> []
      {m, :random_ball, 0} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> []
      {m, :random_box, 0} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> []
      {m, :negate, 1} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, -2.0, 3.0}]
      {m, :weighted_sum, 4} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [2.0, {1.0, 2.0, 3.0}, 3.0, {4.0, 5.0, 6.0}]
      {m, :scalar_triple, 3} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {0.0, 0.0, 1.0}]
      {m, :minkowski_distance, 3} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}, 3.0]
      {m, :chebyshev_distance, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}]
      {m, :p_norm, 2} when m in [Graphmath.Vec3, OriginalGraphmath.Vec3] -> [{1.0, 2.0, 3.0}, 3.0]

      # Mat33
      {m, :identity, 0} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> []
      {m, :zero, 0} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> []
      {m, :add, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,0,0,0,1,0,0,0,1}, {1,2,3,4,5,6,7,8,9}]
      {m, :subtract, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,0,0,0,1,0,0,0,1}, {1,2,3,4,5,6,7,8,9}]
      {m, :scale, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}, 2.5]
      {m, :make_scale, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [2.5]
      {m, :make_scale, 3} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [1.0, 2.0, 3.0]
      {m, :make_translate, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [10.0, 20.0]
      {m, :make_rotate, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [1.57]
      {m, :round, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1.111, 2.222, 3.333, 4.444, 5.555, 6.666, 7.777, 8.888, 9.999}, 2]
      {m, :multiply, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}, {9,8,7,6,5,4,3,2,1}]
      {m, :multiply_transpose, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}, {9,8,7,6,5,4,3,2,1}]
      {m, :column0, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}]
      {m, :column1, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}]
      {m, :column2, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}]
      {m, :row0, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}]
      {m, :row1, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}]
      {m, :row2, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}]
      {m, :diag, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}]
      {m, :at, 3} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}, 1, 1]
      {m, :apply, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}, {1,2,3}]
      {m, :apply_transpose, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,4,5,6,7,8,9}, {1,2,3}]
      {m, :apply_left, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3}, {1,2,3,4,5,6,7,8,9}]
      {m, :apply_left_transpose, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3}, {1,2,3,4,5,6,7,8,9}]
      {m, :transform_point, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,0,10, 0,1,20, 0,0,1}, {1,2}]
      {m, :transform_vector, 2} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,0,10, 0,1,20, 0,0,1}, {1,2}]
      {m, :inverse, 1} when m in [Graphmath.Mat33, OriginalGraphmath.Mat33] -> [{1,2,3,0,1,4,5,6,0}]

      # Mat44
      {m, :identity, 0} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> []
      {m, :zero, 0} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> []
      {m, :add, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}, {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :subtract, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}, {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :scale, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}, 2.5]
      {m, :make_scale, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [2.5]
      {m, :make_scale, 4} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [1.0, 2.0, 3.0, 4.0]
      {m, :make_translate, 3} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [10.0, 20.0, 30.0]
      {m, :make_rotate_x, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [1.57]
      {m, :make_rotate_y, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [1.57]
      {m, :make_rotate_z, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [1.57]
      {m, :round, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1.1,2.1,3.1,4.1,5.1,6.1,7.1,8.1,9.1,10.1,11.1,12.1,13.1,14.1,15.1,16.1}, 0]
      {m, :multiply, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}, {16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1}]
      {m, :multiply_transpose, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}, {16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1}]
      {m, :column0, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :column1, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :column2, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :column3, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :row0, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :row1, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :row2, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :row3, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :diag, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :at, 3} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}, 2, 2]
      {m, :apply, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}, {1,2,3,4}]
      {m, :apply_transpose, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}, {1,2,3,4}]
      {m, :apply_left, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4}, {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :apply_left_transpose, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,4}, {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}]
      {m, :transform_point, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,0,0,10, 0,1,0,20, 0,0,1,30, 0,0,0,1}, {1,2,3}]
      {m, :transform_vector, 2} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,0,0,10, 0,1,0,20, 0,0,1,30, 0,0,0,1}, {1,2,3}]
      {m, :inverse, 1} when m in [Graphmath.Mat44, OriginalGraphmath.Mat44] -> [{1,2,3,0, 0,1,4,0, 5,6,0,0, 0,0,0,1}]

      # Quatern
      {m, :identity, 0} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> []
      {m, :zero, 0} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> []
      {m, :equal_elements, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}, {1,0,0,0}]
      {m, :equal_elements, 3} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}, {1.0001,0,0,0}, 0.01]
      {m, :equal, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}, {1,0,0,0}]
      {m, :equal, 3} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}, {0.9999,0,0,0}, 0.01]
      {m, :create, 4} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [1.0, 0.0, 0.0, 0.0]
      {m, :from_list, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [[1.0, 0.0, 0.0, 0.0]]
      {m, :from_axis_angle, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [1.57, {0,0,1}]
      {m, :add, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}, {5,6,7,8}]
      {m, :subtract, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}, {5,6,7,8}]
      {m, :multiply, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}, {5,6,7,8}]
      {m, :scale, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}, 2.5]
      {m, :get_roll, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}]
      {m, :get_pitch, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}]
      {m, :get_yaw, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}]
      {m, :from_rotation_matrix, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0,1,0,0,0,1}]
      {m, :to_rotation_matrix_33, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}]
      {m, :to_rotation_matrix_44, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}]
      {m, :dot, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}, {5,6,7,8}]
      {m, :norm, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}]
      {m, :normalize_strict, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}]
      {m, :normalize, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}]
      {m, :inverse, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}]
      {m, :conjugate, 1} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,2,3,4}]
      {m, :slerp, 3} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}, {0,1,0,0}, 0.5]
      {m, :transform_vector, 2} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}, {1,2,3}]
      {m, :integrate, 3} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> [{1,0,0,0}, {1,0,0}, 0.01]
      {m, :random, 0} when m in [Graphmath.Quatern, OriginalGraphmath.Quatern] -> []

      _ -> :skip
    end
  end

  def run_benchmarks(filter_mod \\ nil) do
    modules = [
      {Graphmath.Vec2, OriginalGraphmath.Vec2},
      {Graphmath.Vec3, OriginalGraphmath.Vec3},
      {Graphmath.Mat33, OriginalGraphmath.Mat33},
      {Graphmath.Mat44, OriginalGraphmath.Mat44},
      {Graphmath.Quatern, OriginalGraphmath.Quatern}
    ]

    modules = if filter_mod, do: Enum.filter(modules, fn {n, _} -> n == filter_mod end), else: modules

    benchmarks = Enum.reduce(modules, %{}, fn {native_mod, original_mod}, acc ->
      funcs = original_mod.__info__(:functions)
      Enum.reduce(funcs, acc, fn {func, arity}, acc_inner ->
        inputs = get_inputs(original_mod, func, arity)
        if inputs == :skip do
          acc_inner
        else
          name_base = "#{String.replace(to_string(native_mod), "Elixir.Graphmath.", "")}.#{func}/#{arity}"
          acc_inner
          |> Map.put("Native #{name_base}", fn -> apply(native_mod, func, inputs) end)
          |> Map.put("Original #{name_base}", fn -> apply(original_mod, func, inputs) end)
        end
      end)
    end)

    if benchmarks != %{} do
      Benchee.run(benchmarks, time: 0.5, warmup: 0.1, memory_time: 0.1)
    end
  end
end

# Running per module to avoid overwhelming output and long wait
Enum.each([Graphmath.Vec2, Graphmath.Vec3, Graphmath.Mat33, Graphmath.Mat44, Graphmath.Quatern], fn mod ->
  IO.puts "\nBenchmarking #{mod}..."
  BenchHelper.run_benchmarks(mod)
end)
