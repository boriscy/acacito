defmodule Publit.MessageApi do
  defmodule Response do
    @enforce_keys [:status, :body]
    defstruct [:status, :resp, :error, :message, :body]
  end


  @messaging_url "https://fcm.googleapis.com/fcm/send"

  def server_key do
    System.get_env["FIREBASE_SERVER_KEY"]
  end

  def send_messages(tokens, msg) do
    headers = [{"Authorization", "key=#{server_key()}"}, {"Content-Type", "application/json"}]
    body = Poison.encode!(%{data: msg, registration_ids: tokens, priority: "high"})

    try do
      HTTPoison.start()
      resp = HTTPoison.post!(@messaging_url, body, headers)
      body = Poison.decode!(resp.body)

      if body["success"] == 1 do
        %Publit.MessageApi.Response{status: :ok, resp: resp, body: body}
      else
        %Publit.MessageApi.Response{status: :error, resp: resp, body: body}
      end
    rescue
      HTTPoison.Error ->
        %Publit.MessageApi.Response{status: :network_error, message: "Network error", body: "{}"}
    end
  end

  def send_message(token, msg) do
    headers = [{"Authorization", "key=#{server_key()}"}, {"Content-Type", "application/json"}]
    body = Poison.encode!(%{data: msg, to: token, priority: "high"})

    HTTPoison.start()
    HTTPoison.post!(@messaging_url, body, headers)
  end

end

#{
#	"app_id": "f78f735f-a596-4fd8-9524-404f2c843a96",
#	"include_player_ids": ["9ce97a55-b483-4872-9257-997ce7a88dbf"],
#	"heading": "Holaaaaa",
#	"contents": {"en": "Esto es una prueba!"}
#}
