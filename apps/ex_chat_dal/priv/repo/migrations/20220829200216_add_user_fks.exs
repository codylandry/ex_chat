defmodule ExChatDal.Repo.Migrations.AddUserFks do
  use Ecto.Migration

  def change do
    alter table :posts do
      add :author_id, references(:users), null: false
    end

    create index(:posts, [:author_id])

    create table :channel_members do
      add :member_id, references(:users), null: false
      add :channel_id, references(:channels, on_delete: :delete_all), null: false
    end

    create unique_index(:channel_members, [:member_id, :channel_id])
  end
end
