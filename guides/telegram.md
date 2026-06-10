# Telegram Guide

PingPong sends Telegram notifications through the Telegram Bot API. You need a
bot token and the target chat ID.

## Create a Bot

1. Open Telegram and start a chat with `@BotFather`.
2. Send `/newbot`.
3. Follow the prompts to choose a bot name and username.
4. Copy the bot token that BotFather gives you.

Keep the token private. Anyone with the token can use your bot.

## Find a Chat ID

For a direct message:

1. Start a chat with your new bot.
2. Send any message to the bot.
3. Open this URL in a browser, replacing `BOT_TOKEN`:

```text
https://api.telegram.org/botBOT_TOKEN/getUpdates
```

Look for `message.chat.id` in the JSON response.

For a group:

1. Add the bot to the group.
2. Send a message in the group.
3. Call `getUpdates` with the bot token.
4. Use the group `chat.id`. Group IDs are often negative numbers.

## Send a Message

Use service `:telegram`.

```elixir
token = "123456:telegram-bot-token"
chat_id = "123456789"

PingPong.send(
  :telegram,
  %{content: "The nightly build completed successfully.", chat_id: chat_id},
  %{token: token}
)
```

A successful response usually looks like:

```elixir
{:ok, %{"ok" => true, "result" => result}}
```

Message preview:

![Telegram message preview](static/telegram.png)

## Payload

Telegram requires `:content` and `:chat_id`.

```elixir
%{
  content: "Message text",
  chat_id: "123456789"
}
```

PingPong sends `:content` to Telegram as the `text` field.

## Options

Telegram requires `:token`.

```elixir
%{token: "123456:telegram-bot-token"}
```

## Async Example

```elixir
{:ok, task} =
  PingPong.send_async(
    :telegram,
    %{content: "Background job started.", chat_id: chat_id},
    %{token: token}
  )

Task.await(task)
```

## Multiple Notifications

```elixir
notifications = [
  admins: {:telegram, %{content: "Deploy started.", chat_id: admin_chat_id}, %{token: token}},
  alerts: {:telegram, %{content: "Disk usage is high.", chat_id: alerts_chat_id}, %{token: token}}
]

PingPong.send_multiple(notifications)
```

## Common Errors

Missing `:content`, `:chat_id`, or `:token`:

```elixir
{:error, {:missing_required_params}, nil}
```

Unknown service key:

```elixir
{:error, {:unknown_service, :telegram_bot}}
```

Telegram API error:

```elixir
{:error, {:error_response, response}}
```

Transport error:

```elixir
{:error, {:error, reason}}
```

## Troubleshooting

- Make sure the bot token is copied exactly from BotFather.
- Make sure the user or group has sent at least one message after the bot was
  created or added.
- For groups, make sure the bot is still a member of the group.
- If Telegram returns an error response, inspect the response body for the API
  description.
- Do not commit bot tokens. Load them from runtime config or environment
  variables in real applications.
