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

  def server_key_cli do
    "server_key_cli"
  end

  def server_key_trans do
    "server_key_trans"
  end

  def send_message_cli(tokens, msg) do
    send_message(tokens, msg, server_key_cli())
  end

  def send_message_trans(tokens, msg) do
    send_message(tokens, msg, server_key_trans())
  end

  @doc """
  Receives a list of device_tokens in Pushy and sends the message in the msg map
  ```SQL
  create view users_view as
  select id, extra_data, mobile_number, 'client' as usr from user_clients
  union
  select id, extra_data, mobile_number, 'trans' as usr from user_transports
  union
  select id, extra_data, mobile_number, 'org' as usr from users
  ```
  """
  #headers = [{"Authorization", "Basic #{server_key()}"}, {"Content-Type", "application/json"}]
  #@type send_message(list, map) ::
  defp send_message(tokens, msg, server_key) do
    q = from u in "users_view", where: fragment("?->>'device_token'", u.extra_data) in ^tokens, select: fragment("?::text", u.id)
    ids = Repo.all(q)

    msg2 = Map.put(msg, :data, Poison.encode!(msg.data))

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
