step "I am redirected to the inventory path of the pool" do
  expect(current_path).to eq "/manage/#{@pool.id}/inventory"
end

step "there is an external authentication system :name" do |name|
  unless ENV["TEST_AUTH_SYSTEM_PORT"].presence
    raise "export TEST_AUTH_SYSTEM_PORT !"
  end

  @test_authentication_system = FactoryBot.create(
    :authentication_system, :external,
    id: 'test',
    name: name,
    external_sign_in_url: "http://localhost:#{ENV['TEST_AUTH_SYSTEM_PORT']}/sign-in"
  )
end

step "the external authentication system is configured for the user" do
  database[:authentication_systems_users].insert(
    user_id: @user.id,
    authentication_system_id: @test_authentication_system.id
  )
end

step "I am redirected to sign in page" do
  expect(current_path).to eq "/sign-in"
end

step "I enter my email address" do
  fill_in("user", with: @user.email)
end

step "I confirm my identity" do
  click_on "Yes, I am #{@user.email}"
end

step "I am redirected to :path" do |path|
  sleep 1
  expect(current_url).to eq "#{Setting.first.external_base_url}#{path}"
end
