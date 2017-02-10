defmodule Publit.MessagingService do
  @moduledoc """
  Service to send notifications to the user
  """
  @message_api Application.get_env(:publit, :message_api)

  def status_code(resp) do
    {_s, msg} = resp
    {:error, msg}
  end

  def send_messages(tokens, data, cb_ok, cb_error, cb_net_error \\ fn(v) -> end) do
    Task.Supervisor.start_child(Publit.Messaging.Supervisor, fn() ->
        resp = @message_api.send_messages(tokens, data)
        case resp.status do
          :ok -> cb_ok.(resp)
          :error -> cb_error.(resp)
          :network_error -> cb_net_error.(resp)
        end
    end)
  end

  def send_direct_messages(tokens, data) do
    @message_api.send_messages(tokens, data)
  end
end
