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

  click_on 'Reset Password'
  click_on 'Create Reset Link - 3 days'
  token = find_field('reset-token', disabled: true).value
  visit '/reset-password'
  fill_in 'secret token', with: token
  click_on 'Continue'
  fill_in 'New Password', with: user.password
  click_on 'Continue'

  user
end
