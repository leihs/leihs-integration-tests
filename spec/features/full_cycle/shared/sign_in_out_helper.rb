def sign_in_as user, pool=nil
  visit '/'
  fill_in 'user', with: user.email
  click_on 'Login'
  fill_in "password", with: user.password || "password"
  click_on 'Continue'
  wait_until do
    ["/admin/", '/borrow/',
     "/manage/#{pool.try(:id)}/inventory",
     "/manage/#{pool.try(:id)}/daily" ].include? current_path
  end
  case current_path
  when '/admin/'
    find('.fa-circle-user').click
    wait_until { page.has_content? user.lastname }
  when '/borrow/'
    find(".ui-user-profile-button").click
    click_on "User Account"
    page.has_content? "#{user.firstname} #{user.lastname}"
  when "/manage/#{pool.try(:id)}/inventory"
    wait_until { page.has_content? user.lastname }
  when "/manage/#{pool.try(:id)}/daily"
    wait_until { page.has_content? user.lastname }
  end
  visit '/'
end

def sign_out
  visit "/my/auth-info"
  find(".fa-circle-user").click
  click_on "Logout"
  wait_until{ current_path == "/" }
end
