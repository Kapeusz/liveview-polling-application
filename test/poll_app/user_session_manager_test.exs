defmodule PollApp.UserSessionManagerTest do
  use ExUnit.Case, async: true
  alias PollApp.UserSessionManager

  test "adds a new username successfully" do
    assert :ok == UserSessionManager.add_user_name("new_user")
    assert true == UserSessionManager.user_name_taken?("new_user")
  end

  test "returns error when adding a username that is already taken" do
    UserSessionManager.add_user_name("existing_user")
    assert {:error, :already_taken} == UserSessionManager.add_user_name("existing_user")
  end

  test "checks if a username is taken" do
    UserSessionManager.add_user_name("taken_user")
    assert true == UserSessionManager.user_name_taken?("taken_user")
  end

  test "checks if a username is not taken" do
    assert false == UserSessionManager.user_name_taken?("free_user")
  end
end
