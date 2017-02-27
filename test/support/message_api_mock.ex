defmodule Publit.MessageApiMock do

  @resp %HTTPoison.Response{body: "{\"multicast_id\":7506846924425657137,\"success\":1,\"failure\":0,\"canonical_ids\":0,\"results\":[{\"message_id\":\"0:1486409102610914%2fd9afcdf9fd7ecd\"}]}",
    headers: [{"Content-Type", "application/json; charset=UTF-8"},
    {"Date", "Mon, 06 Feb 2017 19:25:02 GMT"},
    {"Expires", "Mon, 06 Feb 2017 19:25:02 GMT"},
    {"Cache-Control", "private, max-age=0"},
    {"X-Content-Type-Options", "nosniff"}, {"X-Frame-Options", "SAMEORIGIN"},
    {"X-XSS-Protection", "1; mode=block"}, {"Server", "GSE"},
    {"Alt-Svc", "quic=\":443\"; ma=2592000; v=\"35,34\""},
    {"Accept-Ranges", "none"}, {"Vary", "Accept-Encoding"},
    {"Transfer-Encoding", "chunked"}], status_code: 200}

  @resp_error %HTTPoison.Response{body: "{\"multicast_id\":4738451672835022850,\"success\":0,\"failure\":1,\"canonical_ids\":0,\"results\":[{\"error\":\"InvalidRegistration\"}]}",
  headers: [{"Content-Type", "application/json; charset=UTF-8"},
   {"Date", "Mon, 06 Feb 2017 22:16:24 GMT"},
   {"Expires", "Mon, 06 Feb 2017 22:16:24 GMT"},
   {"Cache-Control", "private, max-age=0"},
   {"X-Content-Type-Options", "nosniff"}, {"X-Frame-Options", "SAMEORIGIN"},
   {"X-XSS-Protection", "1; mode=block"}, {"Server", "GSE"},
   {"Alt-Svc", "quic=\":443\"; ma=2592000; v=\"35,34\""},
   {"Accept-Ranges", "none"}, {"Vary", "Accept-Encoding"},
   {"Transfer-Encoding", "chunked"}], status_code: 200}

  def send_messages(tokens, msg) do
    update_agent(tokens, msg)

    headers = [{"Authorization", "key=server_key_firebase}"}, {"Content-Type", "application/json"}]

    if Enum.all?(tokens, fn(token) -> String.length(token) > 7 end) do
      body = Poison.decode!(@resp.body)
      %Publit.MessageApi.Response{status: :ok, resp: @resp, body: body}
    else
      body = Poison.decode!(@resp_error.body)
      %Publit.MessageApi.Response{status: :error, resp: @resp_error, body: body}
    end
  end

  def send_message(token, msg) do
    update_agent([token], msg)

    headers = [{"Authorization", "key=server_key_firebase}"}, {"Content-Type", "application/json"}]
    body = Poison.decode!(@resp.body)

    %Publit.MessageApi.Response{status: :ok, resp: @resp, body: body}
  end

  defp update_agent(tokens, msg) do
    if !Process.whereis(:api_mock) do
      raise "Error, the agent :api_mock has not been started, start in your tests with: Agent.start_link(fn -> %{} end, name: :api_mock)"
    end

    Agent.update(:api_mock, fn(v) -> Map.merge(v, %{tokens: tokens, msg: msg}) end)
  end

  def get_data do
    Agent.get(:api_mock, fn(v) -> v end)
  end

end
