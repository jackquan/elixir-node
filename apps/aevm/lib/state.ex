defmodule State do

  @spec init_vm(map(), map()) :: map()
  def init_vm(exec, env) do

    bytecode = Map.get(exec, :code)
    code_bin = bytecode_to_bin(bytecode)

    state = %{
      :stack => [],
      :memory => %{},
      :storage => %{},
      :code => code_bin,
      :cp => 0,
      :jumpdests => [],
      :return => nil,
      :code => code_bin,
      # :return_data => return_data,

      :address => Map.get(exec, :address),
      :caller => Map.get(exec, :caller),
      :data => Map.get(exec, :data),
      :origin => Map.get(exec, :origin),
      :value => Map.get(exec, :value),

      :coinbase => Map.get(env, :coinbase),
      :difficulty => Map.get(env, :difficulty),
      :number => Map.get(env, :number),
      :timestamp => Map.get(env, :timestamp)
    }
  end

  def set_stack(stack, state) do
    Map.put(state, :stack, stack)
  end

  def set_memory(memory, state) do
    Map.put(state, :memory, memory)
  end

  def set_storage(storage, state) do
    Map.put(state, :storage, storage)
  end

  def set_cp(cp, state) do
    Map.put(state, :cp, cp)
  end

  def inc_cp(state) do
    cp = Map.get(state, :cp)
    Map.put(state, :cp, cp + 1)
  end

  def add_jumpdest(jumpdest, state) do
    jumpdests = jumpdests(state)
    jumpdests1 = [jumpdest | jumpdests]
    Map.put(state, :jumpdests, jumpdests1)
  end

  def set_return(return, state) do
    Map.put(state, :return, return)
  end

  def stack(state) do
    Map.get(state, :stack)
  end

  def memory(state) do
    Map.get(state, :memory)
  end

  def storage(state) do
    Map.get(state, :storage)
  end

  def code(state) do
    Map.get(state, :code)
  end

  def cp(state) do
    Map.get(state, :cp)
  end

  def jumpdests(state) do
    Map.get(state, :jumpdests)
  end

  def address(state) do
    Map.get(state, :address)
  end

  def caller(state) do
    Map.get(state, :caller)
  end

  def coinbase(state) do
    Map.get(state, :coinbase)
  end

  def difficulty(state) do
    Map.get(state, :difficulty)
  end

  def number(state) do
    Map.get(state, :number)
  end

  def timestamp(state) do
    Map.get(state, :timestamp)
  end

  def origin(state) do
    Map.get(state, :origin)
  end

  def caller(state) do
    Map.get(state, :caller)
  end

  def value(state) do
    Map.get(state, :value)
  end

  def data(state) do
    Map.get(state, :data)
  end

  # def return_data(state) do
  #   Map.get(state, :return_data)
  # end

  defp bytecode_to_bin(bytecode) do
    bytecode
    |> String.to_charlist()
    |> Enum.chunk_every(2)
    |> Enum.reduce([], fn x, acc ->
      {code, _} = x |> List.to_string() |> Integer.parse(16)

      [code | acc]
    end)
    |> Enum.reverse()
    |> Enum.reduce(<<>>, fn x, acc ->
      acc <> <<x::size(8)>>
    end)
  end
end
