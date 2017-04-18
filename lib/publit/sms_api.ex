defmodule Publit.SmsApi do
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


  # POST https://api.pushy.me/push?api_key=PUSHY_SECRET_API_KEY
  @messaging_url "https://api.pushy.me/push?api_key=#{System.get_env["PUSHY_SECRET_API_KEY"]}"

  def server_key do
    System.get_env["PUSHY_SECRET_API_KEY"]
  end

  @doc """
  Sends to Nexmo API a message
  https://docs.nexmo.com/verify/api-reference/api-reference#vrequest
  """
  #@type send_message(list, map) ::
  def send_message(number, msg) do
    url = "https://rest.nexmo.com/sms/json"

    headers = [{"Content-Type", "application/json"}]
    body = Poison.encode!(%{
      api_key: api_key,
      api_secret: api_secret,
      from: "Acacito",
      to: number,
      text: msg
    })

    try do
      HTTPoison.start()
      resp = HTTPoison.post!(url, body, headers)
      body = Poison.decode!(resp.body)

      st = List.first(body["messages"])["status"]

      case {resp.status_code, st} do
        {200, "0"} ->
          :ok
        {200, "4"} ->
          # "Invalid credentials"
          {:error, :credentials}
        {200, "9"} ->
          # "Partner quota excedded"
          {:error, :quota}
        {200, _} ->
          {:error, st}
      end

      if resp.status_code == 200 do
        %Publit.MessageApi.Response{status: :ok, resp: resp, body: body}
        {:ok, body}
      else
        {:error, "Invalid"}
      end
    rescue
      HTTPoison.Error ->
        %Publit.MessageApi.Response{status: :network_error, message: "Network error", body: "{}"}
    end
  end


  defp api_key, do: System.get_env("NEXMO_API_KEY")
  defp api_secret, do: System.get_env("NEXMO_API_SECRET")

end

