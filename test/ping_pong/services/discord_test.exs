defmodule PingPong.Service.DiscordTest do
  use ExUnit.Case, async: false

  @missing_error {:error, {:missing_required_params}, nil}

  setup do
    previous_options = Application.get_env(:req, :default_options, [])

    on_exit(fn ->
      Application.put_env(:req, :default_options, previous_options)
    end)

    :ok
  end

  test "requires content and webhook" do
    invalid_cases = [
      {nil, %{webhook: "https://discord.test/webhook"}},
      {%{}, %{webhook: "https://discord.test/webhook"}},
      {%{content: "hello"}, nil},
      {%{content: "hello"}, %{}},
      {%{text: "hello"}, %{webhook: "https://discord.test/webhook"}},
      {%{content: "hello"}, %{url: "https://discord.test/webhook"}}
    ]

    for {payload, options} <- invalid_cases do
      assert PingPong.Service.Discord.call(payload, options) == @missing_error
    end
  end

  test "posts content to webhook and accepts Discord's 204 response" do
    Req.default_options(
      adapter: fn request ->
        assert request.url == URI.parse("https://discord.test/webhook")
        assert request.body == ~s({"content":"hello discord"})

        {request, Req.Response.new(status: 204, body: "")}
      end
    )

    assert PingPong.Service.Discord.call(
             %{content: "hello discord"},
             %{webhook: "https://discord.test/webhook"}
           ) == {:ok, ""}
  end

  test "returns HTTP errors from webhook call" do
    Req.default_options(
      adapter: fn request ->
        {request, Req.Response.new(status: 401, body: %{"message" => "unauthorized"})}
      end
    )

    assert PingPong.Service.Discord.call(
             %{content: "hello discord"},
             %{webhook: "https://discord.test/webhook"}
           ) == {:error, {:error_response, %{"message" => "unauthorized"}}}
  end
end
