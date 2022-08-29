# ExChat

This is a toy realtime chat app. The goal is to learn:

- [Elixir](https://elixir-lang.org/)
- [OTP](https://dev.to/lgdev07/elixir-otp-basics-with-project-example-19hg)
- [Ecto](https://hexdocs.pm/ecto/Ecto.html)
- [Phoenix](https://www.phoenixframework.org/)
  - [LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)

## Progress:

- [ ] In memory OTP backend
  - Supervision tree done.
  - Channel genserver done
  - Channel dynamic supervisor done
  - Need to apply db models.
- [ ] Database abstraction layer
  - Nearly done, need to wire up to OTP backend
  - added db migrations, structs, context modules
  - added db seed file for dev
- [ ] Phoenix LiveView Frontend
  - Not started
  - [tailwind??](https://tailwindcss.com/)
  - [alpinejs??](https://alpinejs.dev/)
- [ ] Deployed
  - [fly.io?](https://fly.io/)
  - [gigalixir?](https://www.gigalixir.com/)
