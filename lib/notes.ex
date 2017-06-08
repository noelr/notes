defmodule Notes do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def add(line) do
    GenServer.call(__MODULE__, {:add, line})
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def find(line) do
    GenServer.call(__MODULE__, {:find, line})
  end

  def stats(lines) do
    GenServer.call(__MODULE__, {:stats, lines})
  end

  def heute do
    GenServer.call(__MODULE__, :heute)
  end

  def persist do
    GenServer.call(__MODULE__, :persist)
  end

  def completions do
    GenServer.call(__MODULE__, :completions)
  end

  def init(_args) do
    {:ok, load}
  end

  def handle_call(:import, _from, _state) do
    {:reply, :ok, load}
  end

  def handle_call(:persist, _from, state) do
    lines = Enum.map state, fn(s) -> Poison.encode!(s) end
    File.write "store.json", Enum.join(lines, "\n")
    {:reply, :ok, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:find, line}, _from, state) do
    lines = Enum.filter(state, fn(l) -> l.text == line end)
    {:reply, lines, state}
  end

  def handle_call({:stats, lines}, _from, state) do
    count = Enum.count(lines)
    days = Enum.map lines, fn(l) -> l.timestamp end
    {:ok, first} = Enum.fetch(days, count - 1)
    {:ok, last} = Enum.fetch(days, 0)
    duration = Timex.diff(last, first, :days) + 1
    average = count / duration
    {:reply, %{count: count, duration: duration, average: average}, state}
  end

  def handle_call(:heute, _from, state) do
    now = DateTime.utc_now
    heute = Enum.filter(state, fn(line) ->
      d = line.timestamp
      d.year == now.year && d.month == now.month && d.day == now.day end
    )
    {:reply, heute, state}
  end

  def handle_call(:completions, _from, state) do
    completions = Enum.flat_map(state, fn(entry) -> command(entry) end) |> Enum.uniq
    {:reply, completions, state}
  end

  def handle_call({:add, ""}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:add, raw}, _from, state) do
    new_state = add_line(String.trim(raw), state)
    {:reply, :ok, new_state}
  end

  defp line_to_model(line) do
    s = Poison.decode!(line, keys: :atoms!)
    case DateTime.from_iso8601(s.timestamp) do
      {:ok, date, offset} -> %{timestamp: date, text: s.text}
      _ -> nil
    end
  end

  defp command(%{text: line}) do
    case String.split(line) do
      [w | r] -> ["#{w} ", line]
      _ -> ""
    end
  end

  defp add_line("", state) do
    state
  end

  defp add_line(raw, state) do
    line = raw
           |> timestamp
    new_state = [line | state]
  end

  defp load do
    {:ok, text} = File.read("store.json")
    String.split(text, "\n")
    |> Enum.map(fn(line) -> line_to_model(line) end)
    |> Enum.reject fn(x) -> is_nil(x) end
  end

  defp timestamp(line) do
    %{timestamp: DateTime.utc_now, text: line}
  end
end
