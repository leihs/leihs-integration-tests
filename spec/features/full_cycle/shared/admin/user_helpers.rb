def add_user
  visit '/admin/'
  click_on 'Users'
  click_on 'Add'
  email = Faker::Internet.unique.email
  fill_in 'email', with: email
  fill_in 'firstname', with: Faker::Name.unique.first_name
  fill_in 'lastname', with: Faker::Name.unique.last_name
  click_on 'Create'
  wait_until { current_path.match? %r'/admin/users/[^/]+' }
  wait_until { User.where(email: email).first }
  user = User.where(email: email).first
  user.password = Faker::Internet.password
  click_on 'User-Home'
  click_on 'Password'
  fill_in 'New password', with: user.password
  click_on 'Set password'
  wait_until { current_path == "/my/user/#{user.id}" }
  user
end

