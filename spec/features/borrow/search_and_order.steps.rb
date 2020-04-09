step 'there is/are :n borrowable item(s) for model :model in pool :pool' do |n, model, pool|
  model = LeihsModel.find(product: model)
  pool = InventoryPool.find(name: pool)

  n.to_i.times do
    FactoryBot.create(:item,
                      is_borrowable: true,
                      leihs_model: model,
                      responsible: pool,
                      owner: pool)
  end
end

step 'I enter :term in the search field' do |term|
  fill_in('Suche', with: term)
end

step 'I choose next working day as start date' do
  fill_in('Start-datum', with: Date.today.to_s)
end

step 'I choose next next working day as end date' do
  fill_in('End-datum', with: Date.tomorrow.to_s)
end

step 'I see one model with the title :name' do |name|
  expect(all('.ui-models-list-item').count).to eq 1
  find('.ui-models-list-item', text: name)
end

step 'I click on the model with the title :name' do |name|
  find('.ui-models-list-item', text: name).click
end

step 'the show page of the model :name was loaded' do |name|
  find('header', text: name)
end

step 'the start date chosen on the previous screen is pre-filled' do
  expect(find("input[name='start-date']").value).to eq Date.today.to_s
end

step 'the end date chosen on the previous screen is pre-filled' do
  expect(find("input[name='end-date']").value).to eq Date.tomorrow.to_s
end

step 'I set the quantity to :n' do |n|
  find("input[name='quantity']").set(n)
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
    expect(current_scope).to have_content "#{n} Items"
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

step 'I name the order as :purpose' do |purpose|
  fill_in('purpose', with: purpose)
end

step 'the cart is empty' do
  expect(page).to have_content 'Your order is empty.'
end

step 'I visit the orders page of the pool :name' do |name|
  pool = InventoryPool.find(name: 'Pool A')
  visit("/manage/#{pool.id}/orders")
end

step 'I approve the order of the user' do
  find('[data-order-approve]').click
end

step 'I see the order :purpose under approved orders' do |purpose|
  el = all('div', text: 'Approved Orders')[1]
  expect(el).to have_content purpose
end

step 'the maximum quantity shows :n' do |n|
  expect(page).to have_content /#{n}.max/
end

step 'the search filters are persisted in the url' do
  p_hash = Rack::Utils.parse_nested_query(URI.parse(current_url).query)
  expect(p_hash).to eq({
    "start-date" => Date.today.to_s,
    "end-date" => Date.tomorrow.to_s,
    "term" => "Kamera"
  })
end

step "I clear ls from the borrow app-db" do
  find('.ui-menu-icon').click
  click_on('Clear :ls')
end

step 'I visit the url with query params for dates as before but :m_name as term' do |m_name|
  visit "/app/borrow/?start-date=#{Date.today}&end-date=#{Date.tomorrow}&term=#{m_name}"
end
