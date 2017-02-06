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
    body = Poison.encode!(%{data: msg, registration_ids: tokens})

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

end
