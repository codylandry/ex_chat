defmodule ExChatDal.Posts do
  import Ecto.Query
  alias ExChatDal.{Repo, Posts.Post}

  def list_posts_by_channel_id(channel_id) do
    from(
      p in Post,
      where: p.channel_id == ^channel_id
    )
    |> Repo.all()
  end

  def list_posts_by_author_id(author_id) do
    from(
      p in Post,
      where: p.author_id == ^author_id
    )
    |> Repo.all()
  end

  def create_post(channel_id, attrs) do
    post =
      %Post{}
      |> Post.changeset(Map.put(attrs, :channel_id, channel_id))
      |> Repo.insert!()

    from(p in Post, where: p.id == ^post.id)
    |> preload([:author, :channel])
    |> Repo.one!()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update!()
  end

  def delete_post(post_id) do
    from(p in Post, where: p.id == ^post_id)
    |> Repo.delete_all()
  end

  def list_posts, do: Repo.all(Post)

  def get_post(id), do: Repo.get!(Post, id)
end
