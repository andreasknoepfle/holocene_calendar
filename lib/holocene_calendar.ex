defmodule HoloceneCalendar do
  @moduledoc """
  A calendar implementation of the holocene calendar.
  See https://en.wikipedia.org/wiki/Holocene_calendar.

  The holocene or human calendar adds an extra 10.000 years to the default
  ISO calendar.
  The implementation uses Calendar.ISO internally.

  Examples:

      iex> ~D[2019-01-01] |> Date.convert(HoloceneCalendar)
      {:ok, %Date{calendar: HoloceneCalendar, day: 1, month: 1, year: 12019}}

      iex> ~D[-9999-01-01] |> Date.convert(HoloceneCalendar)
      {:ok, %Date{calendar: HoloceneCalendar, day: 1, month: 1, year: 1}}

      iex> %Date{calendar: HoloceneCalendar, day: 1, month: 1, year: 12019} |> Date.to_string
      "12019-01-01"
  """

  alias Calendar.ISO

  @behaviour Calendar

  @type year :: 1..19999
  @type era :: 0
  @holocene_years 10_000
  @iso_era_day_offset 3_652_425

  @impl true
  defdelegate time_to_string(hour, minute, second, microsecond), to: ISO

  @impl true
  defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: ISO

  @impl true
  defdelegate time_from_day_fraction(day_fraction), to: ISO

  @impl true
  defdelegate day_rollover_relative_to_midnight_utc(), to: ISO

  @impl true
  defdelegate valid_time?(hour, minute, second, microsecond), to: ISO

  @impl true
  defdelegate months_in_year(year), to: ISO

  @impl true
  @spec days_in_month(year, ISO.month()) :: ISO.day()
  def days_in_month(year, month) do
    ISO.days_in_month(year - @holocene_years, month)
  end

  @impl true
  @spec leap_year?(year) :: boolean
  def leap_year?(year), do: ISO.leap_year?(year - @holocene_years)

  @spec day_of_year(year, ISO.month(), ISO.day()) :: 1..366
  @impl true
  def day_of_year(year, month, day) do
    ISO.day_of_year(year - @holocene_years, month, day)
  end

  @impl true
  @spec day_of_week(year, ISO.month(), ISO.day()) :: ISO.day_of_week()
  def day_of_week(year, month, day) do
    ISO.day_of_week(year - @holocene_years, month, day)
  end

  @impl true
  @spec date_to_string(year, ISO.month(), ISO.day()) :: String.t()
  def date_to_string(year, month, day) do
    zero_pad(year, 5) <> "-" <> zero_pad(month, 2) <> "-" <> zero_pad(day, 2)
  end

  @impl true
  @spec naive_datetime_to_string(
          year,
          ISO.month(),
          ISO.day(),
          ISO.hour(),
          ISO.minute(),
          ISO.second(),
          ISO.microsecond()
        ) ::
          String.t()
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
    date_to_string(year, month, day) <> " " <> time_to_string(hour, minute, second, microsecond)
  end

  @impl true
  @spec datetime_to_string(
          year,
          ISO.month(),
          ISO.day(),
          Calendar.hour(),
          Calendar.minute(),
          Calendar.second(),
          Calendar.microsecond(),
          Calendar.time_zone(),
          Calendar.zone_abbr(),
          Calendar.utc_offset(),
          Calendar.std_offset()
        ) :: String.t()
  def datetime_to_string(
        year,
        month,
        day,
        hour,
        minute,
        second,
        microsecond,
        time_zone,
        zone_abbr,
        utc_offset,
        std_offset
      ) do
    date_to_string(year, month, day) <>
      " " <>
      ISO.time_to_string(hour, minute, second, microsecond) <>
      offset_to_string(utc_offset, std_offset, time_zone) <>
      zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  end

  @impl true
  @spec naive_datetime_to_iso_days(
          year,
          ISO.month(),
          ISO.day(),
          Calendar.hour(),
          Calendar.minute(),
          Calendar.second(),
          Calendar.microsecond()
        ) :: Calendar.iso_days()
  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
    ISO.naive_datetime_to_iso_days(
      year - @holocene_years,
      month,
      day,
      hour,
      minute,
      second,
      microsecond
    )
  end

  @impl true
  @spec naive_datetime_from_iso_days(Calendar.iso_days()) ::
          {year, ISO.month(), ISO.day(), Calendar.hour(), Calendar.minute(), Calendar.second(),
           Calendar.microsecond()}
  def naive_datetime_from_iso_days(iso_days) do
    {year, month, day, hour, minute, second, microsecond} =
      ISO.naive_datetime_from_iso_days(iso_days)

    {year + @holocene_years, month, day, hour, minute, second, microsecond}
  end

  @impl true
  @spec valid_date?(year, ISO.month(), ISO.day()) :: boolean
  def valid_date?(year, month, day), do: ISO.valid_date?(year - @holocene_years, month, day)

  @impl true
  @spec quarter_of_year(year, ISO.month(), ISO.day()) :: 1..4
  def quarter_of_year(year, month, day) do
    ISO.quarter_of_year(year - @holocene_years, month, day)
  end

  @spec year_of_era(year) :: {year, era}
  @impl true
  def year_of_era(year) when is_integer(year) and year >= 0, do: {year, 0}

  @impl true
  @spec day_of_era(year, ISO.month(), ISO.day()) :: {day :: pos_integer(), era}
  def day_of_era(year, month, day) do
    era_day =
      case ISO.day_of_era(year - @holocene_years, month, day) do
        {day, 0} -> @iso_era_day_offset - day + 1
        {day, 1} -> @iso_era_day_offset + day
      end

    {era_day, 0}
  end

  # Helpers

  defp zero_pad(number, count) do
    number
    |> Integer.to_string()
    |> String.pad_leading(count, "0")
  end

  # Helpers inspired by Calendar.ISO private functions

  defp offset_to_string(0, 0, "Etc/UTC"), do: "Z"

  defp offset_to_string(utc, std, _zone) do
    total = utc + std
    second = abs(total)
    minute = second |> rem(3600) |> div(60)
    hour = div(second, 3600)
    format_offset(total, hour, minute)
  end

  defp format_offset(total, hour, minute) do
    sign(total) <> zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2)
  end

  defp sign(total) when total < 0, do: "-"
  defp sign(_), do: "+"

  defp zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  defp zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone
end
