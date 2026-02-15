defmodule OriginalLoader do
  def load() do
    path = "deps/graphmath/lib/graphmath"

    # We must compile them in order because Quatern depends on Vec3 and Mat33
    files_to_load = ["Vec2.ex", "Vec3.ex", "Mat33.ex", "Mat44.ex", "Quatern.ex"]

    for file <- files_to_load do
      IO.puts("Loading original #{file}...")
      content = File.read!(Path.join(path, file))
      # Replace all occurrences of Graphmath. with OriginalGraphmath.
      # Use a regex to avoid double replacement if we run multiple times
      new_content = Regex.replace(~r/(?<!Original)Graphmath\./, content, "OriginalGraphmath.")
      Code.compile_string(new_content)
    end
  end
end

OriginalLoader.load()

# Basic check
IO.inspect(OriginalGraphmath.Vec2.add({1.0, 2.0}, {3.0, 4.0}), label: "Original add")
IO.inspect(Graphmath.Vec2.add({1.0, 2.0}, {3.0, 4.0}), label: "Native add")

Benchee.run(%{
  "Original Vec2.add" => fn -> OriginalGraphmath.Vec2.add({1.0, 2.0}, {3.0, 4.0}) end,
  "Native Vec2.add"   => fn -> Graphmath.Vec2.add({1.0, 2.0}, {3.0, 4.0}) end,

  "Original Mat44.multiply" => fn ->
    m1 = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0}
    m2 = {17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0}
    OriginalGraphmath.Mat44.multiply(m1, m2)
  end,
  "Native Mat44.multiply" => fn ->
    m1 = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0}
    m2 = {17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0}
    Graphmath.Mat44.multiply(m1, m2)
  end,

  "Original Quatern.slerp" => fn ->
    q1 = {1.0, 0.0, 0.0, 0.0}
    q2 = {0.0, 1.0, 0.0, 0.0}
    OriginalGraphmath.Quatern.slerp(q1, q2, 0.5)
  end,
  "Native Quatern.slerp" => fn ->
    q1 = {1.0, 0.0, 0.0, 0.0}
    q2 = {0.0, 1.0, 0.0, 0.0}
    Graphmath.Quatern.slerp(q1, q2, 0.5)
  end
}, time: 5, memory_time: 2)
