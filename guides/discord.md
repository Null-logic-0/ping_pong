# Discord Guide

PingPong sends Discord notifications with incoming webhooks. A webhook belongs
to one channel and lets PingPong post messages without a bot user.

## Create a Webhook

1. Open Discord and choose the server.
2. Open the channel where notifications should appear.
3. Go to `Edit Channel` > `Integrations` > `Webhooks`.
4. Create a webhook, choose its name and channel, then copy the webhook URL.

Keep the webhook URL private. Anyone with the URL can post to that channel.

## Send a Message

Use service `:discord`.

```elixir
webhook = "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN"

PingPong.send(
  :discord,
  %{content: "The nightly build completed successfully."},
  %{webhook: webhook}
)
```

Discord accepts a successful webhook post with HTTP status `204`, so the result
is usually:

```elixir
{:ok, ""}
```

Message preview:

![Discord message preview](static/discord.png)

## Payload

Discord requires `:content`.

```elixir
%{content: "Message text"}
```

## Options

Discord requires `:webhook`.

```elixir
%{webhook: "https://discord.com/api/webhooks/..."}
```

## Async Example

```elixir
{:ok, task} =
  PingPong.send_async(
    :discord,
    %{content: "Background job started."},
    %{webhook: webhook}
  )

Task.await(task)
```

## Multiple Notifications

```elixir
notifications = [
  deploys: {:discord, %{content: "Deploy started."}, %{webhook: deploys_webhook}},
  alerts: {:discord, %{content: "Disk usage is high."}, %{webhook: alerts_webhook}}
]

PingPong.send_multiple(notifications)
```

## Common Errors

Missing `:content` or `:webhook`:

```elixir
{:error, {:missing_required_params}, nil}
```

Unknown service key:

```elixir
{:error, {:unknown_service, :discord_bot}}
```

Discord API error:

```elixir
{:error, {:error_response, response}}
```

Transport error:

```elixir
{:error, {:error, reason}}
```

## Troubleshooting

- Make sure the webhook URL was copied completely.
- Make sure the channel and webhook still exist.
- If Discord returns an error response, inspect the response body for the API
  message.
- Do not commit webhook URLs. Load them from runtime config or environment
  variables in real applications.
