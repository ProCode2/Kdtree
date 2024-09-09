defmodule Kdtree do
  defstruct point: nil, left: nil, right: nil

  def build(points, depth \\ 0) do
    # if empty return nil
    if Enum.empty?(points) do
      nil
    else
      # get the number of dimensions
      dimensions = tuple_size(hd(points))
      axis = rem(depth, dimensions)

      # sort the point by the current dimension
      sorted_points = points |> Enum.sort_by(fn point -> elem(point, axis) end)

      median = div(length(sorted_points), 2)

      %Kdtree{
        point: sorted_points |> Enum.at(median),
        left: sorted_points |> Enum.slice(0, median) |> build(depth + 1),
        right: sorted_points |> Enum.slice(median + 1, length(sorted_points)) |> build(depth + 1)
      }
    end
  end
end
