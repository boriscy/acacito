defmodule Publit.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Publit.Repo

  def user_factory do
    %Publit.User{
      email: "amaru@mail.com",
      password: "demo1234",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234")
    }
  end

end
