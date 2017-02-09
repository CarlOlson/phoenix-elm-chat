defmodule Chat.PageControllerTest do
  use Chat.ConnCase

  test "doesnt contain phoenix information", %{conn: conn} do
    conn = get conn, "/"

    text =
      html_response(conn, 200)
      |> Floki.parse()
      |> Floki.text
    refute text =~ ~r/phoenix/
  end
end
