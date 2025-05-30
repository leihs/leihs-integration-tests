def find_date_in_borrow_calendar(date, months_ahead: 12)
  counter = 1
  while Date::MONTHNAMES[date.month] != find(".rdrMonthAndYearPickers").text.split.first
    find(".rdrNextButton").click
    counter += 1
  end
  find(".cal-day", text: date.day, match: :prefer_exact)
end
