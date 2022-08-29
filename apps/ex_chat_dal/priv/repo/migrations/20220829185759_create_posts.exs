defmodule ExChatDal.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table :posts do
      add :content, :string
      add :channel_id, references(:channels, on_delete: :delete_all)

      timestamps()
    end

    create index :posts, [:channel_id]
  end
end
