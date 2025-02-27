step "I open the main menu" do
  wait_until do
    find("nav .ui-menu-icon").click
    @menu = all("#menu", wait: false).first
  end
end

step "I open the user menu" do
  find("nav .ui-user-profile-button").click
end

step "I click on the model with the title :name" do |name|
  find(".ui-models-list-item", text: name).click
end

step "I visit the model show page of model :name" do |name|
  m = LeihsModel.find(product: name)
  visit "/borrow/models/#{m.id}"
end

step "I accept the :title dialog" do |title|
  within(find_ui_modal_dialog(title: title)) do
    click_on "OK"
  end
end

step "I see the order :purpose" do |purpose|
  within find(".tab-content") do
    expect(current_scope).to have_content purpose
  end
end
