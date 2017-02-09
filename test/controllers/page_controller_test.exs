defmodule Chat.PageControllerTest do
  use Chat.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"

    text =
      html_response(conn, 200)
      |> Floki.parse()
      |> Floki.text
    assert text =~ "Welcome to Phoenix!"
  end
end
