defmodule Publit.SessionService do
  use GenServer
  @expires_in_minutes 60

  defstruct [:key, :id, :name, :expires_in, :ref]

  def start_link(%{key: key} = args) do
    GenServer.start_link(__MODULE__, args, name: key)
  end

  def init(args) do
    ref = Process.send_after(self, :bye, args[:expires_in])
    args = Map.put(args, :ref, ref)
    {:ok, struct(%Publit.SessionService{}, args)}
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end


  def handle_call(:get, _from, session) do
    ref = schedule_shutdown(session.ref, session.expires_in)
    {:reply, session, %{session | ref: ref}}
  end

  # Add a new time to expire session
  defp schedule_shutdown(ref, expires_in) do
    Process.cancel_timer(ref)
    Process.send_after(self(), :bye, expires_in)
  end

  def handle_info(:bye, state) do
    {:stop, :shutdown, state}
  end
end
