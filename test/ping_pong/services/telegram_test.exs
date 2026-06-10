defmodule PingPong.Service.TelegramTest do
  use ExUnit.Case, async: false

  @missing_error {:error, {:missing_required_params}, nil}

  setup do
    previous_options = Application.get_env(:req, :default_options, [])

    on_exit(fn ->
      Application.put_env(:req, :default_options, previous_options)
    end)

    :ok
  end

  test "requires content, chat_id, and token" do
    invalid_cases = [
      {nil, %{token: "token"}},
      {%{}, %{token: "token"}},
      {%{content: "hello"}, %{token: "token"}},
      {%{chat_id: "123"}, %{token: "token"}},
      {%{content: "hello", chat_id: "123"}, nil},
      {%{content: "hello", chat_id: "123"}, %{}},
      {%{content: "hello", chat_id: "123"}, %{api_key: "token"}}
    ]

    for {payload, options} <- invalid_cases do
      assert PingPong.Service.Telegram.call(payload, options) == @missing_error
    end
  end

  test "posts sendMessage request with chat id and text" do
    Req.default_options(
      adapter: fn request ->
        assert request.url == URI.parse("https://api.telegram.org/botsecret-token/sendMessage")

        assert JSON.decode!(request.body) == %{
                 "chat_id" => "123",
                 "text" => "hello telegram"
               }

        {request,
         Req.Response.new(status: 200, body: %{"ok" => true, "result" => %{"message_id" => 42}})}
      end
    )

    assert PingPong.Service.Telegram.call(
             %{content: "hello telegram", chat_id: "123"},
             %{token: "secret-token"}
           ) == {:ok, %{"ok" => true, "result" => %{"message_id" => 42}}}
  end

  test "returns HTTP errors from Telegram API" do
    Req.default_options(
      adapter: fn request ->
        {request,
         Req.Response.new(
           status: 429,
           body: %{"ok" => false, "description" => "too many requests"}
         )}
      end
    )

    assert PingPong.Service.Telegram.call(
             %{content: "hello telegram", chat_id: "123"},
             %{token: "secret-token"}
           ) ==
             {:error, {:error_response, %{"description" => "too many requests", "ok" => false}}}
  end
end
