defmodule PollAppWeb.PollLive.Index do
  use PollAppWeb, :live_view

  # alias PollApp.Polls
  # alias PollApp.Polls.Poll

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(PollApp.PubSub, "users")
    {:ok, assign(socket, latest_user: nil)}
  end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, "Edit Poll")
  #   |> assign(:poll, Polls.get_poll!(id))
  # end

  # defp apply_action(socket, :new, _params) do
  #   socket
  #   |> assign(:page_title, "New Poll")
  #   |> assign(:poll, %Poll{})
  # end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Polls")
    |> assign(:poll, nil)
  end

  # @impl true
  # def handle_info({PollAppWeb.PollLive.FormComponent, {:saved, poll}}, socket) do
  #   {:noreply, stream_insert(socket, :polls, poll)}
  # end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   poll = Polls.get_poll!(id)
  #   {:ok, _} = Polls.delete_poll(poll)

  #   {:noreply, stream_delete(socket, :polls, poll)}
  # end

  @impl true
  def handle_info({:new_user, user_name}, socket) do
    # React to the new user announcement, for example, by logging or updating the state
    IO.puts("New user logged in: #{user_name}")
    {:noreply, assign(socket, latest_user: user_name)}
  end
end
