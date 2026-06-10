defmodule PingPong.Service.HTTPTest do
  use ExUnit.Case, async: false

  setup do
    previous_options = Application.get_env(:req, :default_options, [])

    on_exit(fn ->
      Application.put_env(:req, :default_options, previous_options)
    end)

    :ok
  end

  test "posts JSON payload and returns successful response body" do
    Req.default_options(
      adapter: fn request ->
        assert request.method == :post
        assert request.url == URI.parse("https://example.test/messages")
        assert request.body == ~s({"message":"Ping!"})
        assert request.headers["accept"] == ["application/json"]

        assert request.headers["content-type"] == [
                 "application/json; charset=utf-8"
               ]

        {request, Req.Response.new(status: 200, body: %{"delivered" => true})}
      end
    )

    assert PingPong.Service.HTTP.post("https://example.test/messages", %{message: "Ping!"}) ==
             {:ok, %{"delivered" => true}}
  end

  test "accepts custom success status" do
    Req.default_options(
      adapter: fn request ->
        {request, Req.Response.new(status: 204, body: "")}
      end
    )

    assert PingPong.Service.HTTP.post("https://example.test/messages", %{message: "Ping!"}, 204) ==
             {:ok, ""}
  end

  test "returns error response body for non-success status" do
    Req.default_options(
      adapter: fn request ->
        {request, Req.Response.new(status: 400, body: %{"error" => "bad request"})}
      end
    )

    assert PingPong.Service.HTTP.post("https://example.test/messages", %{message: "Ping!"}) ==
             {:error, {:error_response, %{"error" => "bad request"}}}
  end

  test "returns transport error reason" do
    Req.default_options(
      adapter: fn request -> {request, %Req.TransportError{reason: :timeout}} end
    )

    assert PingPong.Service.HTTP.post("https://example.test/messages", %{message: "Ping!"}) ==
             {:error, {:error, :timeout}}
  end
end
