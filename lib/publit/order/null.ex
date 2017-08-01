defmodule Publit.Order.Null do
  import Ecto.Changeset
  import Publit.Gettext

  alias Publit.{Order, Repo, User}
  alias Ecto.Multi

  def null(%Order{status: "new"} = order, %User{} = user, params), do: null_order(%Order{status: "new"} = order, %User{} = user, params)
  def null(%Order{status: "process"} = order, %User{} = user, params), do: null_order(%Order{status: "process"} = order, %User{} = user, params)
  def null(%Order{status: "transport"} = order, %User{} = user, params), do: null_order(%Order{status: "transport"} = order, %User{} = user, params)
  def null(%Order{status: "transporting"} = order, %User{} = user, params), do: null_order(%Order{status: "transporting"} = order, %User{} = user, params)
  def null(%Order{status: "ready"} = order, %User{} = user, params), do: null_order(%Order{status: "ready"} = order, %User{} = user, params)

  defp null_order(order, user, params) do
    cs = cast(order, params, [:null_reason])
    |> validate_required(:null_reason)
    |> validate_length(:null_reason, min: 6)
    |> put_change(:status, "nulled")

    log = %{"msg" => "Order nulled by #{user.full_name} - #{user.email}",
      "user_id" => user.id, "type" => "status:nulled" }

    multi = Multi.new()
    |> Multi.update(:order, cs)
    |> Multi.run(:log, fn(_) -> Order.Log.add(order.id, log) end)

    case Repo.transaction(multi) do
      {:ok, res} ->
        order = Repo.preload(res.order, :user_client)
        send_message(order, gettext("We could not complete your order"))
        {:ok, res.order}
      {:error, :order, cs, _} ->
        {:error, :order, cs}
    end
  end

  @token_id "device_token"

  defp send_message(order, title) do
    tokens = [order.user_client.extra_data[@token_id]]

    cb_ok = fn(_) -> "" end
    cb_err = fn(_) -> "" end
    ord = Publit.TransApi.OrderView.to_api(order)

    Publit.MessagingService.send_message_cli(tokens,
      %{title: title, message: title, data: %{status: "order:updated", order: ord} },
      cb_ok, cb_err)
  end
end
