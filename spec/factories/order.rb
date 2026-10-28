class Order < Sequel::Model(:orders)
  one_to_many(:reservations, key: :order_id)
  many_to_one(:customer_order, key: :customer_order_id)
end
