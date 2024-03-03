defmodule PollApp.PollsManager do
  use GenServer
  require Logger

  # Start the GenServer
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{polls: %{}, votes: %{}}, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{polls: %{}, votes: %{}}}
  end

  def create_poll(question, options, user_name) do
    GenServer.call(__MODULE__, {:create_poll, question, options, user_name})
  end

  def list_polls do
    GenServer.call(__MODULE__, :list_polls)
  end

  def vote(poll_id, user_name, option) do
    GenServer.call(__MODULE__, {:vote, poll_id, user_name, option})
  end

  def get_poll(poll_id) do
    GenServer.call(__MODULE__, {:get_poll, poll_id})
  end

  def delete_poll(poll_id) do
    GenServer.call(__MODULE__, {:delete_poll, poll_id})
  end

  # Server callbacks
  def handle_call(:list_polls, _from, state) do
    polls = Map.values(state.polls)
    {:reply, polls, state}
  end

  def handle_call({:create_poll, question, options_string, creator}, _from, state) do
    poll_ids = Map.keys(state.polls)
    poll_id = if Enum.empty?(poll_ids), do: 1, else: Enum.max(poll_ids) + 1

    options = String.split(options_string, ",")
    options_votes = Enum.map(options, fn option -> {option, 0} end) |> Enum.into(%{})

    new_poll = %{
      id: poll_id,
      question: question,
      options: options,
      votes: options_votes,
      voters: %{},
      creator: creator
    }

    new_polls = Map.put(state.polls, poll_id, new_poll)
    broadcast_update("polls:updates", {:new_poll, new_poll})
    {:reply, :ok, %{state | polls: new_polls}}
  end

  def handle_call({:vote, poll_id, user_name, option}, _from, state) do
    polls = state.polls

    case polls do
      %{^poll_id => poll} ->
        if Map.has_key?(poll.votes, option) && !Map.has_key?(poll.voters, user_name) do
          updated_votes = Map.update!(poll.votes, option, &(&1 + 1))
          updated_voters = Map.put(poll.voters, user_name, true)
          updated_poll = Map.put(poll, :votes, updated_votes) |> Map.put(:voters, updated_voters)
          new_polls = Map.put(polls, poll_id, updated_poll)
          broadcast_update("polls:updates", {:poll_update, poll_id, updated_poll})
          {:reply, :ok, %{state | polls: new_polls}}
        else
          {:reply, {:error, :already_voted}, state}
        end

      _ ->
        {:reply, {:error, :poll_not_found}, state}
    end
  end

  def handle_call({:get_poll, poll_id}, _from, state) do
    case Map.fetch(state.polls, poll_id) do
      {:ok, poll} ->
        {:reply, {:ok, poll}, state}

      {:error, _} ->
        {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:delete_poll, poll_id}, _from, state) do
    if Map.has_key?(state.polls, poll_id) do
      new_polls = Map.delete(state.polls, poll_id)
      broadcast_update("polls:updates", {:poll_deleted, poll_id})
      {:reply, :ok, %{state | polls: new_polls}}
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  # Helper function to broadcast updates
  defp broadcast_update(topic, message) do
    Phoenix.PubSub.broadcast(PollApp.PubSub, topic, message)
  end
end
