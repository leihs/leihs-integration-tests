class CustomerOrder < Sequel::Model(:customer_orders)
  one_to_many(:orders, key: :customer_order_id, class: :Order)
end
