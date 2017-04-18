defmodule Publit.SmsService do
  @moduledoc ~S"""
  Service to send notifications to the user
  the @message_api is defined as:

  - **dev**, **production**: `lib/publit/message_api.ex`
  - **test**: `test/support/message_api_mock.ex`

  There are async functions to send the message and direct message functions,
  the async functions use a `Task.Supervisor` to send the message
  """
  @sms_api Application.get_env(:publit, :sms_api)

  def status_code(resp) do
    {_s, msg} = resp
    {:error, msg}
  end

  @doc """
  """
  #@type send_message(tokens, data, cb_ok, cb_error, cb_net_error) ::
  def send_message(number, msg, cb_ok, cb_error, cb_net_error \\ fn(_v) -> :ok end) do
    Task.Supervisor.start_child(Publit.Messaging.Supervisor, fn() ->
        resp = @sms_api.send_message(number, msg)

        case resp do
          :ok -> cb_ok.(resp)
          {:error, _} -> cb_error.(resp)
          #:network_error -> cb_net_error.(resp)
        end
    end)
  end

  def send_direct_message(tokens, data) do
    @message_api.send_message(tokens, data)
  end

end
