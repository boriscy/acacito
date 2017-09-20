defmodule Publit.SessionServiceTest do
  use ExUnit.Case, async: true
  alias Publit.SessionService


  test "creates" do
    {:ok, pid1} = SessionService.start_link(%{key: :ama, name: "Amaru", expires_in: 1000})

    assert pid1 == Process.whereis(:ama)
    assert %SessionService{key: :ama, name: "Amaru", expires_in: 1000, ref: _ref} = SessionService.get(:ama)

    assert {:error, {:already_started, _pid}} = SessionService.start_link(%{key: :ama, name: "Amaru"})

    {:ok, pid2} = SessionService.start_link(%{key: :luc, name: "Lucas", expires_in: 1000})
    luc = SessionService.get(pid2)

    assert luc.name == "Lucas"
    assert luc.expires_in == 1000
    assert luc.ref
  end
  """
  test "Add more time to session" do
    {:ok, _pid1} = SessionService.start_link(%{key: :ama, name: "Amaru", expires_in: 500})
    ama = SessionService.get(:ama)
    IO.puts "Sleep 400 miliseconds"
    Process.sleep(400)
    ama = SessionService.get(:ama)
    assert ama.name == "Amaru"
    IO.puts "Sleep 400 miliseconds"
    Process.sleep(400)
    ama = SessionService.get(:ama)
    assert ama.name == "Amaru"
    IO.puts "Sleep 550 miliseconds"
    ref = ama.ref
    ref = Process.monitor(ref)
    assert_receive {:DOWN, ^ref, _, _, _}, 550
    #Process.sleep(1100)
  end
  """
end
