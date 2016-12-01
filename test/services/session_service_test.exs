defmodule Publit.SessionServiceTest do
  use ExUnit.Case, async: true
  alias Publit.SessionService


  test "creates" do
    {:ok, pid1} = SessionService.start_link(%{key: :ama, name: "Amaru"})

    assert pid1 == Process.whereis(:ama)
    t = DateTime.to_unix(DateTime.utc_now()) + 60 * 30
    assert SessionService.get(:ama) == %SessionService{key: :ama, name: "Amaru", expires_at: t}

    assert {:error, {:already_started, _pid}} = SessionService.start_link(%{key: :ama, name: "Amaru"})

    {:ok, pid2} = SessionService.start_link(%{key: :luc, name: "Lucas", expires_at: 1})
    luc = SessionService.get(pid2)

    t = DateTime.to_unix(DateTime.utc_now()) + 60 * 30
    assert luc.name == "Lucas"
    assert luc.expires_at == t
  end

  test "Add more time to session" do
    {:ok, _pid1} = SessionService.start_link(%{key: :ama, name: "Amaru"})
    t = DateTime.to_unix(DateTime.utc_now()) + 60 * 30
    ama = SessionService.get(:ama)

    assert ama.expires_at == t

    IO.puts "Going to sleep 3 seconds"
    Process.sleep(3000)

    ama = SessionService.get(:ama)
    assert ama.expires_at == t + 3

    ama = SessionService.get(:ama)
  end

  import Mock

  test "return nil" do
    {:ok, _pid1} = SessionService.start_link(%{key: :ama, name: "Amaru"})
    ama = SessionService.get(:ama)

    with_mock SessionService, [future_time: fn(_v) -> DateTime.to_unix(DateTime.utc_now()) + 60 * 31  end] do
      IO.inspect Publit.SessionService.get(:ama)
    end
  end

end
