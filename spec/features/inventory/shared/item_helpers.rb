def login_as_inventory_user(user)
  visit "/"
  click_on "Login"
  within(".ui-form-signin") do
    fill_in "user", with: user.login || user.email
    find('button[type="submit"]').click
  end
  within(".ui-form-signin") do
    fill_in "password", with: user.password || "password"
    find('button[type="submit"]').click
  end
  wait_until { current_path != "/" }
end

def assert_field(label, value)
  expect(find_field(label, wait: 10).value).to eq value
end

def assert_checked(el)
  expect(el["data-state"]).to eq "checked"
end

def assert_unchecked(el)
  expect(el["data-state"]).to eq "unchecked"
end

def await_debounce
  sleep 0.3
end
