# PingPong

![PingPong](static/ping_pong.png)

PingPong is a small Elixir notification library for sending messages through
multiple services with one consistent API.

Built-in services:

- `:discord` - sends messages to a Discord webhook
- `:telegram` - sends messages through a Telegram bot
- `:mock` - local test service that replies to `%{message: "Ping!"}`

## Installation

Add `ping_pong` to your dependencies:

```elixir
def deps do
  [
    {:ping_pong, "~> 0.1.0"}
  ]
end
```

Then fetch dependencies:

```sh
mix deps.get
```

PingPong starts a `Task.Supervisor` with the application, so async delivery
works when the OTP application is running.

## Quick Start

Send a notification synchronously:

```elixir
PingPong.send(:mock, %{message: "Ping!"}, %{})
```

Successful calls return `{:ok, response}`. Failed calls return
`{:error, {reason, detail}}` or a service-specific error tuple.

## Discord

Discord messages use a webhook URL.

```elixir
PingPong.send(
  :discord,
  %{content: "Deploy finished successfully"},
  %{webhook: "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN"}
)
```

Required payload:

```elixir
%{content: "Message text"}
```

Required options:

```elixir
%{webhook: "Discord webhook URL"}
```

See [guides/discord.md](guides/discord.md) for setup steps and examples.

## Telegram

Telegram messages use a bot token and a chat ID.

```elixir
PingPong.send(
  :telegram,
  %{content: "Deploy finished successfully", chat_id: "123456789"},
  %{token: "123456:telegram-bot-token"}
)
```

Required payload:

```elixir
%{
  content: "Message text",
  chat_id: "Telegram chat ID"
}
```

Required options:

```elixir
%{token: "Telegram bot token"}
```

See [guides/telegram.md](guides/telegram.md) for bot setup and examples.

## Async Delivery

Use `send_async/3` when you want a task instead of blocking on the service
response.

```elixir
{:ok, task} =
  PingPong.send_async(
    :mock,
    %{message: "Ping!"},
    %{}
  )

Task.await(task)
```

Unknown services still return immediately:

```elixir
PingPong.send_async(:unknown, %{}, %{})
#=> {:error, {:unknown_service, :unknown}}
```

## Multiple Notifications

Use `send_multiple/1` to send a list of named notifications. Each notification
is a `{service, payload, options}` tuple.

```elixir
notifications = [
  ops: {:discord, %{content: "Build passed"}, %{webhook: discord_webhook}},
  team: {:telegram, %{content: "Build passed", chat_id: chat_id}, %{token: bot_token}}
]

PingPong.send_multiple(notifications)
```

The return value preserves the IDs:

```elixir
[
  ops: {:ok, ""},
  team: {:ok, %{"ok" => true}}
]
```

## Error Handling

Common errors:

```elixir
{:error, {:unknown_service, service}}
{:error, {:missing_required_params}, nil}
{:error, {:error_response, response}}
{:error, {:error, reason}}
```

For production apps, handle both success and error tuples explicitly:

```elixir
case PingPong.send(:discord, payload, options) do
  {:ok, response} ->
    {:ok, response}

  {:error, reason} ->
    Logger.warning("Notification failed: #{inspect(reason)}")
    {:error, reason}
end
```

## Custom Services

Custom services implement `PingPong.ServiceBehaviour` and can be registered in
application config.

```elixir
defmodule MyApp.EmailService do
  @behaviour PingPong.ServiceBehaviour

  @impl true
  def call(payload, options) do
    # deliver notification here
    {:ok, %{payload: payload, options: options}}
  end
end
```

Register the service:

```elixir
config :ping_pong,
  services: [
    email: MyApp.EmailService
  ]
```

Then send with the custom service key:

```elixir
PingPong.send(:email, %{subject: "Hello"}, %{to: "team@example.com"})
```

## Development

Run the test suite:

```sh
mix test
```

Format code:

```sh
mix format
```

## Contributing

Contributions are welcome. A good contribution usually starts with a small,
focused issue or pull request.

Before opening a pull request:

1. Fork the repository.
2. Create a feature branch.
3. Add or update tests for your change.
4. Run the test suite with `mix test`.
5. Format the code with `mix format`.
6. Describe what changed and why in the pull request.

For new notification services, implement `PingPong.ServiceBehaviour`, add the
service to the registry or configuration examples, and include tests for
success, validation errors, and HTTP/API failures.

## Support

If PingPong helps you, you can support the project here:

- [Ko-fi](https://ko-fi.com/lukatchelidze)
- [PayPal](https://www.paypal.com/paypalme/LukaTchlidze)

## License

PingPong is released under the MIT License. See [LICENSE](LICENSE) for details.
