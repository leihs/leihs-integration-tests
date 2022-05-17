step "I choose to filter by availability" do
  check("Show available only")
end

step "I see one model with the title :name" do |name|
  expect(all(".ui-models-list-item").count).to eq 1
  find(".ui-models-list-item", text: name)
end

step "I filter by :n available item(s) from :start_date to :end_date" do |n, start_date, end_date|
  step "I click on \"Filter\""
  step "I choose to filter by availability"
  step "I enter the date \"#{start_date}\" in the \"From\" field"
  step "I enter the date \"#{end_date}\" in the \"Until\" field"
  step "I enter \"#{n}\" in the \"Quantity\" field"
  step "I click button \"Apply\""
end

step "I clear ls from the borrow app-db" do
  visit "/app/borrow/debug"
  click_on("Clear :ls")
end

# == Leihs Classic

step "I classic click on category :name" do |name|
  find("h2", text: name).click()
end

step "I classic filter by date :start_date to :end_date" do |start_date, end_date|
  step "I enter the date \"#{start_date}\" in the \"Start date\" field"
  step "I enter the date \"#{end_date}\" in the \"End date\" field"
end

def find_one_model_line(model_name)
  sleep(1) # because there is flicker of old content
  lines = all("#model-list a")
  expect(lines.count).to eq 1
  expect(lines[0].find("div", text: model_name)).to be
  lines[0]
end

step "I classic see one model :model_name being grayed out" do |model_name|
  line = find_one_model_line(model_name)
  expect(line[:class].include?("grayed-out")).to be true
end

step "I classic see one model :model_name not being grayed out" do |model_name|
  line = find_one_model_line(model_name)
  expect(line[:class].include?("grayed-out")).to be false
end

step "I classic expand the :text line" do |text|
  line = find('.table .line', text: text)
  line.find('[data-type="inventory-expander"]').click
end

step "I classic open the old manage timeline for the model :model_name in the pool :pool_name" do |model_name, pool_name|
  model = LeihsModel.find(product: model_name)
  pool = InventoryPool.find(name: pool_name)
  visit "/manage/#{pool.id}/models/#{model.id}/old_timeline"
end

step "I take a screenshot named :filename" do |filename|
  doc_screenshot(filename)
end

