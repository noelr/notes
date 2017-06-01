defmodule Web.PageController do
  use Web.Web, :controller

  def index(conn, _params) do
    conn
    |> assign(:lines, Notes.all)
    |> assign(:heute, Notes.heute)
    |> assign(:completions, Notes.completions)
    |> render("index.html")
  end

  def create(conn, %{"note" => %{"line" => line}}) do
    Notes.add(line)
    Notes.persist
    conn
    |> redirect(to: "/")
  end
end
