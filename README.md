[![CircleCI](https://circleci.com/gh/andreasknoepfle/holocene_calendar.svg?style=svg)](https://circleci.com/gh/andreasknoepfle/holocene_calendar)
# HoloceneCalendar

This is a elixir implementation of the [holocene calendar](https://en.wikipedia.org/wiki/Holocene_calendar),
a calendar system for humans. If you do not yet know what the holocene calendar is I recommend watching
[this](https://www.youtube.com/watch?v=czgOWmtGVGs) video from kurzgesagt.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `holocene_calendar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:holocene_calendar, "~> 0.1.0"}
  ]
end
```

## Usage

Converting a `Date` from the ISO calendar implementation to the holocene calendar:
```elixir
iex> ~D[2019-01-01] |> Date.convert(HoloceneCalendar)
{:ok, %Date{calendar: HoloceneCalendar, day: 1, month: 1, year: 12019}}
```

Or use it directly:
```elixir
iex> %Date{calendar: HoloceneCalendar, day: 1, month: 1, year: 12019} |> Date.to_string
"12019-01-01"
```

Also have a look into the [Calendar](https://hexdocs.pm/elixir/1.9.0/Calendar.html#content) behaviour
to get more infos on what you can do with this calendar implementation.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/holocene_calendar](https://hexdocs.pm/holocene_calendar).
