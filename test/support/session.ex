defmodule Publit.Support.Session do
  import Publit.Factory
  import Plug.Conn

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))
  @encrypted_opts Plug.Session.init(@default_opts)

  #defp sign_conn(conn, secret \\ @secret) do
  #  put_in(conn.secret_key_base, secret)
  #  |> Plug.Session.call(@signing_opts)
  #  |> fetch_session
  #end

  defp encrypt_conn(conn) do
    put_in(conn.secret_key_base, @secret)
    |> Plug.Session.call(@encrypted_opts)
    |> fetch_session
  end

  def create_user_org(params \\ %{}) do
    org = insert(:organization, params[:org] || %{})
    role = params[:role] || "admin"
    email = params[:email] || "amaru@mail.com"
    mn = params[:mobile_number] || "77112233"

    user = insert(:user, email: email, mobile_number: mn, organizations: [
      %Publit.UserOrganization{role: role, organization_id: org.id, name: org.name, active: true}
    ])

    {user, org}
  end

  def set_user_org_conn(conn, params \\ %{}) do
    {user, org} = create_user_org(params)

    conn
    |> assign(:current_user, user)
    |> assign(:current_organization, org)
  end

end
