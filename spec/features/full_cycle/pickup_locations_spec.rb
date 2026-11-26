require "spec_helper"

feature "full cycle pickup locations" do
  let(:default_locale) { "en-GB" }
  let(:pul_a_name) { "PUL A" }
  let(:pul_b_name) { "PUL B" }
  let(:pul_a_description) { "Ground floor workshop" }
  let(:pul_b_description) { "Basement studio" }
  let(:main_location_name) { "Main Warehouse" }

  scenario "admin config, inventory, borrow pools, order, and legacy lending" do
    set_default_locale(default_locale)

    @admin = create_initial_admin
    sign_in_as @admin

    @pool = create_inventory_pool
    @lending_manager = add_user
    assign_user_to_pool @lending_manager, @pool, "lending_manager"

    @customer = add_user
    assign_user_to_pool @customer, @pool, "customer"

    @inventory_manager = add_user
    assign_user_to_pool @inventory_manager, @pool, "inventory_manager"

    @pul_a = create_pickup_location(@pool,
      name: pul_a_name,
      description: pul_a_description)
    @pul_b = create_pickup_location(@pool,
      name: pul_b_name,
      description: pul_b_description)
    set_pickup_location_active(@pool, @pul_b, active: false)

    sign_out

    sign_in_as @inventory_manager, @pool
    set_pool_opening_hours @pool
    expect_transportable_field_hidden_in_inventory(@pool)
    @model_a = create_a_model_in_inventory(@pool)
    @model_b = create_a_model_in_inventory(@pool)
    @item_a = create_an_item_in_inventory(@pool, @model_a)
    @item_b = create_an_item_in_inventory(@pool, @model_b)
    sign_out

    sign_in_as @customer
    visit_borrow_pool_show(@pool)
    expect_borrow_pool_pickup_locations_section(visible: false, location_name: pul_a_name)
    sign_out

    sign_in_as @admin
    set_alternative_pickup_locations(@pool,
      enabled: true,
      default_name: main_location_name,
      transfer_buffer_before: 0,
      transfer_buffer_after: 0)
    sign_out

    sign_in_as @inventory_manager, @pool
    set_model_transportable(@pool, @model_a, transportable: true)
    set_model_transportable(@pool, @model_b, transportable: false)
    sign_out

    sign_in_as @customer
    visit_borrow_pool_show(@pool)
    expect_borrow_pool_pickup_locations_section(
      visible: true,
      location_name: pul_a_name,
      description: pul_a_description
    )
    expect(page).not_to have_content(pul_b_name)
    expect(page).not_to have_content(pul_b_description)

    add_model_to_borrow_cart(@model_a, pickup_location: pul_a_name)
    add_model_to_borrow_cart(@model_b, pickup_location: nil)

    order_title = Faker::Lorem.unique.sentence
    @customer_order = submit_borrow_cart_order(order_title)
    @legacy_order = legacy_order_for_customer_order(@pool, @customer_order)
    sign_out

    reservations = Reservation.where(order_id: @legacy_order.id).all
    expect(reservations.size).to eq 2

    res_a = reservations.find { |r| r.model_id == @model_a.id }
    res_b = reservations.find { |r| r.model_id == @model_b.id }
    expect(res_a.pickup_location_id).to eq @pul_a.id
    expect(res_b.pickup_location_id).to be_nil

    sign_in_as @lending_manager, @pool
    visit_legacy_open_orders(@pool)
    open_legacy_order_edit_from_open_orders(@legacy_order)
    expect_legacy_order_edit_page(@legacy_order)
    expect_legacy_order_line_pickup_location(@model_a, location_name: pul_a_name, present: true)
    expect_legacy_order_line_pickup_location(@model_b, location_name: pul_a_name, present: false)

    approve_legacy_order_from_edit_page
    visit_legacy_hand_over(@pool, @customer)
    expect_legacy_hand_over_pickup_location(@model_a, location_name: pul_a_name, present: true)
    expect_legacy_hand_over_pickup_location(@model_b, location_name: pul_a_name, present: false)
  end
end
