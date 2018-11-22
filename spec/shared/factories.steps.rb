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

step "the user is a customer of some pool" do
  FactoryBot.create(:access_right, user_id: @user.id, role: :customer)
end

step "there is an external authentication system" do
  @external_authentication_system =
    FactoryBot.create(:authentication_system, :external)
end

step "the user has external authentication" do
  ext_sys = AuthenticationSystem.find(type: 'external')
  FactoryBot.create(:authentication_system_user,
                    user_id: @user.id,
                    authentication_system_id: ext_sys.id)
end

step "the user does not have password authentication" do
  AuthenticationSystemUser
    .where(user_id: @user.id, authentication_system_id: 'password')
    .delete
end
