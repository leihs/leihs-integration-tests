step 'there is a user' do
  @user = FactoryBot.create(:user)
end

step 'there is an initial admin' do
  @initial_admin = FactoryBot.create(:user, is_admin: true)
  FactoryBot.create(:system_admin, user_id: @initial_admin.id)
end

step 'there is a leihs admin' do
  @leihs_admin = FactoryBot.create(:user, is_admin: true)
end
