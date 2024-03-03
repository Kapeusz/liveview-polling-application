defmodule PollAppWeb.SessionControllerTest do
  use PollAppWeb.ConnCase

  test "GET / renders the index page when user_name is not provided", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Login"
  end

  test "GET / redirects to /polls when user_name is provided", %{conn: conn} do
    user_name = "testuser"
    conn = get(conn, "/", %{"user_name" => user_name})
    assert redirected_to(conn) == "/polls"
    assert get_session(conn, :user_name) == user_name
  end
end
