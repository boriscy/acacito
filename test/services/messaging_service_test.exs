defmodule Publit.MessagingServiceTest do
  use ExUnit.Case, async: false

  alias Publit.{MessagingService}

  describe "messages" do
    test "OK" do
      {:ok, agent} = Agent.start_link fn -> %{resp: nil} end
      cb_ok = fn(resp) ->
        Agent.update(agent, fn(v) -> %{v | resp: resp} end)
      end
      cb_error = fn(_v) -> "" end
      data = %{title: "Test", body: "A test body"}

      {:ok, pid} = MessagingService.send_messages(["demo1234"], data, cb_ok, cb_error)
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, _, _, _} ->
        r = Agent.get(agent, fn(v) -> v end)[:resp]
        assert r.body["success"] == 1
        assert r.body["multicast_id"]
      end
    end

    test "ERROR" do
      {:ok, agent} = Agent.start_link fn -> %{resp: nil} end
      cb_ok = fn(_v) -> "" end
      cb_error = fn(resp) ->
        Agent.update(agent, fn(v) -> %{v | resp: resp} end)
      end
      data = %{title: "Test", body: "A test body"}

      {:ok, pid} = MessagingService.send_messages(["demo123"], data, cb_ok, cb_error)
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, _, _, _} ->
        r = Agent.get(agent, fn(v) -> v end)[:resp]
        assert r.body["success"] == 0
        assert r.body["failure"] == 1
        assert r.body["multicast_id"]
      end
    end

  end
end
