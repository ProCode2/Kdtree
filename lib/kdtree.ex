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

  def nearest(tree, target, depth \\ 0, best \\ nil) do
    if tree == nil do
      best
    else
      dimension = tuple_size(tree.point)
      axis = rem(depth, dimension)

      # find the current best neighbour
      current_best = update_best(tree.point, target, best)

      # next tree to traverse based on if cur value is bigger or greater than terget
      next_tree = if elem(target, axis) < elem(tree.point, axis), do: tree.left, else: tree.right

      # find the potential best value in the selected subtree
      potential_best = nearest(next_tree, target, depth + 1, current_best)

      # we might have to check the other branch because there can be a potential best neighbour existing there as well which might be more closer to target
      potential_best =
        if(needs_checking?(target, tree.point, axis, potential_best)) do
          other_tree = if next_tree == tree.left, do: tree.right, else: tree.left
          potential_best = nearest(other_tree, target, depth + 1, potential_best)
          potential_best
        else
          potential_best
        end

      potential_best
    end
  end

  defp update_best(point, _target, nil), do: point

  defp update_best(point, target, best) do
    if distance(point, target) < distance(point, best), do: point, else: best
  end

  defp distance({x1, y1}, {x2, y2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end

  defp needs_checking?(target, point, axis, best) do
    abs(elem(target, axis) - elem(point, axis)) < distance(best, target)
  end
end
