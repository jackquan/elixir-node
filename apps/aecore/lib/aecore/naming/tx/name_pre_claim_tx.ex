defmodule Aecore.Naming.Tx.NamePreClaimTx do
  @moduledoc """
  Aecore structure of naming pre claim data.
  """

  @behaviour Aecore.Tx.Transaction

  alias Aecore.Chain.ChainState
  alias Aecore.Naming.Tx.NamePreClaimTx
  alias Aecore.Naming.{Naming, NamingStateTree}
  alias Aeutil.Hash
  alias Aecore.Account.{Account, AccountStateTree}

  require Logger

  @type commitment_hash :: binary()

  @typedoc "Expected structure for the Pre Claim Transaction"
  @type payload :: %{
          commitment: commitment_hash()
        }

  @typedoc "Structure that holds specific transaction info in the chainstate.
  In the case of NamePreClaimTx we don't have a subdomain chainstate."
  @type tx_type_state() :: ChainState.naming()

  @typedoc "Structure of the Spend Transaction type"
  @type t :: %NamePreClaimTx{
          commitment: commitment_hash()
        }

  @doc """
  Definition of Aecore NamePreClaimTx structure

  ## Parameters
  - commitment: hash of the commitment for name claiming
  """
  defstruct [:commitment]
  use ExConstructor

  # Callbacks

  @spec init(payload()) :: NamePreClaimTx.t()
  def init(%{commitment: commitment} = _payload) do
    %NamePreClaimTx{commitment: commitment}
  end

  @doc """
  Checks commitment hash byte size
  """
  @spec validate(NamePreClaimTx.t()) :: :ok | {:error, String.t()}
  def validate(%NamePreClaimTx{commitment: commitment}) do
    if byte_size(commitment) == Hash.get_hash_bytes_size() do
      :ok
    else
      {:error,
       "#{__MODULE__}: Commitment bytes size not correct: #{inspect(byte_size(commitment))}"}
    end
  end

  @spec get_chain_state_name :: Naming.chain_state_name()
  def get_chain_state_name, do: :naming

  @doc """
  Pre claims a name for one account.
  """
  @spec process_chainstate(
          NamePreClaimTx.t(),
          Wallet.pubkey(),
          non_neg_integer(),
          non_neg_integer(),
          non_neg_integer(),
          AccountStateTree.accounts_state(),
          tx_type_state()
        ) :: {AccountStateTree.accounts_state(), tx_type_state()}
  def process_chainstate(
        %NamePreClaimTx{} = tx,
        sender,
        fee,
        nonce,
        block_height,
        accounts,
        naming_state
      ) do
    new_senderount_state =
      accounts
      |> Account.get_account_state(sender)
      |> deduct_fee(fee)
      |> Account.transaction_out_nonce_update(nonce)

    updated_accounts_chainstate = AccountStateTree.put(accounts, sender, new_senderount_state)
    commitment_expires = block_height + Naming.get_pre_claim_ttl()

    commitment = Naming.create_commitment(tx.commitment, sender, block_height, commitment_expires)

    updated_naming_chainstate = NamingStateTree.put(naming_state, tx.commitment, commitment)

    {updated_accounts_chainstate, updated_naming_chainstate}
  end

  @doc """
  Checks whether all the data is valid according to the NamePreClaimTx requirements,
  before the transaction is executed.
  """
  @spec preprocess_check(
          NamePreClaimTx.t(),
          Wallet.pubkey(),
          AccountStateTree.accounts_state(),
          non_neg_integer(),
          non_neg_integer(),
          non_neg_integer(),
          tx_type_state
        ) :: :ok | {:error, String.t()}
  def preprocess_check(_tx, _sender, account_state, fee, _nonce, _block_height, _naming_state) do
    if account_state.balance - fee >= 0 do
      :ok
    else
      {:error, "#{__MODULE__}: Negative balance: #{inspect(account_state.balance - fee)}"}
    end
  end

  @spec deduct_fee(ChainState.account(), tx_type_state()) :: ChainState.account()
  def deduct_fee(account_state, fee) do
    new_balance = account_state.balance - fee
    Map.put(account_state, :balance, new_balance)
  end

  @spec is_minimum_fee_met?(SignedTx.t()) :: boolean()
  def is_minimum_fee_met?(tx) do
    tx.data.fee >= Application.get_env(:aecore, :tx_data)[:minimum_fee]
  end
end
