defmodule Publit.MessageApiMock do

  @resp %HTTPoison.Response{body: "{\"id\":\"e8af7ee9-4873-4450-abaa-6152932e0202\",\"recipients\":1}",
  headers: [{"Date", "Tue, 28 Mar 2017 12:34:51 GMT"},
  {"Content-Type", "application/json; charset=utf-8"},
  {"Transfer-Encoding", "chunked"}, {"Connection", "keep-alive"},
  {"Set-Cookie",
   "__cfduid=d9867bec9340add126956f1b04fecb2e11490704491; expires=Wed, 28-Mar-18 12:34:51 GMT; path=/; domain=.onesignal.com; HttpOnly"},
  {"Status", "200 OK"},
  {"Cache-Control", "max-age=0, private, must-revalidate"},
  {"Access-Control-Allow-Origin", "*"}, {"X-XSS-Protection", "1; mode=block"},
  {"X-Request-Id", "e9711083-1507-44d2-b086-ba33a515afba"},
  {"Access-Control-Allow-Headers", "SDK-Version"},
  {"ETag", "W/\"6ac0ef8f1c2ff6ca77779598a77aba58\""},
  {"X-Frame-Options", "SAMEORIGIN"}, {"X-Runtime", "0.034245"},
  {"X-Content-Type-Options", "nosniff"},
  {"X-Powered-By", "Phusion Passenger 5.0.30"}, {"Server", "cloudflare-nginx"},
  {"CF-RAY", "346aa03cfcf407b5-MIA"}], status_code: 200}

  @resp_error %HTTPoison.Response{body: "{\"errors\":[\"You must include which players, segments, or tags you wish to send this notification to.\"]}",
  headers: [{"Date", "Tue, 28 Mar 2017 12:34:38 GMT"},
  {"Content-Type", "application/json; charset=utf-8"},
  {"Transfer-Encoding", "chunked"}, {"Connection", "keep-alive"},
  {"Set-Cookie",
   "__cfduid=d1a8a4f3a4bac9bd2ea59e862cc3f2afe1490704478; expires=Wed, 28-Mar-18 12:34:38 GMT; path=/; domain=.onesignal.com; HttpOnly"},
  {"Status", "400 Bad Request"}, {"Cache-Control", "no-cache"},
  {"Access-Control-Allow-Origin", "*"}, {"X-XSS-Protection", "1; mode=block"},
  {"X-Request-Id", "b177f879-3972-40fb-bed8-7838dd7ec395"},
  {"Access-Control-Allow-Headers", "SDK-Version"}, {"X-Runtime", "0.007269"},
  {"X-Frame-Options", "SAMEORIGIN"}, {"X-Content-Type-Options", "nosniff"},
  {"X-Powered-By", "Phusion Passenger 5.0.30"}, {"Server", "cloudflare-nginx"},
  {"CF-RAY", "346a9fef294907b5-MIA"}], status_code: 400}

  def send_message(tokens, msg) do
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




