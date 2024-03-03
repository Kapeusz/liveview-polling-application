defmodule PollAppWeb.PollLive.Index do
  use PollAppWeb, :live_view
  alias PollApp.PollsManager

  @impl true
  def mount(_params, session, socket) do
    Phoenix.PubSub.subscribe(PollApp.PubSub, "users")
    Phoenix.PubSub.subscribe(PollApp.PubSub, "polls:updates")
    polls = PollsManager.list_polls()

    user_name = session["user_name"] || "anonymous"

    {:ok,
     assign(socket,
       polls: polls,
       new_poll: %{},
       error: nil,
       latest_user: nil,
       current_user: user_name
     )}
  end

  @impl true
  def handle_event("create_poll", %{"poll" => poll_params}, socket) do
    current_user = socket.assigns.current_user

    case PollsManager.create_poll(poll_params["question"], poll_params["options"], current_user) do
      :ok ->
        {:noreply, assign(socket, polls: PollsManager.list_polls(), new_poll: %{}, error: nil)}

      {:error, :empty_question} ->
        {:noreply, assign(socket, error: "The poll question cannot be empty.")}

      {:error, :not_enough_options} ->
        {:noreply, assign(socket, error: "A poll must have at least two options.")}

      {:error, _reason} ->
        {:noreply, assign(socket, error: "Error creating poll")}
    end
  end

  @impl true
  def handle_event("vote", %{"poll_id" => poll_id, "option" => option}, socket) do
    user_name = socket.assigns.current_user
    poll_id = String.to_integer(poll_id)

    case PollsManager.vote(poll_id, user_name, option) do
      :ok ->
        {:noreply, assign(socket, polls: PollsManager.list_polls())}

      {:error, :already_voted} ->
        {:noreply, assign(socket, error: "You have already voted on this poll")}
    end
  end

  @impl true
  def handle_event("delete_poll", %{"id" => poll_id}, socket) do
    current_user = socket.assigns.current_user
    poll_id = String.to_integer(poll_id)

    case PollsManager.get_poll(poll_id) do
      {:ok, poll} ->
        if poll.creator == current_user do
          case PollsManager.delete_poll(poll_id) do
            :ok ->
              {:noreply, assign(socket, polls: PollsManager.list_polls())}

            {:error, :not_found} ->
              {:noreply, assign(socket, error: "Poll not found")}

            _ ->
              {:noreply, assign(socket, error: "Unknown error")}
          end
        else
          {:noreply, assign(socket, error: "You are not authorized to delete this poll")}
        end

      _ ->
        {:noreply, assign(socket, error: "Poll not found")}
    end
  end

  @impl true
  def handle_info({:new_poll, new_poll}, socket) do
    existing_ids = Enum.map(socket.assigns.polls, & &1.id)

    polls =
      if new_poll.id in existing_ids do
        socket.assigns.polls
      else
        [new_poll | socket.assigns.polls]
      end

    {:noreply, assign(socket, polls: polls)}
  end

  @impl true
  def handle_info({:poll_update, poll_id, updated_poll}, socket) do
    polls =
      Enum.map(socket.assigns.polls, fn poll ->
        if poll.id == poll_id, do: updated_poll, else: poll
      end)

    {:noreply, assign(socket, polls: polls)}
  end

  @impl true
  def handle_info({:poll_deleted, deleted_poll_id}, socket) do
    updated_polls =
      Enum.filter(socket.assigns.polls, fn poll ->
        poll.id != deleted_poll_id
      end)

    {:noreply, assign(socket, polls: updated_polls)}
  end

  @impl true
  def handle_info({:new_user, user_name}, socket) do
    {:noreply, assign(socket, latest_user: user_name)}
  end
end
