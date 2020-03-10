require 'spec_helper'
require 'pry'

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
