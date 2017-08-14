defmodule Publit.Account.Password do
  alias Publit.{Repo, Account, UserClient, User, UserTransport}

  def client_password(email) do
    u = Repo.get_by(UserClient, email: email)
    if u do
      send_email_link(u, "")
    end
  end

  def send_email_link(u, path) do
  end
end
