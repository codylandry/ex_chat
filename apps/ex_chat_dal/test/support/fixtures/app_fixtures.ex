defmodule ExChatDal.AppFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExChatDal.App` context.
  """

  @doc """
  Generate a app_name.
  """
  def app_name_fixture(attrs \\ %{}) do
    {:ok, app_name} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> ExChatDal.App.create_app_name()

    app_name
  end
end
