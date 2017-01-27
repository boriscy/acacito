defmodule Publit.MessagingService do
  @moduledoc """
  Service to send notifications to the user
  """
  use HTTPoison.Base

  def status_code(resp) do
    {_s, msg} = resp
    {:error, msg}
  end

  @messaging_url "https://fcm.googleapis.com/fcm/send"

  def message(token, data) do
    headers = [{"Authorization", "key=#{server_key}"}, {"Content-Type", "application/json"}]
    body = Poison.encode!(%{to: token, data: data})

    Task.Supervisor.start_child(Publit.Messaging.Supervisor, fn() ->
      start()
      try do
        resp = HTTPoison.post!(@messaging_url, body, headers)

        if resp.status_code != 200 do
          IO.puts "Send message"
        end
      rescue
        HTTPoison.Error ->
          {Publit.MessagingService, "Network error, firebase not responding"}
      end
    end)
  end

  def server_key do
    System.get_env["FIREBASE_SERVER_KEY"]
  end

end
