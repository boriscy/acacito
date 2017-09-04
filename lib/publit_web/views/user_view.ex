defmodule PublitWeb.UserView do
  use PublitWeb, :view

  def to_api(user) do
    Map.take(user, [:id, :full_name, :email, :locale, :mobile_number])
  end
end
