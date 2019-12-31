defmodule HoloceneCalendarTest do
  use ExUnit.Case
  doctest HoloceneCalendar

  describe "days_in_month/2" do
    test "delegates to ISO calendar with 10,000 years difference" do
      Enum.each(1..12, fn month ->
        assert HoloceneCalendar.days_in_month(12021, month) ==
                 Calendar.ISO.days_in_month(2021, month)

        assert HoloceneCalendar.days_in_month(12020, month) ==
                 Calendar.ISO.days_in_month(2020, month)
      end)
    end
  end

  describe "leap_year?/1" do
    test "delegates to ISO calendar with 10,000 years difference" do
      assert HoloceneCalendar.leap_year?(12021) == false
      assert HoloceneCalendar.leap_year?(12020) == true
    end
  end

  describe "day_of_week/3" do
    test "delegates to ISO calendar with 10,000 years difference" do
      assert HoloceneCalendar.day_of_week(12021, 3, 22) == Calendar.ISO.day_of_week(2021, 3, 22)
      assert HoloceneCalendar.day_of_week(12020, 2, 29) == Calendar.ISO.day_of_week(2020, 2, 29)
    end
  end

  describe "date_to_string/3" do
    test "formats the date with leading zeros and 5 digits for the year" do
      assert HoloceneCalendar.date_to_string(1, 1, 1) == "00001-01-01"
      assert HoloceneCalendar.date_to_string(12020, 12, 31) == "12020-12-31"
    end
  end

  describe "naive_datetime_to_string/7" do
    test "formats the date with leading zeros and 5 digits for the year" do
      assert HoloceneCalendar.naive_datetime_to_string(1, 1, 1, 1, 1, 1, {4, 6}) ==
               "00001-01-01 01:01:01.000004"

      assert HoloceneCalendar.naive_datetime_to_string(12020, 12, 31, 23, 59, 59, {999_999, 2}) ==
               "12020-12-31 23:59:59.99"
    end
  end

  describe "datetime_to_string/12" do
    test "formats the date with leading zeros and 5 digits for the year" do
      assert HoloceneCalendar.datetime_to_string(
               12019,
               8,
               1,
               1,
               2,
               3,
               {4, 5},
               "Europe/Berlin",
               "CET",
               3600,
               0
             ) ==
               "12019-08-01 01:02:03.00000+01:00 CET Europe/Berlin"
    end

    test "UTC times" do
      assert HoloceneCalendar.datetime_to_string(
               12019,
               8,
               1,
               1,
               2,
               3,
               {4, 5},
               "Etc/UTC",
               "UTC",
               0,
               0
             ) ==
               "12019-08-01 01:02:03.00000Z"
    end

    test "negative offset timezone" do
      assert HoloceneCalendar.datetime_to_string(
               12019,
               2,
               28,
               1,
               2,
               3,
               {4, 5},
               "America/Los_Angeles",
               "PDT",
               -28800,
               3600
             ) ==
               "12019-02-28 01:02:03.00000-07:00 PDT America/Los_Angeles"
    end
  end

  describe "naive_datetime_to_iso_days/7" do
    test "delegates to ISO calendar with 10,000 years difference" do
      assert HoloceneCalendar.naive_datetime_to_iso_days(1, 1, 1, 0, 0, 0, {0, 6}) ==
               {-3_652_059, {0, 86_400_000_000}}

      assert HoloceneCalendar.naive_datetime_to_iso_days(12000, 1, 1, 12, 0, 0, {0, 6}) ==
               {730_485, {43_200_000_000, 86_400_000_000}}

      assert HoloceneCalendar.naive_datetime_to_iso_days(12000, 1, 1, 13, 0, 0, {0, 6}) ==
               {730_485, {46_800_000_000, 86_400_000_000}}

      assert HoloceneCalendar.naive_datetime_to_iso_days(9999, 1, 1, 0, 0, 0, {0, 6}) ==
               {-365, {0, 86_400_000_000}}
    end
  end

  describe "naive_datetime_from_iso_days/1" do
    test "delegates to ISO calendar with 10,000 years difference" do
      assert HoloceneCalendar.naive_datetime_from_iso_days({0, {0, 86400}}) ==
               {10_000, 1, 1, 0, 0, 0, {0, 6}}

      assert HoloceneCalendar.naive_datetime_from_iso_days({730_485, {0, 86400}}) ==
               {12_000, 1, 1, 0, 0, 0, {0, 6}}

      assert HoloceneCalendar.naive_datetime_from_iso_days({730_485, {43200, 86400}}) ==
               {12_000, 1, 1, 12, 0, 0, {0, 6}}

      assert HoloceneCalendar.naive_datetime_from_iso_days({-365, {0, 86_400_000_000}}) ==
               {9999, 1, 1, 0, 0, 0, {0, 6}}
    end
  end

  describe "valid_date?/3" do
    test "delegates to ISO calendar with 10,000 years difference" do
      assert HoloceneCalendar.valid_date?(12015, 2, 28) == true
      assert HoloceneCalendar.valid_date?(12015, 2, 30) == false
      assert HoloceneCalendar.valid_date?(1, 12, 31) == true
      assert HoloceneCalendar.valid_date?(1, 12, 32) == false
    end
  end

  describe "quarter_of_year/3" do
    test "delegates to ISO calendar with 10,000 years difference" do
      assert HoloceneCalendar.quarter_of_year(12_016, 1, 31) == 1
      assert HoloceneCalendar.quarter_of_year(12_016, 4, 3) == 2
      assert HoloceneCalendar.quarter_of_year(1, 9, 31) == 3
      assert HoloceneCalendar.quarter_of_year(12_018, 12, 28) == 4
    end
  end

  describe "year_of_era/1" do
    test "always returns the era 0 with the year" do
      assert HoloceneCalendar.year_of_era(1) == {1, 0}
      assert HoloceneCalendar.year_of_era(12_020) == {12_020, 0}
    end
  end

  describe "day_of_era/3" do
    test "before 10,000 HE" do
      assert HoloceneCalendar.day_of_era(1, 1, 1) == {1, 0}
      assert HoloceneCalendar.day_of_era(9999, 12, 31) == {3_652_059, 0}
    end

    test "after 10,000 HE" do
      assert HoloceneCalendar.day_of_era(10_000, 1, 1) == {3_652_060, 0}
      assert HoloceneCalendar.day_of_era(12_020, 5, 28) == {4_389_998, 0}
    end
  end
end
