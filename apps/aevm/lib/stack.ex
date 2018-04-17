defmodule Stack do
  def new() do
    []
  end

  def push(arg, state) do
    stack = State.stack(state)

    if length(stack) < 1024 do
      State.set_stack([arg | stack], state)
    else
      throw({"out_of_stack", stack})
    end
  end

  def pop(state) do
    stack = State.stack(state)

    case stack do
      [arg | stack] -> {arg, State.set_stack(stack, state)}
      [] -> throw({"emtpy_stack", stack})
    end
  end

  def peek(index, state) when index >= 0 do
    stack = State.stack(state)

    if Enum.empty?(stack) do
      throw({"empty stack", stack})
    else
      case Enum.at(stack, index) do
        nil -> throw({"stack_too_small", stack})
        _ -> Enum.at(stack, index)
      end
    end
  end

  def dup(index, state) do
    stack = State.stack(state)

    if Enum.empty?(stack) do
      throw({"empty stack", stack})
    else
      case length(stack) < index do
        true ->
          throw({"stack_too_small_for_dup", stack})

        false ->
          value = Enum.at(stack, index - 1)
          push(value, state)
      end
    end
  end

  def swap(index, state) do
    stack = State.stack(state)

    if Enum.empty?(stack) do
      throw({"empty stack", stack})
    else
      [top | rest] = stack

      case length(rest) < index do
        true ->
          throw({"stack_too_small_for_swap", stack})

        false ->
          index_elem = Enum.at(rest, index - 1)

          stack =
            [index_elem, set_val(index, top, rest)]
            |> List.flatten()

          State.set_stack(stack, state)
      end
    end
  end

  def set_val(1, val, [_ | rest]) do
    [val | rest]
  end

  def set_val(index, val, [elem | rest]) do
    [elem | set_val(index - 1, val, rest)]
  end
end