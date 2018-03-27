defmodule Aevm do
  use Bitwise

  require OpCodes
  require OpCodesUtil
  require AevmConst
  require Stack

  # 0s: Stop and Arithmetic Operations

  def loop(state) do
    cp = State.cp(state)
    code = State.code(state)

    if cp >= byte_size(code) do
      state
    else
      op_code = get_op_code(state)
      state1 = exec(op_code, state)
      state2 = State.inc_cp(state1)
      loop(state2)
    end
  end

  def exec(OpCodes._STOP(), state) do
    state
  end

  def exec(OpCodes._ADD(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result = op1 + op2

    push(result, state)
  end

  def exec(OpCodes._MUL(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result = op1 * op2

    push(result, state)
  end

  def exec(OpCodes._SUB(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result = op1 - op2

    push(result, state)
  end

  def exec(OpCodes._DIV(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result =
      if op2 == 0 do
        0
      else
        Integer.floor_div(op1, op2)
      end

    push(result, state)
  end

  def exec(OpCodes._SDIV(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result =
      if op2 == 0 do
        0
      else
        sdiv(op1, op2)
      end

    push(result, state)
  end

  def exec(OpCodes._MOD(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result =
      if op2 == 0 do
        0
      else
        rem(op1, op2)
      end

    push(result, state)
  end

  def exec(OpCodes._SMOD(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result =
      if op2 == 0 do
        0
      else
        smod(op1, op2)
      end

    push(result, state)
  end

  def exec(OpCodes._ADDMOD(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)
    {op3, state} = pop(state)

    result =
      if op3 == 0 do
        0
      else
        rem(op1 + op2, op3)
      end

    push(result, state)
  end

  def exec(OpCodes._MULMOD(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)
    {op3, state} = pop(state)

    result =
      if op3 == 0 do
        0
      else
        rem(op1 * op2, op3)
      end

    push(result, state)
  end

  def exec(OpCodes._EXP(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result = :math.pow(op1, op2)

    push(result, state)
  end

  # not working correctly
  def exec(OpCodes._SIGNEXTEND(), state) do
    # TODO
    # {op1, state} = pop(state)
    # {op2, state} = pop(state)
    #
    # result = signextend(op2, op1)
    #
    # push(result, state)
  end

  # 10s: Comparison & Bitwise Logic Operations

  def exec(OpCodes._LT(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result =
      if op1 < op2 do
        1
      else
        0
      end

    push(result, state)
  end

  def exec(OpCodes._GT(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result =
      if op1 > op2 do
        1
      else
        0
      end

    push(result, state)
  end

  def exec(OpCodes._SLT(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    sop1 = signed(op1)
    sop2 = signed(op2)

    result =
      if sop1 < sop2 do
        1
      else
        0
      end

    push(result, state)
  end

  def exec(OpCodes._SGT(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    sop1 = signed(op1)
    sop2 = signed(op2)

    result =
      if sop1 > sop2 do
        1
      else
        0
      end

    push(result, state)
  end

  def exec(OpCodes._EQ(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    sop1 = signed(op1)
    sop2 = signed(op2)

    result =
      if sop1 == sop2 do
        1
      else
        0
      end

    push(result, state)
  end

  def exec(OpCodes._ISZERO(), state) do
    {op1, state} = pop(state)

    result =
      if op1 === 0 do
        1
      else
        0
      end

    push(result, state)
  end

  def exec(OpCodes._AND(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result = op1 &&& op2

    push(result, state)
  end

  def exec(OpCodes._OR(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result = op1 ||| op2

    push(result, state)
  end

  def exec(OpCodes._XOR(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result = op1 ^^^ op2

    push(result, state)
  end

  def exec(OpCodes._NOT(), state) do
    {op1, state} = pop(state)

    result = bnot(op1)

    push(result, state)
  end

  def exec(OpCodes._BYTE(), state) do
    {op1, state} = pop(state)
    {op2, state} = pop(state)

    result = byte(op1, op2)

    push(state, result)
  end

  # 20s: SHA3

  def exec(OpCodes._SHA3(), state) do
    # TODO
  end

  ## TODO: Add exec() for #30s and 40s
  # ---------------------------------------------------

  # 50s: Stack, Memory, Storage and Flow Operations

  def exec(OpCodes._POP(), state) do
    {_, state} = pop(state)

    state
  end

  def exec(OpCodes._MLOAD(), state) do
    {address, state} = pop(state)

    result = Memory.load(address, state)

    push(result, state)
  end

  def exec(OpCodes._MSTORE(), state) do
    {address, state} = pop(state)
    {value, state} = pop(state)

    Memory.store(address, value, state)
  end

  def exec(OpCodes._MSTORE8(), state) do
    {address, state} = pop(state)
    {value, state} = pop(state)

    Memory.store8(address, value, state)
  end

  def exec(OpCodes._SLOAD(), state) do
    {address, state} = pop(state)

    result = Storage.sload(address, state)

    push(result, state)
  end

  def exec(OpCodes._SSTORE(), state) do
    {key, state} = pop(state)
    {value, state} = pop(state)

    Storage.sstore(key, value, state)
  end

  def exec(OpCodes._JUMP(), state) do
    # TODO
  end

  def exec(OpCodes._JUMPI(), state) do
    # TODO
  end

  def exec(OpCodes._PC(), state) do
  end

  def exec(OpCodes._MSIZE(), state) do
    # TODO
  end

  def exec(OpCodes._GAS(), state) do
    # TODO
  end

  def exec(OpCodes._JUMPDEST(), state) do
    # TODO
  end

  # 60s & 70s: Push Operations

  def exec(OpCodes._PUSH1() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH2() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH3() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH4() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH5() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH6() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH7() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH8() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH9() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH10() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH11() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH12() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH13() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH14() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH15() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH16() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH17() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH18() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH19() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH20() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH21() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH22() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH23() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH24() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH25() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH26() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH27() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH28() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH29() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH30() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH31() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  def exec(OpCodes._PUSH32() = current_op, state) do
    bytes = current_op - OpCodes._PUSH1() + 1
    {result, state1} = move_cp_n_bytes(bytes, state)

    push(result, state1)
  end

  # 80s: Duplication Operations

  def exec(OpCodes._DUP1() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP2() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP3() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP4() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP5() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP6() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP7() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP8() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP9() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP10() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP11() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP12() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP13() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP14() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP15() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  def exec(OpCodes._DUP16() = current_op, state) do
    bytes = current_op - OpCodes._DUP1() + 1
    dup(bytes, state)
  end

  # 90s: Exchange Operations

  def exec(OpCodes._SWAP1() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP2() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP3() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP4() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP5() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP6() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP7() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP8() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP9() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP10() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP11() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP12() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP13() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP14() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP15() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  def exec(OpCodes._SWAP16() = current_op, state) do
    bytes = current_op - OpCodes._SWAP1() + 1
    swap(bytes, state)
  end

  # a0s: Logging Operations

  def exec(OpCodes._LOG0(), state) do
    # TODO
  end

  def exec(OpCodes._LOG1(), state) do
    # TODO
  end

  def exec(OpCodes._LOG2(), state) do
    # TODO
  end

  def exec(OpCodes._LOG3(), state) do
    # TODO
  end

  def exec(OpCodes._LOG4(), state) do
    # TODO
  end

  # f0s: System operations

  def exec(OpCodes._CREATE(), state) do
    # TODO
  end

  def exec(OpCodes._CALL(), state) do
    # TODO
  end

  def exec(OpCodes._CALLCODE(), state) do
    # TODO
  end

  def exec(OpCodes._RETURN(), state) do
    # TODO
  end

  def exec(OpCodes._DELEGATECALL(), state) do
    # TODO
  end

  def exec(OpCodes._CALLBLACKBOX(), state) do
    # TODO
  end

  def exec(OpCodes._STATICCALL(), state) do
    # TODO
  end

  def exec(OpCodes._REVERT(), state) do
    # TODO
  end

  def exec(OpCodes._INVALID(), state) do
    # TODO
  end

  # Halt Execution, Mark for deletion

  def exec(OpCodes._SUICIDE(), state) do
    # TODO
  end

  def exec([], state) do
    state
  end

  defp sdiv(value1, value2) do
    <<svalue1::integer-signed-256>> = <<value1::integer-unsigned-256>>
    <<svalue2::integer-signed-256>> = <<value2::integer-unsigned-256>>
    Bitwise.band(Integer.floor_div(svalue1, svalue2), AevmConst.mask256())
  end

  defp smod(value1, value2) do
    <<svalue1::integer-signed-256>> = <<value1::integer-unsigned-256>>
    <<svalue2::integer-signed-256>> = <<value2::integer-unsigned-256>>
    result = rem(rem(svalue1, svalue2 + svalue2), svalue2)
    Bitwise.band(result, AevmConst.mask256())
  end

  defp signed(value) do
    <<svalue::integer-signed-256>> = <<value::integer-unsigned-256>>
    svalue
  end

  defp byte(byte, value) when byte < 32 do
    byte_pos = 256 - 8 * (byte + 1)
    mask = 255
    Bitwise.band(Bitwise.bsr(value, byte_pos), mask)
  end

  # defp signextend(value1, value2) do
  #   value1_bits = Aeutil.Bits.extract(<<value1>>)
  #   ext_value1 = extend_bits(value2, value1_bits)
  # end
  #
  # defp extend_bits(number_to_extn_with, list) do
  #   if number_to_extn_with > 0 do
  #     list = List.insert_at(list, 0, List.first(list))
  #     new_list = extend_bits(number_to_extn_with - 1, list)
  #   else
  #     list
  #   end
  # end

  defp push(value, state) do
    Stack.push(value, state)
  end

  defp pop(state) do
    Stack.pop(state)
  end

  defp dup(index, state) do
    Stack.dup(index, state)
  end

  defp swap(index, state) do
    Stack.swap(index, state)
  end

  defp get_op_code(state) do
    cp = State.cp(state)
    code = State.code(state)
    prev_bits = cp * 8

    <<_::size(prev_bits), op_code::size(8), _::binary>> = code

    op_code
  end

  defp move_cp_n_bytes(bytes, state) do
    old_cp = State.cp(state)
    code = State.code(state)

    prev_bits = (old_cp + 1) * 8
    value_size_bits = bytes * 8
    <<_::size(prev_bits), value::size(value_size_bits), _::binary>> = code

    state1 =
      Enum.reduce(1..bytes, state, fn _, state_acc ->
        State.inc_cp(state_acc)
      end)

    {value, state1}
  end
end