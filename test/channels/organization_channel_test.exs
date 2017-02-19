defmodule Publit.OrderChannelTest do
  use Publit.ChannelCase
  alias Publit.{OrganizationChannel}

  @endpoind Publit.Endpoint

  setup do
    {:ok, _, socket} = socket("user:id", %{data: 1})
    |> subscribe_and_join(OrganizationChannel, "organizations:123", %{"id" => 3})

    {:ok, socket: socket}
  end

  test "join", %{socket: socket} do

    IO.inspect socket
  end
end
