step "the user has the email :email" do |email|
  @user.update(email: email.presence)
end

step "the user has the secondary email :email" do |email|
  @user.update(secondary_email: email.presence)
end

step "I hand over something to myself" do
  @p_id = InventoryPool.find(name: "Pool A").id
  visit "/manage/#{@p_id}/users/#{@user.id}/hand_over"
  m = LeihsModel.find(product: "Beamer")
  i = Item.find(model_id: m.id)
  find("#assign-or-add-input input").set(i.inventory_code)
  find(".fa-plus").click
  click_on("Hand Over Selection")
  fill_in("purpose", with: "purpose")
  click_on("Hand Over")
  wait_until { windows.size == 2 }
  windows.second.try(:close)
end

step "I hand over something to my delegation me being the contact person" do
  @p_id = InventoryPool.find(name: "Pool A").id
  visit "/manage/#{@p_id}/users/#{@delegation.id}/hand_over"
  m = LeihsModel.find(product: "Beamer")
  i = Item.find(model_id: m.id)
  find("#assign-or-add-input input").set(i.inventory_code)
  find(".fa-plus").click
  click_on("Hand Over Selection")
  fill_in("purpose", with: "purpose")

  within "#contact-person" do
    find("input#user-id", match: :first).set @user.name
    find(".ui-menu-item a", match: :first, text: @user.name).click
    find("#selected-user", text: @user.name)
  end

  click_on("Hand Over")
  wait_until { windows.size == 2 }
  windows.second.try(:close)
end

step "within the contract I see the email :email" do |email|
  c = Contract.first
  visit "/manage/#{@p_id}/contracts/#{c.id}"
  if email.blank?
    expect(page).not_to have_selector ".customer-email"
  else
    expect(page).to have_content email
  end
end
