defmodule Publit.MessageApi do
  @moduledoc """
  Should send a message similar to
  {
    "app_id": "f78f735f-a596-4fd8-9524-404f2c843a96",
    "include_player_ids": ["9ce97a55-b483-4872-9257-997ce7a88dbf"],
    "heading": "Holaaaaa",
    "contents": {"en": "Esto es una prueba!"}
  }
  """

  defmodule Response do
    @enforce_keys [:status, :body]
    defstruct [:status, :resp, :error, :message, :body]
  end


  @messaging_url "https://onesignal.com/api/v1/notifications"

  def server_key do
    System.get_env["OPEN_SIGNAL_REST_API_KEY"]
  end

  def app_id do
    System.get_env("OPEN_SIGNAL_APP_ID")
  end

  @doc """
  Receives a list of player_ids in OneSignal and sends the message in the msg map
  """
  #@type send_message(list, map) ::
  def send_message(player_ids, msg) do
    headers = [{"Authorization", "Basic #{server_key()}"}, {"Content-Type", "application/json"}]
    body = Poison.encode!(%{
      include_player_ids: player_ids,
      data: msg,
      app_id: app_id,
      player_ids: player_ids,
      heading: msg.heading,
      contents: %{ en: msg.body},
      priority: 10
    })

    try do
      HTTPoison.start()
      resp = HTTPoison.post!(@messaging_url, body, headers)
      body = Poison.decode!(resp.body)

      if resp.status_code == 200 do
        %Publit.MessageApi.Response{status: :ok, resp: resp, body: body}
      else
        %Publit.MessageApi.Response{status: :error, resp: resp, body: body}
      end
    rescue
      HTTPoison.Error ->
        %Publit.MessageApi.Response{status: :network_error, message: "Network error", body: "{}"}
    end
  end

end
