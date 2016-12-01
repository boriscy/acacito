defmodule Publit.OrderChannel do
  use Publit.Web, :channel

  def join("orders:" <> order_id, _params, socket) do
  end
end
