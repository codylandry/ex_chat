#!/usr/bin/env bash
# exit on error
set -o errexit

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
npm install --prefix ./apps/ex_chat_web/assets
npm run deploy --prefix ./apps/ex_chat_web/assets
mix phx.digest

# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite

MIX_ENV=prod mix ecto.migrate