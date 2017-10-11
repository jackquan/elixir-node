defmodule AecoreTxsPoolTest do
  @moduledoc """
  Unit test for the pool worker module
  """
  use ExUnit.Case

  alias Aecore.Txs.Pool.Worker, as: Pool

  setup do
    Pool.start_link()
    []
  end

  test "add transaction, remove it and get pool" do
    {:ok, pubkey} = Aecore.Keys.Worker.pubkey()
    assert :ok = Pool.add_transaction(Aecore.Txs.Tx.create(pubkey, 5))
    assert :ok = Pool.remove_transaction(Aecore.Txs.Tx.create(pubkey, 5))
    tx_pool = Pool.get_pool()
    assert Enum.count(tx_pool) == 1
  end

end
