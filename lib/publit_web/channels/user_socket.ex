defmodule PublitWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "users:*", PublitWeb.UserChannel
  channel "organizations:*", PublitWeb.OrganizationChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
    check_origin: [
      "//localhost", "https://app.acacito.com", "https://cli.acacito.com"
    ]

  #transport :longpoll, Phoenix.Transports.LongPoll#,
  #  window_ms: 10_000,
  #  pubsub_timeout_ms: 2_000,
  #  transport_log: false,
  #  crypto: [max_age: 1209600],
  #  check_origin: false

  @max_age Application.get_env(:publit, :session_max_age)
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user_id", token, max_age: @max_age) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, reason} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PublitWeb.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
