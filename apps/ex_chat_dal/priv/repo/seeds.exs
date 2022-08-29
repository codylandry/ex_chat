alias ExChatDal.{Posts, Channels, Accounts, Repo}

Repo.delete_all(Channels.Channel)
Repo.delete_all(Posts.Post)
Repo.delete_all(Accounts.User)

# Channels
{:ok, general_channel} = Channels.create_channel(%{name: "general"})
{:ok, random_channel} = Channels.create_channel(%{name: "random"})
{:ok, updates_channel} = Channels.create_channel(%{name: "updates"})

# Users
{:ok, bob} =
  Accounts.register_user(%{
    email: "bob-exchat@mailinator.com",
    username: "bob",
    password: "password"
  })

Accounts.User.confirm_changeset(bob) |> Repo.update()
Channels.add_member(general_channel.id, bob.id)
Channels.add_member(random_channel.id, bob.id)


{:ok, tom} =
  Accounts.register_user(%{
    email: "tom-exchat@mailinator.com",
    username: "tom",
    password: "password"
  })

Accounts.User.confirm_changeset(tom) |> Repo.update()
Channels.add_member(general_channel.id, tom.id)
Channels.add_member(updates_channel.id, tom.id)

{:ok, fred} =
  Accounts.register_user(%{
    email: "fred-exchat@mailinator.com",
    username: "fred",
    password: "password"
  })

Accounts.User.confirm_changeset(fred) |> Repo.update()
Channels.add_member(general_channel.id, fred.id)
Channels.add_member(random_channel.id, fred.id)

# Posts

Posts.create_post(%{
  channel_id: general_channel.id,
  author_id: bob.id,
  content: "Hi! My name is bob"
})

Posts.create_post(%{
  channel_id: general_channel.id,
  author_id: tom.id,
  content: "Hi Bob!, how are you?"
})

Posts.create_post(%{
  channel_id: general_channel.id,
  author_id: fred.id,
  content: "Welcome Bob!"
})

Posts.create_post(%{
  channel_id: general_channel.id,
  author_id: bob.id,
  content: "Thanks everyone!"
})

Posts.create_post(%{
  channel_id: random_channel.id,
  author_id: bob.id,
  content: "something random"
})

Posts.create_post(%{
  channel_id: random_channel.id,
  author_id: fred.id,
  content: "very funny"
})

Posts.create_post(%{
  channel_id: updates_channel.id,
  author_id: tom.id,
  content: "Today, I greeted bob"
})



