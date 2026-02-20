require "spec_helper"

feature "Legacy vs Inventory - item create/update parity", type: :feature do
  let(:pool) { FactoryBot.create(:inventory_pool) }
  let(:user) { FactoryBot.create(:user, language_locale: "en-GB") }
  let!(:model) { FactoryBot.create(:leihs_model) }

  before(:each) do
    FactoryBot.create(:user, is_admin: true, admin_protected: true) # bootstrap: needs an admin to show login form
    FactoryBot.create(:access_right,
      inventory_pool: pool,
      user: user,
      role: :inventory_manager)
  end

  scenario "S1: create form defaults match between legacy and inventory" do
    login_as_inventory_user(user)

    # --- Legacy form defaults ---
    visit "/manage/#{pool.id}/items/new"
    wait_until { page.has_selector?("form #is_borrowable", wait: 10) }

    # is_borrowable default: false (Unborrowable radio selected)
    expect(page).to have_selector("#is_borrowable input[value='false']:checked")
    # retired default: false
    expect(find("#retired select", wait: 10).value).to eq "false"
    # is_inventory_relevant default: true (Yes selected in select)
    expect(find("#is_inventory_relevant select", wait: 10).value).to eq "true"
    # owner field shows pool name
    expect(find("input[title='Owner']", wait: 10).value).to eq pool.name
    # is_broken default: false
    expect(page).to have_selector("#is_broken input[value='false']:checked")
    # is_incomplete default: false
    expect(page).to have_selector("#is_incomplete input[value='false']:checked")
    # properties_reference default: invoice
    expect(page).to have_selector("#properties_reference input[value='invoice']:checked")

    # --- Inventory form defaults ---
    visit "/inventory/#{pool.id}/items/create"
    wait_until { page.has_selector?("button[data-test-id='is_borrowable-true']") }

    # is_borrowable default: false (unchecked)
    assert_unchecked(find("button[data-test-id='is_borrowable-true']"))
    # retired default: No
    expect(find("button[name='retired']", wait: 10)).to have_text("No")
    # is_broken default: unchecked
    assert_unchecked(find("button[data-test-id='is_broken-true']"))
    # is_incomplete default: unchecked
    assert_unchecked(find("button[data-test-id='is_incomplete-true']"))
    # is_inventory_relevant default: Yes
    expect(find("button[name='is_inventory_relevant']", wait: 10)).to have_text("Yes")
    # owner: disabled button shows pool name
    expect(find("button[data-test-id='owner_id']", wait: 10)).to have_text(pool.name)
    # properties_reference default: invoice (Running Account)
    assert_checked(find("button[data-test-id='properties_reference-invoice']"))
  end

  scenario "S2: item created in legacy appears correctly in inventory edit form" do
    login_as_inventory_user(user)

    inv_code = "LC-" + rand(10**6).to_s
    serial = Faker::Barcode.isbn
    note_text = Faker::Lorem.sentence
    item_name = Faker::Device.model_name

    # Create item via legacy form
    visit "/manage/#{pool.id}/items/new"
    wait_until { page.has_selector?("form #is_borrowable", wait: 10) }

    find("input[name='item[inventory_code]']").fill_in with: inv_code
    find("input[title='Model']").fill_in with: model.product
    find("ul.ui-autocomplete a").click
    find("input[name='item[serial_number]']").fill_in with: serial
    find("input[name='item[name]']").fill_in with: item_name
    find("textarea[name='item[note]']").fill_in with: note_text
    within("form #is_borrowable") { choose "Unborrowable" }
    find("input[title='Building']").fill_in with: "general building"
    find("ul.ui-autocomplete a").click
    find("input[title='Room']").fill_in with: "general room"
    find("ul.ui-autocomplete a").click

    click_on "Save Item"
    wait_until { page.has_content?("Item saved.") }

    item = Item.find(inventory_code: inv_code)
    expect(item).not_to be_nil
    expect(item.is_borrowable).to be false

    # Navigate directly to inventory item edit form
    visit "/inventory/#{pool.id}/items/#{item.id}"
    wait_until { page.has_selector?("button[data-test-id='is_borrowable-true']") }

    assert_field "Inventory Code", inv_code
    assert_field "Serial Number", serial
    assert_field "Name", item_name
    assert_field "Note", note_text
    assert_unchecked(find("button[data-test-id='is_borrowable-true']"))
  end

  scenario "S3: item created in inventory appears correctly in legacy edit form" do
    login_as_inventory_user(user)

    inv_code = "IC-" + rand(10**6).to_s
    serial = Faker::Barcode.isbn
    item_name = Faker::Device.model_name
    note_text = Faker::Lorem.sentence

    visit "/inventory/#{pool.id}/list"
    click_on "Add inventory"
    click_on "New item"
    wait_until { page.has_selector?("button[data-test-id='is_borrowable-true']") }

    fill_in "Inventory Code", with: inv_code

    find("button[data-test-id='model_id']").click
    find("input[placeholder='Enter search term']", wait: 10).set(model.product)
    expect(page).to have_content model.product
    click_on model.product

    fill_in "Serial Number", with: serial
    fill_in "Name", with: item_name
    fill_in "Note", with: note_text

    find("button[data-test-id='is_borrowable-true']").click

    click_on "building_id"
    expect(page).to have_field(placeholder: "Enter search term")
    click_on "general building"

    click_on "Room"
    expect(page).to have_field(placeholder: "Enter search term")
    click_on "general room"

    click_on "Create"
    wait_until { page.has_text?("Item was successfully created") }

    item = Item.find(inventory_code: inv_code)
    expect(item).not_to be_nil

    visit "/manage/#{pool.id}/items/#{item.id}/edit"
    wait_until { page.has_selector?("form #is_borrowable", wait: 10) }

    expect(find("input[name='item[inventory_code]']").value).to eq inv_code
    expect(find("input[name='item[serial_number]']").value).to eq serial
    expect(find("input[name='item[name]']").value).to eq item_name
    expect(find("textarea[name='item[note]']").value).to eq note_text
    expect(page).to have_selector("#is_borrowable input[value='true']:checked")
  end

  scenario "S4: item edited in legacy reflects correctly in inventory edit form" do
    item = FactoryBot.create(:item,
      responsible: pool,
      owner: pool,
      leihs_model: model,
      is_borrowable: true)

    new_serial = Faker::Barcode.isbn
    new_name = Faker::Device.model_name
    new_note = Faker::Lorem.sentence

    login_as_inventory_user(user)

    visit "/manage/#{pool.id}/items/#{item.id}/edit"
    wait_until { page.has_selector?("form #is_borrowable", wait: 10) }

    find("input[name='item[serial_number]']").fill_in with: new_serial
    find("input[name='item[name]']").fill_in with: new_name
    find("textarea[name='item[note]']").fill_in with: new_note
    within("form #is_borrowable") { choose "Unborrowable" }

    click_on "Save Item"
    wait_until { page.has_content?("Item saved.") }

    visit "/inventory/#{pool.id}/items/#{item.id}"
    wait_until { page.has_selector?("button[data-test-id='is_borrowable-true']") }

    assert_field "Serial Number", new_serial
    assert_field "Name", new_name
    assert_field "Note", new_note
    assert_unchecked(find("button[data-test-id='is_borrowable-true']"))
  end

  scenario "S5: item edited in inventory reflects correctly in legacy edit form" do
    item = FactoryBot.create(:item,
      responsible: pool,
      owner: pool,
      leihs_model: model,
      is_borrowable: false)

    new_serial = Faker::Barcode.isbn
    new_name = Faker::Device.model_name
    new_note = Faker::Lorem.sentence

    login_as_inventory_user(user)

    visit "/inventory/#{pool.id}/items/#{item.id}"
    wait_until { page.has_selector?("button[data-test-id='is_borrowable-true']") }

    fill_in "Serial Number", with: new_serial
    fill_in "Name", with: new_name
    fill_in "Note", with: new_note
    find("button[data-test-id='is_borrowable-true']").click

    click_on "Save"
    wait_until { page.has_text?("Item was successfully saved") }

    visit "/manage/#{pool.id}/items/#{item.id}/edit"
    wait_until { page.has_selector?("form #is_borrowable", wait: 10) }

    expect(find("input[name='item[serial_number]']").value).to eq new_serial
    expect(find("input[name='item[name]']").value).to eq new_name
    expect(find("textarea[name='item[note]']").value).to eq new_note
    expect(page).to have_selector("#is_borrowable input[value='true']:checked")
  end
end
