defmodule Publit.Order.Comment do
  use Publit.Web, :model
  import Publit.Gettext
  alias Publit.{Order, UserClient, UserTransport, Organization, Repo}
  alias Ecto.Multi

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "comments" do
    field :to_id, :binary_id
    field :from_id, :binary_id
    field :comment, :string
    field :comment_type, :string
    field :rating, :integer

    belongs_to :order, Order, type: :binary_id

    timestamps()
  end
  #@coment_types ["cli_org", "cli_trans", "org_cli", "org_trans", "trans_cli", "trans_org"]

  def create(order, from, params) do
    case valid_comment?(order, from, params) do
      :ok ->
        create_comment(order, from, params)
      {:error, err} ->
        {:error, err}
    end
  end

  defp create_comment(order, from, params) do
    c_type = params["comment_type"]

    data = Map.put(order.comment_details, c_type, Ecto.DateTime.utc())
    |> Map.put("#{c_type}_rating", params["rating"])

    o_cs = Ecto.Changeset.change(order) |> put_change(:comment_details, data)

    c_cs = %Order.Comment{}
    |> cast(params, [:rating, :comment, :comment_type])
    |> put_change(:to_id, get_to_id(order, c_type))
    |> put_change(:order_id, order.id)

    multi = Multi.new()
    |> Multi.insert(:comment, c_cs)
    |> Multi.update(:order, o_cs)

    case Repo.transaction(multi) do
      {:ok, res} ->
        {:ok, res}
      {:erro, res} -> {:error, res.order}
    end
  end

  defp valid_comment?(order, %UserClient{id: id}, params) do
    valid_comment?(order, id, :user_client_id, ["cli_org", "cli_trans"], params)
  end
  defp valid_comment?(order, %UserTransport{id: id}, params) do
    valid_comment?(order, id, :user_transport_id, ["trans_org", "trans_cli"], params)
  end
  defp valid_comment?(order, %Organization{id: id}, params) do
    valid_comment?(order, id, :organization_id, ["org_trans", "org_cli"], params)
  end
  defp valid_comment?(order, id, field, types, params) do
    c_type = params["comment_type"]

    with {:client, true} <- {:client, id == Map.get(order, field)},
      {:type, true} <- {:type, Enum.any?(types, fn(v) -> v == c_type end)},
      {:type_v, true} <- {:type_v, !order.comment_details[c_type]},
      {:rating, true} <- {:rating, valid_rating?(params["rating"])} do
        :ok
    else
      {:client, false} -> {:error, gettext("Invalid user")}
      {:type, false} -> {:error, gettext("Invalid comment type")}
      {:type_v, false} -> {:error, gettext("Comment done")}
      {:rating, false} -> {:error, gettext("Invalid rating")}
    end
  end

  def get_to_id(order, c_type) do
    case c_type do
      "cli_org" -> order.organization_id
      "cli_trans" -> order.user_transport_id
      "trans_cli" -> order.user_client_id
      "trans_org" -> order.organization_id
      "org_cli" -> order.user_client_id
      "org_trans" -> order.user_transport_id
    end
  end

  defp valid_rating?(rating) do
    is_integer(rating) && rating > 0 && rating < 6
  end

end
