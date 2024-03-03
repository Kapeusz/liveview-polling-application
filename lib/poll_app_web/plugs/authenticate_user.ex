defmodule PollAppWeb.Plugs.AuthenticateUser do
  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _default) do
    user_name = get_session(conn, :user_name)

    if user_name do
      assign(conn, :current_user, user_name)
    else
      # Check if the current path is not the homepage before redirecting
      unless conn.request_path == "/" do
        conn
        |> put_flash(:error, "You must be logged in to access this page.")
        |> redirect(to: "/")
        |> halt()
      else
        conn
      end
    end
  end
end
