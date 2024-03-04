defmodule PollAppWeb.PollLiveTest do
  use ExUnit.Case, async: true
  use PollAppWeb.ConnCase

  import Phoenix.LiveViewTest

  alias PollApp.PollsManager

  setup do
    unique_name = :"#{__MODULE__}_#{:erlang.unique_integer([:positive])}"
    {:ok, _pid} = PollsManager.start_link(name: unique_name)
    {:ok, polls_manager: unique_name}
  end

  describe "PollLive.Index" do
    setup [:create_user_name]

    test "mounts successfully", %{
      conn: _conn,
      user_name: user_name,
      polls_manager: polls_manager
    } do
      conn = build_conn()
      conn = Plug.Test.init_test_session(conn, user_name: user_name)

      {:ok, index_live, _html} = live(conn, "/polls")

      :ok =
        PollsManager.create_poll(
          "What's your favorite day of the week?",
          "Monday,Tuesday,Wednesday",
          user_name,
          polls_manager
        )

      assert has_element?(index_live, "button", "Delete Poll")
    end

    test "creates a poll", %{conn: _conn, user_name: user_name, polls_manager: polls_manager} do
      conn = build_conn()
      conn = Plug.Test.init_test_session(conn, user_name: user_name)

      {:ok, index_live, _html} = live(conn, "/polls")

      :ok =
        PollsManager.create_poll(
          "What's your favorite color?",
          "Red,Green,Blue",
          "Alice",
          polls_manager
        )

      assert has_element?(index_live, "button", "Delete Poll")
    end

    test "creates a poll and votes on it", %{conn: _conn, user_name: user_name} do
      conn = build_conn()
      conn = Plug.Test.init_test_session(conn, user_name: user_name)

      {:ok, live_view, _html} = live(conn, "/polls")

      assert live_view
             |> form("form", %{
               "poll[question]" => "What's your favorite food?",
               "poll[options]" => "Ice creams,Burger,Pizza"
             })
             |> render_submit()

      assert render(live_view) =~ "What&#39;s your favorite food?"

      assert live_view |> element("button", "Pizza") |> render_click()

      assert render(live_view) =~ "Pizza"
      assert render(live_view) =~ "1 votes"
    end

    test "deletes a poll", %{conn: _conn, user_name: user_name, polls_manager: polls_manager} do
      conn = build_conn()
      conn = Plug.Test.init_test_session(conn, user_name: user_name)

      {:ok, index_live, _html} = live(conn, "/polls")

      :ok =
        PollsManager.create_poll(
          "What's your favorite color?",
          "Red,Green,Blue",
          "Alice",
          polls_manager
        )

      poll_id = 1
      assert index_live |> element("button", "Delete Poll") |> render_click()
      refute has_element?(index_live, "#poll_#{poll_id}")
    end
  end

  defp create_user_name(_) do
    {:ok, user_name: "Alice"}
  end
end
