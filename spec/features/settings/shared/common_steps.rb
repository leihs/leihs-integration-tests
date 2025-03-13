step "the following settings are saved:" do |table|
  settings = Setting.first
  table.each do |key, val|
    expect(settings[key.to_sym].to_s).to eq val
  end
end

step "the following settings exist:" do |table|
  s = Setting.first
  s.update(Hash[*table.raw.flatten])
end

step "I add one item of model :name to the cart" do |name|
  visit "/borrow/models/#{LeihsModel.find(product: name).id}"
  click_on("Gegenstand hinzufügen")
  click_on("Hinzufügen")
end

step "the order is not submitted" do
  expect(current_path).to eq "/borrow/order"
  expect(Order.where(user_id: @user.id, state: "submitted").count).to eq 0
end

step "the order is submitted" do
  expect(current_path).to eq "/borrow/rentals/"
  expect(Order.where(user_id: @user.id, state: "submitted").count).to eq 1
end
