def add_user opts={}
  opts= opts.with_indifferent_access
  visit '/admin/'
  click_on 'Users'
  first(:link_or_button, 'Add User').click
  email = opts[:email] || Faker::Internet.unique.email
  fill_in 'email', with: email
  fill_in 'firstname', with: (opts[:firstname] || Faker::Name.unique.first_name)
  fill_in 'lastname', with: (opts[:lastname] || Faker::Name.unique.last_name)
  click_on 'Add'
  wait_until { current_path.match? %r'/admin/users/[^/]+' }
  wait_until { User.where(email: email).first }
  user = User.where(email: email).first
  user.password = (opts[:password] || Faker::Internet.password)
  # visit "/my/user/#{user.id}" 
  click_on 'User Home'
  click_on 'Password'
  fill_in 'New password', with: user.password
  click_on 'Set password'
  wait_until { current_path == "/my/user/#{user.id}" }
  user
end

