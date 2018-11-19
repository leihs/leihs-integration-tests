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

step "there is a user with an ultimate access" do
  @user = FactoryBot.create(:user, is_admin: true)
  FactoryBot.create(:system_admin, user_id: @user.id)
  FactoryBot.create(:procurement_admin, user_id: @user.id)
  FactoryBot.create(:access_right,
                    user: @user,
                    role: :inventory_manager)
end

step "there is a language :lang with locale name :l_name" do |lang, l_name|
  FactoryBot.create(:language,
                    name: lang,
                    locale_name: l_name)
end
