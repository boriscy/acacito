defmodule Publit.MessagingServiceTest do
  use ExUnit.Case, async: false

  alias Publit.{MessagingService}

  describe "message" do
    test "OK" do
      Agent.start_link(fn -> %{} end, name: :api_mock)

      {:ok, agent} = Agent.start_link fn -> %{resp: nil} end
      cb_ok = fn(resp) ->
        Agent.update(agent, fn(v) -> %{v | resp: resp} end)
      end
      cb_error = fn(_v) -> "" end
      data = %{title: "Test", body: "A test body"}

      {:ok, pid} = MessagingService.send_message(["demo1234"], data, cb_ok, cb_error)
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, _, _, _} ->
        r = Agent.get(agent, fn(v) -> v end)[:resp]

        assert r.body["id"]
        assert r.body["success"]
      end
    end

    test "ERROR" do
      Agent.start_link(fn -> %{} end, name: :api_mock)
      {:ok, agent} = Agent.start_link fn -> %{resp: nil} end

      cb_ok = fn(_v) -> "" end
      cb_error = fn(resp) ->
        Agent.update(agent, fn(v) -> %{v | resp: resp} end)
      end
      data = %{title: "Test", body: "A test body"}

      {:ok, pid} = MessagingService.send_message(["demo123"], data, cb_ok, cb_error)
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, _, _, _} ->
        r = Agent.get(agent, fn(v) -> v end)[:resp]

      end
    end

  end
end
