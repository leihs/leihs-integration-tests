require 'spec_helper'
require 'pry'

feature 'full cycle' do

  scenario 'setup leihs, create users with direct roles, create inventory, order, hand out, take back' do
    set_default_locale("en-GB")

    #################################################################
    # the admin creates users, sets roles, and permissions
    #################################################################

    @admin = create_initial_admin
    sign_in_as @admin

    @pool = create_inventory_pool


    # set up groups

    @group_lending_manager_group = create_group name: 'Lending Managers'
    assign_group_to_pool @group_lending_manager_group, @pool, 'lending_manager'

    @group_inventory_manager_group = create_group name: 'Inventory Managers'
    assign_group_to_pool @group_inventory_manager_group, @pool, 'inventory_manager'

    @group_customer_group = create_group name: 'Customers'
    assign_group_to_pool @group_customer_group, @pool, 'customer'


    # set up users

    @user_direct_customer = add_user lastname: 'DirectCustomer'
    assign_user_to_pool @user_direct_customer, @pool, 'customer'

    @user_direct_lending_manager = add_user lastname: 'DirectLendingManager'
    assign_user_to_pool @user_direct_lending_manager, @pool, 'lending_manager'

    @user_direct_inventory_manager = add_user lastname: 'DirectInventoryManager'
    assign_user_to_pool @user_direct_inventory_manager, @pool, 'inventory_manager'


    @group_customer = add_user lastname: 'GroupCustomer'
    add_user_to_group(@group_customer, @group_customer_group)

    @group_lending_manager = add_user lastname: 'GroupLendingManager'
    add_user_to_group(@group_lending_manager, @group_lending_manager_group)

    @group_inventory_manager = add_user lastname: 'GroupInventoyManager'
    add_user_to_group(@group_inventory_manager, @group_inventory_manager_group)


    @mixed_customer = add_user lastname: 'MixedCustomer'
    assign_user_to_pool @mixed_customer, @pool, 'customer'
    add_user_to_group(@mixed_customer, @group_customer_group)

    @mixed_lending_manager = add_user lastname: 'MixedLendingManager'
    assign_user_to_pool @mixed_lending_manager, @pool, 'lending_manager'
    add_user_to_group(@mixed_lending_manager, @group_lending_manager_group)

    @mixed_inventory_manager = add_user lastname: 'MixedInventoryManager'
    assign_user_to_pool @mixed_inventory_manager, @pool, 'inventory_manager'
    add_user_to_group(@mixed_inventory_manager, @group_inventory_manager_group)


    assign_user_to_pool @admin, @pool, 'inventory_manager'
    add_user_to_group(@admin, @group_customer_group)

    sign_out

    #################################################################
    # the inventory_manager sets up model and item
    #################################################################

    sign_in_as @group_inventory_manager, @pool
    set_pool_opening_hours @pool
    @model = create_a_model @pool
    @item = create_an_item @pool, @model
    sign_out


    #################################################################
    # the customer orders
    #################################################################

    sign_in_as @group_customer
    @order = order @model
    sign_out


    #################################################################
    # the lending_manager hands out
    #################################################################

    sign_in_as @group_lending_manager, @pool
    @contract = hand_over @pool, @order, @model, @item


    #################################################################
    # the lending_manager takes back
    #################################################################

    take_back @pool, @order, @model, @item, @contract


  end
end
