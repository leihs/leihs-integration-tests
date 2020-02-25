require 'spec_helper'
require 'pry'

def create_initial_admin
  visit '/'
  expect(page).to have_content "Initial Admin"
  within 'form#initial-admin-form' do
    fill_in 'email', with: 'admin@example.com'
    fill_in 'password', with: 'admin-password'
    click_on 'Create'
  end
  expect(current_path).to be== '/'
  admin = User.where(email: 'admin@example.com').first
  admin.password = 'admin-password'
  admin
end

def add_user
  visit '/admin/'
  click_on 'Users'
  click_on 'Add'
  email = Faker::Internet.unique.email
  fill_in 'email', with: email
  fill_in 'firstname', with: Faker::Name.unique.first_name
  fill_in 'lastname', with: Faker::Name.unique.last_name
  click_on 'Create'
  wait_until { current_path.match? %r'/admin/users/[^/]+' }
  wait_until { User.where(email: email).first }
  user = User.where(email: email).first
  user.password = Faker::Internet.password
  click_on 'User-Home'
  click_on 'Password'
  fill_in 'New password', with: user.password
  click_on 'Set password'
  wait_until { current_path == "/my/user/#{user.id}" }
  user
end


def sign_in_as user, pool=nil
  visit '/'
  fill_in 'user', with: user.email
  click_on 'Login'
  fill_in 'password', with: user.password
  click_on 'Weiter'
  wait_until do
    ["/admin/", '/borrow',
     "/manage/#{pool.try(:id)}/inventory",
     "/manage/#{pool.try(:id)}/daily" ].include? current_path
  end
  case current_path
  when '/admin/'
    find('.fa-user-circle').click
    wait_until { page.has_content? user.lastname }
  when '/borrow'
    wait_until { page.has_content? user.lastname }
  when "/manage/#{pool.try(:id)}/inventory"
    wait_until { page.has_content? user.lastname }
  when "/manage/#{pool.try(:id)}/daily"
    wait_until { page.has_content? user.lastname }
  end
  visit '/'
end

def sign_out
  visit "/my/user/me"
  find(".fa-user-circle").click
  click_on "Logout"
  wait_until{ current_path == "/" }
end


def create_inventory_pool
  visit '/admin/'
  click_on 'Inventory-Pools'
  click_on 'Add'
  name = Faker::Company.unique.name
  fill_in 'name', with: name
  fill_in 'shortname', with: name.split(" ").map(&:first).join
  fill_in 'email', with: Faker::Internet.unique.email
  click_on 'Add'
  wait_until {current_path.match? %r"/admin/inventory-pools/\w{8}\-\w{4}\-\w{4}\-\w{4}\-\w{12}" }
  id = current_path.split('/').last
  InventoryPool.find(id: id)
end

def assign_user_to_pool user, pool, role = 'customer'
  visit "/admin/inventory-pools/#{pool.id}/users/#{user.id}/roles"
  uncheck role
  check role
  click_on 'Save'
  wait_until{ current_path == "/admin/inventory-pools/#{pool.id}/users/#{user.id}" }
end

def create_a_model pool
  visit "/manage/#{@pool.id}/models/new"
  product = Faker::Commerce.unique.product_name
  find("#product input").fill_in with: product
  click_on 'Save Model'
  wait_until { page.has_content? 'Model saved'}
  LeihsModel.find(product: product)
end

def create_an_item pool, model
  visit "/manage/#{@pool.id}/items/new"
  inv_code = model.product.split(" ").map(&:first).join() + "-" + rand(10**10).to_s
  find("input[name='item[inventory_code]']").fill_in with: inv_code
  find("input[title='Model']").fill_in with: model.product
  find("ul.ui-autocomplete a").click
  find("input[title='Building']").fill_in with: 'general building'
  find("ul.ui-autocomplete a").click
  find("input[title='Room']").fill_in with: 'general room'
  find("ul.ui-autocomplete a").click
  within('form #is_borrowable'){ choose 'OK' }
  click_on 'Save Item'
  wait_until { page.has_content? 'Item saved.'}
  Item.find(inventory_code: inv_code)
end

def order model
  visit '/borrow'
  find('input#search_term').fill_in with: @model.product
  click_on @model.product
  click_on 'Add to order'
  click_on 'Add'
  click_on 'Complete order'
  purpose = Faker::Lorem.unique.sentence
  find("textarea[name='purpose']").fill_in with: purpose
  click_on 'Submit Order'
  wait_until{ page.has_content? 'Your order has been successfully submitted' }
  Order.find(purpose: purpose)
end

def hand_over pool, order, model, item
  visit "/manage/#{pool.id}/daily"
  click_on "Open Orders"
  wait_until{ current_path == "/manage/#{pool.id}/orders" }
  find("a", exact_text: "Approve").click
  click_on "Hand Over"
  sleep 1
  find("input[data-assign-item]").send_keys :enter
  find("input[data-assign-item]").fill_in with: item.inventory_code
  find("a[title~='#{item.inventory_code}']").click
  click_on "Hand Over Selection"
  wait_until{ page.has_content? order.purpose }
  click_on "Hand Over"
  wait_until{ windows.size == 2 }
  switch_to_window(windows.second)
  wait_until{ current_path && current_path.match?(%r"/manage/[^/]+/contracts/[^/]+") }
  contract_id = current_path.split('/').last
  switch_to_window(windows.first)
  windows.second.try(:close)
  wait_until{ page.has_content? "Hand over complete" }
  click_on "Finish this hand over"
  wait_until{ "/manage/#{pool.id}/daily" }
  Contract.find(id: contract_id)
end

def take_back pool, order, model, item, contract
  click_on "Visits"
  click_on "Take Back"
  find("[data-line-type='item_line'] input[type='checkbox']").click
  click_on "Take Back Selection"
  within(".modal"){ click_on "Take Back" }
  click_on "Finish this take back"
end

feature 'full cycle' do

  scenario 'setup leihs, create users with direct roles, create inventory, order, hand out, take back' do

    #################################################################
    # the admin creates users, sets roles, and permissions
    #################################################################

    @admin = create_initial_admin
    sign_in_as @admin

    @pool = create_inventory_pool

    @lending_manager = add_user
    assign_user_to_pool @lending_manager, @pool, 'lending_manager'

    @customer = add_user
    assign_user_to_pool @customer, @pool, 'customer'

    @inventory_manager = add_user
    assign_user_to_pool @inventory_manager, @pool, 'inventory_manager'

    sign_out


    #################################################################
    # the inventory_manager sets up model and item
    #################################################################

    sign_in_as @inventory_manager, @pool
    @model = create_a_model @pool
    @item = create_an_item @pool, @model
    sign_out


    #################################################################
    # the customer orders
    #################################################################

    sign_in_as @customer
    @order = order @model
    sign_out


    #################################################################
    # the lending_manager hands out
    #################################################################

    sign_in_as @lending_manager, @pool
    @contract = hand_over @pool, @order, @model, @item


    #################################################################
    # the lending_manager takes back
    #################################################################

    take_back @pool, @order, @model, @item, @contract


  end
end
