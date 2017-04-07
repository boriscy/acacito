defmodule Publit.MessageApiDev do
  @moduledoc """
  Sends messages to others using channels instead of the service like (MQTT)
  """
  import Ecto.Query
  alias Publit.{UserClient, UserTransport, Repo}

  @resp %HTTPoison.Response{body: "{\"success\":true,\"id\":\"58e24ae3a4f92943d0fd4e2f\"}",
   headers: [{"Content-Type", "application/json; charset=utf-8"},
   {"Date", "Mon, 03 Apr 2017 13:15:15 GMT"}, {"Server", "nginx/1.8.0"},
   {"Vary", "Accept-Encoding"}, {"Content-Length", "48"},
   {"Connection", "keep-alive"}], status_code: 200}

  @resp_error %HTTPoison.Response{body: "{\"error\":\"No devices matched the specified condition.\"}",
   headers: [{"Content-Type", "application/json; charset=utf-8"},
   {"Date", "Mon, 03 Apr 2017 13:16:53 GMT"}, {"Server", "nginx/1.8.0"},
   {"Vary", "Accept-Encoding"}, {"Content-Length", "55"},
   {"Connection", "keep-alive"}], status_code: 400}


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

    if Enum.all?(tokens, fn(token) -> String.length(to_string(token)) > 7 end) do
      body = Poison.decode!(@resp.body)
      %Publit.MessageApi.Response{status: :ok, resp: @resp, body: body}
    else
      body = Poison.decode!(@resp_error.body)
      %Publit.MessageApi.Response{status: :error, resp: @resp_error, body: body}
    end
  end
end
