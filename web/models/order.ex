defmodule Publit.Order do
  use Publit.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "orders" do
    field :user_id, Ecto.UUID
    field :total, :decimal
    field :status, :string, default: "pending"
    #field :details, :map
    field :location, :string
    field :null_reason, :string
    #field :messages, :list

    #embeds_many :details, OrderDetail, on_replace: :delete

    timestamps()
  end
  @statuses ["pending", "process", "deliver", "delivered", "null"]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :total, :details, :location])
    |> validate_required([:user_id, :total, :details, :location])
  end
end
