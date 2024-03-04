defmodule PollApp.PollsManagerTest do
  use ExUnit.Case, async: true
  alias PollApp.PollsManager

  setup do
    unique_name = :"#{__MODULE__}_#{:erlang.unique_integer([:positive])}"
    {:ok, _pid} = PollsManager.start_link(name: unique_name)
    {:ok, polls_manager: unique_name}
  end

  describe "create_poll/3" do
    test "creates a poll with valid data", %{polls_manager: polls_manager} do
      assert :ok =
               PollsManager.create_poll(
                 "What's your favorite color?",
                 "Red,Green,Blue",
                 "Alice",
                 polls_manager
               )
    end

    test "returns an error with invalid data", %{polls_manager: polls_manager} do
      assert {:error, :empty_question} =
               PollsManager.create_poll("", "Red,Green,Blue", "Alice", polls_manager)

      assert {:error, :not_enough_options} =
               PollsManager.create_poll(
                 "What's your favorite color?",
                 "Red",
                 "Alice",
                 polls_manager
               )
    end
  end

  describe "vote/3" do
    test "allows a user to vote on a poll", %{polls_manager: polls_manager} do
      :ok =
        PollsManager.create_poll(
          "What's your favorite color?",
          "Red,Green,Blue",
          "Alice",
          polls_manager
        )

      assert :ok = PollsManager.vote(1, "Bob", "Red", polls_manager)
    end

    test "prevents a user from voting more than once", %{polls_manager: polls_manager} do
      :ok =
        PollsManager.create_poll(
          "What's your favorite color?",
          "Red,Green,Blue",
          "Alice",
          polls_manager
        )

      :ok = PollsManager.vote(1, "Bob", "Red", polls_manager)

      assert {:error, :already_voted} = PollsManager.vote(1, "Bob", "Green", polls_manager)
    end
  end

  describe "list_polls/0" do
    test "lists all polls", %{polls_manager: polls_manager} do
      :ok = PollsManager.create_poll("Poll 1", "Option1,Option2", "Alice", polls_manager)
      :ok = PollsManager.create_poll("Poll 2", "Option3,Option4", "Bob", polls_manager)

      polls = PollsManager.list_polls(polls_manager)
      assert length(polls) == 2
    end
  end

  describe "delete/3" do
    test "allows deletion of an existing poll", %{polls_manager: polls_manager} do
      :ok = PollsManager.create_poll("Test Poll", "Yes,No", "Creator", polls_manager)

      polls = PollsManager.list_polls(polls_manager)
      assert length(polls) == 1
      poll_id = hd(polls).id

      assert :ok = PollsManager.delete_poll(poll_id, polls_manager)

      assert [] == PollsManager.list_polls(polls_manager)
    end

    test "prevents deletion of a non-existent poll", %{polls_manager: polls_manager} do
      non_existent_poll_id = 999
      assert {:error, :not_found} = PollsManager.delete_poll(non_existent_poll_id, polls_manager)
    end
  end
end
