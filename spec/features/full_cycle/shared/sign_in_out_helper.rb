def normalize_path(path)
  path.to_s.sub(%r{/\z}, "")
end

def signed_in_destination?(path, pool_id)
  path = normalize_path(path)
  return true if ["/admin", "/borrow"].include?(path)
  return true if pool_id && path == "/manage/#{pool_id}/inventory"
  return true if pool_id && path == "/manage/#{pool_id}/daily"
  pool_id && path.start_with?("/inventory/#{pool_id}/")
end

def sign_in_as(user, pool = nil)
  Capybara.reset_sessions!
  visit "/"
  fill_in "user", with: user.email
  click_on "Login"
  fill_in "password", with: user.password || "password"
  click_on "Continue"
  pool_id = pool.try(:id)
  wait_until(20) { signed_in_destination?(current_path, pool_id) }
  visit "/my/auth-info"
  wait_until(20) { page.has_content?(user.email) }
  visit "/"
end

def sign_out
  visit "/my/auth-info"
  find(".fa-circle-user").click
  click_on "Logout"
  wait_until { current_path == "/" }
end
