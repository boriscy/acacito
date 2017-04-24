defmodule Publit.SmsApiMock do
  @resp %HTTPoison.Response{body: "{\n    \"message-count\": \"1\",\n    \"messages\": [{\n        \"to\": \"59173732677\",\n        \"message-id\": \"0D0000002EE0D00C\",\n        \"status\": \"0\",\n        \"remaining-balance\": \"1.95200000\",\n        \"message-price\": \"0.04800000\",\n        \"network\": \"73602\"\n    }]\n}",
  headers: [{"Date", "Mon, 17 Apr 2017 19:32:47 GMT"}, {"Server", "PWS/8.2.0.7"},
  {"X-Px",
   "nc h0-s1046.p0-mia ( h0-s1019.p1-iad), nc h0-s1019.p1-iad ( origin)"},
  {"Cache-Control", "max-age=1"}, {"Content-Length", "258"},
  {"Content-Type", "application/json"},
  {"Content-Disposition", "attachment; filename=\"api.txt\""},
  {"X-XSS-Protection", "1; mode=block;"},
  {"X-Nexmo-Trace-Id", "8c1281b595df61a974467d1267f99e47"},
  {"Strict-Transport-Security", "max-age=31536000; includeSubdomains"},
  {"X-Frame-Options", "deny"}, {"Connection", "keep-alive"}], status_code: 200}

  @resp_error %HTTPoison.Response{body: "{\n    \"message-count\": \"1\",\n    \"messages\": [{\n        \"status\": \"3\",\n        \"error-text\": \"to address is not numeric\"\n    }]\n}",
  headers: [{"Date", "Mon, 17 Apr 2017 19:39:48 GMT"}, {"Server", "PWS/8.2.0.7"},
  {"X-Px",
   "nc h0-s1045.p0-mia ( h0-s1019.p1-iad), nc h0-s1019.p1-iad ( origin)"},
  {"Cache-Control", "max-age=1"}, {"Content-Length", "128"},
  {"Content-Type", "application/json"},
  {"Content-Disposition", "attachment; filename=\"api.txt\""},
  {"X-XSS-Protection", "1; mode=block;"},
  {"X-Nexmo-Trace-Id", "37ac9180da3a9f6f6fd0597f1bca658a"},
  {"Strict-Transport-Security", "max-age=31536000; includeSubdomains"},
  {"X-Frame-Options", "deny"}, {"Connection", "keep-alive"}], status_code: 200}


  #@type send_message(list, map) ::
  def send_message(number, msg) do
    update_agent(number, msg)

    Process.sleep(sleep_time())

    case {resp_status(), get_status()} do
      {200, "0"} ->
        :ok
      {200, st} ->
        {:error, st}
    end
  end

  defp resp_status do
    if Process.whereis(:sms_mock) do
      Agent.get(:sms_mock, fn(v) -> v end)[:resp_status] || 200
    else
      200
    end
  end

  defp sleep_time do
    if Process.whereis(:sms_mock) do
      Agent.get(:sms_mock, fn(v) -> v end)[:sleep_time] || 30
    else
      100
    end
  end

  defp get_status do
    Agent.get(:sms_mock, fn(v) -> v end)[:status] || "0"
  end

  defp update_agent(number, msg) do
    if !Process.whereis(:sms_mock) do
      raise "Error, the agent :sms_mock has not been started, start in your tests with: Agent.start_link(fn -> %{} end, name: :sms_mock)"
    end

    Agent.update(:sms_mock, fn(v) -> Map.merge(v, %{number: number, msg: msg}) end)
  end

  def get_data do
    Agent.get(:sms_mock, fn(v) -> v end)
  end

end
