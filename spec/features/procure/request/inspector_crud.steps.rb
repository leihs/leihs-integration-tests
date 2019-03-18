step 'there is an inspector for category :cat' do |cat|
  c = ProcurementCategory.find(name: cat)
  pi = FactoryBot.create(:procurement_inspector, category: c)
  @inspector = @user = pi.user
end

step 'the inspector is a requester too' do
  FactoryBot.create(:procurement_requester, user: @inspector)
end

step 'I log in as the inspector' do
  step 'I log in as the user'
end

step 'I see the article name of the request' do
  expect(page).to have_content @request.article_name
end

step 'the category for the request has been updated to :c' do |c|
  expect(@request.reload.category.name).to eq c
end

step 'I see the article name of the request within budget period :bp' do |bp|
  within find('.card.mb-3', text: bp) do
    expect(current_scope).to have_content @request.article_name
  end
end

step "I don't see the article name of the request within budget period :bp" do |bp|
  within find('.card.mb-3', text: bp) do
    expect(current_scope).not_to have_content @request.article_name
  end
end

step 'the budget period for the request has been updated to :bp' do |bp|
  expect(@request.reload.budget_period.name).to eq bp
end
