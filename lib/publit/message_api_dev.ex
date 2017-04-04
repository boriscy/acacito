defmodule Publit.MessageApiDev do
  @moduledoc """
  Sends messages to others using channels instead of the service like (MQTT)
  """
  import Ecto.Query
  alias Publit.{UserClient, UserTransport, Repo}


  defmodule Response do
    @enforce_keys [:status, :body]
    defstruct [:status, :resp, :error, :message, :body]
  end

  def server_key do
    System.get_env["PUSHY_SECRET_API_KEY"]
  end

  @doc """
  Receives a list of device_tokens in Pushy and sends the message in the msg map
  """
  #headers = [{"Authorization", "Basic #{server_key()}"}, {"Content-Type", "application/json"}]
  #@type send_message(list, map) ::
  def send_message(tokens, msg) do
    q = from ut in UserTransport, where: fragment("?->>'device_token'", ut.extra_data) in ^tokens, select: ut.id
    ids = Repo.all(q)
    q = from uc in UserClient, where: fragment("?->>'device_token'", uc.extra_data) in ^tokens, select: uc.id
    ids = ids ++ Repo.all(q)

    msg2 = msg
    msg2 = Map.put(msg2, :data, Poison.encode!(msg2.data))

    Enum.each(ids, fn(id) -> Publit.Endpoint.broadcast("users:" <> id, "message", msg2) end)
  end
end
