defmodule Web.PageControllerTest do
  use Web.ConnCase

  test "GET /", %{conn: conn} do
    Notes.add("Hallo")
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hallo"
  end

  test "GET /stats/Hallo", %{conn: conn} do
    Notes.add("Hallo")
    conn = get conn, "/stats/Hallo"
    assert html_response(conn, 200) =~ "Hallo"
  end

  test "POST /", %{conn: conn} do
    conn = post conn, "/", %{"note" => %{"line" => "Hallo Test"}}
    assert redirected_to(conn) =~ "/"
  end
end
