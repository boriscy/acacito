defmodule Publit.UserView do
  use Publit.Web, :view

  def to_api(user) do
    Map.take(user, [:id, :full_name, :email, :locale])
  end
end
