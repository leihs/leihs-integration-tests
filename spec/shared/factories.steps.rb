IP_UUID = "6bf7dc96-2b11-43c1-9f49-c58a5b332517"

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

step 'the user is leihs admin' do
  User.where(id: @user.id).update(is_admin: true)
end

step 'the user is sysadmin' do
  FactoryBot.create(:system_admin, user_id: @user.id)
end

step "there is a user with an ultimate access" do
  @user = FactoryBot.create(:user, is_admin: true)
  ip = FactoryBot.create(:inventory_pool, id: IP_UUID)
  FactoryBot.create(:system_admin, user_id: @user.id)
  FactoryBot.create(:procurement_admin, user_id: @user.id)
  FactoryBot.create(:access_right,
                    user: @user,
                    inventory_pool: ip,
                    role: :inventory_manager)
end

step "the user does not have any pool access rights" do
  AccessRight.where(user_id: @user.id).delete
end

step "there is a language :lang with locale name :l_name" do |lang, l_name|
  FactoryBot.create(:language,
                    name: lang,
                    locale_name: l_name)
end

step "the user is customer of some pool" do
  FactoryBot.create(:access_right, user_id: @user.id, role: :customer)
end

step "the user is inventory manager of some pool" do
  @pool = FactoryBot.create(:inventory_pool)
  FactoryBot.create(:access_right,
                    user_id: @user.id,
                    inventory_pool_id: @pool.id,
                    role: :inventory_manager)
end

step "the user is inventory manager of pool :name" do |name|
  pool = FactoryBot.create(:inventory_pool, name: name)
  FactoryBot.create(:access_right,
                    user_id: @user.id,
                    inventory_pool_id: pool.id,
                    role: :inventory_manager)
end

step "the user is group manager of pool :name" do |name|
  pool = FactoryBot.create(:inventory_pool, name: name)
  FactoryBot.create(:access_right,
                    user_id: @user.id,
                    inventory_pool_id: pool.id,
                    role: :group_manager)
end

step "the user is procurement admin" do
  FactoryBot.create(:procurement_admin, user_id: @user.id)
end

step "the user is procurement requester" do
  FactoryBot.create(:procurement_requester, user_id: @user.id)
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

step "the user has no access whatsoever" do
  AccessRight.where(user_id: @user.id).delete
  User.where(id: @user.id).update(is_admin: false)
  SystemAdmin.where(user_id: @user.id).delete
  ProcurementRequester.where(user_id: @user.id).delete
  ProcurementAdmin.where(user_id: @user.id).delete
  ProcurementInspector.where(user_id: @user.id).delete
  ProcurementViewer.where(user_id: @user.id).delete
end
