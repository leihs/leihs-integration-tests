step "the inventory pool has the following workdays:" do |table|
  attrs = {}
  table.rows.each do |day, info, open|
    attrs[day] = case open
    when "true" then true
    when "false" then false
    end
    attrs["#{day}_info"] = info
  end

  @pool.workday.update(attrs)
end

step "the inventory pool has the following holidays:" do |table|
  table.rows.each do |name, start_date, end_date|
    FactoryBot.create(:holiday,
      name: name,
      start_date: eval(start_date),
      end_date: eval(end_date),
      inventory_pool_id: @pool.id)
  end
end

step "the inventory pool has received mails enabled" do
  @pool.update(deliver_received_order_emails: true)
end

step "I visit the borrow page for model :name" do |name|
  visit "/borrow/models/#{LeihsModel.find(product: name).id}"
end

step "as start date I choose the next monday" do
  @next_monday = Date.today.next_occurring(:monday)
  fill_in "startDate", with: @next_monday.strftime("%d/%m/%Y")
end

step "as end date I choose the tuesday after that" do
  fill_in "endDate", with: (@next_monday + 3.day).strftime("%d/%m/%Y")
end

step "I add :var variable to the :tmpl template of locale :locale of the pool" do |var, tmpl, locale|
  tmpl = MailTemplate.find(inventory_pool_id: @pool.id,
    language_locale: locale,
    name: tmpl)
  visit "/admin/inventory-pools/#{@pool.id}/mail-templates/#{tmpl.id}"
  click_on "Edit"
  old = find("#body").value
  new = old.concat("\n#{var}-TITLE\n{{ #{var} }}")
  fill_in "body", with: new
  click_on "Save"
end

step "I visit the orders page of the pool in legacy" do
  visit "/manage/#{@pool.id}/orders"
end

step "I approve the order" do
  find("a[data-order-approve]").click
end

step "the email with subject :subject contains correct workdays according to locale :locale" do |subject, locale|
  email = Email.find(subject: subject)
  body = ["inventory_pool.workdays-TITLE"]
  days = {"monday" => {"en-GB" => "Monday", "de-CH" => "Montag"},
          "tuesday" => {"en-GB" => "Tuesday", "de-CH" => "Dienstag"},
          "wednesday" => {"en-GB" => "Wednesday", "de-CH" => "Mittwoch"},
          "thursday" => {"en-GB" => "Thursday", "de-CH" => "Donnerstag"},
          "friday" => {"en-GB" => "Friday", "de-CH" => "Freitag"},
          "saturday" => {"en-GB" => "Saturday", "de-CH" => "Samstag"},
          "sunday" => {"en-GB" => "Sunday", "de-CH" => "Sonntag"}}
  closed = {"en-GB" => "closed", "de-CH" => "geschlossen"}

  wd = @pool.workday
  days.keys.each do |day|
    body << "#{days[day][locale]}: #{wd.send(day) ? wd.send(:"#{day}_info") : closed[locale]}"
  end
  expect(email.body).to include(body.join("\n"))
end

step "the email with subject :subject contains correct holidays according to locale :locale" do |subject, locale|
  email = Email.find(subject: subject)
  body = ["inventory_pool.holidays-TITLE"]
  formats = {"en-GB" => {"default" => "%d/%m/%Y", "short" => "%d/%m"},
             "de-CH" => {"default" => "%d.%m.%Y", "short" => "%d.%m"}}

  @pool.holidays.each do |hday|
    span = if hday.start_date == hday.end_date
      hday.start_date.strftime(formats[locale]["default"])
    else
      "#{hday.start_date.strftime(formats[locale]["short"])}\u2013#{hday.end_date.strftime(formats[locale]["default"])}"
    end
    body << "#{hday.name}: #{span}"
  end
  expect(email.body).to include(body.join("\n"))
end

step "the user's language locale is :locale" do |locale|
  @user.update(language_locale: locale)
end
