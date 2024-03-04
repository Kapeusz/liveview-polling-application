defmodule PollAppWeb.SessionControllerTest do
  use PollAppWeb.ConnCase

  @valid_user_name "testuser"
  @taken_user_name "takenuser"

  setup do
    # Setup code to ensure a consistent state, like ensuring `@taken_user_name` is marked as taken
    PollApp.UserSessionManager.add_user_name(@taken_user_name)
    :ok
  end

  test "GET / renders the index page when user_name is not provided", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Login"
  end

  test "GET / redirects to /polls when valid user_name is provided", %{conn: conn} do
    conn = get(conn, "/", %{"user_name" => @valid_user_name})
    assert redirected_to(conn) == "/polls"
    assert get_session(conn, :user_name) == @valid_user_name
  end

  test "GET / returns error when user_name is already taken", %{conn: conn} do
    conn = get(conn, "/", %{"user_name" => @taken_user_name})
    assert html_response(conn, 200) =~ "User name already taken. Please choose another."
  end

  test "GET / renders the index page when user_name is empty", %{conn: conn} do
    conn = get(conn, "/", %{"user_name" => ""})
    assert html_response(conn, 200) =~ "Login"
  end

  test "GET / renders the index page when user_name is only whitespace", %{conn: conn} do
    conn = get(conn, "/", %{"user_name" => "   "})
    assert html_response(conn, 200) =~ "Login"
  end
end
