step 'I enter :term in the search field' do |term|
  fill_in('Search', with: term)
end

step 'the search field contains :term' do |term|
  expect(find_field('Search').value).to eq term
end

step 'I choose to filter by availabilty' do
  check("Show available only")
end

step 'I choose next working day as start date' do
  fill_in('From', with: Date.today.to_s)
end

step 'I choose next next working day as end date' do
  fill_in('Until', with: Date.tomorrow.to_s)
end

step 'I see one model with the title :name' do |name|
  expect(all('.ui-models-list-item').count).to eq 1
  find('.ui-models-list-item', text: name)
end

step 'I click on the model with the title :name' do |name|
  find('.ui-models-list-item', text: name).click
end

step 'the show page of the model :name was loaded' do |name|
  find('h1', text: name)
end

step 'the start date chosen previously is pre-filled in the calendar' do
  expect(find(".ui-booking-calendar .date-range-picker input[name='startDate']").value).to eq Date.today.strftime('%d.%m.%Y')
end

step 'the end date chosen previously is pre-filled in the calendar' do
  expect(find(".ui-booking-calendar .date-range-picker input[name='endDate']").value).to eq Date.tomorrow.strftime('%d.%m.%Y')
end

step 'the start date chosen previously is pre-filled in the search panel' do
  within('form[action="/search"]') do
    expect(find_field("From").value).to eq Date.today.to_s
  end
end

step 'the end date chosen previously is pre-filled in the search panel' do
  within('form[action="/search"]') do
    expect(find_field("Until").value).to eq Date.tomorrow.to_s
  end
end

step 'the order panel is shown' do
  find('.ui-booking-calendar')
end

step 'I set the quantity to :n' do |n|
  all(".ui-booking-calendar input").first.set(n)
end

step 'I set the quantity in the cart line to :n' do |n|
  find_field("quantity").set(n)
end

step 'I click on :text and accept the alert' do |text|
  accept_alert { click_on(text) }
end

step 'the cart page is loaded' do
  expect(page).to have_content 'Order Overview'
end

step 'I see one reservation for model :name' do |name|
  find('.flex-row', text: name)
end

step 'the reservation has quantity :n' do |n|
  within find('.flex-row') do
    expect(current_scope).to have_content "#{n} Item(s)"
  end
end

step 'I visit the model show page of model :name' do |name|
  m = LeihsModel.find(product: name)
  visit "/app/borrow/models/#{m.id}"
end

step ':term is pre-filled as the search term' do |term|
  expect(find("input[name='search-term']").value).to eq term
end

step 'I delete the reservation for model :name' do |name|
  find('.flex-row', text: name).find('.ui-trash-icon').click
end

step 'the reservation for model :name was deleted from the cart' do |name|
  expect(page).not_to have_selector('.flex-row', text: name)
end

step 'I name the order as :title' do |title|
  fill_in('title', with: title)
end

step 'the cart is empty' do
  expect(page).to have_content 'Your order is empty'
end

step 'I visit the orders page of the pool :name' do |name|
  pool = InventoryPool.find(name: 'Pool A')
  visit("/manage/#{pool.id}/orders")
end

step 'I approve the order of the user' do
  find('[data-order-approve]').click
end

step 'I see the order :purpose under open orders' do |purpose|
  within find('section', text: 'Open') do
    expect(current_scope).to have_content purpose
  end
end

step 'the maximum quantity shows :n' do |n|
  expect(page).to have_content /#{n}.max/
end

step 'the search filters are persisted in the url' do
  p_hash = Rack::Utils.parse_nested_query(URI.parse(current_url).query)
  expect(p_hash).to eq({
    "available-between?"=>"true",
    "quantity" => "1",
    "start-date" => Date.today.to_s,
    "end-date" => Date.tomorrow.to_s,
    "term" => "Kamera",
    "user-id" => @user.id
  })
end

step "I clear ls from the borrow app-db" do
  find('.ui-menu-icon').click
  click_on('Clear :ls')
end

step 'I visit the url with query params for dates as before but :m_name as term' do |m_name|
  visit \
    "/app/borrow/" \
    "?available-between%3F=true" \
    "&start-date=#{Date.today}" \
    "&end-date=#{Date.tomorrow}" \
    "&term=#{m_name}"
end

step 'I click on :label for the model :name' do |label, name|
  find(".flex-row", text: name).click_button("Edit")
end

step 'I increase the start date by 1 day for the model :name' do |name|
  fill_in('from', with: Date.tomorrow.to_s)
end

step 'I increase the end date by 1 day for the model :name' do |name|
  fill_in('until', with: (Date.tomorrow + 1.day).to_s)
end

step 'the reservation data was updated successfully for model :name' do |name|
  within find('.flex-1', text: 'Kamera') do
    s = Date.tomorrow.strftime('%-m/%-d/%Y')
    e = (Date.tomorrow + 1.day).strftime('%-m/%-d/%Y')
    expect(current_scope).to have_content(/#{s}...#{e}/)
    expect(current_scope).to have_content('4 Item(s)')
  end
end

step "I see :n times :name" do |n, name|
  pre = find("pre", match: :first).text
  o = JSON.parse(pre).deep_symbolize_keys
  rs = o[:"sub-orders-by-pool"].first[:reservations]
  expect(rs.count).to eq 4
  m = LeihsModel.find(product: name)
  expect(rs.map { |r| r[:model][:id] }.uniq).to eq [m.id]
end
