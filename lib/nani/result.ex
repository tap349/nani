defmodule Nani.Result do
  defstruct ~w(
    cursor
    data
  )a

  @type t :: %__MODULE__{cursor: String.t() | nil, data: any}

  def unwrap({:ok, %__MODULE__{data: data}}) do
    {:ok, data}
  end

  def unwrap({:error, _message_or_atom} = response) do
    response
  end
end
