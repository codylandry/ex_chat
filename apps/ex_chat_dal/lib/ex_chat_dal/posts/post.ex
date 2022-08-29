defmodule ExChatDal.Posts.Post do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    belongs_to :channel, ExChatDal.Channels.Channel
    belongs_to :author, ExChatDal.Accounts.User

    timestamps()
  end

  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:content, :channel_id, :author_id])
    |> validate_required([:content, :channel_id, :author_id])
    |> assoc_constraint(:channel)
    |> assoc_constraint(:author)
  end
end
