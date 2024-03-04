defmodule PollAppWeb.SessionController do
  use PollAppWeb, :controller

  def index(conn, params) do
    if get_session(conn, :user_name) do
      # Redirect logged-in users to the polls page directly
      redirect(conn, to: "/polls")
    else
      handle_new_or_returning_visitor(conn, params)
    end
  end

  defp handle_new_or_returning_visitor(conn, %{"user_name" => user_name} = _params) do
    trimmed_user_name = String.trim(user_name)

    if trimmed_user_name != "" do
      case PollApp.UserSessionManager.add_user_name(trimmed_user_name) do
        :ok ->
          conn
          |> put_session(:user_name, trimmed_user_name)
          |> redirect(to: "/polls")

        {:error, :already_taken} ->
          conn
          |> put_flash(:error, "User name already taken. Please choose another.")
          |> render("index.html")
      end
    else
      conn
      |> put_flash(:error, "User name cannot be empty.")
      |> render("index.html")
    end
  end

  # Render the homepage for new or returning visitors without a session
  defp handle_new_or_returning_visitor(conn, _params), do: render(conn, "index.html")
end
