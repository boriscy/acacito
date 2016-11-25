defmodule Publit.SessionService do
  use GenServer

  defstruct [:key, :id, :name, :expires_at]

  def start_link(%{key: key} = args) do
    GenServer.start_link(__MODULE__, args, name: get_key(key))
  end

  defp get_key(key) do
    cond do
      is_atom(key) -> key
      String.valid?(key) -> String.to_atom(key)
    end
  end

  def init(args) do
    {:ok, struct(%Publit.SessionService{}, args)}
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, session) do
    {:reply, session, session}
  end
end
