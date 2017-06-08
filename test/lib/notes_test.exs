defmodule NotesTest do
  use ExUnit.Case

  test "adding notes" do
    Notes.add("Hallo")
    all = Notes.all
    assert List.first(all).text == "Hallo"
  end

  test "find" do
    Notes.add("Hallo")
    found = Notes.find("Hallo")
    assert List.first(found).text == "Hallo"
  end

  test "heute" do
    Notes.add("Hallo")
    all = Notes.all
    assert List.first(all).text == "Hallo"
  end

  test "completions includes a space" do
    Notes.add("Hallo")
    completions = Notes.completions
    assert List.first(completions) == "Hallo "
  end
end
