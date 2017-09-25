defmodule PublitWeb.MobileController do
  use PublitWeb, :controller

  """
  %{"device_id" => "", "message" => "Ahi esta Boris mensae",
    "message_id" => "5eab5621-eb81-4f9a-93e6-5fc3dd176512", "phone" => "70314273",
    "secret" => "heuf6e7ehdh", "sent_timestamp" => "1505908408944",
    "sent_to" => ""}
  """
  # POST /dashboard
  def create(conn, params) do
    Ecto.Adapters.SQL.query(Publit.Repo, "insert into messages_t (num, message, send_at) values ($1, $2, $3)", [params["phone"], params["message"], params["sent_timestamp"]])

    IO.inspect params
    text(conn, Poison.encode!(%{payload: %{success: true}}))
  end
end

