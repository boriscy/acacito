defmodule Publit.MessageApiMock do

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


  def server_key_trans do
    "server_key_trans"
  end

  def server_key_cli do
    "server_key_cli"
  end

  def send_message_trans(tokens, msg) do
    send_message(tokens, msg, server_key_trans())
  end

  def send_message_cli(tokens, msg) do
    send_message(tokens, msg, server_key_cli())
  end

  defp send_message(tokens, msg, server_key) do
    update_agent(tokens, msg, server_key)

    headers = [{"Content-Type", "application/json"}]

    if Enum.all?(tokens, fn(token) -> String.length(token) > 7 end) do
      body = Poison.decode!(@resp.body)
      %Publit.MessageApi.Response{status: :ok, resp: @resp, body: body}
    else
      body = Poison.decode!(@resp_error.body)
      %Publit.MessageApi.Response{status: :error, resp: @resp_error, body: body}
    end
  end

  defp update_agent(tokens, msg, server_key) do
    if !Process.whereis(:api_mock) do
      raise "Error, the agent :api_mock has not been started, start in your tests with: Agent.start_link(fn -> %{} end, name: :api_mock)"
    end

    m = %{tokens: tokens, msg: msg, server_key: server_key}
    Agent.update(:api_mock, fn(v) -> v ++ [m] end)
  end

  def get_data do
    Agent.get(:api_mock, fn(v) -> v end)
  end

end




