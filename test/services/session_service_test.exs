defmodule Publit.SessionServiceTest do
  use ExUnit.Case, async: true
  alias Publit.SessionService


  test "creates" do
    {:ok, pid1} = SessionService.start_link(%{key: "ama", name: "Amaru"})

    assert pid1 == Process.whereis(:ama)
    assert SessionService.get(:ama) == %SessionService{key: "ama", name: "Amaru"}

    assert {:error, {:already_started, _pid}} = SessionService.start_link(%{key: "ama", name: "Amaru"})

    d = DateTime.to_unix(DateTime.utc_now()) + 3600
    {:ok, pid2} = SessionService.start_link(%{key: "luc", name: "Lucas", expires_at: d})
    luc = SessionService.get(pid2)

    assert luc.name == "Lucas"
    assert luc.expires_at == d
  end
end
