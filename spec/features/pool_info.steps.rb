def click_on_toggle(id)
  page.execute_script("document.getElementById('#{id}').click()")
end

step "I click on :target within :cont" do |target, cont|
  within(id: cont.downcase) { click_on target }
end

step "I mark :day as closed" do |day|
  within ".modal" do
    click_on_toggle "#{day.downcase}-switch"
  end
end

step "I set Hours Info for :day to :txt" do |day, txt|
  within ".modal" do
    find("tr", text: day).find("input[type='text']").set txt
  end
end

step ":day is :open_closed and has :txt as hours info" do |day, open_closed, txt|
  within("#workdays") do
    within find("tr", text: day) do
      on_off = case open_closed
      when "open" then "on"
      when "closed" then "off"
      end
      expect(current_scope).to have_selector(".fa-toggle-#{on_off}")
      expect(current_scope).to have_content(txt)
    end
  end
end

step ":day is :open_closed and has no hours info" do |day, open_closed|
  within("#workdays") do
    within find("tr", text: day) do
      on_off = case open_closed
      when "open" then "on"
      when "closed" then "off"
      end
      expect(current_scope).to have_selector(".fa-toggle-#{on_off}")
      expect(current_scope).to have_content("#{day} unlimited")
    end
  end
end

step "for :day there is a message :txt" do |day, txt|
  expect(find("#opening-times .row", text: day).text)
    .to eq "#{day}\n#{txt}"
end

step "for :day there is no message" do |day|
  expect(find("#opening-times .row", text: day).text)
    .to eq day.to_s
end

step "I click on inventory pool :name" do |name|
  find(".ui-list-card", text: name).click
end

step "I add a past holiday :name" do |name|
  within ".modal" do
    find("input[placeholder='Name']").set name
    find("input#start-date").set (Date.today - 2.days).strftime
    find("input#end-date").set (Date.today - 1.day).strftime
    click_on "Add"
  end
end

step "I add a current holiday :name" do |name|
  within ".modal" do
    find("input[placeholder='Name']").set name
    find("input#start-date").set Date.today.strftime
    find("input#end-date").set (Date.today + 1.day).strftime
    click_on("Add")
  end
end

step "I add a future holiday :name" do |name|
  within ".modal" do
    find("input[placeholder='Name']").set name
    find("input#start-date").set (Date.today + 1.day).strftime
    find("input#end-date").set (Date.today + 2.days).strftime
    click_on("Add")
  end
end

step "I see a holiday :name" do |name|
  within "#holidays" do
    expect(current_scope).to have_content(name)
  end
end

step "there is holiday :name" do |name|
  within "#holidays" do
    expect(current_scope).to have_content(name)
  end
end

step "I fill in :id with" do |id, txt|
  fill_in id, with: txt
end

step "the column :class_name has text" do |class_name, txt|
  expect(find("td.#{class_name}").text).to eq txt
end

step "there is contact information text for pool :name" do |name, txt|
  @searched_pool = InventoryPool.find(name: name)
  expect(@searched_pool).not_to be_nil, "Pool with name '#{name}' not found"

  expected_email = @searched_pool.email
  expect(expected_email).not_to be_nil, "Email for pool '#{name}' not found"

  contact_section = find("section", text: "Contact").text
  expect(contact_section).to include("Contact\n#{expected_email}\n#{txt}")
end

step "there is contact information text" do |txt|
  expect(find("section", text: "Contact").text).to eq "Contact\n#{txt}"
end
