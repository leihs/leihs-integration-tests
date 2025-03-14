require 'spec_helper'
require 'pry'


feature 'full cycle' do
  let(:default_locale) { "en-GB" }
  let(:submitted_subject_1) { Faker::Lorem.sentence }
  let(:approved_subject_1) { Faker::Lorem.sentence }
  let(:submitted_subject_2) { Faker::Lorem.sentence }
  let(:approved_subject_2) { Faker::Lorem.sentence }

  scenario 'setup leihs, create users with direct roles, create inventory, order, hand out, take back' do
    set_default_locale(default_locale)

    @admin = create_initial_admin
    sign_in_as @admin

    #################################################################
    # the admin adjusts mail templates and creates a pool
    #################################################################

    adjust_mail_template_subject('submitted', default_locale, submitted_subject_1)
    adjust_mail_template_subject('approved', default_locale, approved_subject_1)

    @pool = create_inventory_pool

    check_pool_template_subject('submitted', default_locale, submitted_subject_1, @pool)
    check_pool_template_subject('approved', default_locale, approved_subject_1, @pool)

    adjust_mail_template_subject('submitted', default_locale, submitted_subject_2, @pool)
    adjust_mail_template_subject('approved', default_locale, approved_subject_2, @pool)

    #################################################################
    # the admin creates users, sets roles, and permissions
    #################################################################

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
    set_pool_opening_hours @pool
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

    #################################################################
    # emails checks
    #################################################################

    expect(Mail.all.count).to eq 2
    expect(Mail.all.map(&:subject).to_set).to eq [submitted_subject_2, approved_subject_2].to_set
  end
end
