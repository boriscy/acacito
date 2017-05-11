defmodule Publit.MessageApi do
  @moduledoc """
  Should send a message similar to
  {
      "to": "a6345d0278adc55d3474f5",
      "tokens": ["a6345d0278adc55d3474f5"],
      "data": {
          "message": "Hello World!",
      }
  }
  """

  defmodule Response do
    @enforce_keys [:status, :body]
    defstruct [:status, :resp, :error, :message, :body]
  end


  # POST https://api.pushy.me/push?api_key=PUSHY_SECRET_API_KEY
  @messaging_url "https://api.pushy.me/push?api_key=#{System.get_env["PUSHY_SECRET_API_KEY"]}"

  def server_key_trans do
    System.get_env["PUSHY_SECRET_API_KEY"]
  end

  def server_key_cli do
    System.get_env["PUSHY_SECRET_API_KEY_CLI"]
  end

  def send_message_trans(tokens, msg) do
    send_message(tokens, msg, server_key_trans())
  end

  def send_message_cli(tokens, msg) do
    send_message(tokens, msg, server_key_cli())
  end

  @doc """
  Receives a list of device_tokens in Pushy and sends the message in the msg map
  """
  #headers = [{"Authorization", "Basic #{server_key()}"}, {"Content-Type", "application/json"}]
  #@type send_message(list, map) ::
  defp send_message(tokens, msg, server_key) do
    url = "https://api.pushy.me/push?api_key=#{server_key}"

    headers = [{"Content-Type", "application/json"}]
    body = Poison.encode!(%{
      data: msg,
      tokens: tokens,
      priority: 10
    })

    try do
      HTTPoison.start()
      resp = HTTPoison.post!(url, body, headers)
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
