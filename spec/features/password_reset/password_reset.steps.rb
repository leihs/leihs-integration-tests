require 'mail'

step "the following Users exist:" do |table|
  table.hashes.each do |user|
    FactoryBot.create(:user, {
      firstname: user['name'],
      lastname: user['name'],
      login: user['login'],
      email: yamlval(user['email']),
      password_sign_in_enabled: yamlval(user['password_sign_in']),
      password: user['password'].presence
    })
  end
end

step "the smtp default from address is :email" do |email|
  SmtpSetting.first.update(default_from_address: email)
end

step "I am :user" do |user|
  @user = User.find(firstname: user, lastname: user)
end

step "I fill out my :user_param" do |user_param|
  fill_in('user', with: (user_param === 'email' ? @user.email : @user.login))
end

step "I click :text" do |text|
  find('a, button', text: text).click
end

step "I see the login form with a password field" do
  within('.ui-form-signin') do
    expect(page).to have_selector('input[type=password]')
  end
end

step "I :whether_to the :text button" do |positive, text|
  expectation = positive ? :to : :not_to
  expect(page).send(expectation, have_selector('button', text: text))
end

step "I see :pfx :field filled out" do |pfx, field|
  within('.ui-form-signin') do
    case [pfx, field]
    when ['my', 'email']
      expect(find_field_val('user', @user.email)).to be
    when ['my', 'login']
      expect(find_field_val('user', @user.login)).to be
    when ['the', 'token']
      expect(find_field_val('token', @the_password_reset_token)).to be
    else
      fail 'dont know which field to check!'
    end
  end
end

step "my mailbox is empty" do
  expect(Mail.all).to be_empty
end

step "I receive an email" do
  mails = []
  wait_until(10) do
    mails = fetch_emails_for_user(@user.email)
    mails.length === 1
  end
  @the_email = mails.first
  puts "\n----------\nYOU'VE GOT MAIL!\n\n"
  puts @the_email
  puts "\n----------"
end

step "the email is from :addr" do |addr|
  expect(@the_email.from).to include addr
end

step "the email has a subject of :text" do |text|
  expect(@the_email.subject).to eq text
end

step "the email body contains :text" do |text|
  expect(get_email_body(@the_email)).to include text
end

step "the email body contains the password reset link and token" do
  links = URI.extract(get_email_body(@the_email)).map {|s| URI.parse(s) }
  the_link = links.find {|uri| uri.path.include? 'reset' }
  the_params = Rack::Utils.parse_query(the_link.query)
  @the_password_reset_link = the_link.to_s
  @the_password_reset_token = the_params['token']
  expect(@the_password_reset_link).to be
  expect(@the_password_reset_token).to be
end

step "I open the password reset link" do
  visit @the_password_reset_link
end

step "I fill out the secret token" do
  fill_in 'token', with: @the_password_reset_token
end

step "I fill out a new password in the password field" do
  @the_new_password = Faker::String.random([8,16])
  within('.ui-form-signin') do
    fill_in 'newPassword', with: @the_new_password
  end
end

step "I see the message :msg" do |msg|
  expect(page).to have_content(msg)
  # TODO: match UI!
  # expect(page).to have_selector('.ui-flash-messages', text: msg)
end

step "I can log in with the new password" do
  visit '/sign-in'
  within('.ui-form-signin') do
    fill_in('user', with: @user.email || @user.login)
  end
  step('I click on "Weiter"')
  within('.ui-form-signin') do
    fill_in 'password', with: @the_new_password
  end
  step('I click on "Weiter"')
  visit '/my/user/me/auth-info'
  ['Auth-Info', @user.id].each do |txt|
    expect(page).to have_content(txt)
  end
end

step "I have a current password reset with props :code" do |code|
  @my_current_password_reset = create(
    :user_password_reset, user: @user, **eval(code))
end

step "I fill out the secret token from my current password reset" do
  fill_in 'token', with: @my_current_password_reset.token
end

placeholder :whether_to do
  match /dont see|do not see|can not|cant/ do
    false
  end
  match /see|can/ do
    true
  end
end

private

def yamlval(raw_value)
  YAML.load("{ parsed_value: #{raw_value} }")['parsed_value']
end

def find_field_val(name, val)
  all("input[name=#{name}]").find {|f| f[:value] === val}
end

def fetch_emails_for_user(email_address)
  Mail.all.select { |mail| mail.to.include?(email_address) }
end

def get_email_body(email)
  # TODO: to handle multipart, select by content text and join!
  email.decoded
end
