step "I am on the show page of the pool :name" do |name|
  wait_until{ InventoryPool.find(name: "New Pool") }
  @pool ||= InventoryPool.find(name: name)
  wait_until { current_path.match "^\/admin\/inventory-pools\/#{@pool.id}" }
end

step "I go to the mail templates page of pool :name" do |name|
  @pool ||= InventoryPool.find(name: name)
  visit "/manage/#{@pool.id}/mail_templates"
end

step "I click on :label for template :tmpl" do |label, tmpl|
  within find(".list-of-lines .row", text: tmpl) do
    click_on(label)
  end
end

step "I enter :text for all languages" do |text|
  all("textarea").each { |ta| ta.set(text) }
end

step "all languages contain :text" do |text|
  all("textarea").each { |ta| expect(ta.text).to eq text }
end

step "I give myself the role of an inventory manager for the pool" do
  FactoryBot.create(:access_right,
                    user: @current_user,
                    inventory_pool: @pool,
                    role: :inventory_manager)
end

step "I click on :label within the navigation" do |label|
  within '.nav-component' do
    click_on label
  end
end
