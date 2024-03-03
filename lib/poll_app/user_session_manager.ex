defmodule PollApp.UserSessionManager do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def add_user_name(user_name) do
    GenServer.call(__MODULE__, {:add_user_name, user_name})
  end

  def user_name_taken?(user_name) do
    GenServer.call(__MODULE__, {:user_name_taken?, user_name})
  end

  # Server
  def handle_call({:add_user_name, user_name}, _from, state) do
    if Map.has_key?(state, user_name) do
      {:reply, {:error, :already_taken}, state}
    else
      Phoenix.PubSub.broadcast(PollApp.PubSub, "users", {:new_user, user_name})
      {:reply, :ok, Map.put(state, user_name, true)}
    end
  end

  def handle_call({:user_name_taken?, user_name}, _from, state) do
    is_taken = Map.has_key?(state, user_name)
    {:reply, is_taken, state}
  end
end
