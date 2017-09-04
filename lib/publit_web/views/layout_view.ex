defmodule PublitWeb.LayoutView do
  use PublitWeb, :view

  def active_link(conn, uri) do
    {:ok, reg} = Regex.compile(conn.request_path)

    if Regex.match?(reg, uri) do
      "active"
    end
  end
end
