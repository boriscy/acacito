defmodule Publit.Order.Organization do
  use PublitWeb, :model
  alias Publit.{Order, Repo}

  embedded_schema do
    field :name, :string
    field :mobile_number, :string
    field :address, :string
  end

end
